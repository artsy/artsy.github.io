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
author: Orta Therox
github-url: 'https://www.github.com/orta'
twitter-url: 'http://twitter.com/orta'
blog-url: 'http://orta.io'
---

As a part of going through the design patterns we've found in the creation of the Artsy iOS apps, I'd like to talk a bit about Hybrid Applications. A hybrid application refers to an app that uses native code and web content intertwined. Our flagship iOS app, [eigen](https://github.com/artsy/eigen) is a hybrid app, and it seems to get more and more hybrid-y each release. Let's talk a little bit about the pros and cons of this. <!-- more -->

----

### What is a Hybrid App

I gave the widest possible definition above, so let's dig in as this can be a contentious. There is a whole spectrum of which an app can be classed as a hybrid app. This ranges from; more or less web-tech everywhere to 100% Objective-C.

A great example of the furthest to the web-side is [ATOM](https://atom.io), the text editor. It's on the extreme side because all of the user interface is built using HTML + CSS, and almost all of the app is in javascript. The trade-off for them is that they can easy write cross-platform code, that will work reliably with technology that the vast majority of programmers use.

An example of a purely native application would be [Energy](https://github.com/artsy/energy/). It is a hundred thousand plus lines of Objective-C. Yet under the hood, there's definitely some web-tech there. Prior to iOS7 nearly all `UILabel`s, `UITextField`s and `UITextField`s [used WebKit for rendering](http://www.objc.io/issues/5-ios7/getting-to-know-textkit/). Not to mention that when a Partner send's an email via Energy, the editor is a `UIWebView`. However, from the app developer's perspective they are creating native interactions that act consistent with the rest of the operating system.

### Eigen

When we started building Eigen, it was very obvious that we had a Sisyphean task ahead of us. We wanted to take the core ideas of the Artsy website, _The Art World Online_ and convert it into Mobile, _The Art World in Your Pocket_.

That's not impossible, but the mobile team was a fraction of the Artsy development team. Any new features added to the website would need a mobile equivalent, and given the speed in which web developer's can ship, we'd need to outnumber them to stand a chance at keeping up.

So, we opted for building a highly integrated mobile website at the same time, it would use the same design language as the iOS app and can act as a way for Android device to access Artsy.

### Techniques for doing it well

So we'll be talking about our [`ARInteralMobileViewContrller`](https://github.com/artsy/eigen/blob/6bb44a01c1b23fb8e92c645c3091fd33725743c3/Artsy/View_Controllers/Web_Browsing/ARInternalMobileWebViewController.m) - which currently relies on `UIWebView` but is in [the process of](https://github.com/artsy/eigen/pull/606) migrating to `WKWebkit`.

* Scroll like an [iOS app](https://github.com/artsy/eigen/blob/6bb44a01c1b23fb8e92c645c3091fd33725743c3/Artsy/View_Controllers/Web_Browsing/ARExternalWebBrowserViewController.m#L39) by setting the web view's `scrollView.decelerationRate = UIScrollViewDecelerationRateNormal`.

* Use a simple design language to avoid the [uncanny valley](http://tvtropes.org/pmwiki/pmwiki.php/Main/UncannyValley). Using different typographical rules on tabs, buttons or switches makes

* Take over navigation. This means pushing a [new view controller](https://github.com/artsy/eigen/blob/6bb44a01c1b23fb8e92c645c3091fd33725743c3/Artsy/View_Controllers/Web_Browsing/ARInternalMobileWebViewController.m#L180) on the navigation stack every time a user intends to change context.

* Take over common OS features. We take over [social sharing](https://github.com/artsy/eigen/blob/master/Artsy/View_Controllers/Web_Browsing/ARInternalMobileWebViewController.m#L184-L190)  instead of letting the web site send you to an external page, offering a native share sheet instead.

### Downsides

When you choose developer ease over user experience it's important to take into consideration some of the downsides.

* Localisation is difficult. Cocoa offers a great localisation APIs. We can't use them, otherwise half of our app is correctly localised and the rest isn't.

* OS features like [Dynamic Type](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/TransitionGuide/AppearanceCustomization.html) are also a no-go.

* Conforming to the Operating System's Human Interface Guidelines is more difficult, as you're relying less on foundations built with this in mind.

* Web tech is slower, and threading APIs are generally poor. A dfficulty here is that you are also complicating the technical stack upon which [your app sits above](https://twitter.com/sandofsky/status/634129798936162308).

The fact that we were able to ship an app at all was because we could build the most important parts native, then rely on web technologies to cover the rest of the ground.

The nature of doing it this way comes with trade-offs, ones that we've been willing to make so far. 
