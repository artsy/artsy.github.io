---
layout: post
title: "We open sourced our Isomorphic Javascript website"
date: 2014-09-05 15:09
comments: true
categories: [Isomorphic, JavaScript, Node.js, Shared, Ezel, Open Source, ]
author: Craig Spaeth & Brennan Moore
github-url: https://www.github.com/artsy
twitter-url: http://twitter.com/artsy
---

![May The Force be With You](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/force.png)

At Artsy we've been in the process of re-writing our entire web front-end to move off Rails and on to a [Node.js](http://nodejs.org/) stack that shares Javascript code and rendering between the server and client, otherwise known as [Isomorphic Javascript](http://nerds.airbnb.com/isomorphic-JavaScript-future-web-apps/). We've successfully fully migrated to this new stack and not only have we open sourced our boilerplate, [Ezel](http://ezeljs.com),  but we've gone a step further.

Today we're happy to announce the entire Artsy.net desktop web app, [Force](https://github.com/artsy/force-public), is completely open source!

<!-- more -->

Hopefully this serves as an example of how we structured a large [Ezel](http://ezeljs.com) project. Unfortunately due to image licensing issues we cannot open up the Artsy API and therefore this repo currently can't serve as an actual runnable clone of our website. However, we'll continue to merge our production code into it and if you have any question feel free to hit us up on twitter: [@craigspaeth](https://twitter.com/craigspaeth), [@dzucconi](https://twitter.com/dzucconi), [@zamiang](https://twitter.com/zamiang).

## We learned a couple things

Our transition to an isomorphic Javascript stack has been very successful albeit with some speed bumps. If you're interested in the details we've written [a blog post](http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/), given a talk at [Node on the Road](https://www.joyent.com/developers/videos/node-js-on-the-road-nyc-craig-spaeth-brennan-moore) (slides [here](http://www.slideshare.net/craigspaeth/artsy-node-on-the-roady-slides)), and another more extensive talk at [this meetup](http://www.hakkalabs.co/articles/monolithic-to-distributed-how-artsy-transitioned-from-ruby-on-rails-to-node-js-and-isomorphic-javascript#).

## Modularity

[![Nathan Sawaya, Red Head, 2009](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/sawaya.jpg)](https://artsy.net/artwork/nathan-sawaya-red-head)

One of the biggest takeaways from the transition is the pleasure of modularity. By breaking our project up into smaller reusable pieces such as [apps & components](https://github.com/artsy/ezel#project-vs-apps-vs-components) we make it easier to refactor independently and expirement with confidence knowing our code is encapsulated.

For instance we recently redesigned our about page. To gradually introduce this we forked our about app into an about2 app which you can see [a little back in Force's history](https://github.com/artsy/force-public/tree/0d5a49da08e94a91b3f23c7cd1005c1e83da7ba5/apps). This let us push code behind an admin-only page and when it was time to introduce the new about page we simply deleted the old about app and search and replaced "about2" to "about".

[Components](https://github.com/artsy/ezel#components) are particularly useful for re-usability. For instance building [this gene page](https://artsy.net/gene/abstract-expressionism) (source code [here](https://github.com/artsy/force-public/tree/master/apps/gene)) was mostly a matter of pulling in  various components like a [follow button](https://github.com/artsy/force-public/tree/master/components/follow_button), a [filter](https://github.com/artsy/force-public/tree/master/components/filter) component, this [artist fillwidth layout](https://github.com/artsy/force-public/tree/master/components/artist_fillwidth_list), and more.

We're so convinced this encapsulation is important that we've updated Ezel to [use app/component-level public folders](https://github.com/artsy/ezel/tree/master/src/js-example/apps/commits/public/images) so you can keep your static assets [cohesive](http://www.wikiwand.com/en/Cohesion_(computer_science)) with their respective apps/components.

## Open Source by Default

![Ocotcat](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/octocat.jpg)

Even though Force isn't a useful library that can be used by the community at large we're hoping it serves as a nice reference for how we structure some of our apps. Unless there's something sensitive like licensed fonts, or API keys/secrets checked into the repo there's no reason we need to privatize our code so we'll open source Artsy app-specific modules like [these backbone mixins](https://github.com/artsy/artsy-backbone-mixins) [this Artsy API authentication library](https://github.com/artsy/artsy-passport), or [this module we use to cache server-side Backbone requests](https://github.com/artsy/backbone-cache-sync).

We wanted to spread this open-source-by-default culture. After discovering we needed to privatize our configuration with sensitive keys/secrets to make Force open source we decided to update Ezel's config approach to use a .env file for configuration. This makes it easy to privatize your sensitive config data and allow the rest of your app code to be open source. You can read more about this in [Ezel's Build Scripts & Configuration docs](https://github.com/artsy/ezel#build-scripts--configuration).

## Spread The Love

We're excited to continue pushing open source at Artsy and hope 