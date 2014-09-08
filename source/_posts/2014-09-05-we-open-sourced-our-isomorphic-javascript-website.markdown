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

Hopefully this serves as an example of how we structured a large [Ezel](http://ezeljs.com) project. Unfortunately due to image licensing issues we cannot open up the Artsy API and therefore this repo currently can't serve as an actual runnable clone of our website. However, we'll continue to merge our production code into it and if you have any questions feel free to hit us up on twitter: [@craigspaeth](https://twitter.com/craigspaeth), [@dzucconi](https://twitter.com/dzucconi), [@zamiang](https://twitter.com/zamiang).

## We learned a couple things

Our transition to an isomorphic Javascript stack has been very successful albeit with some speed bumps. If you're interested in the details we've written [a blog post](http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/), given a talk at [Node on the Road](https://www.joyent.com/developers/videos/node-js-on-the-road-nyc-craig-spaeth-brennan-moore) (slides [here](http://www.slideshare.net/craigspaeth/artsy-node-on-the-roady-slides)), and another more extensive talk at [this meetup](http://www.hakkalabs.co/articles/monolithic-to-distributed-how-artsy-transitioned-from-ruby-on-rails-to-node-js-and-isomorphic-javascript#).

## Modularity

[![Nathan Sawaya, Red Head, 2009](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/sawaya.jpg)](https://artsy.net/artwork/nathan-sawaya-red-head)

One of the biggest takeaways from the transition is the pleasure of modularity. By breaking our project up into smaller reusable pieces such as [apps & components](https://github.com/artsy/ezel#project-vs-apps-vs-components) we make it easier to expiriment, test, and refactor with confidence knowing our code is encapsulated into clearly defined pieces.

For instance we recently redesigned our about page. To gradually introduce this we simply started a new about2 app along side our old about app which you can see [a little back in Force's history](https://github.com/artsy/force-public/tree/0d5a49da08e94a91b3f23c7cd1005c1e83da7ba5/apps). This let us push code into the new about2 app with confidence it wasn't touching other parts of the stack. When it was time to ship it, we simply deleted the old about app folder and search and replaced "about2" to "about". There was no need to dig around various stylesheets, views, etc. folders looking for places where code for the old about page might still live.

[Components](https://github.com/artsy/ezel#components) are particularly useful for re-usability. For instance building [this gene page](https://artsy.net/gene/abstract-expressionism) (source code [here](https://github.com/artsy/force-public/tree/master/apps/gene)) was mostly a matter of pulling in various components like a [follow button](https://github.com/artsy/force-public/tree/master/components/follow_button), a [filter](https://github.com/artsy/force-public/tree/master/components/filter) component, this [artist fillwidth layout](https://github.com/artsy/force-public/tree/master/components/artist_fillwidth_list), etc. Because the CSS for those components are clearly self-contained it's easy to build up a small asset package that uses only the minimal CSS needed which you can see [here](https://github.com/artsy/force-public/blob/master/assets/gene.styl).

We're so convinced this encapsulation is important that we've updated Ezel to [use app/component-level public folders](https://github.com/artsy/ezel/tree/master/src/js-example/apps/commits/public/images) by default so you can even modularize static assets, like images, and keep them coupled with their respective apps/components.

## Open Source by Default

![Ocotcat](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/octocat.jpg)

Even though Force isn't a library that can be leveraged by the community at large, we're hoping it serves as a nice reference for how we structure some of our apps. Unless there's something sensitive like licensed fonts, or API keys/secrets checked into the repo there's no reason we need to privatize our code. We'll even open source Artsy app-specific modules like [these backbone mixins](https://github.com/artsy/artsy-backbone-mixins) [this Artsy API authentication library](https://github.com/artsy/artsy-passport), or [this module](https://github.com/artsy/backbone-cache-sync) we use to cache server-side Backbone requests.

To make Force open source we needed to privatize our configuration defaults so as to not expose sensitive keys/secrets it in our public repo. To do this we wrote a .env file and uploaded it as a private gist that gets downloaded when setting up. We wanted to spread this open-source-by-default culture so we decided to update Ezel's configuration to be able to use a .env file in this way as well. This makes it easy to privatize your sensitive config data and allow the rest of your app code to be open source. You can read more about this in Ezel's [Build Scripts & Configuration docs](https://github.com/artsy/ezel#build-scripts--configuration).

## Spreading The Love

We're excited to continue pushing open source at Artsy. For more exciting open source projects take a look at [our Github profile](https://github.com/artsy).