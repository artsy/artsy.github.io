---
layout: epic
title: The Relay Network Deep Dive
date: 2018-07-25
categories: [relay, graphql, JavaScript, guest]
author: sibelius
series: Omakase
---

> Hey all, we have another guest post, this one comes from [Sibelius Seraphini][sib] - a very active contributor to
> Relay and its eco-system. When we spotted he had wrote an amazing article on how the networking aspects of Relay
> comes together, we wanted to expand his reach and inform more people on how Relay comes together.
>
> -- Orta

Data fetching is a hard problem for apps. You need to ask yourself a lot of questions: How do you ask for data from
a server? How do you handle authentication? When is the right time to request data? How can you ensure you have all
the necessary data to render your views? How can you make sure you're not over-fetching? Can you do lazy loading?
When should you trigger lazy loading of data? What about pre-fetching data?

[Relay][relay] is a framework for building data-driven applications which handles data fetching for you. For an
introduction to Relay, read [their docs][relay], and also check out my Relay talk at [React Conf BR][rbr].

> You don’t deep dive if you don’t know how to swim

## TL;DR Relay Modern Network

Relay will aggregate the data requirements (fragments) for your components, then create a request to fulfill it.
The API to do this is via the [Relay Environment][env]:

> The Relay "Environment" bundles together the configuration, cache storage, and network-handling that Relay needs
> in order to operate.

This post focuses on the "network-handling" part, the [Network Layer][network]. The network layer's responsibility
is to make a request to a server (or a local graphql) and return the response data to Relay. Your implementation
should conform to either [FetchFunction][ff] for a Promise-like API, or [SubscribeFunction][sf] for an
Observable-like API.

This article will provide 5 implementations of a Relay Network Interface, each of one providing more capabilities
than the other one, eventually enabling GraphQL Live Queries and Deferrable Queries.

