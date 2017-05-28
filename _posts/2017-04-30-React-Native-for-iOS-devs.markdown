---
layout: post_longform
title: Intro to React Native for an iOS Developer
date: 2017-04-30
categories: [Technology, emission, react-native, react, javascript]
author: orta
series: React Native at Artsy
---

React Native is a new native library that vastly changes the way in which you can create applications. The majority of the information and tutorials on the subject come from the angle of "you are a web developer, and want to do native" - which is how it was introduced inside Artsy.

We've been doing it now for over a year, and have really started to slow down on drastic changes inside the codebase. This is great because it means we're spending less time trying to get things to work, and more time building on top of a working setup.

This article will try to cover an awful lot, so free up 15 minutes, make a tea and then come back to this. It's worth your time if you're interested in all the hype around React Native.

<!-- more -->

React Native is a way to write React apps app that run as native programs. It bridges the JavaScript React code that you write with native UIView elements. React Native has two main aims:

* Learn Once, Write Anywhere.
* Make a native developer experience as fast as the web developer's.

"Learn Once, Write Anywhere" is a play on Java's "Write Once, Run Anywhere" - something that has not worked well for user-interface heavy mobile clients. The idea of running the same code everywhere encourages platform-less APIs which water down the positives of each platform.

"Learn once" in this context is that you can re-use the same ideas and tools across many platforms. You don't lose your ability to write the same user experiences as you can with native code, but you can re-use your skills from different platforms in different contexts. That is the "Write Anywhere."


* React (JS Lib) + React Native (Obj-C / Java)
* JS runtime runs on webkit - it is not node, but you could barely tell.
* JS runtime talks to native components through the RN bridge
* Any native code can be bridged, passes back into the JS world via async APIs
* trade-off on performance is that all JS work is done off main thread, all UI layout is done on BG thread natively 
* very hard to write blocking code

# React 

React offers a uni-direction Component model that _can_ handle what is traditionally handled by the MVC paradigm. The library was created originally for the web, where updates at the equivalent of UIView level are considered slow. React provides a diffing engine for a tree of components that would _eventually_ be represented as HTML, allowing you to write the end-state of your interface and React would apply the difference to only the HTML that changes.

This pattern is applied by providing a consistent way to represent a component's state. Imagine if every UIView subclass had a "setState" function where you applied 

React was built out of a desire to abstract away a web page's true view hierarchy (called the DOM) so that they could make changes to all of their views and then React would handle finding the differences between view states.


- Composition as the core concept
- React as diff engine
- Singular definitions of state and props
- Provides a singular object model for web, which aims to cut across responsibilities like 

React Native

- Separates React from React DOM
- Components as Views + View Controllers
- Show how a component tree can be mapped very easily to MVC paradigm
- Uses flexbox for layouts, which is way simpler and less likely to be buggy than auto layout

Ten minutes to try out React

Don't skip this, you can do this right now.

- Install node
- Install yarn
- `yarn create react-native`
- Install VS Code
- Show how to edit a component
- Explain how to turn on HMR
- Make them edit something again, see the changes live

So what is going on?

- RNP as dev server
- Create React Native
- JSX as HTML in JS
- JSX is basically a pretty way to write `React.createElement`

Writing JavaScript

