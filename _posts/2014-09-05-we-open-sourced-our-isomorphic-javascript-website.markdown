---
layout: post
title: "We open sourced our Isomorphic Javascript website"
date: 2014-09-05 15:09
comments: true
categories: [Isomorphic, JavaScript, Node.js, Shared, Ezel, Open Source, force]
author: [craig, brennan]
---

![May The Force be With You](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/force.png)

Today we're happy to announce we've open sourced the entire Artsy.net web app, [Force](https://github.com/artsy/force).

Over the past few months, we've rewritten our web front-end to move off Rails and on to a [Node.js](http://nodejs.org/) stack that shares Javascript code and rendering between the server and client, otherwise known as [Isomorphic Javascript](http://nerds.airbnb.com/isomorphic-JavaScript-future-web-apps/). After migrating to this new stack, we open-sourced our boilerplate, [Ezel](http://ezeljs.com), and have now gone a step further and open sourced Artsy.net.

<!-- more -->

## Isomorphic vs Monolithic

Our transition to an isomorphic Javascript stack has been very successful albeit with some speed bumps. If you're interested in the details we've written [a blog post](http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/), given a talk at [Node on the Road](https://www.joyent.com/developers/videos/node-js-on-the-road-nyc-craig-spaeth-brennan-moore) (slides [here](http://www.slideshare.net/craigspaeth/artsy-node-on-the-roady-slides)), and another more extensive talk at [this meetup](http://www.hakkalabs.co/articles/monolithic-to-distributed-how-artsy-transitioned-from-ruby-on-rails-to-node-js-and-isomorphic-javascript#).

The short story is that we moved from a monolithic rails app to a couple of Node servers on Heroku. This vastly improved the performance of our site and our own development speed. Using the patterns in Ezel, we are able to tailor assets packages to specific pages and render some of the page on the server. This cut our page-load in half (from 6.5 seconds to under 3 seconds) and our tests take about 5 minutes (down from around 5 hours!) with little reduction in coverage. Performance numbers aside, our real win was dramatically improved development speed due to some architecture decisions we made.

## Modularity

[![Nathan Sawaya, Red Head, 2009](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/sawaya.jpg)](https://artsy.net/artwork/nathan-sawaya-red-head)

One of the biggest takeaways from the transition is the pleasure of modularity. By breaking our project up into smaller reusable pieces such as [apps & components](https://github.com/artsy/ezel#project-vs-apps-vs-components) we make it easier to experiment, test, and refactor with confidence knowing our code is encapsulated into clearly defined pieces.

For instance, we recently redesigned our [about](https://artsy.net/about) page. To gradually introduce the new page, we simply started a new about2 app along side our old about app which you can see [a little back in Force's history](https://github.com/artsy/force/tree/0d5a49da08e94a91b3f23c7cd1005c1e83da7ba5/apps). This let us push code into the new about2 app with confidence it wasn't touching other parts of the stack. When it was time to ship it, we simply deleted the old about app folder and search and replaced "about2" to "about". There was no need to dig around various stylesheets, views, etc. folders looking for places where code for the old about page might still live.

[Components](https://github.com/artsy/ezel#components) are particularly useful for re-usability. For instance building [this gene page](https://artsy.net/gene/abstract-expressionism) (source code [here](https://github.com/artsy/force/tree/master/apps/gene)) was mostly a matter of pulling in various components like a [follow button](https://github.com/artsy/force/tree/master/components/follow_button), a [filter](https://github.com/artsy/force/tree/master/components/filter) component, this [artist fill-width layout](https://github.com/artsy/force/tree/master/components/artist_fillwidth_list), etc. Because the CSS for those components are clearly self-contained it's easy to build up a small asset package that uses only the minimal CSS needed which you can see [here](https://github.com/artsy/force/blob/master/assets/gene.styl).

We're so convinced this encapsulation is important that we've updated Ezel to [use app/component-level public folders](https://github.com/artsy/ezel/tree/master/src/js-example/apps/commits/public/images) by default so you can even modularize static assets, like images, and keep them coupled with their respective apps/components.

## Open Source by Default

![Ocotcat](/images/2014-09-05-we-open-sourced-our-isomorphic-javascript-website/octocat.jpg)

Even though Force isn't a library, we have open-soured many of its components and libraries. Before open sourcing Force, we open sourced app-specific modules such as [these backbone mixins](https://github.com/artsy/artsy-backbone-mixins) [this Artsy API authentication library](https://github.com/artsy/artsy-passport), or [this module](https://github.com/artsy/backbone-cache-sync) we use to cache server-side Backbone requests.

Open-sourcing Force was pretty straightforward but we needed to make our sensitive keys/secrets private while not complicating development. To do this we wrote a .env file and uploaded it as a private gist that gets downloaded when setting up the app. We wanted to spread this open-source-by-default culture so we decided to update Ezel's configuration to be able to use a .env file in this way as well. This makes it easy keep your sensitive configuration data private while allowing the rest of your app code to be open source. You can read more about this in Ezel's [Build Scripts & Configuration docs](https://github.com/artsy/ezel#build-scripts--configuration).

## Spreading The Love

Force serves as an example of how we structured a large [Ezel](http://ezeljs.com) project and contains the full commit history of its construction. Unfortunately, due to image licensing issues, we cannot open up the Artsy API and therefore this repository can't serve as a runnable clone of our website. However, we will continue to merge our production code into it. If you have any questions feel free to hit us up on twitter: [@craigspaeth](https://twitter.com/craigspaeth), [@dzucconi](https://twitter.com/dzucconi), [@zamiang](https://twitter.com/zamiang).

We're excited to continue pushing open source at Artsy. For more exciting open source projects take a look at [our GitHub profile](https://github.com/artsy).
