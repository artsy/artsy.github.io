---
layout: post
title: 'Cocoa Architecture: Dependencies'
date: 2015-09-18T00:00:00.000Z
comments: false
categories:
  - ios
  - mobile
  - architecture
  - dependencies
author: orta
series: Cocoa Architecture
---

As a part of going through the design patterns we've found in the creation of the Artsy iOS apps, I'd like to talk a bit about some of
the way in which we decide our apps dependencies.

It's easy to think of your dependencies as being things in your Podfile, but it's a bit more nuanced than that. The tools you use for development, deployment, testing and external integrations are all things in which you depend on others to make your app work. I'd like to look into the hows and the whys of the decisions we've made.

<!-- more -->
--------------------------------------------------------------------------------

The mobile team of is a collection of smart people; we aim to work with people who have different opinions, and different backgrounds. This means we often don't agree on project direction but moving forwards is about finding compromise. Every technical project within Artsy has a de-facto leader, and they get to make the call at the end of the day.

This means that dependencies and priorities change per-project, because a different developer has more influence on the end result. There isn't a singular "Artsy Mobile" way.

### Implicit Dependencies

Thinking on the largest macro scope, I think these are our biggest dependencies:

* Xcode
* iOS SDK
* Swift
* CocoaPods
* Individual Pods
* Fastlane

Some of these are mandatory, mainly Xcode and the iOS SDK. Talk to someone at Facebook however and they'll tell you even that can become a [much weaker dependency](http://facebook.github.io/react-native/) than you'd think. For us though, we still create native apps that eventually get built via `xcodebuild` either via Xcode/AppCode/Vim as a part of our individual build processes.

The dependencies provided by Apple are the daily trade-off in order to build apps that are competitive. Apple ships a new SDK each year, developers need to ship new builds. If you can keep pace, then you can get your app in-front of millions of potentially paying customers.

### Leveraging OSS

So, allow me to don my best flame-proof suit and answer the intent of the question that was originally asked of us? _What qualities do we look for in OSS dependencies?_

This question is interesting because we're not just shipping an app in the dark, every app we have is open source and available for inspection. Our choices with OSS dependencies become our implicit public recommendations, why else would we be using them?

