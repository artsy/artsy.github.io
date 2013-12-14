---
layout: post
title: "Moving Artsy to Node.js & Sharing Code Server/Client"
date: 2013-11-30 22:38
comments: true
categories:
---

![Diagram of Isomorphic Architecture](http://nerds.airbnb.com/wp-content/uploads/2013/11/isomorphic-client-server-mvc.png)

Recently AirBnB came out with [an article](http://nerds.airbnb.com/isomorphic-javascript-future-web-apps/) describing a growing trend in web development to share code between the browser and server using [Node.js](http://nodejs.org/). Artsy's been riding this wave for a while and seeing many benfits -- pages load faster, devs are more productive, and javascript coding is just a better experience. We're so happy with it that we're running our mobile website on Node and transitioning our main desktop website.

We've even open sourced our efforts along the way including [various](https://github.com/artsy/benv) [node](https://github.com/artsy/sharify) [modules](https://github.com/artsy/backbone-super-sync) coalescing into a boilerplate project called [Ezel](http://ezeljs.com/).

I'm going to tell Artsy's story of moving to modular [Backbone](http://backbonejs.org/) apps that share code server/client and why they've made life better.

<!-- more -->

## From Rails to Backbone to Problems

![Evolution of Artsy Diagram]()

Artsy began as a pretty standard Rails app that adopted [Grape](https://github.com/intridea/grape) for our API. While building our Grape API we wrote more client-side javascript and soon adopted [Backbone](http://backbonejs.org/) for organization. Eventually we cleanly separated our project into a single page Backbone app talking to our Grape API all on top of [Rails](http://rubyonrails.org/).

It wasn't long until the Backbone + Rails monolith grew into an massive beast full of problems including...

* SEO and [initial page load speed](https://blog.twitter.com/2012/improving-performance-twittercom) suffered because of lacking server-side rendering.
* Slow following renders because of large asset packages without clear ways to break them up.
* Maintaining duplicated Ruby/Javascript code such as templates, date libraries, etc.
* [Very slow and brittle builds](http://artsy.github.io/blog/2013/06/14/writing-headless-backbone-tests-with-node-dot-js/) due to lacking good javascript testing tools and relying too much on [Capybara](https://github.com/jnicklas/capybara).
* Poor mobile experience from trying to responsively scaling down a large single page app with bloated and unused assets.
* Slow asset compilation, server boot, and test suite times. Productivity suffered greatly as more code was added to the same monolithic project.

## There's got to be a better way

A monorail that treats it's client-side code as a second class citzen was clearly not going to scale. Our poor mobile web experience was a good candidate to try something new by building an external mobile website at m.artsy.net.

Some goals became clear:

* Better client-side tools from javascript testing to package mangers.
* Share rendering code server/client to reduce duplication and optimize initial page load and SEO.
* Flexibility. Not all pages need to be in the same single page app. We need a way to divide our app into smaller chunks with smaller asset packages.

## Choosing Technology

![Logos of Browserify, Express, and Backbone]()

Node makes sharing rendering code server/client possible, so that's a clear choice. There are some existing frameworks/libraries to acomplish this including [Derby](http://derbyjs.com/) and [Rendr](https://github.com/airbnb/rendr). However, adopting these had challenges of their own including being difficult to integrate with our API, learning unecessary conventions, or being early prototypes with lacking documentation.

We wanted an approach that breaks our app into smaller, more flexible, pieces. Not all of Artsy needs to be a thick-client app, or even use much client-side javascript at all. Combining most of the server and client into a shared abstraction, like many existing tools did, seemed like an unecessary black box. Instead we chose to endure some glue code and use popular lower level tools like [Backbone](http://backbonejs.org/), [Browserify](http://browserify.org/), and [Express](http://expressjs.com/), focusing on composable modules where some can be easily be shared server/client.

## Sharing and Rendering Client/Server

[Browserify](http://browserify.org/) let's you write modules that can run in Node or the browser. Many modules like [moment](http://momentjs.com/) can be required and work the same way on the server or client and _it just works_. With Browserify's transforms we can also share non-javascript components like [jade templates](http://jade-lang.com/) using [jadeify](https://github.com/OliverJAsh/node-jadeify2).

Since Backbone is written to be able to run on both sides we can browserify and share our models and collections server/client as well. However there were two main speed bumps in doing this:

1. Backbone uses ajax for persistance by default.

   We needed a Backbone.sync adapter that makes HTTP requests server-side. [So we did, and it's open sourced.](https://github.com/artsy/backbone-super-sync)

2. Data needed to be shared in model code on the server and client.

   For instance our API is still being served from Rails at an external url configured by an [environment variable](http://en.wikipedia.org/wiki/Environment_variable). We need to be able to pass this variable to the model on the server and client. [Bootstrapping data](http://backbonejs.org/#FAQ-bootstrap) is a common technique to share data by rendering snippets of javascript on the server that expose that data globally to the client. To avoid exposing shared data as globals we open sourced a tiny module called [sharify](https://github.com/artsy/sharify) that injects your data into a hash that can be required on the server and client.

With those challenges solved sharing rendering code is as simple as requiring the model and template on the server or client and using it where need be. An example using the same artwork model and template server/client might look like this:

``` javascript models/artwork.js
var Backbone = require('backbone'),
    API_URL = require('sharify').data.API_URL;

module.exports = Artwork = Backbone.Model.extend({

  url: API_URL + '/api/v1/artwork'

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
    ARTWORK = require('sharify').data.ARTWORK,
    detailsTemplate = require('templates/artwork-details.jade');

// Instantiate a new artwork from the sharified data and
// re-render the body whenever the model is changed.
var artwork = new Artwork(ARTWORK);
artwork.on('change', function() {
  $('body').html(detailsTemplate({ artwork: artwork }));
});
```

## Developer Happiness

### Package Mangers

What's also nice about using Node and Browserify is we can now use npm as a package manager for the client or server. There are [other](http://bower.io/), [package](http://component.io/), [managers](http://jamjs.org/) for the client-side. But since we're already using npm, and npm supports git urls, we can often get away with just pointing to the project hosted on npm or Github without having to fork the project.

For projects that don't support [Common.js modules](http://wiki.commonjs.org/wiki/Modules/1.1) or npm, often one can get away with something like this:

``` json
"devDependencies": {
  "zepto": "git://github.com/madrobby/zepto.git#c074a94f0f26dc946f1c501f5f45d603adada44d"
}
```

``` javascript client.js
// Require the base Zepto library (attaches `Zepto` to window)
require('zepto/src/zepto.js');
// Attach Zepto's plugins
require('zepto/src/event.js');
require('zepto/src/detect.js');
// ....
```

### Testing

People are finally taking client-side javascript testing seriously and with Node it gets much better. I wrote [an entire article](/blog/2013/06/14/writing-headless-backbone-tests-with-node-dot-js/) on how to use Node to write fast, headless, client-side tests. So if you're interested in the gory details please [check it out](/blog/2013/06/14/writing-headless-backbone-tests-with-node-dot-js/). What's different now is with Browserify the friction is reduced even more.

Our modules are written like node modules, so testing them headlessly in Node is pretty straightforward -- require them into a runner like [mocha](http://visionmedia.github.io/mocha/). The main gotchya is when your code depends on DOM APIs, global libraries like [Zepto](http://zeptojs.com/), pre-rendered html, client-side templates, or other things that are unique to the browser environment. For this we wrote a library of test helpers called [benv](https://github.com/craigspaeth/benv) which can help with some of these common necessities when testing browser code in Node.

### Modularity is King

We expirment a lot at Artsy, and are constantly refactoring code. This time around we wanted to avoid writing an inflexible, monolithic, app that drops all of it's interaction code into folders like /stylesheets /views /javascripts, /controllers, etc.. This not only makes it unclear where the boundaries of your app are, but it also makes it tempting to just throw all of your assets into one giant app.css and app.js package. These large asset packages were a big performance hit to our growing Backbone app that had to download large multi-megabyte files before rendering any content.

By organizing our project into smaller ["apps"](https://github.com/artsy/ezel#apps) and ["components"](https://github.com/artsy/ezel#components) we are able to easily maintain and iterate on smaller, decoupled, portions. This also made it easy to [break up our asset packages](https://github.com/artsy/ezel#asset-pipeline) by explicitly requiring into each app and component's javascripts and stylsheets using Browserify and [Stylus](http://learnboost.github.io/stylus/docs/import.html). For more details on this please take a look at our open source boilerplate, [Ezel](http://ezeljs.com/)'s [organization docs](https://github.com/artsy/ezel#project-vs-apps-vs-components) and [asset pipeline section](https://github.com/artsy/ezel#asset-pipeline).

It's also worth noting that while Browserify solves clear boundaries for javascript, CSS doesn't have the same luxaries. To avoid CSS spagetti we followed a simple convention of namespacing all of our CSS classes by the app or component folder name. This was largely inspired by a [blog post from Philip Walton](http://philipwalton.com/articles/css-architecture/).


## Success!

With this new architecture and set of Node tools we've seen enormous benefits compared to the pains of developing Backbone on a monorail. We have a solid mobile web experience now, our pages load faster, we can render more content on the server for SEO, our test/build/deploy cycles went from hours to minutes, our dev onboarding time went from days to minutes, and overall front-end dev happiness has significantly improved.

Follow us on [Github](https://github.com/artsy). We've been, and will continue, to open source our efforts wherever possible as we continue to bootstrap more projects off [Ezel](http://ezeljs.com/) and explore more territory where we run javascript on both sides.