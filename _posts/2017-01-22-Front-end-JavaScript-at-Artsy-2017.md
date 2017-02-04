---
layout: post
title: "Exploration: Front-end JavaScript at Artsy in 2017"
date: 2017-01-22 12:17
author: orta
categories: [javascript, emission, reactnative, force, typescript]
series: React Native at Artsy
---

The Artsy web team have been early adopters of node, and for the last 4 years the stable stack for the Artsy website has been predominantly been Node + CoffeeScript + Express + Backbone. In 2016 the mobile team announced that it had moved to React Native, matching the web team as using JavaScript as the tools of their trade.

Historically we have always had two separate dev teams for building Artsy.net and the corresponding iOS app, we call them (Art) Collector Web, and Collector Mobile. By the end of 2016 we decided to merge the teams. The merger has given way to a whole plethora of ideas about what modern JavaScript looks like and we've been experimenting with finding common patterns between web and native.

This post tries to encapsulate what we consider to be our consolidated stack for web/native Artsy in 2017. 

TLDR: GraphQL, TypeScript, React/React Native, Relay, Yarn, Jest, and VS Code.  

<!-- more -->

## Overview

* TypeScript
  - Like Ruby, less magic, more types, better tooling
  - Inferred typing
  - Types provide documentation
  - Types provide interfaces
  - Types can come from external definitions
  - Types are optional, use them when we want
  - TS is a consolidation of Future JS + Types, basically Babel + Flow
  - Classes exist, are optional, but we use them in React
  - Generics, Enums and union types
  - Soundness "unsound" behavior = `any`
  - Deep Dive - https://github.com/basarat/typescript-book
  - Looking open to extensions (e.g. Relay)

## GraphQL

GraphQL is a way to handle API requests. I consider it the successor to REST when working with front-end clients. A big claim, yeah. So, what is it?

Officially [GraphQL is a specification][graph-spec]. A server can conform to the GraphQL spec, and then clients can make queries against it. Think of it a bit like how SQL is a standardized way of doing database queries across multiple databases types. 

