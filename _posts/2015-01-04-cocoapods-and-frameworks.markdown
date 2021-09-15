---
layout: post
title: "CocoaPods and Frameworks"
date: 2015-01-04 16:43
comments: true
categories: [iOS, mobile]
author: ash
---

As I mentioned in my [retrospective on Eidolon](https://artsy.github.io/blog/2014/11/13/eidolon-retrospective/), Artsy iOS codebases are often used as testbeds for new CocoaPods features. With Eidolon, we had the opportunity to try out CocoaPods' support for frameworks and Swift. This post is a look back at the month of using dependencies as dynamic frameworks instead of static libraries.

<!-- more -->

Updating was pretty easy: we used a `Gemfile` and `bundler` to specify a pre-release version of CocoaPods, as well as pre-release versions of its dependencies. (Updating now is easy – just run `[sudo] gem install cocoapods --prerelease` to grab the latest beta.)

After updating to CocoaPods, all of our existing code had to be migrated. Previously, we could import all the frameworks we used in the bridging header and they would be accessible to all of our Swift files. [This commit](https://github.com/orta/eidolon/commit/abc359c55d4322d21d88349fbd044bf5b5f04725) is an example of having to add `import Moya` statements all throughout our Swift files that needed to access that library.

One by one, we created podspecs for libraries we were using. Then we would push the podspecs to a fork of that library. By specifying in our Podfile which repository CocoaPods should fetch the code from, we were able to use our own podspecs without bothering the library authors themselves. Some libraries did [accepted pull requests](https://github.com/Quick/Quick/pull/197) to add the podspecs from us.

The final step to update was getting our tests to pass. Up to this point, we had added all of our classes to both the app target *and* the test target. The helpful upshot of this is that all of the test were able to access the Swift classes without us having had declared those classes `public`. Swift classes are `internal` by default, so separating out the app code from the test target required [quite a few](https://github.com/orta/eidolon/pull/4) tedious changes throughout our codebase.

![Level up.](/images/2015-01-04-cocoapods-and-frameworks/levelup.gif)

Eidolon is pretty distinct among iOS applications: from day one, it was developed completely in the open. Developing this kind of app in the open posed some new challenges, including limiting access to fonts for which we have licenses to use but not to distribute. Orta [solved this problem](http://artsy.github.io/blog/2014/06/20/artsys-first-closed-source-pod/) earlier this year by having two pods: one private, and one public, but with identical header files. When installing the dependencies, CocoaPods uses one pod or the other depending on a [complex heuristic](https://github.com/artsy/eidolon/blob/4ae52f166f2d1620f25a59f36e6a87915ba32705/Podfile#L31-L35). However, the names of the pods are used as names for the Swift modules generated from them. Since the pods have different names, the `import Artsy_UIFonts` statements won't make sense if someone only has access to the `Artsy_OSSUIFonts` module. Swift's lack of a preprocessor led to some [hacks](https://github.com/artsy/eidolon/commit/57aa66681727cfed11239f9b5a62bb59fee35f1a). However, CocoaPods now allows you to specify a module name for a pod, so we'll be fixing the issue [shortly](https://github.com/artsy/Artsy-OSSUIFonts/issues/1).

Of course, Swift still has some rough edges, too. Namely, we can't compile our app with compiler optimizations enabled – the compiler will segfault. It turns out that one of our dependencies was causing the segfault – probably just a Swift compiler bug, but we needed a workaround until it's fixed. I got more familiar with post-install hooks when I dipped my toes into Ruby to [disable the optimization on specific pods](https://github.com/ashfurrow/cocoapods-chillax-swift).

Orta used the opportunity of using a prerelease version of CocoaPods to help define the new `plugin` syntax in the [Podfile](https://github.com/artsy/eidolon/commit/cdc8dde011e98878a7dde646d0da75c34c8fd5a9#diff-4a25b996826623c4a3a4910f47f10c30).

One issue that Marius covered in the [CocoaPods blog post](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) is that of bundles. Since a framework is a separate bundle from the app (as opposed to a static library, which is in the same bundle), code that relies on `[NSBundle mainBundle]` isn't going to behave correctly in a framework. An unexpected problem we encountered related to bundles was our use of custom fonts. For Eidolon, our fonts reside in a CocoaPod and, therefore, now in a framework. That means that the font files aren't in our app's bundle anymore and `UIFont`'s `fontWithName:` wasn't finding those font files, regardless our use of the `UIAppFonts` key in any info.plist file. Borrowing a [solution from OpenSans](https://github.com/CocoaPods-Fonts/OpenSans/blob/874e65bc21abe54284e195484d2259b2fe858680/UIFont%2BOpenSans.m#L18-L38), we were able to use CoreText to load the font manually.

Finally, we were done.

![Finally finished.](/images/2015-01-04-cocoapods-and-frameworks/success.gif)

Adopting CocoaPods with support for frameworks early helped us identify features and bug fixes that we could ask the CocoaPods developers for. Now, there is still time to let the team know what awesome feature you'd like to see included, but you'll have to try the fancy new CocoaPods version in order to figure out what that feature is. Sure, CocoaPods 0.36 is still in beta, but since you're already using a pre-1.0 dependency mananger, you're probably cool with trying out awesome, cutting-edge stuff. Try the new release when you get a chance and [let the team know](https://github.com/CocoaPods/CocoaPods/issues/new) if you have feedback.


Our path to using CocoaPods with frameworks was bumpy, but we were the first ones to try. Today, the process is a lot easier.

The CocoaPods team has a [wonderful guide](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) for library authors to adopt the new CocoaPods version, so we'll likely see lots of new pods from open source Swift code, just like we already have with Objective-C.

A sincere thanks to [Marius](http://twitter.com/mrackwitz) and everyone on the CocoaPods team for their dedicated work on the support for frameworks in CocoaPods.

![Great work, team.](/images/2015-01-04-cocoapods-and-frameworks/highfive.gif)
