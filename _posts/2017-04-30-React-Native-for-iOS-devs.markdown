---
layout: epic
title: Intro to React Native for an iOS Developer
date: 2017-05-30
categories: [Technology, emission, react-native, react, javascript]
author: orta
series: React Native at Artsy
---

React Native is a new native library that vastly changes the way in which you can create applications. The majority of the information and tutorials on the subject come from the angle of _"you are a web developer, and want to do native"_.

This makes sense, given that the size of that audience is much bigger, and far more open in the idea of writing apps using JavaScript. For web developers it opens a new space to work, for native developers it provides However, this is not how React Native was introduced inside Artsy. The push came from the native team. 

We've been doing it now for over a year, and have started to slow down on drastic changes inside the codebase. This is great because it means we're spending less time trying to get things to work, and more time building on top of a working setup.

I'd like to try cover a lot of the common questions we get asked about from the perspective of native developers:

-   What is React Native?
-   How do you use React Native?
-   When is React Native a good technology choice?

This article will try to cover an awful lot, so free up 15 minutes, make a tea and then come back to this. It's worth your time if you're interested in all the hype around React Native.

<!-- more -->

At the highest level, React Native is a way to write React apps that run as native programs. You write your app's code in JavaScript, and React Native bridges that code with native UIView elements. React Native has two stated aims:

-   Learn Once, Write Anywhere.
-   Make a native developer experience as fast as the web developer's.

_"Learn Once, Write Anywhere"_ is a play on Java's _"Write Once, Run Anywhere"_ - something that has not worked well for user-interface heavy mobile clients. The idea of running the same code everywhere encourages platform-less APIs which water down the positives of each platform.

_"Learn once"_ in this context means that you can re-use the same ideas and tools across many platforms. You don't lose your ability to write the same user experiences as you can with native code, but you can re-use your existing skills from different platforms in different contexts. That is the _"Write Anywhere."_

# React

React offers a uni-direction Component model that _can_ handle what is traditionally handled by the MVC paradigm. The library was created originally for the web, where updates at the equivalent of UIView level are considered slow. React provides a diffing engine for a tree of components that would _eventually_ be represented as HTML, allowing you to write the end-state of your interface and React would apply the difference to only the HTML that changes.

This pattern is applied by providing a consistent way to represent a component's state. Imagine if every UIView subclass had a "`setState`" function where you applied 

React was built out of a desire to abstract away a web page's true view hierarchy (called the DOM) so that they could make changes to all of their views and then React would handle finding the differences between view states.


</article>
<article style='display: flex; flex-flow:row;'>

<img style='flex:1' src="/images/what-is-rn/simple-overview-render.png" height=544/>
<div style='flex:1'>
{% include_relative svgs/rn/simple-component-overview.svg %}
</div>

<div style='flex:1' id='simple-components'>
  <div class="component" id='sc-v' data-props="{ query: 'Tracy', results: [{ name: 'Tracy Emin', url: 'img/tracy.png' }, { name: 'Tom Thompson', url: 'img/tom-t.png' }, { name: 'Tom Sachs', url: 'img/tom-s.png' }] }"><p>View</p>
    <div class="component" id='sc-v-textfield' data-props="{ text: 'Tracy' }"><p>SearchQueryInput</p></div>
    <div class="component" id='sc-v-results' data-props="{ results: [{ name: 'Tracy Emin', url: 'img/tracy.png' }, { name: 'Tom Thompson', url: 'img/tom-t.png' }, { name: 'Tom Sachs', url: 'img/tom-s.png' }] }"><p>SearchResults</p>
      <div class="component" id='r-v-results-tracey' data-props="{ name: 'Tracy Emin', url: 'img/tracy.png' }" ><p>ArtistResult</p></div>
      <div class="component" id='r-v-results-tom-t' data-props="{ name: 'Tom Thompson', url: 'img/tom-t.png' }" ><p>ArtistResult</p></div>
      <div class="component" id='r-v-results-tom-s' data-props="{ name: 'Tom Sachs', url: 'img/tom-s.png' }" ><p>ArtistResult</p></div>
    </div>
    <div class="component" id='sc-v-done' data-state="{ onTap: () => void }"><p>Button</p></div>
  </div>
