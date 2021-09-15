---
layout: post
title: 'Cocoa Architecture: Hybrid Apps'
date: 2015-08-24T00:00:00.000Z
comments: false
categories:
  - ios
  - mobile
  - architecture
  - eigen
  - hybrid
author: orta
series: Cocoa Architecture
---

As a part of going through the design patterns we've found in the creation of the Artsy iOS apps, I'd like to talk a bit about _Hybrid Applications_. A hybrid application refers to an app that uses native code and web content intertwined. Our flagship iOS app, [eigen](https://github.com/artsy/eigen) is a hybrid app, and it seems to get more and more hybrid-y each release. Let's talk a little bit about the pros and cons of this approach.

<!-- more -->
--------------------------------------------------------------------------------

# What is a Hybrid App
Above is the widest possible definition above, so let's dig in as this can be a contentious. There is a whole spectrum of which an app can be classed as a hybrid app. This ranges from more or less web-tech everywhere to 100% native code like Objective-C / Swift.

A great example of the furthest to the web-side is [ATOM](https://atom.io), the text editor. It's on the extreme side because all of the user interface is built using HTML + CSS, and almost all of the app is in javascript. The trade-off for them is that their developers can easy write cross-platform code, that will work reliably with technology that the vast majority of programmers use. This vastly reduces the barrier to entry for contributors and gives ATOM a really large community of programmers to draw from with respect to extending the app.

An example of a purely native application would be [Energy](https://github.com/artsy/energy/). It's over a hundred thousand plus lines of Objective-C. Yet under the hood, there's definitely some web-tech there. Prior to iOS7 `UILabel`s, `UITextField`s and `UITextField`s [used WebKit for rendering](http://www.objc.io/issues/5-ios7/getting-to-know-textkit/). Not to mention that when a Partner sends an email via Energy, the editor is a `UIWebView`. However, from the app developer's perspective they are creating native interactions that are consistent with the rest of the operating system's behavior.

# Eigen
When we started building Eigen, it was very obvious that we had a Sisyphean task ahead of us. We wanted to take the core ideas of the Artsy website,  _The Art World Online_, and convert it into mobile, _The Art World in Your Pocket_.

That's not impossible, but the mobile team was a fraction of the Artsy development team. Any new features added to the website would need a mobile equivalent, and given the speed in which web developer's can ship, we'd need to outnumber them to stand a chance at keeping up.

So, we opted for building a highly integrated mobile website at the same time, it would use the same design language as the iOS app and can act as a way for Android devices to access Artsy.

# Techniques for Doing It Well
So we'll be talking about our [ARInteralMobileViewController](https://github.com/artsy/eigen/blob/6bb44a01c1b23fb8e92c645c3091fd33725743c3/Artsy/View_Controllers/Web_Browsing/ARInternalMobileWebViewController.m) - which currently relies on `UIWebView` but is in [the process of](https://github.com/artsy/eigen/pull/606) migrating to `WKWebkit`.

- Scroll like an [iOS app](https://github.com/artsy/eigen/blob/6bb44a01c1b23fb8e92c645c3091fd33725743c3/Artsy/View_Controllers/Web_Browsing/ARExternalWebBrowserViewController.m#L39) by setting the web view's `scrollView.decelerationRate = UIScrollViewDecelerationRateNormal`.

- Use a simple design language to avoid the [uncanny valley](http://tvtropes.org/pmwiki/pmwiki.php/Main/UncannyValley). Care about using the same [typographical rules](https://github.com/artsy/Artsy-UILabels) on everything including tabs, buttons and switches.

- Take over navigation. This means pushing a [new view controller](https://github.com/artsy/eigen/blob/6bb44a01c1b23fb8e92c645c3091fd33725743c3/Artsy/View_Controllers/Web_Browsing/ARInternalMobileWebViewController.m#L180) on the navigation stack every time a user intends to change context.

- Take over common OS features. We take over [social sharing](https://github.com/artsy/eigen/blob/master/Artsy/View_Controllers/Web_Browsing/ARInternalMobileWebViewController.m#L184-L190)  instead of letting the web site send you to an external page, offering a native share sheet instead.

# Downsides
When you choose developer ease over user experience it's important to take into consideration some of the downsides.

- Localisation is difficult. Cocoa offers a great localisation APIs. We can't use them, otherwise half of our app is correctly localised and the rest isn't.

- Conforming to the operating system's Human Interface Guidelines is difficult, as you're relying less on foundations built with this in mind.

- Web tech is slower, and threading APIs are generally poor. A difficulty here is that you are also complicating the technical stack upon which your app sits above. When relying on web-tech in a Mac app, it's common for that trade-off to show itself in excessive memory usage over time.

# Evolution
One of the most interesting developments this year in the Cocoa world is Facebook's [react-native](https://cocoapods.org/pods/React), a bridge between web technology and native code that doesn't rely on using the [traditional DOM](http://www.quirksmode.org/dom/intro.html) - freeing it from a lot of the common problems found in highly web-based apps.

We're pretty optimistic about it on the mobile team. We're not quite willing to jump head-first into a [pre-1.0 technology](http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/) again, but it shows a lot of promise.

The fact that we were able to ship an app at all was because we could build the parts that meant the most to us native, then rely on web technologies to cover the rest of the ground. By being pragmatic in our approach to using web tech, we have the chance to stand on the shoulders of giants.
