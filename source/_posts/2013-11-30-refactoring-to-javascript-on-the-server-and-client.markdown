---
layout: post
title: "Refactoring to Javascript on the Server &amp; Client"
date: 2013-11-30 22:38
comments: true
categories:
---

Recently AirBnB came out with [an article](http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/) describing a growing trend in web development to share code between the browser and server using [Node.js](http://nodejs.org/). At Artsy we've been riding this wave for a while now and are seeing many benfits -- our pages load faster, our devs are more productive, and javascript coding is just an overall better experience. We're so happy with it that we're running our entire mobile website ([m.artsy.net](http://m.artsy.net)) on Node and are in the process of transitioning our main desktop website ([artsy.net](http://artsy.net)) as well.

We've also open sourced of efforts along the way including [various](https://github.com/artsy/benv) [node](https://github.com/artsy/sharify) [modules](https://github.com/artsy/backbone-super-sync) coalescing into a boilerplate project called [Ezel](http://ezeljs.com/).

I'm going to describe the problems we've faced that drove us to Node and the many benefits we've gained from moving towards highly modular [Backbone](http://backbonejs.org/) apps that share code server/client.

<!-- more -->

## From Rails to Backbone to Problems

Artsy began as a pretty standard Rails app configured to use [Mongo](http://www.mongodb.org/) as a database and [Grape](https://github.com/intridea/grape) as an API. As we were building our Grape API we started to write more client-side javascript and soon adopted [Backbone](http://backbonejs.org/) to give structure to our jQuery spagetti. Over time we removed a lot of our controller code and server-side view logic. This cleanly separated our application into a single page Backbone app talking to our Grape API all on top of Rails.

This worked out well for a while until the Backbone + Rails monolith started to grow into an massive beast full of problems including...

* SEO and [initial page load speed](https://blog.twitter.com/2012/improving-performance-twittercom) issues because of lacking server-side rendering.
* Slow following renders because of downloading large asset packages without clear ways to break them up.
* Maintaining duplicated code such as templates, date libraries, etc. for Ruby and Javascript.
* [Very slow and brittle builds](http://artsy.github.io/blog/2013/06/14/writing-headless-backbone-tests-with-node-dot-js/) due to lacking good javascript testing tools and relying too much on [Capybara](https://github.com/jnicklas/capybara).
* Attempting to responsively scale down a large single page app lead to a very poor mobile experience that's bloated by unused javascript and CSS.
* Slow asset compilation, server boot, and test suite times. Productivity got worse and worse as more code was added to the same monolithic project.

## There's got to be a better way

It became clear building everything on a monorail that treats it's client-side code as a second class citzen was not going to scale. Our mobile web experience was a good candidate to try something new after many subpar attempts at responsively scaling down our monolithic Backbone + Rails app, and so we embarked on building m.artsy.net.

Going into this new project some goals became clear:

* Better client-side development tools such package mangers and better javascript testing.
* Share rendering code between the client and server to reduce duplication and optimize initial page load/SEO.
* Flexibility. Artsy is too big to be put into one thick-client app that loads all of it's assets up front. We need a way to break up sections that can choose how much client-side code to use and only include the javascript/CSS necessary.

Node makes sharing rendering code between the server and browser possible. There were some existing frameworks/libraries that help acomplish this including [Derby](http://derbyjs.com/) and [Rendr](https://github.com/airbnb/rendr). However adopting these had challenges of their own including being difficult to integrate with our API, learning unecessary conventions and features, or being early prototypes with lacking documentation.

Ultimately it felt as if these tools were trying to hide the browser and server environments by creating an abstracted "shared" envrionemnt that reduces glue code. Given how very different the browser and server are it seemed overly optimistic and unecessary to do this. Instead we chose to endure some glue code, combine smaller components, and focus on writing modules that can easily be shared between the browser and server.

## Sharing and Rendering Client/Server

Choosing Node as a platform brings many solutions to the goals we layed out. [Browserify](http://browserify.org/) makes it easy to write code that can run in Node or be packaged up to run in the browser. This makes sharing code between the browser and server a much easier task, and many modules like [moment](http://momentjs.com/) can be required the same way on the server or client and _it just works_. With Browserify's transforms we can also share non-javascript components such as [jade templates](http://jade-lang.com/) between the client and server using [jadeify](https://github.com/OliverJAsh/node-jadeify2). This makes the goal of [DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself)ing up our rendering code and speeding up initial page load very attainable.

We've all been writing Backbone code on the client-side at Artsy for a while, so it would be preferable to use familiar tools when we can. Luckily Backbone is written to be able to run in Node or the browser. This means we can share our models and collections between the server and client by writing them in Browserify modules. However there were two main speed bumps in the way of this:

1. By default Backbone uses jQuery's ajax for persistance.

  We needed to write a Backbone.sync adapter that makes HTTP requests server-sidez. [So we did, and it's open sourced.](https://github.com/artsy/backbone-super-sync)

2. Certain data needed to be accessed in model code on the server and client.

  For instance our API is still being served from Rails at an external url configured by an [environment variable](http://en.wikipedia.org/wiki/Environment_variable). We need to be able to pass this variable to the model on the server and client. [Bootstrapping data](http://backbonejs.org/#FAQ-bootstrap) is a common technique to share data by rendering snippets of javascript on the server that expose that data globally to the client. To avoid exposing shared data as globals we open sourced a tiny module called [sharify](https://github.com/artsy/sharify) that injects your data in a common `sd` namespace that can be required on the server and client.

With those challenges solved sharing rendering code is as simple as requiring the model and template on the server or client and using it where need be. An example using the same artwork model and template server/client might look like this:

``` javascript models/artwork.js
var Backbone = require('backbone'),
    sd = require('sharify').data;

module.exports = Artwork = Backbone.Model.extend({

  url: sd.API_URL + '/api/v1/artwork'

});
```

The shared partial template:

```jade templates/artwork-details.jade
h1= artwork.get('artist').name
h2= artwork.get('title')
```

The full server-side page including the partial:

```jade templates/artwork-page.jade
doctype 5
html
  head
    title Artsy | #{artwork.get('title')}
  body
    include artwork-details
```

Route handler that uses the model server-side.

``` javascript app.js
//...
var Artwork = require('models/artwork.js');

app.get('/artwork/:id', function(req, res) {
  new Artwork({ id: req.params.id }).fetch({
    success: function(artwork) {
      // Boostrap artwork data into sharify
      res.locals.sd.ARTWORK = artwork.toJSON();
      res.render('artwork-page', { artwork: artwork });
    }
  });
});
```

Client side code that requires the jade partial with [jadeify](https://github.com/OliverJAsh/node-jadeify2) and uses the model client-side.

``` javascript client.js
var Artwork = require('models/artwork.js'),
    sd = require('sharify').data,
    detailsTemplate = require('templates/artwork-details.jade');

// Instantiate a new artwork from the sharified data and
// re-render the body whenever the model is changed.
var artwork = new Artwork(sd.ARTWORK);
artwork.on('change', function() {
  $('body').html(detailsTemplate({ artwork: artwork }));
});
```

## Developer Happiness

We can use npm as a package manager for the client or server, and since npm is flexible enough to allow pointing to git urls, we don't have to fork every client-side project we want to include on the client.