As a client, you [send](https://github.com/artsy/eigen/blob/dac7c80b66b600f9a45aaae6095544fe420f0bbc/Artsy/Networking/ARRouter.m#L1011) a "[JSON-shaped query](http://graphql.org/docs/getting-started/#queries)" structure, which is hierarchical and easy to read:

```json
{
  artwork(id: "kimber-berry-as-close-to-magic-as-you-can-get") {
    id
    additional_information

    is_price_hidden
    is_inquireable
  }
}

```

> This will search for a [specific artwork](https://www.artsy.net/artwork/kimber-berry-as-close-to-magic-as-you-can-get), with the response JSON as the Artwork's `id`, `additional_information`, `is_price_hidden` and `is_inquireable`.

It's important to note here, the data being sent _back_ is specifically  what you ask for. This is not defined on the server as a _short_ or _embedded_ version of a model, but the specific data the client requested. When bandwidth and speed is crucial, this is the other way in which GraphQL vastly improves an app-user's experience.

This is in stark contrast to other successors to REST APIs, the hypermedia APIs, like [HAL](http://stateless.co/hal_specification.html) and [JSON-API](http://jsonapi.org) - both of which are optimised for caching, and rely on "one model, one request" types of API access. E.g. a list of Artworks would actually contain a list of hrefs instead of the model data, and you have to fetch each model in a separate request.

Hypermedias APIs have a really useful space in cross-server communications, but are extremely wasteful of the most precious resource on a front-end device - bandwidth. The sooner you can enough information to present a screen 

I explored our usage of GraphQL from the perspective of a native developer [earlier in the year][mob-graph]. 

We use GraphQL as an API middle-layer. It acts as an intermediate layer between multiple front-end clients and multiple back-end APIs. This means we can easily coalesce many API calls into a single request, this can be a _massive_ user experience improvement when you have a screen that requires information from varied sources before you can present anything to a user.

<img src="/images/2016-06-19-graphql-for-iOS-devs/graphQL.svg" width=100%>

  - Owned by front-end
  - Moves control of what data is accessed on to clients
  - Acts as a meta-API between many APIs
  - Tiny data up, tiny data down
  - Strictly typed
  - Easy to export all schema
  - Graphiql
  - Starting to see wider adoption due to GitHub

* React / React Native
  - React is only our view layer
  - But when you're building API-driven apps, that could be all you need

  - Stable, mature library, on web this is not new territory
  - Requires a re-think of how views should be structured
  - Separation of view hierarchy code and app logic via JSX

  - One way data flow
  - Virtual DOM
  - There is a 4.5k word essay on our move to React Native

  - Ideas like pure function makes it easy to write tests
  - A lot of great tooling available 

## Relay

Any front-end client has a lot of work to do on a page:

  * Fetching all the data for a view hierarchy.
  * Managing asynchronous state transitions and coordinating concurrent requests.
  * Managing errors.
  * Retrying failed requests.
  * Updating the local cache after receiving new results/changes the server objects responses.
  * Optimistically updating the UI while waiting for the server to respond to mutations.

This is typically handled in a per-page basis, for example the API details, and state management between a Gene page, and an Artist page are different. In part because they have different data-models, but also that they have different correlated data. However, they do share a lot the common responsibilities mentioned above. In our native side, we struggled to find abstractions that would work across multiple pages. Relay fixes this, and does it in a shockingly elegant way. 

Relay is a framework for building data-driven react apps which relies on a deep connection to GraphQL. You wrap your React components inside a Relay container, which handles the networking and setting the state for your component.

```js
// This is a normal React component, taken directly from our app
// It will optionally show a description if one exists on a gene.

class Biography extends React.Component {
  render() {
    const gene = this.props.gene
    if (!gene.description) { return null }

    return (
      <View>
        <SerifText style={styles.blurb} numberOfLines={0}>{gene.description}</SerifText>
      </View>
    )
  }
}

// We take the above container, and wrap it with relay and a description of what parts
// of a GraphQL request does the component need from the API. 

export default Relay.createContainer(Biography, {
  fragments: {
    gene: () => Relay.QL`
      fragment on Gene {
        description
      }
    `,
  }
})

// Then when the Biography component is rendered, the component is given props of 
// `gene.description` by the Relay container. 
```

Relay handles this by having each component in your view hierarchy exposing the fragments of a GraphQL query. There is a pre-render stage where all of your components fragments are brought together to make a single API request. So in the case of the Gene, it may look something like:

```json
{
  gene(id: "the-fantastic") {
    // could have come from the root component's fragment
    id
    name 

    // came from the above Header fragment
    description 

    // could have come from a RelatedArtists component's fragment
    trending_artists {
      name
      href
    }
  }
}
``` 

The data is first looked up inside Relay's local cache, and then any un-cached items are requested from the network. The results of the query is then moved into the component via it's props. Relay will only provide the specific data each component has requested. So the `Header` component would get nothing for `this.props.gene.name`. This data-masking is a great way of ensuring the connection between component and API.

I'd strongly recommend taking the dive into both the [Thinking with GraphQL][thinking-ql] and then [Thinking with Relay][think-rl] tutorials to learn more. 


## Yarn

I have a lot of respect for NPM, their scale is [through the roof][npm]. They built out the foundations for a massive, thriving community. They did a great job. Like a lot of the JavaScript eco-system, their tooling is allows you to get away with a lot of things. You can have the same dependency inside the app with multiple versions, or apps with a dependency tree that is different each time you run `npm install`.

We have multiple engineers who have worked on a dependency manager for half a decade, having indeterminate builds in JavaScript was something that worried us greatly. Luckily, there is Yarn.

Yarn is a Facebook project that replaces the NPM [cli][cli] client. It's very new, so unlike NPM it does not have to worry about backwards compatibility. It is what I'd imagine a fresh re-write of the NPM cli would look like. 

Yarn is significantly faster, has a determinate process for setting up and project and uses a lockfile by default to ensure everyone using the project gets the exact same dependency tree. It uses NPM as a server, and so you get the same node modules as you with the NPM cli.

Sometimes Yarn gives you pleasant surprises too, my favourite being that `yarn run [x]` will check to see if that is a local command that you could run, saving a bunch of redundant settings.

Converting a codebase can be as simple as going into your project and running:

```shell
npm install -g yarn
yarn install
```

Now you have a lockfile, and are using yarn. Awesome, if you are migrating from a project with a shrink-wrap - I have a script which will generate a summary of the changes for you: [script][yarn-migrate], [example][yarn-example].

## Jest

One of the things that I find particularly pleasant about the JavaScript ecosystem are their testing tools. With our React Native, we came into the eco-system with fresh eyes, and it was pretty obvious that Jest was an exceptional testing framework. I hear historically Jest has been a bit meh, but it is without a doubt worth another look.

**The watcher** - 

**Fast and safe** - 

**Snapshots** -

**No config** - except when you do, supports etc

**Extremely welcoming** - 



- Git diff based watcher
- Watcher handles interruptions
- Fast, caches transpiled files via haste-map
- Runs failed tests first on next run
- Extensible and open to improvements 
- Comprehensive amount of matchers
- Natural support of async code
- Handles JSON snapshot testing elgantly
- No configuration, but you can if you want to
- Smart, logical, mocking system for any dependencyso
- Officially supports Babel, TypeScript, webpack
- Has custom ESLint rules
- Ease of porting from other testing tools via codemods
- Meaningful error messages
- Built-in code coverage
- Parallel, and totally sandboxed tests


* VS Code
  - Open Source
  - Process Separated
  - Project Oriented
    - User and project settings
    - Can provide consistent Artsy dev experience
  - Carefully extensible
  - Regular monthly updates
  - TypeScript codebase
  - Works really well with TypeScript
  - Inline Debugging
  - Inline docs
  - Shallow to make changes in


### End

- It's the facebook stack. lols.

- Relying on mostly solid multi-year old projects (which is old in web-years)
- We help out, fixing gaps between these larger projects e.g. vscode-jest, relay fork
- Potential for sharing code between web and native
- All open source, all hackable


[mob-graph]: /blog/2016/06/19/graphql-for-mobile/
[graph-spec]: https://github.com/facebook/graphql
[think-ql]: https://facebook.github.io/relay/docs/thinking-in-graphql.html
[think-rl]: https://facebook.github.io/relay/docs/thinking-in-relay.html
[npm]: http://blog.npmjs.org/post/143451680695/how-many-npm-users-are-there
[cli]: https://en.wikipedia.org/wiki/Command-line_interface
[yarn-script]: https://gist.github.com/orta/cb6d0b8256852c1f01ecf1d803b664c9
[yarn-example]: https://github.com/artsy/metaphysics/pull/479
