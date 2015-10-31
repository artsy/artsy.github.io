---
layout: post
title: "ARAnalytics - Analytics for iOS Apps"
date: 2013-04-10 17:23
comments: true
categories: [iOS, Analytics, ARAnalytics]
author: orta
---

In both my [personal apps](http://orta.github.com) and Artsy Folio, I'm always after a deeper understanding of how people use the app. There's three ways to do this: ask users, watch users and track usage. I'd like to talk about the third of these.

We've experimented with quite a lot of analytics tools for the Artsy website, and it seemed fitting to do the same for our mobile app. We wanted the freedom to change the analytics tool without having to change the code, and so [ARAnalytics](http://github.com/orta/ARAnalytics) was born.

<!-- more -->

ARAnalytics is the adaption of [Analytical](https://github.com/jkrall/analytical) and  [Analytics.js](http://segmentio.github.com/analytics.js/) to iOS. By using [Cocoapods](http://cocoapods.org) it became possible to set up the entire analytics stack with only a few lines of code in your `Podfile`.

``` ruby
  pod "ARAnalytics/Crashlytics"
  pod "ARAnalytics/Mixpanel"
```

The list of supported libraries is pretty vast ( _TestFlight, Mixpanel, Localytics, Flurry, Google Analytics, KISSMetrics, Countly, Crittercism, Bugsnag and Crashlytics_ ) and the API for `ARAnalytics` tries to bridge any gaps it can find in the implementations.

`ARAnalytics` simplifies the API to two main parts of tracking; user details and events. User details are things like your internal ID for a user, and custom properties like your app's preferences, whilst events are temporal actions that are triggered based off user actions.

There is another tool worth mentioning and that is [Analytics](http://cocoadocs.org/dosets/Analytics/0.0.5/) which is a new port of Analytics.js which does a similar _simple API to different analytics providers_ but works by offloading the work to the server. I think there are advantages and disadvantages to both of these approaches, but I think one or the other should cover nearly all use cases!

ARAnalytics is available on Github at [orta/ARAnalytics](http://github.com/orta/ARAnalytics) and documented on [Cocoadocs](http://cocoadocs.org/docsets/ARAnalytics/1.2/) (which Artsy proudly sponsors!)
