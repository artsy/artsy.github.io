---
layout: post
title: "Postmortem: Swift at Artsy"
date: 2017-01-22 12:18
author: orta
categories: [swift, eigen, eidolon, javascript, emission, reactnative]
series: React Native at Artsy
---

Swift was announced in June 2014, by August we had started using it in Artsy. By October, we had [Swift in production][eidolon-postmortem] channeling hundreds of thousands of dollars in auction bids.  

Since then we've built an [appleTV app][emergence] in Swift, integrated Swift-support into our key app Eigen and built non-trivial parts of that [application in Swift][live-a]. It is pretty obvious that Swift is the future of native development on Apple platforms. 

We first started experimenting with with React Native in February 2016, and by August 2016, we announced that [Artsy moved to React Native][artsy-rn] effectively meaning new code would be in JavaScript from here onwards.

We're regularly asked _why_ we moved, and it was touched on briefly in our announcement but I'd like to dig in to this and try to cover a lot of our decision process. So, if you're into understanding why a small team of iOS developers with decades of experience switched to JavaScript, read on. 

<!-- more -->

We were finding that our current patterns of building apps were not scaling as the team and app scope grew. Building anything new inside Eigen barely re-used existing code, and it was progressively taking longer and longer to build features. App and test build times were increasing, it would take 2 iOS engineers to build a feature in a similar time-frame as a single web engineer. 

We eventually gave up trying to keep pace with the web.

Once we came to this conclusion, our discussion came to "what can we do to fix this?" Over the course of the 2015/2016 winter break we explored ideas on how we could write more re-usable code.    

### What are Artsy's apps?

Eigen specifically is an app where we taken JSON data from the server, and convert it into a user interface. It nearly always can be described as a function taking data and mapping it to a UI.

We have different apps with different trade-offs. [Eidolon][eidolon] (our Auctions Kiosk app) which contains a lot of Artsy-wide unique business logic which is handled with local state like card reader input, or unique user identification modes. [Emergence][emergence] is a trivial-ish tvOS app which has a few view controllers, and is mostly handled by Xcode's storyboards.

Eigen is where we worry, other apps are limited in their scope, but Eigen is basically the mobile representation of Artsy. We're never _not_ going to have something like Eigen. 

We eventually came to the conclusion that we needed to re-think our entire UIKit stack for Eigen. Strictly speaking, Objective-C was not a problem for us, our issues came from abstractions around the way we built apps.

Re-writing from scratch was not an option. That takes a lot of time However, a lot of companies used the Objective-C -> Swift transition as a time to re-write from scratch. We asked for the experiences from employees who had opted to do this, they said it was a great marketing tool for hiring - but was a lot of pain to actually work with day to day.

In the end we came to the conclusion that we could try build a component-based architecture either from scratch ( one very similar to the route Spotify ([hub][hub]) or Hyperslo ([Spots][spots]) took ) or inspired by React ( like Bending Spoons ([Katana][katana]) ).

Post-discussion we had two big software projects to work on, Live Auctions for iOS, and a re-design of the initial Home screen. 

I'm cautious of someone reading this and TLDRing "Orta/Artsy say Swift sucks" - it doesn't. It is not the right choice for our business today.


### Swift's upsides

* Inter-operable with Objective-C, no re-write required
* Great for teaching
  - Would love a Playgrounds.app for Mac

* Great for building encapsulated systems
  - Types work well here

* You can use whatever new features are released 
* Nascent community we were already members of
* 


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
 - Small pool of active contributors to OSS

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

[eidolon-postmortem]: http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/
[emergence]: https://github.com/artsy/emergence
[live-a]: http://artsy.github.io/blog/2016/08/09/the-tech-behind-live-auction-integration/
[artsy-rn]: 
[what-is-artsy-app]: /blog/2016/08/24/On-Emission/#Why.we.were.in.a.good.position.to.do.this
[eidolon]

[spots]: https://cocoapods.org/pods/Spots
[hub]: https://cocoapods.org/pods/HubFramework
[katana]: https://cocoapods.org/pods/Katana
