---
layout: epic
title: Relay Modern Network Deep Dive
date: 2018-07-25
categories: [relay, graphql, JavaScript, guest]
author: sibelius
---

> [BLURB]
>
> -- Orta

Data fetching is a hard problem. How to ask data to a server? When to ask data to server? How to make sure you have
all necessary data to render your View? How to handle lazy loading? When to lazy load data? When to prefetch data?

Relay Modern is a framework to build data driven applications that solves data fetching problems. For introduction
to Relay Modern reads their docs, and check my Relay Modern talk in [React Conf BR][rbr]

> You don’t deep dive if you don’t know how to swim

## TL;DR Relay Modern Network

Relay will aggregate all components data requirements (fragments) and create a request to fulfill it. The network is
responsible to get this request, send it to a server or a local graphql and return the response data to it.

This article will provide 5 implementations of Relay Modern Network, each of one providing more capabilities than
the other one, enabling GraphQL Live Queries and Deferrable Queries.

All the code implementation for these 5 implementations are open source here:
https://github.com/sibelius/relay-modern-network-deep-dive.

<!-- more -->

### Simplest Network Layer

The simplest network layer would get the request and send it to a GraphQL server to resolve and return the data to
Relay environment.

```js
const fetchFunction = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap
) => {
  const body = JSON.stringify({
    query: request.text, // GraphQL text from input
    variables
  });

  const headers = {
    Accept: "application/json",
    "Content-type": "application/json",
    authorization: getToken()
  };

  const response = await fetchWithRetries(ENV.GRAPHQL_URL, {
    method: "POST",
    headers,
    body,
    fetchTimeout: 20000,
    retryDelays: [1000, 3000, 5000, 10000]
  });

  const data = await response.json();

  if (isMutation(request) && data.errors) {
    throw data;
  }

  return data;
};
```

The body of our request has the GraphQL query and the variables.

If it is a mutation it throw an error when there is data.errors.

We return the GraphQL response to update the Relay Environment (store where relay keep the data).

### Network that Handle Uploadables

```js
function getRequestBodyWithUploadables(request, variables, uploadables) {
  let formData = new FormData();
  formData.append("query", request.text);
  formData.append("variables", JSON.stringify(variables));

  Object.keys(uploadables).forEach(key => {
    if (Object.prototype.hasOwnProperty.call(uploadables, key)) {
      formData.append(key, uploadables[key]);
    }
  });

  return formData;
}
```

If you wanna send files to your GraphQL Server, you need to change your request body to use FormData.

### Network that Caches Requests

```js
const relayResponseCache = new RelayQueryResponseCache({ size: 250, ttl: oneMinute });

const cacheHandler = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: UploadableMap
) => {
  const queryID = request.text;

  if (isMutation(request)) {
    relayResponseCache.clear();
    return fetchFunction(request, variables, cacheConfig, uploadables);
  }

  const fromCache = relayResponseCache.get(queryID, variables);

  if (isQuery(request) && fromCache !== null && !forceFetch(cacheConfig)) {
    return fromCache;
  }

  const fromServer = await fetchFunction(request, variables, cacheConfig, uploadables);
  if (fromServer) {
    relayResponseCache.set(queryID, variables, fromServer);
  }

  return fromServer;
};
```

Built on top of the other 2 implementations, we use RelayQueryResponseCache to query GraphQL requests based on query
and variables. Every time a mutation is done, we should invalidate all cache as we are not sure how this affect all
cached queries responses.

### Network using Observable

Relay provides a limited implementation of [ESObservables][]. I recommend reading [A General Theory of
Reactivity][reactivity] to understand why we need to use Observable instead of promises in some situations. While a
promise is one value in a time space, an observable is a stream of values in a time space.

