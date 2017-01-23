---
layout: post
title: "Postmortem: Swift at Artsy"
date: 2017-01-22 12:18
author: orta
categories: [swift, eigen, eidolon, javascript, emission, reactnative]
series: React Native at Artsy
---

* Eidolon (aug 4, 2014)
* Emergence
* Eigen
* CocoaPods / CocoaDocs

<!-- more -->

We did two big projects to understand what the future was Live Auctions in Swift, Artist and Home VC done in React Native

I'm cautious of someone reading this and TLDRing "Orta/Artsy say Swift sucks" - it doesn't. It is not the right choice
for our business today

### Swift + Native Downsides

* Fussy compiler wrt Typing (systems vs apps)
 - Harder to build easy to change systems
 - http://mjtsai.com/blog/2014/10/14/hypothetical-objective-c-3-0/#comment-2177091
 - https://github.com/artsy/causality

* Compiler iteration cycle
 - Sure it will get faster, but it'll not be faster than a simpler language
 - No concept like a watch mode
 - App Changes require full state reload

* Open but hard to be accessible
 - You need to be a compiler engineer to improve Swift
 - Can't fork Foundation, Cocoa, UIKit
 - Much smaller pool of active contributors to OSS in native

* Tooling immaturity, and redundant re-implementations
 - Community manually re-create a bunch of apple tools, why?
 - Community had to re-write every useful library "For Swift" again, making it instable
 - Community changed to be "Swift XX" as opposed to "Cocoa XX", swift purism vs mature pragmaticism

* Inter-op with Cocoa feels forced (relevant?)
 - The best parts of Apple's tooling requires writing non-canonical Swift
 - Struct vs NSObject trees, dynamic keyword

* Will only be usable for Apple products
 - Why use Swift when there's Kotlin?
 - Swift on a Server might be usable in a few years, not sure anyone would push on server  
 

### Swift's upsides

* Inter-operable with Objective-C, no re-write required
* Great for teaching
  - Would love a Playgrounds.app for Mac

* Great for building encapsulated systems
  - Types work well here

### React Native

Full context is: http://artsy.github.io/blog/2016/08/15/React-Native-at-Artsy/

But as a direct comparison to Swift:

* Reduce the barrier to entry for rest of team
  - more external contributions from web engineers since we moved

* Better abstractions for building JSON driven apps
 - https://rauchg.com/2015/pure-ui

* Encourages mobile developers to make API changes, same concepts
  - Web and API is JS, same tools, same workflow

* Conceptual idea of customizing your language to the project
  - We pick and choose language features we want

* "Forking" / Contributing back (can't use our own fork of Swift)
  - You can expect a reply to an issue, you don't to a radar
  - Relay
  - VS Code
  - React-Native

* Falling back to native code is no problem at all

* Tests operate outside of the iOS sim

https://twitter.com/orta/status/705137290092400640