</div>

<script>
$("svg").find("g#React > rect").hover(function(){
    console.log(this.id)
    
}, function () {

});
</script>

</article>
<article class="post">


[ 
  Diagram:
    Component tree on one side, App prototype on the other
    Mouse-overing a component or view in the app would select both and show props
    Should be 1-1 with view to components
]

This kind of tree structure should feel quite similar to the view tree that you see inside a tool like Reveal, or inside the Xcode visual inspector.

Instead of MVC, React uses composition of components to handle complexity, oddly enough - this should feel quite similar to iOS development. The screen of an iOS app is typically made up of `UIView`s, and `UIViewController`s which exist inside interlinked trees of hierarchy. A `UIViewController` itself doesn't have a visual representation, but exists to manipulate data, handle actions and the view structure for views who do.

A component can be both view and view controller.

[
  multi-step diagram:
    UIView tree ->
    UIView + UIViewController tree ->
    Component Tree

    App Prototype

    In the component tree 

]

By merging the responsibilities of a `UIView` and `UIViewController` into a Component, there is a consistent way to work with all aspects of your app. Let's take a trivial example. Downloading some data from the network and showing it on a screen.

In UIKit-world you would:

-   Create a `UIViewController` which makes the API request on it's `viewDidLoad`
-   While the request is sent you present a set of views for loading
-   When the API request has returned you remove the loading screen
-   You take the data from the request and create a view hierarchy then present that

In React you would:

-   Create a component which makes the API request on it's `onMount`
-   While the request is sent you render another component for showing loading
-   The results come back and you change your "state" on the main component with the API request
-   The state change re-runs your render method, which passes the API "state" down to the component for your page

They are conceptually very similar. React does two key things differently:

-   Handle "state" change on any component
-   Handle view destructuring/structuring

So, I've been quoting "state", I should explain this. There are two types of "state" inside React, and I've been using the quoted term to refer to both for simplicity till now.

> There are two types of data that control a component: `props` and `state`. `props` are set by the parent and they are fixed throughout the lifetime of a component. For data that is going to change, we have to use `state`.

