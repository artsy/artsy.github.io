---
layout: post
title: 'Automating TestFlight Deploys using Fastlane'
date: 2015-12-15T00:00:00.000Z
comments: false
categories: [ios, mobile, devops, ci]
author: orta
---

I've been a really [strong supporter](http://artsy.github.io/blog/2015/09/18/Cocoa-Architecture-Dependencies/) of the [Fastlane](https://fastlane.tools) toolset. I think it fixes a lot of common developer problems, in a space that Apple doesn't really touch. The command line.

We've added hints of Fastlane to our apps at different rates, [Eidolon](https://github.com/artsy/eidolon/) uses Fastlane for everything but [Eigen](https://github.com/artsy/eigen/)/[Energy](https://github.com/artsy/energy)/[Emergence](https://github.com/artsy/emergence) have been pretty slow on the uptake.

When [Felix](https://krausefx.com/)  announced [Match](https://krausefx.com/blog/introducing-match-a-new-approach-to-code-signing) this week, I felt like he tackled a problem we face in our [small dev team](http://artsy.net/job/mobile-engineer). I integrated this, only to find that it could also fix my problems with deployment. The rest of this post goes into the "how I did this." You can also cheat and look at the [commits](https://github.com/artsy/eigen/compare/d06270882aadec8f03927455a5229b53dd0a73c8...9eaf9082ebdcdf75f12ad2804260587e01526f2d) directly.

<!-- more -->

First up, a TLDR for Match. _Match is a tool that keeps all of your code-signing setup in a private git repo._ We currently keep them in a shared 1password vault. By switching to using a private git repo we can can use our existing GitHub authentication for CI to provide access to the certificates for signing on circle.

We use a Makefile, I know that Fastlane provides an awesome tool in the form of [Fastlane Lanes](https://github.com/fastlane/fastlane#features) - but we're pretty happy with a Makefile, they're the simplest tool that does what we need.

I wanted to lower the barrier for us shipping betas, so I opted to add another build step in the CI process. This step checks what branch is it, and if it's the beta branch, grab the certs, then deploy.

``` sh
deploy_if_beta_branch:
	if [ "$(LOCAL_BRANCH)" == "beta" ]; then make certs; make ipa; make distribute; fi
```

`make certs` is really simple, it runs: `bundle exec match appstore --readonly`  which and pulls metadata from a [MatchFile](https://github.com/artsy/eigen/blob/9eaf9082ebdcdf75f12ad2804260587e01526f2d/fastlane/Matchfile). This means we can sign app store builds on CI.

The next step is generating an ipa, we do this with [gym](https://github.com/fastlane/gym) via `make ipa` which looks like this:

``` sh
ipa: set_git_properties change_version_to_date
	bundle exec gym
```

It executes some make tasks to ensure we know what git commit each build is, and we use the date to provide a faux-[semver](http://semver.org) for apps.

Gym will build our app, according to our [GymFile](https://github.com/artsy/eigen/blob/9eaf9082ebdcdf75f12ad2804260587e01526f2d/fastlane/GymFile). Nothing too surprising in there. It will output an [ipa](http://apple.stackexchange.com/questions/26550/what-does-ipa-stand-for) and a [dsym](http://stackoverflow.com/questions/3656391/whats-the-dsym-and-how-to-use-it-ios-sdk) that `make distribute` can handle.

`make distribute` is a pretty easy one, we generate a CHANGELOG via Ruby, then run the command `bundle exec pilot upload -i build/Artsy.ipa`
