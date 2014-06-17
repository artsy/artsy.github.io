---
layout: full_width_post
title: "Building the Xcode Plugin Snapshots"
date: 2014-06-17 10:50
comments: false
sharing: false
categories: [Testing, Objc, Cocoa, Xcode, Plugins]
author: Orta
github-url: https://github.com/orta
twitter-url: http://twitter.com/orta
blog-url: http://orta.github.io
---

I'm the kind of guy who thinks better tooling means better outcomes. But when good tooling isn't available, it's time to build it yourself. It's this attitude that lead to my work on [CocoaDocs.org](http://cocoadocs.org), and then to [CocoaPods.org](http://cocoapods.org) & its documentation.

We've been trying to apply this to testing, and in order to pull this off I've had to extend Xcode to show off the results of failing tests in a more visual way. I built [Snapshots for Xcode](https://github.com/orta/snapshots).  Let's go through the process of building an Xcode plugin so you can do this too. Screw stability.

<!-- more -->

Lets start of with some Xcode inception, the nicest way to start working on Xcode plugins is to install [Alcatraz](http://alcatraz.io):

```
curl -fsSL https://raw.github.com/supermarin/Alcatraz/master/Scripts/install.sh | sh
```

From Alcatraz, at a minimum, you're going to want to have [XcodeExplorer](https://github.com/edwardaux/XcodeExplorer) installed to dig through notifications and the view heriarchy, and then [Delisa Mason](http://delisa.me)'s [Xcode 5 Plugin](https://github.com/kattrali/Xcode5-Plugin-Template) template.

Now you can create a new project and pick "Xcode 5 Plugin" this will do a bunch of the boring work around getting set up on a project, though it misses one bit that to me is essential, setting the Scheme Target, so go to the Scheme editor and make it open Xcode.

![Go set you target dangit](/images/2014-06-17-building-the-xcode-plugin-snapshots/scheme.png)

This means that when you do `cmd + r` on your project it will open a new instance of Xcode with your plugin installed, this makes the dev cycle for a plugin as simple as a normal app. Going from here to some extent is a bit of an excercise for the reader, I can't tell you how to build your plugins. However I can offer some general advice.

* When you see a class you don't know, google it, chances are Luis Solano has you covered with [Xcode-RuntimeHeaders](https://github.com/luisobo/Xcode-RuntimeHeaders).
* Use id with fake class interfaces to get around having the headers for Xcode's classes.
* Avoid 3rd party dependencies as much as possible as all plugin classes are in the same runtime.
* A lot of work is done in notifications, so it's easy to hook in to state changes.
* Swizzle as little as possible
* Wrap code you're not 100% on with `@try {} @catch {}` once it's working and die elegantly
* Look at the source code of other plugins
* Read [the notes](https://github.com/kattrali/Xcode5-Plugin-Template#notes) on the Xcode5 Plugin Template

Next up you want to get it on Alcatraz, this is as simple as a pull request to the [alcatraz-packages repo](https://github.com/supermarin/alcatraz-packages). It's like the old days of CocoaPods! Then you have a plugin, and people will always be using the master HEAD version of your plugin, so be wary around putting unstable code on that branch.