---
layout: post
title: "Building the Xcode Plugin Snapshots"
date: 2014-06-17 10:50
comments: false
sharing: false
categories: [Testing, Objc, Cocoa, Xcode, Plugins, iOS]
author: orta
---

I'm the kind of guy who thinks better tooling means better outcomes. But when good tooling isn't available, it's time to build it yourself. It's this attitude that lead to my work on [CocoaDocs.org](http://cocoadocs.org), and then to [CocoaPods.org](http://cocoapods.org) & its documentation.

We've been trying to apply this to testing, and in order to pull this off I've had to extend Xcode to show off the results of failing tests in a more visual way. To that end, I've extended Xcode to show the results of failing [view tests](https://github.com/facebook/ios-snapshot-test-case) in a more visual way by building [Snapshots for Xcode](https://github.com/orta/snapshots).  Let's go through the process of building an Xcode plugin so you can do this too. Screw stability.

<!-- more -->

## Getting started

Lets start of with some Xcode inception. The nicest way to start working on Xcode plugins is to install [Alcatraz](http://alcatraz.io) the Xcode plugin package manager:

```
curl -fsSL https://raw.github.com/supermarin/Alcatraz/master/Scripts/install.sh | sh
```

From Alcatraz you should have [XcodeExplorer](https://github.com/edwardaux/XcodeExplorer) installed. This lets you dig through internal notifications and the Xcode view heriarchy for debugging. Then you'll want [Delisa Mason](http://delisa.me)'s [Xcode 5 Plugin](https://github.com/kattrali/Xcode5-Plugin-Template) template which also comes from Alcatraz. Now you can create a new project and pick _"Xcode 5 Plugin"_. This will do a bunch of the boring work around getting set up on a project, though it misses one bit that to me is essential, setting the Scheme Target. Once setup go to the Scheme editor and make it open Xcode as the target.

![Go set you target dangit](/images/2014-06-17-building-the-xcode-plugin-snapshots/scheme.png)

This means that when you do `cmd + r` on your project it will open a new instance of Xcode with your plugin installed, making the dev cycle for a plugin as simple as a normal OS X app. From here I can't tell you how to build your plugin. It's just normal development, however I can offer some general advice:

* When you see a class you don't know, google it, chances are Luis Solano has you covered with [Xcode-RuntimeHeaders](https://github.com/luisobo/Xcode-RuntimeHeaders).
* Use id with fake class interfaces to get around having the headers for Xcode's classes.
* Avoid 3rd party dependencies as much as possible as all plugin classes are in the same runtime.
* A lot of work is done in notifications, so it's easy to hook in to state changes.
* Swizzle as little as possible
* Wrap code you're not 100% on with `@try {} @catch {}` once it's working to crash elegantly
* Look at the source code of other plugins
* Read [the notes](https://github.com/kattrali/Xcode5-Plugin-Template#notes) on the Xcode5 Plugin Template

## Releasing

Next up you want to get it on Alcatraz, this is just a pull request to the [alcatraz-packages repo](https://github.com/supermarin/alcatraz-packages), it's like the old days of CocoaPods! Then you have a plugin, and people will always be using the master HEAD version of your plugin, so be wary around putting unstable code on that branch.

It's easy to forget that if you build apps you have all the tools you need to improve your workflow, one improvement that saves you an hour today could save thousands of human-hours once it's out in the community.
