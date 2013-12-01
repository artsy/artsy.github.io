---
layout: post
title: "Refactoring to Javascript on the Server &amp; Client"
date: 2013-11-30 22:38
comments: true
categories: 
---

Recently AirBnB came out with [an article](http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/) describing a growing trend in web development to share code between the browser and server using [Node.js](http://nodejs.org/). At Artsy we've been riding this wave and are seeing many benfits as we transition more web apps to use this shared javascript server/client environment. This article is going to describe the problems we've faced that drove us here, and the journey we've taken towards this future.

## From Rails to Backbone to Problems

Artsy began as a pretty standard Rails app with [Mongo](http://www.mongodb.org/) as a database and [Grape](https://github.com/intridea/grape) as an API. As we were building our Grape API we started to write more client-side javascript and quickly adopted [Backbone](http://backbonejs.org/) to give structure to our jQuery spagetti. Over time we removed a lot of our controller code and server-side view logic. This cleanly separated our application into a single page Backbone app talking to our Grape API all on top of Rails.

This worked out quite well for a while until this project started to grow into a massive monolith full of problems...

* Lack of rendering on the server lead to issues with SEO and [initial page load speed](https://blog.twitter.com/2012/improving-performance-twittercom).
* A single page monolith without a sane way to break up asset packages meant large asset downloads before rendering further content.
* Duplicated templates and libraries to work in Ruby and Javascript lead to maintanence headaches.
* Lack of good javascript testing tools lead to 