```js
const fetchFunction = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap,
  sink: Sink<any>
) => {
  const body = getRequestBody(request, variables, uploadables);

  const headers = {
    ...getHeaders(uploadables),
    authorization: getToken()
  };

  const response = await fetchWithRetries(ENV.GRAPHQL_URL, {
    method: "POST",
    headers,
    body,
    fetchTimeout: 20000,
    retryDelays: [1000, 3000, 5000, 10000]
  });

  const data = await handleData(response);

  if (isMutation(request) && data.errors) {
    sink.error(data);
    sink.complete();

    return;
  }

  sink.next(data);
  sink.complete();
};

const executeFunction = (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap
) => {
  return Observable.create(sink => {
    fetchFunction(request, variables, cacheConfig, uploadables, sink);
  });
};
```

Instead of return a promise that will resolve a single GraphQL response. We return an Observable that could fulfill
many responses before it finishes.

This is used on [GraphQL Living Queries][live], as you are going to resolve the same query more than once.

### Deferrable Queries Network

A common case for deferrable queries is to lazy load fragments, like let's load Post content first and then load all
comments of this post after the post is loaded.

Without deferrable queries you could simulate this using [@include Relay Modern][include] directive and a refetch
container, when the component mounts it will change the variable used on @include to true and get the rest of the
data.

The problem with above approach is that you need to wait the component to mount before start the next request, this
will be more a big deal when Async React start working.

The deferrable query will start as soon as the previous query has finished.

```js
const PostFragment = createFragmentContainer(Post, {
  post: graphql`
    fragment Post_post on Post {
      title
      commentsCount
      ...CommentsList_post @relay(deferrable: true)
    }
  `
});
```

In the fragment above, it will first get title and commentsCount data from Post, and after it will get the data for
CommentsList_post fragment.

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
      cacheHandler(request, variables, cacheConfig, uploadables, sink, true);
    }

    if (request.kind === "BatchRequest") {
      batchRequestQuery(request, variables, cacheConfig, uploadables, sink);
    }
  });
};
```

Our execute function now can handle 2 types of requests: a `Request` that is a single GraphQL query; and a
`BatchRequest` that could have many queries with interrelated data among them.

So how does a batchRequestQuery looks like:

```js
const getDeferrableVariables = (requests, request, variables: Variables) => {
  const { argumentDependencies } = request;

  if (argumentDependencies.length === 0) {
    return variables;
  }

  return argumentDependencies.reduce((acc, ad) => {
    const { response } = requests[ad.fromRequestName];

    const variable = get(response.data, ad.fromRequestPath);

    // TODO - handle ifList, ifNull
    return {
      ...acc,
      [ad.name]: variable
    };
  }, {});
};

const batchRequestQuery = async (
  request: RequestNode,
  variables: Variables,
  cacheConfig: CacheConfig,
  uploadables: ?UploadableMap,
  sink: Sink<ExecutePayload>
) => {
  const requests = {};

  for (const r of request.requests) {
    const v = getDeferrableVariables(requests, r, variables);

    const response = await cacheHandler(r, v, cacheConfig, uploadables, sink, false);

    requests[r.name] = response;
  }

  sink.complete();
};
```

`getDeferrableVariables` function will get variables from result data from other requests.

`batchRequestQuery` function will execute each of the requests, and will `sink.next()` as soon as it has the GraphQL
server response data. It will only close the Observable stream when all requests has been fullfiled.

--

Relay Modern is very flexible!

You can have a custom network layer that uses observables to always resolves from cache data first and then resolves
from the server.

You can implement offline first apps using a custom network layer.

## More Resources

If you don't know GraphQL or you want to improve it, take a look on our boilerplate that uses dataloader to batch
and cache requests to database https://github.com/entria/graphql-dataloader-boilerplate

We also have a simple boilerplate for Relay Modern with React Navigation
https://github.com/entria/ReactNavigationRelayModern If you have questions about this or anything send me a DM on
twitter https://twitter.com/sseraphini

[rbr]: https://speakerdeck.com/sibelius/reactconfbr-is-relay-modern-the-future
[esobservables]: https://github.com/tc39/proposal-observable
[reactivity]: https://kriskowal.gitbooks.io/gtor/content/
[live]: https://github.com/facebook/relay/issues/2174
[include]: https://facebook.github.io/relay/docs/en/graphql-in-relay.html#directives
