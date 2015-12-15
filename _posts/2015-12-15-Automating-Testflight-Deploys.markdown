---
layout: post
title: 'Automating TestFlight Deploys using Fastlane'
date: 2015-12-15T00:00:00.000Z
comments: false
categories: [ios, mobile, devops, ci]
author: orta
---

I've been a really [strong supporter](http://artsy.github.io/blog/2015/09/18/Cocoa-Architecture-Dependencies/) of the [fastlane](https://fastlane.tools) toolset. I think it fixes a lot of common developer problems, in a space that Apple doesn't really touch. The command line.

We've added hints of fastlane to our apps at different rates, [Eidolon](https://github.com/artsy/eidolon/) uses fastlane for everything but [Eigen](https://github.com/artsy/eigen/)/[Energy](https://github.com/artsy/energy)/[Emergence](https://github.com/artsy/emergence) have been pretty slow on the uptake, though they have more complicated setups, being App Store apps.

When [Felix](https://krausefx.com/) announced [match](https://krausefx.com/blog/introducing-match-a-new-approach-to-code-signing) this week, I felt like he tackled a problem we face in our [small dev team](http://artsy.net/job/mobile-engineer). I integrated this, only to find that it could also fix my problems with deployment. The rest of this post goes into the "how I did this." You can also cheat and look at the [commits](https://github.com/artsy/eigen/compare/d06270882aadec8f03927455a5229b53dd0a73c8...9eaf9082ebdcdf75f12ad2804260587e01526f2d) directly.

<!-- more -->

First up, a TLDR for [match](https://github.com/fastlane/match). _match is a tool that keeps all of your code-signing setup in a private git repo._ We currently keep them in a shared 1Password vault. By switching to using a private git repo we can can use our existing GitHub authentication for CI to provide access to the certificates for signing on circle.

We use a [Makefile](https://github.com/artsy/eigen/blob/master/Makefile), I know that fastlane provides an awesome tool in the form of [fastlane lanes](https://github.com/fastlane/fastlane#features) - but we're pretty happy with a Makefile, they're the simplest tool that does what we need.

I wanted to lower the barrier for us shipping betas, so I opted to add another build step in the CI process. This step checks what branch is it, and if it's the beta branch, grab the certs, then deploy.

``` sh
deploy_if_beta_branch:
	if [ "$(LOCAL_BRANCH)" == "beta" ]; then make certs; make ipa; make distribute; fi
```

`make certs` is really simple, it runs: `bundle exec match appstore --readonly` which and pulls metadata from a [Matchfile](https://github.com/artsy/eigen/blob/9eaf9082ebdcdf75f12ad2804260587e01526f2d/fastlane/Matchfile). This means we can sign app store builds on CI.

If you don't know what the `bundle exec` prefix is, I'd recommend reading my guide on the CocoaPods website for [Gemfile](https://guides.cocoapods.org/using/a-gemfile.html)s.

The next step is generating an ipa, we do this with [gym](https://github.com/fastlane/gym) via `make ipa` which looks like this:

``` sh
ipa: set_git_properties change_version_to_date
	bundle exec gym
```

It executes some make tasks to ensure we know what git commit each build is, and we use the date to provide a faux-[semver](http://semver.org) for apps.

Gym will build our app, according to our [Gymfile](https://github.com/artsy/eigen/blob/9eaf9082ebdcdf75f12ad2804260587e01526f2d/fastlane/GymFile). Nothing too surprising in there. It will output an [ipa](http://apple.stackexchange.com/questions/26550/what-does-ipa-stand-for) and a [dsym](http://stackoverflow.com/questions/3656391/whats-the-dsym-and-how-to-use-it-ios-sdk) that `make distribute` can handle.

`make distribute` is a pretty easy one, we generate a CHANGELOG via Ruby, then run the command `bundle exec pilot upload -i build/Artsy.ipa`, it will ship it to iTunes Connect after configuration from the [Appfile](https://github.com/artsy/eigen/blob/9eaf9082ebdcdf75f12ad2804260587e01526f2d/fastlane/AppFile). This is great, but it goes one better. It will, by default, run a synchronous check for whether the App has finished processing.

{% expanded_img /images/2015-12-15-Automating-Testflight-Deploys/ci-itunes-screenshot.png %}

This is awesome. I'd like to add a Slack message to tell us that it's shipped too, which would be much easier if we used a [Fastfile](https://github.com/fastlane/fastlane/tree/master/docs#after_all-block). We've not entirely moved all of our apps to TestFlight, this is our first experiment in the space, we've been really happy with Hockey, and still are. However, without trying new things we'll never be able to know what we should consider internal best practices.
