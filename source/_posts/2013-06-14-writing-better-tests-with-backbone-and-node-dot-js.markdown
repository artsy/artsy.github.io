---
layout: post
title: "Writing Better Tests With Backbone and Node.js"
date: 2013-06-14 17:48
comments: true
categories: [Javascript, Backbone.js, Node.js]
---

# Outline
* Brief History
  * Started off Rails, added Backbone, added grape
  * Added Jasmine, added capybara[blog post]
  * Growing pains: tests too slow
  * A chance to reboot
    * Built CMS and Admin panel, moved to node.js
    * Thick-client testing out the gate
    * Tests run headless ~60x faster, way more unit test coverage
* Writing unit tests in node.js
  * self-contained modular code, minimum globals
  * Setup an environment in jsdom
  * require or stub global dependencies
  * stub ajax
* Writing integration tests in node.js
  * zombie.js
  * conditional logic in app server to swap API
* Pro tips
  * separate your tests
  * modularize all the things
  * use browserify/require/component/bower to bring modularity and package management to the client

## A Brief History

If you've been keeping up with this blog you may have figured out that Artsy is a thick client [Backbone.js](http://backbonejs.org/) app sitting on top of [Rails](http://rubyonrails.org/) and consuming a [Grape](https://github.com/intridea/grape) JSON API. Getting to this point involved many growing pains, one of the biggest being testing a thick-client javascript application in a thick-server ruby framework.

We started off as a very conventional thick-server Rails app, but once we realized our javascript code was growing in complexity we needed some tools to untangle our code and avoid that dreaded jQuery spaghetti. We adopted Backbone + [Jammit](http://documentcloud.github.io/jammit/) and soon the next question was how to test this. First we used [Jasmine](https://github.com/searls/jasmine-rails) which easily integrated with Rails. This was a good start, but at the time was quite a challenge to wrap our thick-client newbie heads around how to integrate and write testable js code. Our search continued for alternative client-side coverage and so followed `gem install capybara`.

[Capybara](http://jnicklas.github.io/capybara/) is a [Selenium](http://docs.seleniumhq.org/) backed DSL that quickly got us writing integration tests and was easy to use. Of course the sweet taste of human-readable instructions for a browser in time turned sour the slower and more brittle our test suite became. Even so, [we've been able to wrangle Capybara](http://artsy.github.io/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/) to do most of our UI testing, but there has always been a lurking feeling there must be a better way.

That better way came to us when building out a separate CMS application for our gallery partners to upload and manage their own Artsy content. The result was another thick-client Backbone app consuming our Grape API, but this time backed by node.js. Testing was built to handle thick-client javascript out of the gate, resulting in a headless test suite that runs 60 times faster, easier to integrate and debug, and far more unit test coverage.

## Writing javascript unit tests in node.js

Backbone modularizes your code into sensible components that provide structure to your app. This modularization is the key to writing good code that can be tested independently (otherwise known as unit testing).

...