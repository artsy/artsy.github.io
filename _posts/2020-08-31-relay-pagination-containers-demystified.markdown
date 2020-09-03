---
layout: epic
title: "Relay Pagination Containers Demystified"
date: 2020-08-31
categories: [react, relay, culture]
author: ash
---

In 2017, Artsy adopted [Relay](https://relay.dev/en/) in both its front-end web and iOS codebases (using React and
React Native, respectively). Generally speaking, this investment has turned out very well for us! Relay empowers
product teams to quickly iterate on new features and to share common infrastructure across web and iOS codebases.
However, most of the original engineers who pioneered using Relay at Artsy have since moved on to their next role;
this has left a knowledge gap where Artsy engineers are comfortable _using_ Relay, but they don't totally
understand how it works.

This is a problem as old as software engineering itself, and it has a simple solution: learn and then teach others.
We'll be driving a peer learning group centering around Relay, but today we are going to dive into the part of
Relay that comes up the most in requests for pairing: getting Relay pagination to work. (Note: we're going to use
plain old Relay and not [relay-hooks](https://github.com/relay-tools/relay-hooks).)

<!-- more -->

My goal with this post is to show my thought process when trying to learn about, and clean up our use of, Relay
pagination containers. This post emphasizes the _demystifying_ process and not so much the _Relay pagination
containers_ themselves – we'll briefly cover some Relay fundamentals before diving into a case study on how
problematic code proliferates through copy-and-paste.

Let's back up and talk a little bit about what Relay is and how it works. Relay is a framework that glues React
components and GraphQL requests together. React components define the data they need from a GraphQL schema in order
to render themselves, and Relay handles actually fetching GraphQL requests and marshalling data into the React
component tree. It is very efficient because of build-time optimizations by the Relay compiler.

The simplest use of Relay is a [fragment container](https://relay.dev/docs/en/fragment-container), which is created
from a React component and a [GraphQL fragment](https://blog.logrocket.com/graphql-fragments-explained/). (We're
going to skip over how the GraphQL query is made, but
[here are the docs on query renderers](https://relay.dev/docs/en/query-renderer) if you're curious.)

```js
class Artist extends React.Component {
  render() {
    return <Text>The artist name is ${this.props.artist.name}.</Text>
  }
}

export ArtistFragmentContainer = createFragmentContainer(Artist, {
  artist: graphql` # artist will be passed in as props
    fragment Artist_artist on Artist { # Relay has strong naming conventions
      name # Get all the data we want here
    }
  `
})
```

(At Artsy, we use [TypeScript with Relay](https://github.com/relay-tools/relay-compiler-language-typescript), but
for this blog post we'll stick to JavaScript.)

So we have a plain React component that gets some props, and a Relay fragment container that wraps it, defining the
data that the component needs.

There are other types of Relay containers beyond simple fragment containers.
[Refetch containers](https://relay.dev/docs/en/refetch-container) are like fragment containers except you can
refetch their contents from your GraphQL server (in response to, for example, user interaction). Using a refetch
container is very similar to using a plain fragment container. But today, we want to talk about
[pagination containers](https://relay.dev/docs/en/pagination-container), which use a GraphQL construct called
_connections_ to show page after page of data.

[GraphQL connections](https://www.apollographql.com/blog/explaining-graphql-connections-c48b7c3d6976/) are beyond
the scope of this blog post, but they are a way to fetch lists of data without running into the limitations of
returning a simple array. Connections can return metadata about their results, like how many total results there
are, and use cursors (rather than page numbers) for paginating. They also handle when items are inserted or deleted
from the results between requests for pages –
[check out this blog post](https://artsy.github.io/blog/2020/01/21/graphql-relay-windowed-pagination/) for more
info on how to use connections with Relay.

Pagination containers take considerably more setup than plain fragment containers, and the setup itself is very
fickle. Things simply will not work until you get the configuration _exactly correct_, and then everything works
perfectly. The setup is largely repeated boilerplate, and what I've noticed (from other engineers but also myself)
is that the boilerplate for new pagination containers gets copy-and-pasted from existing ones. We will see how this
leads to small problems getting propagated throughout the codebase, and leads to engineers not feeling confident
when working in pagination containers.

So let's modify the Relay container above to fetch a list of the artist's artworks. This is a very simple example,
only used to illustrate how to use pagination containers.

```js
class Artist extends React.Component {
  render() {
    return (
    <Text>The artist name is ${this.props.artist.name}.</Text>
    {this.props.artist.artworks.edges.map(node =>
      /* Render each artwork */
      <Text key={node.id}>{node.name}</Text>
    )}
    {this.props.relay.hasMore() &&
      <Button onPress={() => this.props.relay.loadMore() } text="Load next page" />
    )
  }
}

export ArtistFragmentContainer = createPaginationContainer(Artist, {
  artist: graphql`
    fragment Artist_artist on Artist
      @argumentDefinitions(
        count: { type: "Int", defaultValue: 10 }
        cursor: { type: "String" }
      ) {
      name
      id
      artworksConnection(first: $count, after: $cursor) @connection(key: "Artist_artworks") {
        edges {
          node {
            title # Now fetch all the artwork data
            id
          }
        }
      }
    }
  `
}, {
  direction: "forward",
  getConnectionFromProps(props) {
    return props.artist.artworks
  },
  getFragmentVariables(prevVars, count) {
    return {
      ...prevVars,
      count,
    }
  },
  getVariables(props, { count, cursor }, fragmentVariables) {
    return {
      id: props.artist.id,
      count,
      cursor,
    }
  },
  query: graphql` # Here is the query to fetch any specific page
    query ArtistArtworksQuery(
      $id: ID!
      $count: Int!
      $cursor: String) {
      artist(id: $id) {
        ...Artist_artist @arguments(
          count: $count
          cursor: $cursor
        )
      }
    }
  `
})
```

Wow, that's a lot! I don't want to get too bogged down in details, so let's break this apart at a high level:

- We changed the React component to show a list of artworks and include a button to load the next page.
- We changed from `createFragmentContainer` to using `createPaginationContainer`.
- We added GraphQL fragment variables for `count` and `cursor` to be passed through to the new
  `artworksConnection`, which we also added.
- Finally, we added a whole new configuration parameter to `createPaginationContainer`.

This last bit is the part where I see the most frustration. Hopefully what follows will clear things up.

I like to always start by [reading the docs](https://relay.dev/docs/en/pagination-container). The `direction` key
is the direction that we paginate through, either `"forward"` or `"backward"`. `getConnectionFromProps` is a
function that returns the GraphQL connection, in case the query has more than one. And `query` is used to fetch any
specific page of results.

Those all makes sense to me, but then we arrive at the real gotchas: `getFragmentVariables` and `getVariables`. The
docs are helpful, but only if you understand
[the internals of how Relay works](https://relay.dev/docs/en/runtime-architecture.html). Relay has a sophisticated
architecture that delivers some really well-performing code, but its abstractions sometimes
"[leak](https://en.wikipedia.org/wiki/Leaky_abstraction)" and you have to deal with underlying implementation
details of Relay (like [the Relay store](https://relay.dev/docs/en/relay-store)) which you don't need to know about
_most_ of the time.

So what are these two functions? Let's return to the docs:

- `getFragmentVariables` is used when re-rendering the component, to retrieve the previously-fetched GraphQL
  response for a certain set of variables.
- `getVariables` is used when actually fetching another page, and its return value is given to the `query`.

I think of `getFragmentVariables` as a kind of caches key for lookup in Relay's internal store. Our implementation
of `getFragmentVariables` above doesn't really do anything interesting, but a connection that accepted `sort` or
`filter` parameters would need to return those to avoid lookup collisions when the user changed sort and filter
options.

Now for `getVariables`, which are the variables used for the `query` later on. It really ought to be named
`getQueryVariables`, I think. But I digress.

Every implementation of `getFragmentVariables` I could find at Artsy was identical, which makes sense because _that
is the default implementation_. We shouldn't be defining this option at all! As far as I can tell, Artsy started
with a few pagination containers that supplied this parameter unnecessarily and it got copy-and-pasted throughout
our codebases.

After revisiting the docs, I noticed other optional parameters that don't need to be defined either. Let's rewrite
the call to `createPaginationContainer` to only supply the parameters that are required:

```js
export ArtistFragmentContainer = createPaginationContainer(Artist, {
  artist: graphql`
    fragment Artist_artist on Artist @argumentDefinitions(
      count: { type: "Int", defaultValue: 10 }
      cursor: { type: "String" } {
      name
      id
      artworksConnection (first: $count, after: $cursor) @connection(key: "Artist_artworks") {
        edges {
          node {
            title # Now fetch all the artwork data
            id
          }
        }
      }
    }
  `
  }, {
  getVariables(props, { count, cursor }, fragmentVariables) {
    return {
      id: props.artist.id,
      count,
      cursor,
    }
  },
  query: graphql` # Here is the query to fetch any specific page
    query ArtistArtworksQuery(
      $id: ID!
      $count: Int!
      $cursor: String) {
      artist(id: $id) {
        ...Artist_artist @arguments(
          count: $count
          cursor: $cursor
        )
      }
    }
  `
})
```

This is a lot nicer! By not specifying unnecessary options, we have a smaller surface area to make mistakes in. We
also have fewer overloaded terms, like "variables", so now it's more obvious that `getVariables` supplies data for
the `query` below it.

I've already [sent a pull request](https://github.com/artsy/eigen/pull/3711) to clean up our use of pagination
containers in our React Native app, and will be following up on the web side next. But I wouldn't have discovered
this if I hadn't really dug into the docs, which I only did so that I could write this blog post. Earlier I said
that the solution to a knowledge gap is simple: learn, and then teach. I learned a lot about Relay today, and I
hope this blog post illustrates the value in the learn-then-teach approach.
