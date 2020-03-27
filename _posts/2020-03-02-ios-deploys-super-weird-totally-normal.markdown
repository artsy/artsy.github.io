---
layout: epic
title: "iOS Deploys: Super Weird And Totally Normal"
date: 2020-03-02
categories: [ios, deployment, continuous deployment, fastlane]
author: ash
---

Software deploys! What a concept. You have some code running somewhere, and you need to get it running somewhere
else. What could possibly go wrong? While web developers have become accustom to some _really slick_ deploy
processes, iOS developers have to work within some very different constraints.

Today I want to explore the differences between deploying iOS software and front-end/back-end web software. Some of
these differences are inherent to how the code gets executed, and some of the differences are incidental to choices
that Apple has made. These are constraints that iOS developers need to work within. As Artsy has adopted React
Native over the past four years, we have had more and more of our web engineering colleagues contributing to our
iOS app. For these web engineers, getting familiar with the iOS deploy constraints is as important as getting to
know Xcode and CocoaPods.

<!-- more -->

## A Release Case Study

We're going to use a case study to frame today's discussion. Artsy's Mobile Experience team recently got a ticket
from our Platform team. The nature of the ticket itself doesn't matter, but it involved a change we were making to
our API. I fixed the bug and submitted a pull request, which quickly got merged. We tested the bug fix in our next
beta deploy, and everything looked fine. Great so far.

Artsy releases iOS software on a two-week release cadence, and this bug fix was scheduled to be released to users
the following week. But our back-end team wanted to quickly deploy that API change, which would require the app bug
fix to get released to users _first_.

So... what to do?

Do we release off-cadence? Or do we push back on our Platform team and ask them to hold off until the scheduled
release?

Let's actually pause for a moment and consider one of the assumptions we made above. If you're a web engineer, the
idea of releasing only every two weeks might seem pretty strange! I mean, why not release continuously? For
example, Artsy's website gets deployed to our staging environment after every merged pull request, and staging then
gets promoted to production several times a day. This process is generally referred to as "continuous delivery",
and [it has a lot of advantages](https://www.thoughtworks.com/insights/blog/case-continuous-delivery). That's why
it's so common among web engineering teams. So why not use continuous delivery on iOS apps?

## The Executable Problem

There are two reasons we can't use continuous delivery on iOS. First, continuous delivery is only really possible
when you control where the software gets executed (or, in the case of web front-ends, where the client-side code
gets served from). Artsy controls our own servers, so we can deliver web software continuously. The next time a
user makes a web request, they'll get the updated code. However, the Artsy iOS app runs on our users' devices,
instead. We can't push out updates to users' iPhones or iPads in the same way we can push updates to our servers.

iOS apps are binary executables that are distributed through Apple's App Store, and updates to apps have to be
pulled down by devices. Even if _most_ users have automatic updates turned on, those updates are typically
installed overnight. Consequently, there's quite a lag between when we deploy an iOS update and when users run the
code. While it only takes about a week for 80% of our users to update to the latest version, there's a very long
tail after that.

![Graph of in-use versions of Artsy's app, illustrating both the quick adoption of new updates by most users and the long tail of old versions that are never updated](/images/2020-03-02-ios-deploys-super-weird-totally-normal/graph.png)

iOS software is executed in an environment that we don't control, that we can't push updates to, and most
importantly, that we can't roll back deploys on. If we ship a version of our app with a bug, but then ship an
updated version with a fix right away, there is absolutely no guarantee that users will install that update.
_Ever_. That means that _every_ deploy we make to our iOS software requires a lot of confidence in that code. In
contrast, rolling back a web deploy is quite painless. If we ship a bug to the web, no problem: just roll back the
deploy, fix the bug, and re-deploy with the fix.

(Note: some readers might be wondering why we don't take advantage of over-the-air updates to our React Native
JavaScript bundle. This is definitely possible, but our app is brownfield with some native code and some React
Native code and we haven't yet built out the infrastructure for this. As more and more code shifts to React Native,
we plan to investigate OTA updates to JavaScript bundles.)

## Apple's Platform, Apple's Rules

The second reason to deploy iOS software on a schedule, rather than with continuous delivery, depends on the App
Store review process. This is another big difference that takes web engineers a while to get used to. Whenever we
ship a version of our iOS app, we ship it to Apple for review, and then Apple ships it to our users. I'm not going
to debate the utility of Apple as an intermediary – the fact is that they own the iOS platform and these are the
rules they have chosen. If you want to ship iOS software, then you have to abide by Apple's rules.

App Store review isn't exactly QA. I mean, if we were to ship an app update and it crashes upon launch, Apple isn't
likely to approve that update. But if we have a small bug buried somewhere in the app, we can't expect Apple to
find it. Apple is only testing for adherence to their
[App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/). Apple is looking for
things like: is the app trying to steal user data? Is the app displaying objectionable material, given its age
rating? Is the app's description and App Store metadata correct? That kind of stuff.

So not only do iOS software developers need a lot of confidence in every deploy, but they also need to abide by
Apple's guidelines.

Alright. Let's return to the case study from earlier.

## Case Study Resolution

We had a bug fix in our app, and getting it deployed was blocking an important change to our back-end API. First,
we had to consider that some users simply wouldn't get the update. We had to ask ourselves if this would block the
back-end change entirely – through open discussions with the team, we decided to move forward. Second, we had to
consider the other work that had been merged since our last release. Were we confident in deploying that work
as-is? And what amount of QA would need to be done to ship those changes as well?

That last point is really interesting because there was actually another option. Rather than deploy the app based
off the current `master` branch (with the bug fix _and_ other work included), we did something a bit clever.
[fastlane](https://fastlane.tools), the tool we use to automate our iOS deploys, will tag each commit that we
submit to the App Store. So rather than deploy the current `master` branch, which would require very rigorous QA,
we checked out the previous release tag. We then used
[`git cherry-pick`](https://www.atlassian.com/git/tutorials/cherry-pick) to apply _only_ the bug fix changes, and
deployed from there.

![Screenshot from Slack where I detailed my plan to cherry-pick the commits](/images/2020-03-02-ios-deploys-super-weird-totally-normal/slack.png)

This isolated the changes we were making to the app and minimized the amount of QA we needed to feel confident in
our release. Even still, we ran through our usual QA script. As I hope I've demonstrated above, it's always better
to be safe than be sorry when it comes to deploying iOS software.

This `git cherry-pick` approach has its own trade-offs, but it is very effective in the right circumstance. It's an
approach I've only had to use a few times during my time at Artsy, but it's a good approach to be familiar with.
This situation also highlights a benefit of automating iOS deploys: we know _exactly_ which commit each version of
our app is running, making it easy to `git cherry-pick` with confidence.

I hope I've illustrated how iOS software is a bit different from web software, both inherently and incidentally.
Many of these same quirks apply to Android deploys as well. Mobile software feels closer to software sold in
shrink-wrapped boxes than it does to Docker images shipped to Kubernetes clusters. And that's okay. Different
platforms will always have different constraints. Hopefully by understanding these constraints, mobile and web
engineers can gain a greater empathy for one another and, ideally, share ideas and solutions so we can all learn
and grown together.