- Simple and complex, flawed but fixed
- Tooling does a really good job of keeping really bad JS code out of your app
- Language that allows for many types of programming
- JS is a lot of very simple tools built on top of each other, which creates a tower of dependencies
- Always evolving, tools to let you pick and choose what features you want
[[[[[[[[[[[[=Some useful JS terms:
]
  - Destructuring
  - x
  - y

Node

- No standard library
  - + and - of this
- Open and chaotic ecosystem
- Often flipped by new ideas and paradigms

General overview of terms you'll be interested in WRT node:

- Node
- NPM
- Babel
- Sourcemaps
- Reflux
- Redux
- Flow
- TypeScript
- Lodash (underscore)
- Relay 

Web Style Development Experiene

- For the web "tooling" != IDE
- The UNIX idea of small individual libs
- A million options, but very few attempts to provide cohesive toolkits 
- Last 2-3 years has brought great strides forwards in the community
  - Typed JS with inference
  - Tooling like nuclide / vscode
  - Safe dependency management in Yarn (and now in npm)
  

Tooling

- Nuclide is good, but not good enough
- Flow is good, but editor support is not good enough
- We use TypeScript but it is a bit of a battle **today**
- TypeScript + VS Code is basically Xcode level of quality, just less polished but more reliable and open source.
- Newest release of RN includes some of our work on making 
- node community is great at automation: linters and formatters work reliably and inside your editor
- Debugging is tricky, but feasible. O2.

Testing

- Testing on native is a nightmare
- Apple's tooling for tests has always been bad

There are two ways to write tests for your react native code: in process and out of process. E.g. in JS side, or in native side. 

- JS side: Choice of many test runners, built with hundreds of people involved in multi-year test runners
- Native side: Probably one person making XCTest, one person trying to get some improvements in Xcode each year

- JS side: Instant, can run at the same time as your app
- Native side: Requires stopping your app, running tests, then restarting the work

We had a few native tests, but very quickly we stopped running them. 

- We use Jest for all these reasons (quote JS post)

- CI process is just a linux box
- CI takes ~3m


Deployment

- Because JS is separate from app, JS can be updated separately
- JS is not dynamically changing application via swizzling etc - just new JS talking to existing native code
- This means you _can_ ship a different version of the JS to your app, but not all features can be shipped to old clients
- We don't do it, for our ~month cadence, 2 day review time is OK
- We do use it for having betas using different builds of the JS runtime. No need to deploy to testflight on every commit when we can ship just the JS and make our own commit chooser.
- Deployment is tricky because you have two version number for _your_ RN: the version of the components, and the version of your native bridge

Doing it right per platform

- RN gives you the ability to think in cross-platform
- Most devs are JS people trying to ship to Android/iOS
- They're interested in getting it done vs getting it right
- show my navigation issue

- Doing it right will inevitably require native code
- RN is a focused UI framework 
- Does not hinder you from making apps with traditionally native features: e.g. NSUserActivity, Spotlight etc
- Making some of these features requires crossing the bridge back to native land and having the work done there
- _We_ still think in terms of UIViewControllers which have a react view tree, not there is an app react component with sub-react components as view controllers.

- RN provides some pretty clever ways to handle cross-platform 

- note somewhere that our imageviews use SDWebImage to share cache

Create React App

Ironically after this, one of the biggest projects to happen in RN in the last 6 months is CRNA. This is the super easy to get started RN experience. It's what we used earlier to get started.

- Makes one big assumption: you will not write native code.
- Remove this assumption and you can really tighten the tooling at JS level.
- Leaves the native side of it to Expo
- Expo is another company, but all the code is OSS - and they seem nice
- Can handle compiling and shipping your app for you from the cloud
- You can eject from CRNA to your own app at any time

Animations

- React Native probably isn't the right tooling for building something like Garageband. 
- Excels at handling user state -> user interface
- However, most apps are using pretty small animations here and there and React Native handles those _really, really well_.
- Provides a tonne of primitives to allow writing declaritive animations

Places where React Native hasn't fit for us

- So far, nowhere. Lols. Can't be true overall though.
- Something like our Kiosk app isn't an amazing fit
- Storyboards is a great abstraction for this kind of app, it has lots of obviously connected screens
- However, if we could have re-used our components from another app really easily, it'd probably have been easier to write, significantly easier to maintain. We'd also have considerably more contributions from people outside of the core two developers who worked on it.

When to choose React Native?

- Maybe update this post WWDC?
- React Native provides a cross platform API, and so it can fall into a usual watered down version of the API it abstracts. 
- Lots of apps don't bother with all the hard stuff though.
- For me, any app whose main job is to take an API and turn it into data should probably be a react native app.
- Apple gives a lot of polish on it's dev tools, but at the price of a closed system.


Now that I am reasonably proficient with the trade-offs, if I would use React Native

- An app whose sole purpose is to consume an external resource: e.g. an API.
- An app that doesn't easily fit into a single storyboard.
- Any app where Android is a hard requirement, because we don't have an android team, we can get it 70% of the way before we have to have someone with deep skills on the team.
 
I wouldn't use React Native if I were writing:

- A non-traditional app: e.g. a watchOS/iMessage/macOS app.

These are not platforms that are well tested, and kept up to date by the ever-changing node world. You can do it, but you will definitely have to get your hands dirty in the React Native source-code for the platform..

- An encrypted chat client
- Apps for a bank
- Apps that interact with life-critical systems like health


Not because you are shipping the source code for your app inside the app, that's never stopped websites handling the above. The bridging between runtimes is leaky, and is a great place vector for attacking your application. 

- Working in RN gives you the chance to have more of your app easier to de-silo your mobile engineering teams, making it simpler to write code across all teams because you have  with



Brownfield

If you're thinking of adding RN to an existing app, first read [on emission][]. We think of our RN to be a series of components which are consumed by our app as a CocoaPod.

Greenfield

I'd probably start with a CRNA app, it's a good starting point. I feel safe that I can eject out of the environment provided when the app becomes complex enough to warrant native code

I would probably start with this boiler-plate, but I am a domain expert now. In order to feel comfortable with it, you'll need to be comfortable with 

* TypeScript
* Babel
* JavaScript
(etc etc)

In the same kind of way that you had to become comfortable with project management inside Xcode, or understanding what an LLVM error meant you had to change. Boilerplates give you more, but require a higher base knowledge. I wrote one app for Artsy in just JavaScript, and I really disliked the experience. I won't make that mistake again.