> [React Native - State](https://facebook.github.io/react-native/docs/state.html)

So in our case above, getting the API results only changes the state on the component which makes the request. However, the results are passed down into the props _(properties)_ of the component's children as any further changes to the API data (for example if you were polling for updates) would result in a re-render of the child-components.

- Handle view destructuring/structuring

Because of the consolidated rules around state management React can quite easily know when there have been changes throughout your component tree and to call `render` for those components. `render` is the function where you declare the tree of children for a component.

> The flow in React is one-directional. We maintain a hierarchy of components, in which each component depends only on its parent and its own internal state. We do this with properties: data is passed from a parent to its children in a top-down manner. If an ancestor component relies on the state of its descendant, one should pass down a callback to be used by the descendant to update the ancestor.

> [React Native - Communication between native and React Native](https://facebook.github.io/react-native/docs/communication-ios.html)

Props are treated as the equivalent as a Swift `let` variable in this case, any changes to props require an new version of the component to exist in the tree and thus `render` is called.

So, in summary: React's paradigm is a component tree, where the `render` function of a component passes down one component's state into the props of the children.

# React Native

React was built for the web - but some-one realised that they could de-couple the React component tree from the HTML output, and instead that could be a tree of UIView's.

That is the core idea of React Native. Bridge the React component tree to native primitives. React Native runs on a lot of platforms:

-   iOS
-   Android
-   tvOS
-   VR
-   macOS
-   Windows
-   Ubuntu

Each of these platforms will have their own way of showing some text e.g.

-   `RCTText` for iOS and tvOS - [which uses NSTextStorage, and drawRect][1]
-   `Textfield` for Android - which uses [Canvas and a DrawCommand][2]
-   `Three.js view primitive` for VR - which uses [BitmapFontGeometry][3] + [Shaders][4]
-   `RCTText` for macOS [which also uses NSTextStorage, and drawRect][5]
-   `ReactTextShadowNode` for Windows - which uses a [RichTextBlock][6]
-   `QQuickItem` for Ubuntu - Which uses [QString to render][7]

But when working at React-level, you would use the component `Text`. This means you can work at a cross-platform level, by relying on the primitives provided by each implementation of React Native.

For iOS, this works by using a JavaScript runtime (running via JavaScriptCore in your app) which sends messages across a bridge that handles the native `UIView` hierarchy. 

[
  Graph
    JS Runtime - Bridge - Native Views
]

This bridging is how you get a lot of the positive aspects of working with the JavaScript tooling eco-system. The JavaScript used by React can be updated independent of the app, but so long as it is working with the same native bridge version. This is how React can safely have a reliable version of [Injection for Xcode][].

Like any cross-platform abstraction, React Native can be leaky. To write a cross-platform app that purely lives inside JS Runtime, you have to write React-only code. React + React Native doesn't have ways to handle primitives like `UINavigationController` - they want your entire app to be represented as a series of components that can be mapped across many platforms. 

This isn't optimal when you're coming in from the native world - where you're used to building platform-specific experiences, and are genuinely excited at the prospect of platform-specific APIs. Generally you can look for other teams who have felt the same and are willing to write native-bridged code that's specific to iOS. Shout-out to [Wix][] and [AirBnB][] who are doing great work in this space.

Is this a critical problem against React Native? I don't think so, we've added native abstractions where it was the right decision and we've used JavaScript when it was the right decision. For example, our `Image` component is a bridged native component that uses `SDWebImage` under the hood so that we can share an image cache with the rest of the app.

## Ten minutes to try out React

OK, no joke, don't skip this, you can do try React Native right now. This will require some terminal skills, it shouldn't be much more than you'd have used with CocoaPods though.

</article>
<article style='display: flex; flex-flow:row;'>
<div style='flex:1'>

```sh
# If you don't have homebrew
# see [homebrew site]

# Install the JavaScript tools you'll need
brew install nodejs yarn

# You'll want Visual Studio Code to work on this
brew cask install visual-studio-code

# Install the React Native CLI
yarn global add react-native-cli

# Create a new React Native
# project called TrendingArtists
react-native init TrendingArtists
```

</div>
<div style='flex:1'>

<p>You'll need <code>node</code> and <code>yarn</code> installed globally so you can run JavaScript and handle dependency management respectively.<p>

<p>For working inside a JavaScript project, I'd strongly recommend using Microsoft's <a href='https://code.visualstudio.com'>Visual Studio Code</a>, it does a great job for React Native.</p>

<p>Next up we're going to make the initial project and look around, so once all the installing has finished. You can follow along with the next section.</p>

</div>
</article>
<article class='post'>

Alright, so that should do a lot of downloading, and you'll have a new folder with a fully set up project for iOS and Android. We'll be focusing on the iOS side.

So, open up `TrendingArtists` in your editor and inside your terminal with `cd TrendingArtists`. From the terminal you can get the Xcode project compiled, and opened inside the iOS simulator with `react-native start ios`. 

This first uses `xcodebuild` to compile the native app found in `ios/TrendingArtists.xcodeproj` it will then load up the the React Native Packager. We'll cover that later, for now, think of it as JavaScript file change watcher.

Once a simulator has popped up, and you see the "Welcome to React Native" screen. Now that we've got "an app" running. Let's take a moment to look through what we got.


</article>
<article style='display: flex; flex-flow: row;'>
<div style='flex:1'>


```sh
$ tree .

├── __tests__
│   ├── index.android.js
│   └── index.ios.js
├── android - [snipped]
├── app.json
├── index.android.js
├── index.ios.js
├── ios
│   ├── TrendingArtists
│   │   ├── AppDelegate.h
│   │   ├── AppDelegate.m
│   │   ├── Base.lproj
│   │   │   └── LaunchScreen.xib
│   │   ├── Images.xcassets
│   │   │   └── AppIcon.appiconset
│   │   │       └── Contents.json
│   │   ├── Info.plist
│   │   └── main.m
│   ├── TrendingArtists-tvOS
│   │   └── Info.plist
│   ├── TrendingArtists-tvOSTests
│   │   └── Info.plist
│   ├── TrendingArtists.xcodeproj
│   │   ├── project.pbxproj
│   │   ├── project.xcworkspace
│   │   │   ├── contents.xcworkspacedata
│   └── TrendingArtistsTests
│       ├── Info.plist
│       └── TrendingArtistsTests.m
├── jsconfig.json
├── package.json
├── node_modules [x million files snipped]
└── yarn.lock
```

</div>
<div style='flex:1'>

<p><strong>What are we looking at?</strong></p>

<p>First up - we have some test files, these files are unique per platform - though they do have the same code right now. In React Native imports can resolve to be different per-platform, which is why you see <code>.android.js</code> or <code>.ios.js</code>.</p>

<p>The next important files are: <code>index.android.js</code> and <code>index.ios.js</code>. These are the launching point for this app, so it's in there you'll find the code for what we're seeing.</p>

<p>In the <code>ios</code> folder, we have the native side of React Native. Looks pretty empty from here, but when you open the workspace you'll note that it is referring to a lot of <code>xcproject</code>s which are inside your <code>node_modules</code> folder.</p>

<p>The Xcode project is really barebones, it's just an <code>AppDelegate</code> that creates a <code>UIView</code> subclass. You can see that it references <code>index.ios.js</code> which is where your JavaScript side starts.</p>

<p>Then you have the <code>Package.json</code> which is like an Xcodeproj + Podfile in one, and the <code>node_modules</code> folder. Which houses all your JavaScript dependencies.</p>

</div>
</article>
<article class='post'>

I'd like to show you how to make a change appear instantly. In your iOS Simulator, perform a shake gesture (<code>cmd + ctrl + z</code>) and in the React Native debug menu, hit "Enable Live Reload". Once you're back in an app, do another shake gesture, and turn on "Hot Reloading".

Now you can go into your text editor and change some of the words inside `index.ios.js` - those changes will be reflected almost instantly. You can do this for almost anything, almost anywhere. We're been working [on Emission][emission] for over a year, and this is still close to instant in every place we work.

If you'd like to go through a tutorial from this point, I'd recommend these:

- The React Native site
- [look for other tutorials]

We're going to back to talking about the hows and whys.

## Writing JavaScript

JavaScript is a deceptively simple language with a lot of weird gotchas, which makes it easy to be disparaging against. Especially coming from the native world, where you are used to type systems and low-level programming. 

I think it's safe to say that the majority of JavaScript's warts are fixed by tooling nowadays. Tools like ESLint, TSLint, Babel, Prettier, TypeScript and Flow make it difficult to write bad code, and the JavaScript community really comes together to fix it's own problems. This differs from the [Sword of Damocles][] that [exists for big OSS projects][retro-swift-sherlock] in the iOS community.

[
  table
    ESLint/TSLint: does this
    Babel: Does that
    Prettier: Etc
]

These inter-linked, composable tools basically represent the entire idea of the JavaScript community. You add them to your project, and your project gets littered with all these small config files that eventually creates the kind of cohesive tooling that you would expect from a single vendor.

The good part is that they are interchangeable, we switched from Flow to TypeScript with roughly 2 week's work, then a week to come close to perfect for example. The bad side is that the configuration aspects of these projects feels like something you do once, then forget until it needs to change.

The defaults that React Native template have are _really solid_, it's just if you come from a typed environment like all iOS engineers have - basic JavaScript just not enough.

I wrote up a glossary of terms from JavaScript when I first started understanding the community, you can [find it here][js-glossary].

## Node.js

There are two main environments for writing JavaScript in: the browser, and inside Node. Node is the JavaScript runtime from Google Chrome (called V8, their version of JavaScriptCore) with a UNIX-like baseline set of APIs.

It provides relatively few APIs, it is expected that you would use a node module for anything particularly high level. the principal being that a standard library (like Foundation in iOS) is always going to be out of date, and incompatible with what web-browsers ship.

A node module is a set of JavaScript files with a particular structure. Generally, there is a `package.json` to describe the library, and an `index.js` with the code for the library. Libraries can be as small as a single-function to typical a "XYZKit" you would expect from CocoaPods. As JavaScript tends to be bundled and minified based on code used, developers mainly worry about the overall file-size of their library. You would use a package manager like NPM or Yarn to manage these dependencies. Node modules have the unique, and very dangerous idea of allowing multiple versions of the same library to exist inside your application. This "fixes" the problem of dependency hell, at the cost of many potential runtime issues.

When writing JavaScript with React Native, you are using node modules, but _strictly speaking_ you are not writing a node app. The code that you write is executed inside JavaScriptCore and so doesn't have access to the UNIX-like API from node. 

This can make it a bit confusing about whether you can or can't use a library from NPM. This also gets a bit more tricky, for example your tests _are_ running inside node. So, it's fine for your tests to use all of those APIs and libraries, but not your app's code. So far, from my experience this hasn't been a problem, in part because of how we use React Native (mainly API -> UI). I researched all of this during the creation of this post, and I hadn't really noticed the mismatch during active development.

If you want to spend some time browsing around and understanding the JS world, here's a few jump-off points;

-   NPM
-   Yarn
-   Babel
-   Sourcemaps
-   Reflux
-   Redux
-   Flow
-   TypeScript
-   Lodash
-   Relay 
-   Prettier
-   Jest

# Web Style Development Experience

The compile and reboot cycle of native apps is particularly painful when you are sitting next to a web engineer. React Native aims to re-use a lot of the JavaScript tooling to 

-   For the web "tooling" != IDE
-   The UNIX idea of small individual libs
-   A million options, but very few attempts to provide cohesive toolkits 
-   Last 2-3 years has brought great strides forwards in the community
    -   Typed JS with inference
    -   Tooling like nuclide / vscode
    -   Safe dependency management in Yarn (and now in npm)

## JS Tooling

Facebook's tooling 

-   Nuclide is good, but not good enough
-   Flow is good, but editor support is not good enough
-   We use TypeScript but it is a bit of a battle **today**
-   TypeScript + VS Code is basically Xcode level of quality, just less polished but more reliable and open source.
-   Newest release of RN includes some of our work on making 
-   node community is great at automation: linters and formatters work reliably and inside your editor
-   Debugging is tricky, but feasible. O2.

Testing

-   Testing on native is a nightmare
-   Apple's tooling for tests has always been bad

There are two ways to write tests for your react native code: in process and out of process. E.g. in JS side, or in native side. 

-   JS side: Choice of many test runners, built with hundreds of people involved in multi-year test runners
-   Native side: Probably one person making XCTest, one person trying to get some improvements in Xcode each year

-   JS side: Instant, can run at the same time as your app
-   Native side: Requires stopping your app, running tests, then restarting your work

We had a few native tests, but very quickly we stopped running them. 

-   We use Jest for all these reasons (quote JS post)

-   CI process is just a linux box
-   CI takes ~3m

Deployment

-   Because JS is separate from app, JS can be updated separately
-   JS is not dynamically changing application via swizzling etc - just new JS talking to existing native code
-   This means you _can_ ship a different version of the JS to your app, but not all features can be shipped to old clients
-   We don't do it, for our ~month cadence, 2 day review time is OK
-   We do use it for having betas using different builds of the JS runtime. No need to deploy to testflight on every commit when we can ship just the JS and make our own commit chooser.
-   Deployment is tricky because you have two version number for _your_ RN: the version of the components, and the version of your native bridge

Doing it right per platform

-   RN gives you the ability to think in cross-platform
-   Most devs are JS people trying to ship to Android/iOS
-   They're interested in getting it done vs getting it right
-   show my navigation issue

-   Doing it right will inevitably require native code
-   RN is a focused UI framework 
-   Does not hinder you from making apps with traditionally native features: e.g. NSUserActivity, Spotlight etc
-   Making some of these features requires crossing the bridge back to native land and having the work done there
-   _We_ still think in terms of `UIViewControllers` which have a react view tree, not there is an app react component with sub-react components as view controllers.

-   RN provides some pretty clever ways to handle cross-platform 

-   note somewhere that our imageviews use SDWebImage to share cache

## Create React Native App

One of the biggest projects to happen in the React Native world in the last 6 months is Create React Native App (CRNA). This is the "super easy to get started" React Native experience. 

Remember that most of the people coming to React Native are web developers, and the idea of writing Objective-C/Swift/Java to them is unappealing. CRNA actually removes the ability for you to write native code, and trades that with letting a company called Expo do it for you.

Expo are a pretty new company, whose work is entirely open source. They've done a lot of interesting work in the community, and as individuals they are well respected for contributions to React Native the library - and a bunch of related libraries. You can use the Expo app from the App Store to run your CRNA project on any iOS/Android device instantly, and the app has a lot more baseline UI components to work with than React Native does on its own.

With CRNA you are giving up control of the native side, but gaining a lot on the ease-of-use side. CRNA doesn't force the project to stay this way though, you can eject your app from the Expo and start adding native code to the app. 

Why did I even mention this? Well, if you're looking at React Native for a greenfield app (e.g. something new), CRNA may be your best option. When you're getting started, less options is better, and this is the optimal setup according to the React Native team. 

## Animations

A question which regularly comes up is "How can React Native handle animations?" - at this point the answer is "well enough for 80% of all apps, it's enough for ours." 

There are two primitives for animation from React Native:

-   `Animated` - This is a fine-grained API for handling changes ( we use this on our buttons for making the transition animations the same as our native ones. )
-   `LayoutAnimation` - This API feels a little bit like `UIView +animate:` - in that you can tell tje layout engine that the next update should be animated instead of replaced.

These provide enough for a most use-cases, but there is a more direct API and a few more JS-level techniques that you can use if you are really starting to feel like you're dropping frames inside a specific animation.

## Facebook patent clause

[TODO]

## Places where React Native hasn't fit for us

So far, nowhere. 

Note though, the types of apps we create are exclusively API driven, with a unique visual style which totally covers the exposed UI surface. React Native is a great fit for this kind of app.

Our main app Eigen, is a `UIViewController` browser, and React Native components are just one type of `UIViewController` that can be browsed. Nearly every `UIViewController` is the representation of an API endpoint, so React Native + Relay is a great match.

I used to say that our Kiosk app, Eidolon, might not be a good fit because of it's reliance on handling a credit-card reader and that the app was good fit for being a storyboard-driven app. However, I'm not so sure about this anymore. The project React Storybooks is not a direct replacement for storyboards, but as a live-programming/prototyping environment it's 👍. The credit-card reader is already wrapped into a Reactive paradigm, going one step further and making it a JavaScript EventEmitter isn't a big-jump.

Our tvOS app Emergence could probably be re-wrote in a week at this point. Is it worth a re-write? No. If I had to write it from scratch, would I use React Native? Probably, but it would depend on how stable tvOS support feels.

Our oldest app, Energy, is an app for keeping your portfolio of artworks with you at all times. Again, API -> UI. It's an app which currently has a lot of demands on running offline. This is the only part that makes me a bit unsure what that could look like with respect to moving the interface to React Native.

## When to choose React Native?

-   Maybe update this post WWDC?

React Native provides a cross platform API, and so it can fall into a watered down version of the API it abstracts. This means that it can be a bit more work than normal to use obviously iOS-specific features like `UIUserActivity`, `CSSearchableIndex` or `UIUserNotification`s.

That's not enough of a downside to contrast against:

-   A _significantly_ better way to handle state and user-interfaces
-   The potential to write code that is cross-platform, and also share ideas with the web
-   An open development environment that respects your time

Especially when there is an Xcode project which you can use to do whatever you want with, you just need to learn how to jump back and forth between the two worlds.

React Native is a great fit for apps that:

-   Are driven by an API, or an obvious state-store
-   Want to have a unique look and feel

Here's the final thing. When React Native was proposed as an option for us, the majority of our mobile dev team were not exactly excited at the prospect of using it. As we grew to understand the positive changes it was bringing for us, and our users, I at least was really happy that Alloy was willing to say "I think this could work."

It's less risky now, but it's obviously a big dependency inside your app. Ideally, someone in your team should be able to feel comfortable reading, and potentially fixing code inside React Native the library. 

<!--
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
-->

## Integrating in to an Existing app

If you're thinking of adding RN to an existing app, first read [on emission][]. We think of our RN to be a series of components which are consumed by our app as a CocoaPod. This is the same pattern Airbnb, and Facebook used. Then, check out AirBnB's experiences [in this video][8].

## Greenfield

I'd recommend start with a CRNA app, it's a good starting point. I feel safe that I can eject out of the environment provided when the app becomes complex enough to warrant native code.

I personally would probably start with this boiler-plate, but I am a domain expert now. In order to feel comfortable with it, you'll need to be comfortable with 

-   TypeScript
-   Babel
-   JavaScript
    (etc etc)

In the same kind of way that you had to become comfortable with project management inside Xcode, or understanding what an LLVM error meant you had to change. Boilerplates give you more, but require a higher baseline knowledge. I wrote one app for Artsy in just JavaScript, and the lack of dev-time safety made me feel far less experienced than I am. I'd rather not make that mistake again.

[injection for xcode]: ???

[sword of damocles]: ???

[retro-swift-sherlock]: ???

[Airbnb]: ???

[Xix]: ???

[1]: https://github.com/facebook/react-native/blob/559805d0b04da99b80a0813917b7eaa2716faa4c/Libraries/Text/RCTText.m#L117

[2]: https://github.com/facebook/react-native/blob/559805d0b04da99b80a0813917b7eaa2716faa4c/ReactAndroid/src/main/java/com/facebook/react/flat/DrawTextLayout.java

[3]: https://github.com/facebook/react-vr/blob/1f037c118b2088f7881c240fdfd6c204de8b2c65/OVRUI/src/UIView/UIView.js#L221

[4]: https://github.com/facebook/react-vr/blob/master/OVRUI/src/SDFFont/SDFFont.js

[5]: https://github.com/ptmt/react-native-macos/blob/f3ce1d124e32a95e48ed26c05865e150714887da/Libraries/Text/RCTText.m#L182

[6]: https://github.com/Microsoft/react-native-windows/blob/2cc697859c80f59350e9613565a975023ae1046e/ReactWindows/ReactNative/Views/Text/ReactTextShadowNode.cs#L252

[7]: https://github.com/CanonicalLtd/react-native/blob/98e0ce38cdcb8c489a064c436a353be754e95f89/ReactUbuntu/runtime/src/reactrawtextmanager.cpp#L84

[8]: https://www.youtube.com/watch?v=tWitQoPgs8w
[emission]: https://github.com/artsy/emission/
[js-glossary]: ???
