---
layout: post
title: 'Work Offline More'
date: 2015-09-30T00:00:00.000Z
comments: false
categories:
  - ios
  - mobile
  - process
  - flow
author: Orta Therox
github-url: 'https://www.github.com/orta'
twitter-url: 'http://twitter.com/orta'
blog-url: 'http://orta.io'
---

Want to know what I love writing in a pull request? _Sorry this is such a big PR, but I was working offline…_ It is one of the key reasons I managed to get our Artsy Shows TV app released ahead of schedule with a looming unknown App Store deadline. Offering more time for polish like thumbnail image pre-caching.

During the last week before shipping I was scheduled to get a H1B VISA stamp for my passport, which means a trip to London. London is basically a **million** miles away from where I occasionally live in Huddersfield. So I opted for a coach. On the 5 and a half hours of travel, I had gone from behind schedule to feature complete prototype. On the way back, I had started to remove the word prototype from what we were looking at.

I _always_ optimise to work offline on every iOS project. Here's some tips on how we do it in all our apps.

<!-- more -->

### Easiest way

Eigen, our biggest app, has a complicated relationship with our API. There are too many networking calls to effectively stub for development in the app, this I know because I wrote [the PR](LINKTOPR) forcing us to stub all networking in tests.

I found a great workaround though, there is a tool for storing an entire networking session, so that you can use it again and get determinate results called [VCRURLConnection](http://cocoapods.org/pods/VCRURLConnection). This is normally done in tests but it can easily be used in your app code instead.

We already had an admin panel within our app. So I added the ability to start saving the networking session, then when you're done, to be able to save it and re-use that next time.

![Eigen Admin Panel](/images/2015-09-30-offline/eigen-admin.png)

### The "requires some work, but is worth it" way

[Moya](https://github.com/Moya/Moya) is a networking client we created where stubbed data is a first-class citizen. This means converting your apps networking from "uses the API" to "uses the locally stored stubbed examples." Is a quick change in your apps code.

### The "let's just get it done" way

When I was working offline on the coach, I took a technique we use for testing and applied it to our application code. In this case we were using RxSwift+Moya for networking, so we provided a different Observable chain instead. However, using something like Network Models would offer the same abstraction layer required to pull this off.

This passed along some stubbed objects that were made in the same class. Nothing fancy, but I didn't need too much to work with at this point.

### Motivation

I don't use 3G on my phone, I rely entirely on WIFI for internet access, and don't particularly have a problem with the lack of connection. The outside world is distracting enough. Being able to work offline means I can shut the world out for a while and just focus on getting something done.

It's possible to not just have less distractions, but to be able to work faster. `VCRURLConnection` and using stubs are faster than normal networking, so you can iterate faster on your app too.

True to my word, I'm writing this blog post offline, I have 7 hours and 23 more minutes before the plane lands in JFK.

I'm going to use the rest of this time to try ship something hard.

`<edit>`I built this: <a href="https://github.com/artsy/energy/pull/86">artsy/energy/pull/86</a>`</edit>`
