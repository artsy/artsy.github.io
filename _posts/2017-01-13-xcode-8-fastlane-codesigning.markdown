---
layout: post
title: "Xcode 8 Manual Codesigning with Fastlane"
date: 2017-01-13 14:00
author: ash
categories: [mobile, ios, devops, ci]
---

New year, new deploy process! Late last year our mobile team completed the update to Swift 3 (and thus, the update to Xcode 8). The latest version of Apple's IDE includes a lovely feature: automating provisioning profile management! (Note: not sarcasm, the feature is really nice. Check out the [WWDC video](https://developer.apple.com/videos/play/wwdc2016/401/) for an in-depth exploration.)

![Automatic code signing settings](/images/2017-01-13-xcode-8-fastlane-codesigning/xcode-screenshot.png)

However, when I went to make our first [automated deploy](http://artsy.github.io/blog/2015/12/15/Automating-Testflight-Deploys/) today, things didn't work; I got a somewhat cryptic error about code signing.

<!-- more -->

> Code signing is required for product type 'Application' in SDK 'iOS 10.1'

Code signing was failing for our project. Hmm. First step in fixing a bug is always to reproduce it, which I could do locally. I started looking into the code that manages our deploys' signing process and got lost. My colleague Orta was kind enough to give me a hand.

Some background: the Fastlane suite of tools includes [Match](https://github.com/fastlane/fastlane/tree/master/match), which manages your signing certificates and provisioning profiles in a private GitHub repository. We don't use match due to complications with our multiple apps, but we use [very similar logic](https://github.com/artsy/eigen/blob/608f60860165dd9b3c376da00492a3cb36bf5214/fastlane/Fastfile#L95-L130) to clone the repo, extract the certificate and profile, and install the keys on CI.

So what wasn't working?

Well it turns out that Xcode's fancy new automatic code signing was incompatible with our manual process of specifying certificates and profiles. The easy solution would be to simply disable that setting, but that would be a shame: the new automatic code signing makes developing on devices way easier and we didn't want to sacrifice that for the sake of our deploys.

So we went looking and luckily found [the solution](https://github.com/artsy/eigen/pull/2104). We amended our codesigning setup with the [update_project_provisioning](https://docs.fastlane.tools/actions/#update_project_provisioning) and [update_project_team](https://docs.fastlane.tools/actions/#update_project_team) Fastlane actions, and the [update_project_codesigning plugin](https://github.com/hjanuschka/fastlane-plugin-update_project_codesigning). Basically, we disable the automatic signing feature and then manually set the provisioning profile to the one we cloned from our private GitHub repo.

So remember folks, if you're ever asked to sacrifice ease of development for the sake of getting computers to behave, there's probably a better way.
