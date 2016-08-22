---
layout: post
title: "On our implementation of React Native"
date: 2016-08-18 12:17
author: orta
categories: [tooling, mobile, eigen, node, reactnative]
series: React Native at Artsy
---

<center>
 <img src="/images/emission/emission-logo-artsy.svg" style="height:300px;">
</center>

I arrived fashionably late to the React Native party in Artsy. I had been a part of our [Auctions Team][auctions_team], where we worked in Swift with [some light-FRP][interstellar]. We were not affected by 4 months of work on moving to React Native, at all. 

It was a quiet revolution. We did not have to install `npm`, made zero changes to the code for auctions and the whole app's infrastructure barely changed. What gives? 

Well, first up we weren't planning a re-write, we don't have that kind of luxury and the scope of our app is too big compared to the team working on it. Second, we reused existing dependency infrastructure. Read on to find out what that looks like.

<!-- more -->

### Why we were in a good position to do this

Let's talk a little about the Artsy flagship app, [Eigen][eigen]. It's an app that aimed to comprehensively cover the art world. From [Shows](https://www.artsy.net/shows) to [Galleries](https://www.artsy.net/galleries), [Fairs](https://www.artsy.net/art-fairs), [Auctions](https://www.artsy.net/auctions), [Museums & Institutions](https://www.artsy.net/institutions).  

It all looks a bit like this: 

{% expanded_img /images/emission/eigen-overview.jpg %}

Our app neatly splits into two areas of view controllers, ones that act as a browser chrome, and individual view controllers that normally map 1:1 to routes on the Artsy website. 

For example, `artsy.net/artwork/glenn-brown-suffer-well` maps to the native `ARArtworkViewController`. 

{% expanded_img /images/emission/eigen.svg %}

Just as a browser knows very little about the individual content of the pages that it is rendering, the eigen chrome exists _relatively_ independent of the view controllers that are showing. 

Each view controller also knows very little about each other, so actions that trigger a new view controller are generally done by creating a string route and passing it through the routing system. I've wrote about about this in [Cocoa Architecture: Router Pattern][router_pattern]. 

Interestingly if the router cannot route a view controller, it will pass through to a web view. This is why we consider the app a [hybrid app][hybrid_app]. This system means adding new view controllers is extremely easy.

### Introducing Emission

Emission is:

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

The thing that's interesting from the integration side, is that each `Container` is effectively a View Controller that React Native provides to a host application.

#### The iOS App

The iOS app acts as a host target for the CocoaPod, and provides an instance of an [AREmission][ar_emission] object to the view controllers using React Native. The app is nothing special, it is the default app that is created using `pod lib create`. We then [use CocoaPods][pods_emission] to bring in React from inside the `node_modules/` folder the Emission node module creates.

The `AREmission` instance is the intermediary between the host-app ([The Emission Example app][example_emission], or [Eigen][eigen_emission].) It has an API for handling routing, and passing authentication credentials into the React Native world.

We use the example app to do development inside React Native. As of right now, it is simply a tableview that provides a list of View Controllers [that represent an exposed Container][app_delegate_cont]. Once you are in the right view controller, you can rely on [Hot Reloading][reloading] to simplify your work.

#### The Pod

An important part of working with React Native, is that you can choose to use native code when appropriate. The [Pod for][podspec] Emission, created entirely in Objective-C, provides:

* Communication between React Native and the host app objects via [native modules][native_modules] 
* `UIViewController` subclasses for Host apps to consume.
* Bridges for native views into React Native.
 
The choice of Objective-C is for simplicity, and language stability. Swift is technically an option, but it's not  worth the complications for [a few simple objects][emission_pod_classes]. 

In order to share native views with our host app, Eigen, we created a library to just hold the shared UI components, [Extraction][extraction]. These are [factored out of Eigen][extraction_files, and into a pod. Emission and Eigen have this as a dependency.

#### Pod Deployment
>>>>>>> e92f4341a01c3c752a1e8729942ba17938e8bf54


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
