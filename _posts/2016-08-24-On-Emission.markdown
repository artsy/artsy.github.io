---
layout: epic
title: "On our implementation of React Native"
date: 2016-08-24 12:17
author: orta
categories: [tooling, mobile, eigen, node, reactnative]
series: React Native at Artsy
---

<center>
 <img src="/images/emission/emission-logo-artsy.svg" style="height:300px;margin-bottom: 60px;">
</center>

I arrived fashionably late to the [React Native party][architectual] in Artsy. I had been a part of our [Auctions Team][auctions_team], where we worked in Swift with [some light-FRP][interstellar]. We were not affected by the 4 months of simultaneous work on moving to React Native, at all.

It was a quiet revolution. I did not have to install `npm`, I made zero changes to the code for auctions and the whole app's infrastructure barely changed. Yet we moved to making all new code inside our 3 year old iOS app use React Native. What gives? 

Well, first up we weren't planning a re-write, we don't have that kind of luxury and the scope of our app is too big compared to the team working on it. Second, we reused existing dependency infrastructure to support JavaScript based apps. Read on to find out what that looks like.

<!-- more -->

### Why we were in a good position to do this

Let's talk a little about the Artsy flagship app, [Eigen][eigen]. It's an app that aimed to comprehensively cover the art world. From [Shows](https://www.artsy.net/shows) to [Galleries](https://www.artsy.net/galleries), [Fairs](https://www.artsy.net/art-fairs) to [Auctions](https://www.artsy.net/auctions), [Museums](https://www.artsy.net/institutions) to [Magazines](https://www.artsy.net/articles).

It all looks a bit like this: 

{% include epic_img.html url="/images/emission/eigen-overview.jpg" title="Overview of Emission" style="width:100%;" %}

Our app neatly splits into two areas of view controllers, ones that act as a browser chrome, and individual view controllers that normally map 1:1 to [routes][ar_router] on the Artsy website. 

For example, the route `artsy.net/artwork/glenn-brown-suffer-well` maps to the native `ARArtworkViewController`.

{% include epic_img.html url="/images/emission/eigen.svg" title="Overview of Eigen" %}

Just as a browser knows very little about the individual content of the pages that it's rendering, the eigen chrome exists _relatively_ independent of the view controllers that are showing. 

Each view controller also knows very little about each-other, so actions that trigger a new view controller are generally done by creating a string route and passing it through the routing system. I've wrote about this pattern in [Cocoa Architecture: Router Pattern][router_pattern]. 

Interestingly, if the router cannot route a view controller, it will pass through to a web view. This is why we consider the app a [hybrid app][hybrid_app]. This pattern means adding new view controllers is extremely easy.

### Introducing Emission

Emission is what we use to contain all of our React Native components. Our flagship app Eigen, can depend on and use without needing to bother with the implementation details of React Native. At it's core, Emission is:

- A node module.
- A CocoaPod.
- An iOS App.

#### The Node Module

Emission itself, is a node module. In our case, it is a JavaScript library that exposes 3 JavaScript objects.

``` javascript
/* @flow */
'use strict';

import Containers from './lib/containers';
import Components from './lib/components';
import Routes from './lib/relay/routes';

import './lib/relay/config';
import './lib/app_registry';

export default {
  Containers,
  Components,
  Routes,
};
```

Another node project can have Emission as a dependency - then can access our `Container`s, `Component`s and `Route`s. A container is a [Relay container][relay_cont], a component is a [React Component][react_component] and a Route is a [Relay Route][relay_route].

The thing that's interesting from the integration side, is that each `Container` is effectively a View Controller that Emission provides to a host application. React Native ignores  the concept of view controllers from the Cocoa world, so we have an [ARComponentViewController][arcomponent] which is subclassed for each exposed `Component` class. 

#### The iOS App

The iOS app acts as a host target for the CocoaPod, and provides an instance of an [AREmission][ar_emission] object to the view controllers using React Native. The app is nothing special, it is the default app that is created using `pod lib create`. We then [use CocoaPods][pods_emission] to bring in React from inside the `node_modules/` folder the Emission node module creates.

The `AREmission` instance is the intermediary between the host-app ([The Emission Example app][example_emission], or [Eigen][eigen_emission].) It has an API for handling routing, and passing authentication credentials into the React Native world.

We use the example app to do development inside React Native. As of right now, it is simply a tableview that provides a list of view controllers [that represent an exposed Container][app_delegate_cont]. Once you are in the right view controller, you can rely on [Hot Reloading][reloading] to simplify your work.

#### The Pod

An important part of working with React Native, is that you can choose to use native code when appropriate. The [Pod for][podspec] Emission, created entirely in Objective-C, provides:

* Communication between React Native and the host app objects via [native modules][native_modules].
* `UIViewController` subclasses for Host apps to consume.
* Bridges for existing native views (like our [SwitchView][switch_view]) into React Native.
 
The choice of Objective-C is for simplicity, and language stability. Swift is technically an option, but it's not  worth the complications for [a few simple objects][emission_pod_classes]. 

In order to share native views with our host app, Eigen, we created a library to just hold the shared UI components, [Extraction][extraction]. These are [factored out of Eigen][extraction_files], and into a pod. Emission and Eigen have this as a dependency.

#### Pod Deployment

What makes this work well, from the perspective of Eigen is that the React Native comes in atomically. The Podspec [references][emission_resource] the few native classes, and a single JavaScript file. 

This JavaScript file is the bundled version of all our React Native code. It's [updated  by running][emission_run_bundle] `npm run bundle`. This generates both the minified JS, and a source map so that we can transcribe the error reports into the code we write.

Using the CocoaPod, Emission can provide native view controllers that use React Native under the hood. The host app does not need to know the underlying details like `npm`.

### On Emission

Whether this is a pattern other apps can follow is hard to say, we were in a great position to do this. Our app has view controllers that have very little communication with each other and the host app does not need to bridge large amounts of information. 

As ever, our work is open source, and we ensure that anyone can download and run Emission, so if you'd like to understand more, clone [artsy/emission][repo] and study the implementation.   

[auctions_team]: /blog/2016/08/09/the-tech-behind-live-auction-integration/
[interstellar]: https://cocoapods.org/pods/Interstellar
[eigen]: https://github.com/artsy/eigen/
[router_pattern]: https://artsy.github.io/blog/2015/08/15/Cocoa-Architecture-Router-Pattern/
[hybrid_app]: http://artsy.github.io/blog/2015/08/24/Cocoa-Architecture-Hybrid-Apps/
[ar_emission]: https://github.com/artsy/emission/blob/master/Pod/Classes/Core/AREmission.m
[example_emission]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/Example/Emission/AppDelegate.m#L56
[eigen_emission]: https://github.com/artsy/eigen/blob/41b00f6fe497de9e902315104089370dea417017/Artsy/App/ARAppDelegate%2BEmission.m
[reloading]: http://facebook.github.io/react-native/releases/0.31/docs/debugging.html#automatic-reloading
[relay_cont]: https://facebook.github.io/relay/docs/api-reference-relay-container.html
[react_component]: https://facebook.github.io/react/docs/component-api.html
[relay_route]: https://facebook.github.io/relay/docs/guides-routes.html#content
[pods_emission]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/Example/Podfile
[app_delegate_cont]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/Example/Emission/AppDelegate.m#L159-L169
[podspec]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/Emission.podspec
[native_modules]: https://facebook.github.io/react-native/docs/native-modules-ios.html
[emission_pod_classes]: https://github.com/artsy/emission/tree/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/Pod/Classes
[extraction]: https://github.com/artsy/extraction
[extraction_files]: https://github.com/artsy/extraction/tree/d6a32186f7098eb2ec5d05e2fb5302a8378eff70/Extraction/Classes
[emission_resource]: https://github.com/artsy/emission/blob/master/Emission.podspec#L17-L18
[emission_bundling]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/package.json#L7
[emission_run_bundle]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/package.json#L7
[arcomponent]: https://github.com/artsy/emission/blob/eb9d0f6ca0edd3eb9f07dd9ff3b8499f095bc45b/Pod/Classes/ViewControllers/ARComponentViewController.m
[ar_router]: https://github.com/artsy/eigen/blob/master/Artsy/App/ARSwitchBoard.m#L122
[switch_view]: https://github.com/artsy/extraction/blob/d6a32186f7098eb2ec5d05e2fb5302a8378eff70/Extraction/Classes/ARSwitchView.m
[architectual]: /blog/2016/08/15/React-Native-at-Artsy/
[repo]: https://github.com/artsy/emission#reactions--emissions
