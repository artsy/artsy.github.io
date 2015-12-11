---
layout: post
title: 'Work Offline More'
date: 2015-09-30T00:00:00.000Z
comments: false
categories: [ios, mobile, process, flow]
author: orta
---

Want to know what I love writing in a pull request? _Sorry this is such a big PR, but I was working offline…_ It is one of [the](https://github.com/artsy/Emergence/pull/23) [key](https://github.com/artsy/Emergence/pull/39) [reasons](https://github.com/artsy/Emergence/pull/45) I managed to get our [Artsy Shows TV](https://github.com/artsy/emergence) app released ahead of schedule with a looming unknown App Store [deadline](https://github.com/artsy/Emergence/issues?q=milestone%3A%221.0+Ship+to+Apple%22). Offering more time for polish like thumbnail image [pre-caching](https://github.com/artsy/Emergence/compare/84855a310d47e071419b52b78978d14d751ec4e0...40966752111a309a20b4878e00a1c8e27cb53261).

During the last week before shipping I was scheduled to get a H1B VISA stamp for my passport, which means a trip to London. London is basically a **million** miles away from where I occasionally live in Huddersfield. So I opted for a coach. On the 5 and a half hours of travel, I had gone from behind schedule to feature complete prototype. On the way back, I had started to remove the word prototype from what we were looking at.

I _always_ optimise to work offline on every iOS project. Here's some tips on how we do it in all our apps.

<!-- more -->

### Easiest way

Eigen, our biggest app, has a complicated relationship with our API. There are too many networking calls to effectively stub for development in the app, this I know because I wrote [the PR](https://github.com/artsy/eigen/pull/575) forcing us to stub all networking in tests.

I found a great workaround though: there is a tool for storing an entire networking session, so that you can use it again and get determinate results called [VCRURLConnection](http://cocoapods.org/pods/VCRURLConnection). This is normally done in tests but it can easily be used in your app code instead.

We already had an admin panel within our app. So I added the ability to start [saving the networking session](https://github.com/artsy/eigen/blob/06aeb6f7ce4b95155729aa37c36fddc54767931f/Artsy/View_Controllers/Admin/ARAdminSettingsViewController.m#L171-L206).

![Eigen Admin Panel](/images/2015-09-30-offline/eigen-admin.png)

When you hit save, every networking request is saved into memory, and then once you hit save, this is stored in a JSON file that the app will use that for all networking data on the next few runs.

### The "requires some work, but is worth it" way

[Moya](https://github.com/Moya/Moya) is a networking client we created where stubbed data is a first-class citizen. This means converting your app's networking from "uses the API" to "uses the [locally stored stubbed examples](https://github.com/artsy/eidolon/blob/master/Kiosk/App/StubResponses.m)." Is a quick change in your apps code.

### The "let's just get it done" way

When I was working offline on the coach, I took a technique we use for testing and applied it to our application code. We use an abstraction called network models that separates what you want vs. what the API does to get it. In the case of Emergence I created [requests](https://github.com/artsy/Emergence/blob/18e501a4d6925ea5fb0f35174a6c0c3c96f70533/Emergence/Contexts/Presenting%20a%20Show/ShowNetworkingModel.swift) that would pass along stubbed models instead of doing the real work.

It's nothing fancy, but I didn't need too much to work with at this point. It's enough to start building, which is what counts, you can go and test properly once you're online.

### Motivation

I don't use 3G on my phone, I rely entirely on Wi-Fi for internet access, and don't particularly have a problem with the lack of connection. The outside world is distracting enough. Being able to work offline means I can shut the world out for a while and just focus on getting something done.

It's possible to not just have less distractions, but to be able to work faster. `VCRURLConnection` and using stubs are faster than normal networking, so you can iterate faster on your app, too.

True to my word, I'm writing this blog post offline, I have 7 hours and 23 more minutes before the plane lands in JFK.

I'm going to use the rest of this time to try ship something hard.

`<edit>`I built this: [artsy/energy/pull/86](https://github.com/artsy/energy/pull/86). `</edit>`
