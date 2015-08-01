---
layout: post
title: "Open Sourcing Energy"
date: 2015-08-01 13:54
comments: false
categories: [ios, mobile, energy, open source, oss]
author: Orta Therox
github-url: https://www.github.com/orta
twitter-url: http://twitter.com/orta
blog-url: http://orta.io

---

The Artsy Mobile team is pretty agressive in our stance on [Open Source by Default](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html). We've talked about it at [conferences](https://www.youtube.com/watch?v=2DvDeEZ0NDw&spfreload=10) [around](https://www.youtube.com/watch?v=SjjvnrqDjpM) [the](https://www.youtube.com/watch?v=zPbLYWmLPow) [world](https://speakerdeck.com/orta/ios-at-artsy), in [renowned magazines](www.objc.io/issues/22-scale/artsy) and on [our blog](http://artsy.github.io/blog/2015/04/28/how-we-open-sourced-eigen/).

It's worth mentioning that we don't just talk externally about Open Source. Internally the entire development team runs talks, explains how GitHub works and what the implications of all our work in the open are. We strive for an open culture in more than just the development team. The development team is just further along in the process.

The Open Source app idea started with an experiment in the Summer of 2014, asking "What does a truely Open Source App look like?"  The outcome of that was our Swift Kiosk app, [Eidolon](https://github.com/artsy/eidolon/). Open from day one. We took the knowledge from that, and applied it to our public facing app, [Eigen](https://github.com/artsy/eigen/). Open from day 806. That made 2/3rds of our apps Open Source. 

Let's talk about our final app, [Energy](https://github.com/artsy/energy). Open from day 1427 and ~3400 commits.

<!-- more -->

----------------

![ENERGY](/images/2015-08-01-open-sourcing-eigen/ENERGY.png)

{% expanded_codeblock lang:sh %}

  Hardware Model:  iPhone5,2
  OS Version:      iPhone OS 8.1.2 (12B440)

  Exception Type:  SIGSEGV
  Exception Codes: SEGV_ACCERR at 0x10
  Crashed Thread:  0

  Thread 0 Crashed:
  0   libobjc.A.dylib                      0x2fa2ff90 lookUpImpOrForward + 48
  1   libobjc.A.dylib                      0x2fa2ff57 _class_lookupMethodAndLoadCache3 + 32
  2   libobjc.A.dylib                      0x2fa361d9 _objc_msgSend_uncached + 22
  3   UIKit                                0x2573f4bd -[UIScrollView _getDelegateZoomView] + 68
  4   UIKit                                0x2599b757 -[UIScrollView _offsetForCenterOfPossibleZoomView:withIncomingBoundsSize:] + 42
  5   UIKit                                0x25d22b09 -[UIView _nsis_center:bounds:inEngine:] + 892
  6   UIKit                                0x257e3e59 -[UIView _applyISEngineLayoutValues] + 120
  7   UIKit                                0x2570a0ef -[UIView _resizeWithOldSuperviewSize:] + 150
  8   UIKit                                0x25705b9d -[UIView layoutBelowIfNeeded] + 672
  9   Artsy                                0x00058087 -[ARArtworkView setUpCallbacks] + 1238
  10  Artsy                                0x00039da5 -[Artwork onFairUpdate:failure:] + 332
  11  Artsy                                0x001c9b3f -[KSPromise resolveWithValue:] + 374
  12  Artsy                                0x001c8ccb -[KSDeferred resolveWithValue:] + 62
  13  Artsy                                0x00039adf -[Artwork updateFair] + 602
  14  Artsy                                0x0008a69d +[ArtsyAPI getFairsForArtwork:success:failure:] + 368
  15  libdispatch.dylib                    0x2ff897bb _dispatch_call_block_and_release + 8
  16  libdispatch.dylib                    0x2ff897a7 _dispatch_client_callout + 20
  17  libdispatch.dylib                    0x2ff8cfa3 _dispatch_main_queue_callback_4CF + 718
  18  CoreFoundation                       0x221f93b1 __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__ + 6
  19  CoreFoundation                       0x221f7ab1 __CFRunLoopRun + 1510
  20  CoreFoundation                       0x221453c1 CFRunLoopRunSpecific + 476
  21  CoreFoundation                       0x221451d3 CFRunLoopRunInMode + 106
  22  GraphicsServices                     0x295430a9 GSEventRunModal + 136
  23  UIKit                                0x25754fa1 UIApplicationMain + 1440
  24  Artsy                                0x0001dea3 -[Sale .cxx_destruct] + 194
  25  libdyld.dylib                        0x2ffa9aaf start + 0

{% endexpanded_codeblock %}



Energy is commonly known as [Artsy Folio](http://folio.artsy.net). It's a tool for Artsy's Partners to showcase their artworks on the go, and quickly email them. Here's a beautiful splash showing it in action.

{% expanded_img http://folio.artsy.net/images/cover-bbf6fdf4.jpg Folio overview %}

This app comes from the pre-CocoaPods, pre-ARC, pre-UICollectionView and pre-Auto Layout days. It spent 3 years with no tests, but has come up to over 50% code coverage in the last year. It's testing suite is super fast, given that we learned a lot with Eigen's tests we stuck with five main principals: 

* No un-stubbed HTTP requests.
* Avoid `will`s in a test as much as possible.
* Never allow access to the main Core Data instance in tests
* Dependency Inject anything
* Use snapshots to test view controller states

### On Opening Folio

Folio is interesting in that it has competitors. To some extent the Kiosk app does too, but the cost of entry there is really high in comparison. Folio on the other hand, has a handful of competing businesses who exist to _only_ build a Gallery/Museum/Collector portfolio app. In opening the code for Folio, we're not making it easy for people to copy and paste our business, it's very directly tied to Artsy's APIs and [CMS](http://www.dylanfareed.com/projects/artsy-cms/). 

I commonly get questions about the process of Open Sourcing an app, so here's what happened after I decided it was time. First, I emailed my intent:

{% expanded_img /images/2015-08-01-open-sourcing-eigen/oss-energy-email.png %}

The concepts I wanted to cover were: "This is a codebase is worthy of art", "We know what we're doing", "This doesn't make it simple for someone to create a business off our product" and "I've managed to get a lot of the source out already." I gave a month or so to ensure that I can have corridor chats with people in order to be certain around opinions. We had some dicsussion in the email thread about ways in which an open source'd Energy would impact the team, and overall the reaction was positive. This wasn't surprising, the non-technical parts of the team are regularly kept up to date on thoughts like this.

After the internal announcement I started looking at the codebase, what should be cleaned up. I don't believe a codebase is ever perfect ( just look at Eigen's [HACKS.md](https://github.com/artsy/eigen/blob/3f29f61f2b96f516e9ecf407818b82911b268694/HACKS.md) ) but one thing I learned from the launch of Eigen is that we need a lot of beginner docs to help people get started. So I went into Energy's [docs](https://github.com/artsy/energy/tree/master/docs) directory and started comparing it to [Eigen](https://github.com/artsy/eigen/tree/master/docs)'s. 

With the docs ready, we anticipated the repo change as we did [with Eigen](/blog/2015/04/28/how-we-open-sourced-eigen/). This means making sure all loose pull requests were wrapped up. All code comments were audited. Then we used [github-issue-mover](https://github.com/google/github-issue-mover) to migrate important issues to the new repo. Then we deleted the `.git` folder in the app, and `git init` to create a new repo. 

Given that we have three Open source apps now, I wanted to give them a consistent branding when we talk about the apps from the context of the codebase. It's like programming, if you're writing a similar thing 3 times, definitely time to refactor. 

{% expanded_img /images/2015-08-01-open-sourcing-eigen/oss-design-sketch.png %}

Finally, I started working on the announcement blog post. Which you're reading. I'll send a pull request for this blog post, then when it's merged. I'll make one more final look over how everything looks, then make the new Energy repo public.

### On more than just Opening Source

Eigen, the public facing iOS app, allows people to log in with a trial user account. We also have a known API Key + Secret for the [OSS app](https://github.com/artsy/eigen/blob/master/Makefile#L41-L42). With this, any developer can run a few commands and have a working application to play around in. This makes it easy to look around and see how things are done.

Energy, however, requires you have a Artsy partner account. So opening it up would mean that an OSS developer hits the login screen and is stuck. In developing this app, I've slowly been creating my own partner gallery account based on my paintings and photography. So now when you set up the app to be ran as an OSS app, it will pre-load a known database of artworks and metadata from my test gallery. 

Its easy to imagine that open sourcing something is an end-point, but from our perspective it is a journey. We want to make sure that anyone can download this app, learn how and why it's structured and then run through the app with a debugger to get a deeper sense of how everything connects. Just releasing the code would have been underwhelming. Instead we're aiming high.

I think that there is no higher compliment to your team, and your code than opening it to the public. 

You should open source your app.