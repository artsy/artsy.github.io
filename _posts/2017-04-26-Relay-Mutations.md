---
layout: post_longform
title: Relay Mutations
date: 2017-04-26
categories: [relay, graphql, JavaScript, guest]
author: nik
---

> Hey there everyone, it took us two years to [make our](https://github.com/artsy/metaphysics/pull/583) GraphQL implementation support any mutations. We opted to keep it read-only for quite a long time because we use GraphQL to consolidate multiple APIs, but as we start new projects as GraphQL + databases then understanding mutations becomes much more important.
>
> Last month, I talked with the team at [Graph.cool](https://www.graph.cool/) about having them talk through Relay mutations comprehensively as a guest post on the Artsy Engineering blog. So, I'm really excited to introduce this great post on the topic by [Nikolas Burk](http://twitter.com/nikolasburk).
>
> -- Orta

#  The Magic behind Relay Mutations

[Relay](https://facebook.github.io/relay/) is a powerful GraphQL client for React and React Native applications. It was open sourced by Facebook alongside GraphQL in 2015 and is a great tool for supporting you with managing your app's data layer.

In this post, we are going to explore how Relay mutations work by looking at a React Native app. The code can be found on [GitHub](https://github.com/graphcool-examples/react-native-relay-pokedex-example). Our sample application is a simple _Pokedex_, where users can manage their Pokemons.

![](http://i.imgur.com/S21GfEo.png)

> Note: We're going to assume a basic familiarity with GraphQL in this article. If you haven't heard of GraphQL before, the [documentation](www.graphql.org) and the [GraphQL for iOS Developers](http://artsy.github.io/blog/2016/06/19/graphql-for-mobile/) post are great places to start. If you're interested in learning more about Relay in general, head over to [Learn Relay](www.learnrelay.org) for a comprehensive tutorial.

<!-- more -->

If you want to run the example with your own GraphQL server, you can use [graphql-up](https://www.graph.cool/graphql-up/) to quickly spin one up yourself from within your browser. Simply click the pink button and follow the instructions on the website.

[![graphql-up](http://static.graph.cool/images/graphql-up.svg)](https://www.graph.cool/graphql-up/new?source=https://raw.githubusercontent.com/graphcool-examples/react-native-relay-pokedex-example/master/pokedex.schema)

## Relay - A brief Overview

Relay is the most sophisticated GraphQL client available at the moment. Like GraphQL, it has been used and battle-tested internally by Facebook for many years before it was open sourced.

Relay surely isn't the easiest framework to learn - but when used correctly, it takes care of managing large parts of your app's data layer in a consistent and reliable manner! It therefore is particularly well-suited for complex applications with lots of data interdependencies and provides outstanding longterm developer productivity.

### Declarative API and Colocation

With Relay, React components specify their data requirements in a declarative fashion, making use of GraphQL _fragments_.

> A [GraphQL fragment](https://learngraphql.com/basics/fragments) is a selection of fields on a GraphQL type. You can use them to define _reusable sub-parts_ of queries or mutations.

Considering the `PokemonDetails` view above, we need to display the Pokemon's name and image. The fragment that represents these data requirements looks as follows:

```
fragment PokemonDetails on Node {
  ... on Pokemon {
    id
    name
    url
  }
}
```

Note that the `id` is required so that Relay can identify the objects in the cache, so it's included in the payload as well (even if it's not displayed on the UI).

These fragments are kept in the same file as the React component, so UI and data requirements are _colocated_. Relay then uses a [higher-order component](https://facebook.github.io/react/docs/higher-order-components.html) called [`Relay.Container`](https://facebook.github.io/relay/docs/guides-containers.html#content), to wrap the component along with its data requirements. From this point, the developer doesn't have to worry about the data any more! It will be fetched behind the scenes and is made available to the component via its props.

### Build-time Schema Validation

Another great feature of Relay that ensures developer productivity is  _schema validation_. At build time, Relay checks your GraphQL queries, fragments and mutations to ensure their compatibility with the GraphQL API. It is thus able to catch any typos or other schema-related errors before you run (or even worse: deploy) your app, saving your users from unpleasant experiences. Note that the schema validation step requires a [Babel Relay Plugin](https://facebook.github.io/relay/docs/guides-babel-plugin.html). 

## Mutations in Relay

### GraphQL Recap

In GraphQL, a _mutation_ is the only way to create, update or delete data on the server - they effectively are the GraphQL abstraction for *changing state* in your backend. 

As an example, creating a new Pokemon in our sample app uses the following mutation:

```
mutation CreatePokemon($name: String!, $url: String!) {
  createPokemon(input: {
    name: $name,
    url: $url
  }) {
    # payload of the mutation (will be returned by the server)
    pokemon {
      id 
    }
  }
}
```

Notice that mutations, similar to queries, also require a _payload_ to be specified. This payload represents the information that we'd like to have returned from the server after the mutation was performed. In the above example, we're asking for the `id` of the new `pokemon`.

### The Magic: Declarative Mutations 🔮

Relay doesn't (yet) give the developer the ability to manually modify the data that it stores internally. Instead, with every change, it requires a declarative _description_ of how the local cache should be updated after the change happened in the form of a [mutation](https://facebook.github.io/relay/docs/guides-mutations.html#content) and then takes care of the update under the hood.

The description is provided by subclassing `Relay.Mutation` and implementing (at least) four methods that help Relay to properly update the local store:

- `getMutation()`: the name of the mutation (from the GraphQL schema)
- `getVariables()`: the input variables for the mutation
- `getFatQuery()`: a GraphQL query that fetches all data that potentially was changed due to the mutation
- `getConfigs()`: a precise specification how the mutation should be incorporated into the cache

In the following, we'll take a deeper look at the different kinds of mutations in our sample app, which are used for creating, updating and deleting Pokemons.

> Note: We're using the [Graphcool Relay API](https://www.graph.cool/docs/reference/relay-api/overview-aizoong9ah) for this example. If you used `graphql-up` to create your own backend, you can explore the API by pasting the endpoint for the Relay API into the address bar of a browser.

### Creating a new Pokemon: `RANGE_ADD` 

![](http://i.imgur.com/yskx5KU.png)

Let's walk through the different methods and understand what information we have to provide so that Relay can successfully merge the newly created Pokemon into its store.

The first two methods, `getMutation()` and `getVariables()` are relatively obvious and can be retrieved directly from the documentation where the API is described.

The implementations look as follows:

```js
getMutation() {
  return Relay.QL`mutation { createPokemon }`
}

getVariables() {
  return {
    name: this.props.name,
    url: this.props.url,
  }
}
```

Notice that the `props` of a `Relay.Mutation` are passed through its constructor. Here, we simply provide the `name` and the `url` of the Pokemon that is to be created.

Now, on to the interesting parts. In `getFatQuery()`, we need to specify the parts that might change due to the mutation. Here, we simply specify the `viewer`:

```js
getFatQuery() {
  return Relay.QL`
    fragment on CreatePokemonPayload {
      viewer {
        allPokemons
      }
    }
  `
}
```

Notice that _every_ subfield of `allPokemons` is also automatically included with this approach. In our example app, `allPokemons` is the only point we expect to change after our mutation is performed.

Finally, in `getConfigs()`, we need to specify the [mutator configurations](https://facebook.github.io/relay/docs/guides-mutations.html#mutator-configuration), telling Relay exactly how the new data should be incorporated into the cache. This is where the magic happens:

```js
getConfigs() {
  return [{
    type: 'RANGE_ADD',
    parentName: 'viewer',
    parentID: this.props.viewerId,
    connectionName: 'allPokemons',
    edgeName: 'edge',
    rangeBehaviors: {
      '': 'append'
    }
  }]
}
```

We first express that we want to _add_ the node using `RANGE_ADD` for the `type` (there are 5 different types in total). 

Relay internally represents the stored data as a graph, so the remaining information expresses where exactly the new node should be hooked into the existing structure.

Let's consider the shape of the data before we move on:

```
viewer {
  allPokemons {
    edges {
      node {
        id
        name
      }
    }
  }
}
```

Here we clearly see the direct connection between `viewer` and the Pokemons goes through `allPokemons` _connection_, so the _parent_ of the new Pokemon is the `viewer`. The name of that connection is `allPokemons`, and lastly the `edgeName` is taken from the payload of the mutation.

The last piece, `rangeBehaviors`, specifies whether we want to _append_ or _prepend_ the new node.

Executing the mutation is as simple as calling `commitUpdate` on the `relay` prop that's injected to each component being wrapped with a `Relay.Container`. An instance of the mutation and the expected variables are passed as arguments to the constructor:

```js
_sendCreatePokemonMutation = () => {
  const createPokemonMutation = new CreatePokemonMutation({
    viewerId: this.props.viewer.id,
    name: this.state.pokemonName,
    url: this.state.pokemonUrl,
  })
  this.props.relay.commitUpdate(createPokemonMutation)
}
```

### Updating a Pokemon: `FIELDS_CHANGE`

Like with creating a Pokemon, `getMutation()` and `getVariables()` are trivial to implement and can be derived directly from the API documentation:

```js
getMutation() {
  return Relay.QL`mutation { updatePokemon }`
}

getVariables() {
  return {
    id: this.props.id,
    name: this.props.name,
    url: this.props.url,
  }
}
```

In `getFatQuery()`, we only include the `pokemon` which includes the updated info this time, since that is the only part we expect to change after our mutation:

```js
getFatQuery() {
  return Relay.QL`
    fragment on UpdatePokemonPayload {
      pokemon
    }
  `
}
```

Finally, `getConfigs()`, this time specifies a mutator configuration of type `FIELDS_CHANGE` since we're only updating properties on a single Pokemon:

```js
getConfigs() {
  return [{
    type: 'FIELDS_CHANGE',
    fieldIDs: {
      pokemon: this.props.id,
    }
  }]
}
```

As sole additional piece of info, we declare the ID of the Pokemon that is being updated so that Relay has this information available when receiving the new Pokemon data.

### Deleting a Pokemon: `NODE_DELETE`

As before, `getMutation()` and `getVariables()` are self-explanatory:

```js
getMutation() {
  return Relay.QL`mutation { deletePokemon }`
}

getVariables() {
  return {
    id: this.props.id,
  }
}
```

Then, in `getFatQuery()`, we need to retrieve the `pokemon` from the mutation payload:

```js
getFatQuery() {
  return Relay.QL`
    fragment on DeletePokemonPayload {
      pokemon
    }
  `
}
```

In `getConfigs()`, we're getting to know another mutator configuration type called `NODE_DELETE`. This one requires a `parentName` as well as a `connectionName`, both coming from the mutation payload and specifying where that node existed in Relay's data graph. Another requirement, that is specifically relevant for the implementation of a GraphQL server, is that the mutation payload of a deleting mutation always needs to return the `id` of the deleted node so that Relay can find that node in its store. Taking all of this together, our implementation of `getConfigs()` can be written like so:

```js
getConfigs() {
  return [{
    type: 'NODE_DELETE',
    parentName: 'pokemon',
    connectionName: 'edge',
    deletedIDFieldName: 'deletedId'
  }]
}
```

## Wrapping Up

Relay has a lot of benefits that make it a very compelling framework to use for state management and interaction with GraphQL APIs. Its major strengths are a highly optimized cache, thoughtful UI integration as well as the declarative API for data fetching and mutations. 

The initial version of Relay came with a notable learning curve due to lots of magic happening behind the scenes. However, Facebook recently released the first release candidates of [Relay v1.0.0](https://github.com/facebook/relay/releases/) (_Relay Modern_) with the [goal of making Relay generally more approachable](https://code.facebook.com/posts/1362748677097871).

It's worth noting that Relay isn't the only available GraphQL client. Apollo Client is a great alternative which is a lot easier to get started with. [For a detailed comparison please refer to this article.](https://www.graph.cool/docs/tutorials/relay-vs-apollo-iechu0shia/)

If you want to learn more about GraphQL and want to stay up-to-date with the latest news of the GraphQL community, subscribe to [GraphQL Weekly](https://graphqlweekly.com/).
