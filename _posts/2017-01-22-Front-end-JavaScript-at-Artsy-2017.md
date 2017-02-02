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

### Overview

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

* GraphQL
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

* Relay
  - A framework for data-driven react apps
  - Declarative API, no need to declare an API call/fetch
  - Co-location of data and API request
  
  - Show an example

  - Explain a query, and root container
  - Caching
  - Data Masking

  - https://facebook.github.io/relay/docs/thinking-in-graphql.html#content
  - https://facebook.github.io/relay/docs/thinking-in-relay.html#content

* Yarn
  - New, no demands for backwards compat
  - Fast, local caching
  - Determinate
  - Smart defaults (`yarn run jest`)
  - Flattened dependencies


* Jest
  - Git diff based watcher
  - Watcher handles interruptions
  - Fast, caches transpiled files via haste-map
  - Runs failed tests first on next run
  - Extensible and open to improvements 
  - Comprehensive amount of matchers
  - Natural support of async code
  - Handles JSON snapshot testing elgantly
  - No configuration, but you can if you want to
  - Smart, logical, mocking system for any dependency
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


