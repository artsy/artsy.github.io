---
layout: post
title: "Refactoring to Javascript on the Server &amp; Client"
date: 2013-11-30 22:38
comments: true
categories: 
---

Recently AirBnB came out with [an article](http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/) describing a growing trend in web development to share code between the browser and server using [Node.js](http://nodejs.org/). At Artsy we've been riding this wave and are seeing many benfits as we transition more of our web apps to use this shared javascript environment. This article is going to describe the problems we've faced that drove us here, and the journey we've taken towards this future of [Backbone](http://backbonejs.org/) apps that run server/client and use our API as a data source.

If you want to jump ahead to some code, we've open sourced [various](https://github.com/artsy/benv) [node](https://github.com/artsy/sharify) [modules](https://github.com/artsy/backbone-super-sync) along the way coalescing into a boilerplate project called [Ezel](http://ezeljs.com/).

# From Rails to Backbone to Problems

Artsy began as a pretty standard Rails app with [Mongo](http://www.mongodb.org/) as a database and [Grape](https://github.com/intridea/grape) as an API. As we were building our Grape API we started to write more client-side javascript and soon after adopted [Backbone](http://backbonejs.org/) to give structure to our jQuery spagetti. Over time we removed a lot of our controller code and server-side view logic. This cleanly separated our application into a single page Backbone app talking to our Grape API all on top of Rails.

This worked out well for a while until this project started to grow into an massive monolith full of problems including...

* Lack of rendering on the server lead to issues with SEO and [initial page load speed](https://blog.twitter.com/2012/improving-performance-twittercom).
* A single page monolithic Backbone app without a sane way to break up asset packages meant large CSS/Javascript downloads before rendering further content.
* Duplicated code such as templates, date libraries, etc. for Ruby and Javascript.
* Lack of good javascript testing tools [lead to very slow and brittle builds](](http://artsy.github.io/blog/2013/06/14/writing-headless-backbone-tests-with-node-dot-js/)) that relied on integration tests using [Capybara](https://github.com/jnicklas/capybara).
* Attempting to responsively scale down a large single page app lead to a very poor mobile experience that's bloated by unused javascript and CSS.
* The more code added to the same project slowed everything down such as server boot up time, asset compliation time, test suite time, etc. shooting producity.

# There's got to be a better way

It became clear building everything on a monorail that treats it's client-side code as a second class citzen was not going to scale. Our mobile web experience was a good candidate to try something new after many subpar attempts at responsively scaling down our monolithic Backbone/Rails app, and so we embarked on building m.artsy.net.

Going into this new project some goals became clear:

* Better client-side development tools such package mangers and better javascript testing.
* Share rendering code between the client and server to reduce duplication and optimize initial page load/SEO.
* Flexibility. Artsy is too big to be put into one thick-client app that loads all of it's assets up front. We need a way to break up sections that can choose how much client-side code to use and only include the javascript/CSS necessary.

Node.js makes sharing rendering code between the server and browser possible. There were some existing frameworks/libraries that help acomplish this including [Derby](http://derbyjs.com/) and [Rendr](https://github.com/airbnb/rendr). However adopting these had challenges of their own including being difficult to integrate with our API, learning unecessary conventions and features, or being early prototypes with lacking documentation.

Ultimately it felt as if these tools were trying to hide the browser and server environments by creating an abstracted "shared" envrionemnt that reduces glue code. Given how very different the browser and server are it seemed overly optimistic and unecessary to do this. Instead we chose to endure some glue code, combine smaller components, and focus on writing modules that can sanely be shared between the browser and server using [Browserify](http://browserify.org/).

# Modularity is King

Many of our goals are