---
layout: post
title: "Artsy's first closed source Pod"
date: 2014-06-20 17:53
comments: false
sharing: false
categories: [Testing, Objc, Cocoa, Xcode, Plugins, iOS]
author: orta
---

When I joined Artsy, [dB](http://code.dblock.org) pitched me this idea: _Open source as default._

I took this to heart. I genuinely believe the idea behind the philosophy. It's cool that our real product isn't our implementations on the web or native but the data which powers it - [the Art Genome Project](https://artsy.net/theartgenomeproject). Similarly, I spend a bunch of time [on](https://github.com/AshFurrow/ARCollectionViewMasonryLayout) [open](https://github.com/dblock/ARASCIISwizzle) [sourcing](https://github.com/dblock/ios-snapshot-test-case-expecta) [solid](https://github.com/dblock/ARTiledImageView) [abstractions](https://github.com/dstnbrkr/DRBOperationTree) [from](https://github.com/orta/ORSimulatorKeyboardAccessor) [our](https://github.com/orta/ORStackView) [apps](https://github.com/orta/ARAnalytics), always taking the opinion if something is used in more than one place, it should be open sourced.

This week I pushed some libraries that were a bit different, read on to find out why.

<!-- more -->

## The problem

I was modernizing a section of [Folio](http://orta.github.io/#folio-header-unit) that hasn't changed in 2 years to use custom UILabel subclasses consistent with [the Artsy iOS app](https://iphone.artsy.net) and realized I was copying and pasting a large amount of code from one app to the other. This got me thinking about ways to keep this code in one place, as we might start another project which needs these same styles soon.

## The solution

I didn't want to put it on the public CocoaPods Spec Repo, because it's not very relevant to the larger community, but in keeping with our philosophy of "open source by default," I definitely wanted to publish it as an example for others. The most elegant answer was to create our own [public Specs Repo](https://github.com/artsy/specs), which serves as a good reference when people want to know what a private specs repo looks like.

Like anyone who has tried to modularize a pretty large code-base, it turns out a lot of things were connected together. I couldn't just build my [Artsy+UILabels](http://github.com/Artsy/Artsy-UILabels) repo and put everything in there. Instead I had to also build Artsy+UIFonts and [Artsy+UIColors](http://github.com/Artsy/Artsy-UIColors).

One of the good things about having to build three libraries is that I became very familiar with `pod lib create`. This is a command for building the scaffolding around a CocoaPod, making it much easier to create something fast. We had been holding off doing a [big update](https://github.com/CocoaPods/pod-template/pull/33) to the command because no-one knew what WWDC would bring. Now we know, so I've worked on a new version of the command that programmatically manipulates an example project via [xcodeproj](https://github.com/CocoaPods/Xcodeproj). I've used it in creating all of these libraries. Expect to see it on the CocoaPods blog soon.

## Caveat

I built three libraries, but one of them is unique. I modelled Artsy+UIFonts from [Kyle Fuller](http://kylefuller.co.uk)'s [OpenSans-pod](https://github.com/kylef/OpenSans-pod), where the CocoaPod has the font resources and installing it moves them into your project. This is great for a free or open-source font, but would break commercial font licenses. For that reason, we don't have the ability to open source that project. Thus Artsy Mobile's first closed-source library.

This is a great example of how you can build a private specs repo, whilst the public-private aspect is not applicable to most companies. I find it to be a nice halfway house between open source as default, and keeping something internal. For more info on setting up your own private specs repos, [check the guides](http://guides.cocoapods.org/making/private-cocoapods.html).