You can see the code for these 5 network layers on GitHub here, open source under MIT license:
[https://github.com/sibelius/relay-modern-network-deep-dive](https://github.com/sibelius/relay-modern-network-deep-dive).

<!-- more -->

### Simplest Network Layer

The simplest network layer would; get the request, send it to a GraphQL server to resolve and return the data to
Relay environment.

```js
const fetchFunction = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap
) => {
  // Most GraphQL APIs expect a POST with a JSON
  // string containing the query and associated variables
  const body = JSON.stringify({
    query: request.text, // GraphQL text from input
    variables
  })

  const headers = {
    Accept: "application/json",
    "Content-type": "application/json",
    authorization: getToken()
  }

  const response = await fetchWithRetries(ENV.GRAPHQL_URL, {
    method: "POST",
    headers,
    body,
    fetchTimeout: 20000,
    retryDelays: [1000, 3000, 5000, 10000]
  })

  const data = await response.json()

  // Mutations should throw when they have errors, making it easier
  // for client code to react
  if (isMutation(request) && data.errors) {
    throw data
  }

  // We return the GraphQL response to update the Relay Environment
  // which updates internal store where relay keeps its data
  return data
}
```

### Network that Handle Uploadables

The GraphQL spec does not handle form data, and so if you need to send along files to upload to your server with a
mutation, you'll want to use the uploadables API in Relay when you commit the mutation.

Adding uploadables in a mutation will inevitably get passed to your network interface, where you'll need to change
your request body to use FormData instead of the JSON string above:

```js
function getRequestBodyWithUploadables(request, variables, uploadables) {
  let formData = new FormData()
  formData.append("query", request.text)
  formData.append("variables", JSON.stringify(variables))

  Object.keys(uploadables).forEach(key => {
    if (Object.prototype.hasOwnProperty.call(uploadables, key)) {
      formData.append(key, uploadables[key])
    }
  })

  return formData
}
```

### Network that Caches Requests

This builds on top of the other 2 implementations, we use
[RelayQueryResponseCache](https://github.com/facebook/relay/blob/v1.6.0/packages/relay-runtime/network/RelayQueryResponseCache.js#L24-L29)
to query GraphQL requests based on query and variables.

Every time a mutation happens, we should invalidate our cache as we are not sure how a change can affect all cached
query responses.

```js
// Create our own in-memory cache
const relayResponseCache = new RelayQueryResponseCache({ size: 250, ttl: oneMinute })

const cacheHandler = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: UploadableMap
) => {
  const queryID = request.text

  // If it's a mutation, clear all cache, then call the implementation above
  if (isMutation(request)) {
    relayResponseCache.clear()
    return fetchFunction(request, variables, cacheConfig, uploadables)
  }

  // Try grab the request from the cache first
  const fromCache = relayResponseCache.get(queryID, variables)
  // Did it hit? Or did we suppress the cache for this request
  if (isQuery(request) && fromCache !== null && !forceFetch(cacheConfig)) {
    return fromCache
  }

  // Make the request, and cache it if we get a response
  const fromServer = await fetchFunction(request, variables, cacheConfig, uploadables)
  if (fromServer) {
    relayResponseCache.set(queryID, variables, fromServer)
  }

  return fromServer
}
```

### Network using Observable

Relay provides a limited implementation of the upcoming [ESObservables][] spec. I recommend reading [A General
Theory of Reactivity][reactivity] to understand why Observables are a great solution instead of promises in some
situations. Notably; a promise is one value in a time space, an observable is a stream of values in a time space.

<!-- [TODO: Why Sink and not the Relay Observable? Observable is exported but has one more function (complete)] -->

To work with this API, we're going to use a private interface for the observable object called Sink:

```js
/**
 * A Sink is an object of methods provided by Observable during construction.
 * The methods are to be called to trigger each event. It also contains a closed
 * field to see if the resulting subscription has closed.
 */
export type Sink<-T> = {|
  +next: T => void,
  +error: (Error, isUncaughtThrownError?: boolean) => void,
  +complete: () => void,
  +closed: boolean
|}
```

Which is the shape of the Observable object we pass back to Relay:

```js
const fetchFunction = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap,
  sink: Sink<any>
) => {
  const body = getRequestBody(request, variables, uploadables)

  const headers = {
    ...getHeaders(uploadables),
    authorization: getToken()
  }

  const response = await fetchWithRetries(ENV.GRAPHQL_URL, {
    method: "POST",
    headers,
    body,
    fetchTimeout: 20000,
    retryDelays: [1000, 3000, 5000, 10000]
  })

  const data = await handleData(response)

  if (isMutation(request) && data.errors) {
    sink.error(data)
    sink.complete()

    return
  }

  sink.next(data)
  sink.complete()
}

// Instead of returning a Promise that will resolve a single GraphQL response.
// We return an Observable that could fulfill many responses before it finishes.

const executeFunction = (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap
) => {
  return Observable.create(sink => {
    fetchFunction(request, variables, cacheConfig, uploadables, sink)
  })
}
```

This is an implementation you would need when working with [GraphQL Live Queries][live] (based on polling), as you
are going to resolve the same query more than once.

### Deferrable Queries Network

A common case for deferrable queries is to lazy load fragments. This lets you get request content above the page
fold first, and then request additional data after. A good example is loading a Post's content first and then
subsequently loading all comments of this post after the post has finished.

Without deferrable queries you could simulate this using the [@include][include] directive in your Relay fragment
and a [refetch container][refetch]. When the component mounts the refetch container changes the variable used on
the `@include` to true and it will request the rest of the data.

The problem with above approach is that you need to wait for the component to mount before you can start the next
request. This becomes a bigger problem as React does more work asynchronously.

<!-- TODO: There are no docs for relay deferrable -->

An ideal deferrable query will start as soon as the previous query has finished, rather than depending on your
React components render cycles. Relay provides a [directive][] for this: `@relay(deferrable: true)`:

```js
const PostFragment = createFragmentContainer(Post, {
  post: graphql`
    fragment Post_post on Post {
      title
      commentsCount
      ...CommentsList_post @relay(deferrable: true)
    }
  `
})
```

In the fragment above, Relay will first get the `title` and `commentsCount` from the Post, then afterwards Relay
will get the data for `CommentsList_post` fragment. Sending both through the observable.

Here is the implementation of an execute function to handle a batched request:

```js
const executeFunction = (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap
) => {
  return Observable.create(sink => {
    if (request.kind === "Request") {
      cacheHandler(request, variables, cacheConfig, uploadables, sink, true)
    }

    if (request.kind === "BatchRequest") {
      batchRequestQuery(request, variables, cacheConfig, uploadables, sink)
    }
  })
}
```

This execute function now can handle 2 types of requests:

- a single GraphQL query `Request`
- or a `BatchRequest` that could have be many queries with inter-related data

So, what does the `batchRequestQuery` function look like?

<!-- TODO: Annotate ths code, I'm not 100% what it's doing myself -->

```js
// Get variables from the results that have already been sent
const getDeferrableVariables = (requests, request, variables: Variables) => {
  const { argumentDependencies } = request

  if (argumentDependencies.length === 0) {
    return variables
  }

  return argumentDependencies.reduce((acc, ad) => {
    const { response } = requests[ad.fromRequestName]

    const variable = get(response.data, ad.fromRequestPath)

    // TODO - handle ifList, ifNull
    // See: https://github.com/facebook/relay/issues/2194
    return {
      ...acc,
      [ad.name]: variable
    }
  }, {})
}

// Execute each of the requests, and call `sink.next()` as soon as it has the GraphQL
/// server response data.
//
// It will only close the Observable stream when all requests has been fulfilled.
const batchRequestQuery = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap,
  sink: Sink<ExecutePayload>
) => {
  const requests = {}

  for (const r of request.requests) {
    const v = getDeferrableVariables(requests, r, variables)

    const response = await cacheHandler(r, v, cacheConfig, uploadables, sink, false)

    requests[r.name] = response
  }

  sink.complete()
}
```

## Relay Modern is very flexible

Depending on your application needs, you can scale from a simpler Promise-based API for your custom network layer
to one that uses Observables to always resolves from cache data first and then resolves from the server.

Here are some production examples:

- [Artsy Emission][artsy]: Uses the Promise API, caches the results locally, and shares logic with native code in
  an iOS app so that queries can be pre-cached before the JavaScript runtime has started.

- [ReactRelayNetworkModern][]: A network layer that uses the middleware pattern to separate responsibilities like
  retrying, logging, caching and auth.

- [timobetina's example][timobetina]: The simplest Observable network layer you can start with.

<!-- TODO: More, @sibelius do you have some good examples? -->

## More Resources

If you want to expand your understanding of GraphQL and Relay Modern, I have two great related resources:

- A boilerplate that uses dataloader to batch and cache requests to your database in a GraphQL API:
  [https://github.com/entria/graphql-dataloader-boilerplate](https://github.com/entria/graphql-dataloader-boilerplate)

- A simple boilerplate for working with Relay Modern and React Navigation:
  [https://github.com/entria/ReactNavigationRelayModern](https://github.com/entria/ReactNavigationRelayModern)

If you have questions about this or anything send me a DM on twitter
[https://twitter.com/sseraphini](https://twitter.com/sseraphini)

[rbr]: https://speakerdeck.com/sibelius/reactconfbr-is-relay-modern-the-future
[esobservables]: https://github.com/tc39/proposal-observable
[reactivity]: https://kriskowal.gitbooks.io/gtor/content/
[live]: https://github.com/facebook/relay/issues/2174
[include]: https://facebook.github.io/relay/docs/en/graphql-in-relay.html#directives
[relay]: https://facebook.github.io/relay/
[env]: https://facebook.github.io/relay/docs/en/relay-environment.html
[network]: https://facebook.github.io/relay/docs/en/network-layer.html
[ff]: https://github.com/facebook/relay/blob/v1.6.0/packages/relay-runtime/network/RelayNetworkTypes.js#L79-L90
[sf]: https://github.com/facebook/relay/blob/v1.6.0/packages/relay-runtime/network/RelayNetworkTypes.js#L92-L107
[refetch]: https://facebook.github.io/relay/docs/en/refetch-container.html
[directive]: https://github.com/facebook/relay/issues/2194#issuecomment-383466255
[artsy]: https://github.com/artsy/emission/blob/master/src/lib/relay/fetchQuery.ts
[reactrelaynetworkmodern]: https://github.com/relay-tools/react-relay-network-modern
[timobetina]: https://github.com/facebook/relay/issues/2174#issuecomment-375274003
[sib]: https://github.com/sibelius
