---
layout: post
title: "Moving Artsy to Node.js & Sharing Code Server/Client"
date: 2013-11-30 22:38
comments: true
categories: [AWS, OpsWorks, Heroku, dev-ops]
author: Craig Spaeth
github-url: https://www.github.com/craigspaeth
twitter-url: http://twitter.com/craigspaeth
---

![Diagram of Shared Server/Client Architecture](/images/2013-11-30-moving-artsy-to-node-dot-js-and-sharing-code-server-client/isomorphic.png)

Recently AirBnB came out with [an article](http://nerds.airbnb.com/isomorphic-JavaScript-future-web-apps/) describing a growing trend in web development to share code between the browser and server using [Node.js](http://nodejs.org/). Artsy's been riding this wave for a while now and seeing many benfits -- pages load faster, devs are more productive, and JavaScript coding is just an overall better experience. We're so happy with running our mobile wesbite on Node that we're currently transitioning our main desktop website as well.

If you're interested in jumping ahead and starting your own project like this we've open sourced [various](https://github.com/artsy/benv) [node](https://github.com/artsy/sharify) [modules](https://github.com/artsy/backbone-super-sync) coalescing into a boilerplate project called [Ezel](http://ezeljs.com/).

In this article I'll tell Artsy's story of moving from a single Rails app to modular [Backbone](http://backbonejs.org/) apps on Node that share code server/client.

<!-- more -->

## From Rails to Backbone to Problems

![Evolution of Artsy SOA Diagram](/images/2013-11-30-moving-artsy-to-node-dot-js-and-sharing-code-server-client/rails-evolution.png)

Artsy began as a pretty standard [Rails](http://rubyonrails.org/) app that adopted [Grape](https://github.com/intridea/grape) for our API. While building our API we wrote a lot of client-side JavaScript -- soon adopting [Backbone](http://backbonejs.org/) for organization. Eventually we cleanly separated our project into a single page Backbone app talking to our API all on top of Rails.

Unfortunately it wasn't long until the Backbone + Rails monolith grew into an massive beast full of problems including...

* SEO and initial page load speed suffered because of lacking server-side rendering. Twitter [describes this quite well](https://blog.twitter.com/2012/improving-performance-twittercom).
* Slow following client-side renders because of downloading large asset packages without clear ways to break them up.
* Maintaining duplicated Ruby/JavaScript code such as templates, date libraries, etc.
* Very slow and brittle test suites due to lacking good JavaScript testing tools and relying too much on [Capybara](https://github.com/jnicklas/capybara).
* Poor mobile experience from trying to responsively scale down a large single page app with bloated and unused assets.
* Slow asset compilation, server boot, and general build times. Productivity suffered greatly as more code was added to the same monolithic project.

## There's got to be a better way

A monorail that treats it's client-side code as a second class citzen was clearly not going to scale. Our poor mobile web experience was a good candidate to try something new. So we started building a separate mobile optimized website at m.artsy.net.

Some goals became clear:

* Better client-side tools from JavaScript testing to package mangers.
* Share rendering code server/client to reduce duplication and optimize initial page load.
* Flexibility. We needed a way to divide our app into smaller chunks with smaller asset packages.

## Choosing Technology

![Logos of Browserify, Express, and Backbone](/images/2013-11-30-moving-artsy-to-node-dot-js-and-sharing-code-server-client/tech.png)

Node was a clear choice because it makes sharing rendering code server/client possible where other languages and frameworks struggle to do so. There were some existing Node projects that acomplish this including [Derby](http://derbyjs.com/) and [Rendr](https://github.com/airbnb/rendr). However, adopting these had challenges of their own including being difficult to integrate with our API, learning unecessary conventions, or being early prototypes with lacking documentation.

We wanted an approach that breaks our app into smaller, more flexible, pieces. Not all of Artsy needs to be a thick-client app, or even use much client-side JavaScript at all. Adopting an existing solution and combining most of the server and client into a shared abstraction seemed like an unecessary black box. Instead we decided on our own, lighter-weight, solution using [Express](http://expressjs.com/) and [Backbone](http://backbonejs.org/) for structure, and [Browserify](http://browserify.org/) to compose modules where some can be shared server/client.

## Sharing and Rendering Server/Client

![Diagram of Server + Client Render](/images/2013-11-30-moving-artsy-to-node-dot-js-and-sharing-code-server-client/rendering.png)

To share rendering code server/client we had to make sure our templates, and objects being passed in to them, could work the same server/client.

### Sharing Objects (Backbone Models)

[Browserify](http://browserify.org/) lets you write modules that can run in Node or the browser. Since Backbone is able to be required on the server out of the box we can easily write models and collections that can be required on both sides with Browserify. However there are two main speed bumps in doing this:

1. Backbone uses ajax for persistance.

   We needed a [Backbone.sync](http://backbonejs.org/#Sync) adapter that makes HTTP requests server-side. So we wrote one, and [it's open sourced.](https://github.com/artsy/backbone-super-sync)

2. Data from the server needed to be shared in modules that are used server/client.

   For instance our API is an external url stored in an [environment variable](http://en.wikipedia.org/wiki/Environment_variable). We needed to use this variable in a module that will be required on the server and client with Browserify. [Bootstrapping data](http://backbonejs.org/#FAQ-bootstrap) is a common technique to share data from the server by embedding JavaScript in the initial html and exposing that data globally to the client. To avoid the necessity of exposing globals we open sourced a tiny module called [sharify](https://github.com/artsy/sharify) that wraps some bootstrapping magic for you.

### Sharing Templates

Browserify even lets you share non-JavaScript components server/client using [transforms](https://github.com/substack/node-browserify#list-of-source-transforms). To reuse our [jade templates](http://jade-lang.com/) server/client it's a simple matter of using the [jadeify](https://github.com/OliverJAsh/node-jadeify2) transform.

### All Together Now

With templates and models requireable server/client, sharing rendering code becomes much simpler. An example using the same artwork model and detail template server/client might look like this:

Shared Backbone "Artwork" model to be required server/client:

``` javascript models/artwork.js
var Backbone = require('backbone'),
    API_URL = require('sharify').data.API_URL;

module.exports = Artwork = Backbone.Model.extend({

  url: API_URL + '/api/v1/artwork'

});
```

Shared partial jade template used server/client:

```jade templates/artwork-details.jade
h1= artwork.get('artist').name
h2= artwork.get('title')
```

Full server-side page template including the partial:

```jade templates/artwork-page.jade
doctype 5
html
  head
    title Artsy | #{artwork.get('title')}
  body
    include artwork-details
    != sharify.script()
```

Route handler that uses the model server-side.

``` javascript app.js
//...
var Artwork = require('models/artwork.js');

app.get('/artwork/:id', function(req, res) {
  new Artwork({ id: req.params.id }).fetch({
    success: function(artwork) {
      // Boostrap artwork data into sharify
      res.locals.sharify.data.ARTWORK_JSON = artwork.toJSON();
      res.render('artwork-page', { artwork: artwork });
    }
  });
});
```

Client side code that requires the partial template and model.

``` javascript client.js
var Artwork = require('models/artwork.js'),
    ARTWORK_JSON = require('sharify').data.ARTWORK_JSON,
    detailsTemplate = require('templates/artwork-details.jade');

var artwork = new Artwork(ARTWORK_JSON);
artwork.on('change', function() {
  $('body').html(detailsTemplate({ artwork: artwork }));
});
```

## Developer Happiness

![Happy Developer Image](/images/2013-11-30-moving-artsy-to-node-dot-js-and-sharing-code-server-client/so-much-win.png)

Not only does sharing code server/client let you easily optmize page rendering for fast page loads, but development becomes a lot nicer because we can re-use server-side JavaScript tools including...

### Package Mangers

With Browserify we can now use npm as a package manager for server, or client-side, dependecies. There are [other](http://bower.io/), [package](http://component.io/), [managers](http://jamjs.org/) for the client-side. But since we're already using npm, and [npm supports git urls](https://npmjs.org/doc/json.html#Git-URLs-as-Dependencies), we can usually point to the project hosted on npm or Github without having to fork it.

For projects that don't support [CommonJS modules](http://wiki.commonjs.org/wiki/Modules/1.1), or npm, often one can still use npm and requires like so:

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

Testing is light-years better because you can test all of your code headlessly in Node. I wrote [an entire article](/blog/2013/06/14/writing-headless-backbone-tests-with-node-dot-js/) on this, and with Browserify it's even better.

Models, templates, and other modules that are shared server/client can just be required into [mocha](http://visionmedia.github.io/mocha/) and tested server-side. For more view-like client-side code that depends on DOM APIs, pre-rendered html, etc. we open sourced a library of test helpers called [benv](https://github.com/craigspaeth/benv) to help build a fake browser environment in Node for testing.

### Modularity

We wanted to avoid a monolithic organization that groups code by type such as "stylesheets", "javascripts", "controllers", etc. Not only is this a maintanence problem as it make boundaries of your app unclear, but it also affects your users because it encourages groupping all of your assets into large, monolithic, packages that take a long time to download.

Instead we broke up our project into smaller conceptual pieces called "apps" (small express sub-applications [mounted into the main project](http://vimeo.com/56166857)) and "components" (portions of reusable UI such as a modal widget). This let us easily maintain decoupled segments of our project and build up smaller asset packages through Browserify requires and [Stylus](http://learnboost.github.io/stylus/docs/import.html) imports. For more details on how this is done please check out our open source boilerplate [Ezel](http://ezeljs.com/), specifically it's [organization](https://github.com/artsy/ezel#project-vs-apps-vs-components), and [asset pipeline](https://github.com/artsy/ezel#asset-pipeline) docs.

It's also worth noting: To avoid CSS spagetti we followed a simple convention of namespacing all of our classes/ids by the app or component name it was a part of. This was inspired by a [blog post from Philip Walton](http://philipwalton.com/articles/css-architecture/).


## Success!

With this new architecture and set of Node tools we've seen enormous benefits compared to the pains of developing Backbone on a monolithic Rails project. Our mobile web experience is much better, we can render more content on the server for SEO and faster page loads, our test/build/deploy cycles went from hours to minutes, our dev onboarding time went from days to minutes, and overall dev happiness has significantly improved.

Follow us on [Github](https://github.com/artsy). It's an exciting time to be developing JavaScript apps and we will continue to open source our efforts wherever possible. I hope this has been helpful and please leave any questions or comments below.