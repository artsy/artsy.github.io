---
layout: post
title: "Exploration: Front-end JavaScript at Artsy in 2017"
date: 2017-01-22 12:17
author: orta
categories: [javascript, emission, reactnative, force, typescript]
series: React Native at Artsy
---

The Artsy web team have been early adopters of node, and for the last 4 years the stable stack for the Artsy website has been predominantly been Node + CoffeeScript + Express + Backbone. In 2016 the mobile team announced that it had moved to React Native, matching the web team as using JavaScript as the tools of their trade.

Historically we have always had two separate dev teams for building Artsy.net and the corresponding iOS app, we call them Collector Web, and Collector Mobile. By the end of 2016 we decided to merge the teams. The merger has given way to a whole plethora of ideas about what modern JavaScript looks like and we've been experimenting with finding common patterns between web and native.

This post tries to encapsulate what we consider to be our consolidated stack for web/native Artsy in 2017. 

TLDR: GraphQL, TypeScript, React/React Native, Relay, Yarn, Jest, and VS Code.  

<!-- more -->

### Overview

* TypeScript
  - Like Ruby, less magic, more types, better tooling
  - Biggest compilation unit is a file, not a target

* GraphQL
  - Vastly reduces networking traffic
  - Amazing tooling
  - Typed data, exportable 

* React / React Native
  - Awesome abstraction for data driven UI
  - Encourages better code reuse and data encapsulation

* Relay
  - Reduces boilerplate considerably

* Yarn
  - Fast, reliable

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
  - Carefully extensible

  - Open, extensible and regularly updated