To to give the simplest TLDR; I created the [CocoaPods Quality Indexes](https://guides.cocoapods.org/making/quality-indexes). The Quality Indexes (QIs) are a series of metrics that are applied programmatically to every library which generate a single number that [cocoapods.org](http://cocoapods.org) uses for search ranking. These are based on conversations within Artsy, and as many contributors as I could during the course of a year. Here are a few QIs that matter a lot to me:

* The library is popular, this is measured in GitHub stars.
* Great README, has a CHANGELOG and uses internal appledoc/headerdoc.
* The project has test coverage.

If you're interested in the reasoning behind these, I'd recommend reading the [full guide for the metrics](https://guides.cocoapods.org/making/quality-indexes).

If I could determine that a project was a good dependency via code - I wouldn't be writing apps, I'd be a millionaire, who has moved on to working in politics or cryptography in Denmark. So what are the key metrics that not Turing-compatible?

#### Can We Take Over?

We're a pretty versatile bunch of developers, even with our focus on native iOS development. Being able to understand a foreign codebase when debugging a problem, in order to [grok](http://dictionary.reference.com/browse/grok) if a bug lies in our code or a libraries is essential.

Being blocked because you don't understand how to create an assembly trampoline for message passing on 64 bit processors sucks. Relying on someone else to provide a fix in their spare time, is a nice way to strain a relationship.

There have been times when we've taken over libraries completely, which has worked out well for everyone involved. Examples being [NAMapKit](https://cocoapods.org/pods/NAMapKit) and [Specta](https://cocoapods.org/pods/Specta)/[Expecta](https://cocoapods.org/pods/Expecta). It can be a matter of providing small incremental work on the project, or just being someone with a vision [for the project](http://orta.io/rebase/oss-management/).

#### Features vs Hidden Dependencies

A dependency can offer you shortcuts to features, new ways to do things or a way to interface with externalities. When you look at the README you get to see all of the best parts of a library, the reasons why it's worth trying, the easy installation instructions. You don't get to see some of uglier issues under the surface, that only become exposed once you look a bit harder.

These can be subtle for example, using Fastlane introduces a lot of dependencies.

``` sh
~/dev/scratch ⏛  cat Gemfile
gem 'fastlane'

~/dev/scratch ⏛  bundle install
[...]
Bundle complete! 1 Gemfile dependency, 73 gems now installed.
```

There's a trade-off here, Fastlane provides a great programmable API to a bunch of really annoying time-consuming tasks. There isn't a system similar to CocoaPods' subspecs which lets a library consumer choose to use a subset of a dependency graph, so instead everyone gets `slack-notifier` regardless of if you need it.

ReactiveCocoa feels quite similar. In exchange for Cocoa-native approach to Functional Reactive Programming you also have:

* Swizzling dealloc on objects in order to do it's magic KVO-unbinding at runtime.
* To pretty much giving up on trying to use the stack trace for understanding flow. Instead you can use their custom dtrace instrument.
* Complicated pre-compiler macros that can get tricky to debug.

These trade-offs can be happily made in exchange for ReactiveCocoa's well thought out API. Functional Reactive Programming is something that the majority of us are particularly interested in. Since Swift came out, a few Swift-only FRP libraries have been released. So we've been keeping our eyes [on the alternatives](https://cocoapods.org/?q=summary%3Areactive).

#### Focus

Ideally you're bringing in a dependency for one specific task. Something like [ObjectiveSugar](https://cocoapods.org/pods/ObjectiveSugar) is a great example of a small focused library. I studied it's API when we first integrated it, and it's not really changed at all since. The library authors have done a great job of ensuring that Objective Sugar stays on-topic.

#### Community Relationships

The amount of energy you have to put into using certain dependencies, in an engaging way like we do, also means you have to interact with external people. This is often the case with OSS, so we’re used to that and quite good at it. Sometimes, however, people and their opinions don’t match, it’s a fact of life, and in these cases it can be worth choosing to not use a certain dependency.

One such example has been ReactiveCocoa. While they are free to make whatever decisions they like, we feel that we’ve wasted energy on supporting their dependencies in CocoaPods that took away from our already constraining time-budget. Our interactions consume and creates energy that we don't want to be associated with. This makes us want to engage less with the community at whole, which is really not something we want. So that, combined with our opinion on the framework itself (as aforementioned) means we’re looking at alternatives.

This contrasts sharply with working on Fastlane, where we're willing to take the dependency graph in part because working with [Felix Krause](https://krausefx.com) is such a pleasure. We've sent PRs,  helped out on [documentation](https://github.com/KrauseFx/fastlane/pull/173) and provided advice on how we would/are using Fastlane. I actively feel guilty that we're still not deploying to the App Store using Fastlane because of this relationship.

#### Project Maturity

We got burned by working with Swift too early, but coming back at Swift 2.0 feels good. We just started introducing Swift into our Objective-C codebases, as it's looking like the tooling has matured.

We spent a good chunk of time over the last 6 months discussing and testing out React Native as an approach for building apps. It's turning into an amazing platform, but for us it's not mature enough to start building apps with it as a foundation.

## Not All Dependencies are Third Party

We ship a lot of our internal code as Pods. The rubric we use for deciding on when to externalise code is "would we want this in more than 2 apps" at the moment. This is an easy choice for libraries as fundamental as a fonts, or colours schemes. It becomes a more nuanced choice when it comes to [a class or two](https://github.com/ashfurrow/Forgeries), or [some functions](https://github.com/orta/ar_dispatch).

Creating a library that gets popular can also turn into an unexpected time-sink, we've been supporting [ARAnalytics](https://cocoapods.org/pods/ARAnalytics) for 4 years now and nearly all features for the last 3 years have come from external developers. Ensuring that they don't break the build, making monthly releases and keeping documentation up to date takes time. [Moya](https://cocoapods.org/pods/Moya) has consumed multiple weekends in a row of our time.

Ensuring that we are good stewards for the code we release as a separate consumable library is important to our team values. We've not had to deprecate a library, though I look forwards to doing that to [ORStackView](https://cocoapods.org/pods/ORStackView) at some point when everyone is building for iOS9+.

### Nuance

There are no simple answers to "should you use a certain dependency". The CocoaPods QIs can give you a sense of what libraries are worth looking into, then you can load up a demo for the library by running `pod try [Podname]` to dig around and get a feel for how the library works. These decisions end up being quite personal.

We work with external dependencies because we enjoy:

* Working with other people.
* Making improvements for the entire community, instead of just ourselves.
* Not having to re-invent the wheel.

For us, it's nearly always win-win.
