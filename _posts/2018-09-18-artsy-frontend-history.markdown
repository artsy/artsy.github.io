---
layout: epic
title: "A History of Artsy's Web Frontend"
date: 2018-09-18
author: ash
categories: [react, ezel, javascript, force, architecture, best practices]
---

As Artsy Engineering grows this in 2018, we have so many newcomers looking for context: they want to understand the
systems they'll be working in day-to-day. Awesome! But it's not enough to understand the systems themselves, it's
often helpful to understand the _history_ of how we ended up where we are. In an effort to help contextualize our
web frontend (which is [open source][force]), this blog post will document the major transitions that Artsy's web
presence has made over the past seven years. Let's begin!

<!-- more -->

## Backbone + CoffeeScript

Artsy as you know it today began as a standard Rails application. We ran `git init` in January 2011, which coupled
our backend API to our web frontend, but since our frontend was just a fancy user interface for our API, this
worked for over two years. The web app itself was a kind of simplified MVC – controller logic lived inside the
views and models dealt with backend communication and notifying the view of state changes. For CSS, we used the
SASS CSS preprocessor. The Rails backend served initial pages that were then populated with follow-up API calls
made on the client-side. At a _very_ high level, this isn't _that_ different from what we do today with React.

Our site was built with a framework called [Backbone][], which was really well-suited for our needs at the time.
From their documentation:

> Philosophically, Backbone is an attempt to discover the minimal set of data-structuring (models and collections)
> and user interface (views and URLs) primitives that are generally useful when building web applications with
> JavaScript. In an ecosystem where overarching, decides-everything-for-you frameworks are commonplace, and many
> libraries require your site to be reorganized to suit their look, feel, and default behavior — Backbone should
> continue to be a tool that gives you the _freedom_ to design the full experience of your web application.

As an outsider to the web at that time, I can't comment too heavily on Backbone. It seems like the freedom
(emphasis theirs) that they describe is a freedom from tangled jQuery code everywhere. I think our definition of
freedom on the web frontend has evolved since then, but that's just my feeling.

The other key component to our web frontend was [CoffeeScript][]. According to its documentation, "CoffeeScript is
a little language that compiles into JavaScript", which was pretty important at the time. JavaScript in 2011 is
very different from JavaScript today. The CoffeeScript docs also state that "JavaScript has always had a gorgeous
heart", which I'm not sure I'd agree with to be honest, but the CoffeeScript project really shows how a handful of
engineers working to improve something they care about can change and entire industry. While I don't think
contemporary JavaScript would have gotten as good as it has without CoffeeScript, it's a bit anachronistic to see
it used today.

Our goal as a (very small!) engineering team at the time was to keep our moving parts to a minimum.
Rails+SASS+CoffeeScript+Backbone helped us achieve that goal, and we couldn't have gotten this far without the help
of those projects.

## Ezel

In November 2013, we split our web frontend from the API backend. You can read
[all the details in this blog post](2013_review), but the story is summarized nicely as "moving from a single
monolithic application to modular Backbone apps that run in Node and the browser and consume our external API."
This move from monolith to modular systems continues to influence day-to-day work on the Artsy Engineering team.

We moved our API from Rails to [Grape][], partially motivated by a desire to build an iOS application that would
consume this API. We faced a lot of problems with the split, including SEO problems, severe page load times,
maintaining duplicated backend and frontend UI templates, slow test suites, and poor developer productivity. We
took the project of building our mobile web frontend, m.artsy.net (still known as "martsy" internally) as an
opportunity to address these problems.

We built our new site with [Node.js][node] since it easily allowed server-side rendering. We split out areas of
concern into separate "apps", with their own bundled CSS/JS to help page load times. We server-side rendered
above-the-fold content and used client-side JS to load the rest, which helped SEO and user experience. We took a
[BEM][]-like approach to our CSS, which helped developer productivity. Our technical decisions were driven
primarily by our desire to create great user experiences.

And because we are an open source by default organization, we collected these approaches into an open source
project called [Ezel][].

We used Ezel for a few years without too much change in our web frontend stack. It proved really useful for helping
build other web apps – CMS systems for our partners, auction-management systems for our admins, all kinds of
projects – and most of those projects started on Heroku before moving to our Ops Works stack as needed. Our
frontend mindset at the time (2015) was focused on getting to a stable, predictable stack. However... we started
experimenting with React around the same time.

CoffeeScript and Backbone were still working for us, and we still use them in production in many systems. However,
the state of the art in web development moved on. When I joined the auctions team and helped maintain one of our
CoffeeScript+Backbone apps, I was _very_ confused about how data flowed from one part of the app to another, across
languages, with a lot of magic happening. I think that's typical in these kinds of apps – "convention over
configuration" is a good mantra _if_ you can expect that incoming engineers are familiar with the conventions.
That's just not the case anymore.

By 2016, we launched our [first app built with React][auctions], which both proved the technology was ready for
production use _and_ convinced our engineers that React is simply a better paradigm for building user interfaces.

## React

By 2017, the divisions between our mobile frontend and web frontend teams had been totally dissolved (as they
should – the division between mobile and web developers is a false dichotomy). Our [2017 tech stack
post][2017_review] discusses this in depth, but our goal was really to unify the paradigm that frontend engineers
at Artsy use to build user interfaces, whether that's on mobile or web. React and React Native were our answer to
that challenge.

TODO: stitch, typescript, palette, reaction, etc

[force]: https://github.com/artsy/force
[backbone]: http://backbonejs.org
[coffeescript]: https://coffeescript.org
[grape]: https://github.com/ruby-grape/grape
[node]: https://github.com/ruby-grape/grape
[bem]: http://getbem.com/introduction/
[ezel]: https://github.com/artsy/ezel
[2013_review]: http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/
[2017_review]: http://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017/
[auctions]: http://artsy.github.io/blog/2016/08/09/the-tech-behind-live-auction-integration/
