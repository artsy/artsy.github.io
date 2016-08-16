---
layout: post
title: How we Open Source'd Eigen
date: 2015-04-28
comments: no
categories: [ios, mobile, eigen, keys, open source, oss]
author: orta
series: Open Sourcing Your App
---

It was 95 days ago, and I was sitting before of my computer in NYC. I loaded my terminal, opened [TapTalk](https://taptalk.me) on my phone, tapped on my collegue [Ash's](http://ashfurrow.com) avatar and held my finger there. I paused, this moment was a long time, it was worth waiting. I switched the camera from my face to the screen with the terminal open.

This moment was probably the most nervous I had been in years. It showed `git push origin master`. I said "it's happening." I hit return. A new era in the Artsy mobile team had started. A few minutes later, I wrote this tweet:

<center>
<blockquote class="twitter-tweet" data-cards="hidden" lang="en"><p>We have open source’d the <a href="https://twitter.com/artsy">@Artsy</a> iOS app.&#10;&#10;<a href="https://t.co/c1SWtHmUgy">https://t.co/c1SWtHmUgy</a>&#10;&#10;🎉</p>&mdash; Ørta (@orta) <a href="https://twitter.com/orta/status/558395611754819586">January 22, 2015</a></blockquote>
</center>


Let's go over the process we went through to get to that point.

<!-- more -->

Credit where credit is due, when we were [working on Eidolon](/blog/2014/11/13/eidolon-retrospective/), our CTO [dB](http://code.dblock.org/) just casually tossed the idea that, really, Eigen should be open source too. Eigen is the code name for the [Artsy iOS app](http://iphone.artsy.net/). This totally threw me for a loop, we were only just getting to a point where we could build an app from scratch in the open. Trying to get a project that had existed for years and had its own momentum converted would take a lot of thinking about.

We devoted time at the end of 2014 to understand what the constraints were for getting the app opened. From a purely functional perspective we would have to start with a [drastic decision](https://github.com/artsy/mobile/issues/11) around the repo itself.

### The Repo

![Rise And Fall](/images/2015-04-28-open-sourcing-your-apps/rise-and-fall.png)

We opted to go for a total repo switch, removing all history. There were a lot of places where keys could have been hiding within the app. To get this done we migrated the existing `eigen` to `eigen-private` on github, and did a fresh `git init`. People who have joined Artsy Mobile post-OSS have never even cloned the `eigen-private` repo. So I feel good about this call.

We used the last few moments of the private repo to remove all of the default Apple copyright notices. We didn't feel they added anything on top of the git history, and made it feel like the founders of a project were more important than anyone working on improvements.

It wasn't all smooth sailing with respect to the repo switch however. As the switch happened the WatchKit came out, and we had devoted quite a lot of time to building an app in it. Given that you [can't predict Apple](http://www.elischiff.com/blog/2015/3/24/fear-of-apple)'s reactions, and you couldn't ship an app with an embedded watch app to the store, we opted to work on a branch from our private repo. [For months](https://github.com/artsy/eigen/pull/302). In the end it was easier to have the two folders next to each other, then copy & paste over all the files and to set all the settings in the Xcode project again.

One of the things that we found a bit sad about the transition to a new repo, is that it's hard to give past contributors recognition for their work. One of the ways we've worked around this is by having a file [documenting past contributors](https://github.com/artsy/eigen/pull/409) in our repo.

### Docs

We had to significantly update our README, and a lot of the process around bootstrapping. We wanted to reduce the friction to actually trying the app as much as possible. It's easy to look at the source on github but to be able to get it up and running quickly should be a really high priority. So our README is based on getting it up and running as an OSS project, not for someone internal who may push betas/releases.

When we opened the repo, there [were a lot](https://github.com/artsy/eigen/pulls?q=is%3Apr+is%3Aclosed+sort%3Acreated-asc) of documentation fix PRs - thanks *segiddins*, *neonichu* and *dkhamsing*. They have low barriers to entry, and fun to make for people looking through big projects. We still get them pretty regularly.

### Secrets

There aren't large sections of the our app that we are keeping secret, though we have discussed ways in which we could. There is however a nice solution to having something different for OSS vs your internal team, API compatible CocoaPods. We [do this](/blog/2014/06/20/artsys-first-closed-source-pod/) for our fonts in all apps. We've talked extensively about our [tools for keeping](/blog/2015/01/21/cocoapods-keys-and-CI/) API keys secret, so no need to go over that twice.

Other than that we had already been opening any good abstractions as CocoaPods for anyone to use. All our dependencies were packaged outside of the app, we had no crazy internal SDKs or anything worth hiding within the codebase.

### Selling the idea

It's one thing to think that it's possible, it's another to do it. I'm glad that I am in a position where I can enact change. I felt no resistence in the process. I kept offering potential avenues for someone to stop me, too. I emailed the entire team as I started the process 2 weeks before it happened, I talked to anyone who might write issues or contribute from the design team. As I got further along the process and sent another email out that it was going to happen tomorrow. All I got were 👍 and 🎉s in [GIF](https://itunes.apple.com/us/app/gifs/id961850017?l=en&mt=12) form. So I kept moving forwards till that tweet above.

From our dev team's perspective, this is not a brave new world. Our website, [force](https://github.com/artsy/force), is open source. Though they operate under different constraints.

From the perspective of Artsy, even though opening our code aligns very strongly with our [values of openness](/blog/2015/03/31/the-culture-of-openness-artsy-mobile/), we are still a company. Opening up our codebase lets our competitors see what we're up to in advance, and [closed source](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html) is still the norm for apps. Opening our code and process is also opening ourselves to criticism.


### Evolution of the team

3 months on the way we operate has changed. We're a lot more organized, and the Eigen repo is easily the most well run project on the mobile team. It has [active milestones](https://github.com/artsy/eigen/milestones), that represent long term goals and the current sprint. We discuss a lot of the interesting cultural choices publicly on [issues](https://github.com/artsy/eigen/issues/221) and in our [mobile team repo](https://github.com/artsy/mobile/issues). Having this app in the open, and the experience of doing so has also improved our workflow on other apps. Eidolon for example now runs with a similar structure.

![Sprint Planning Issue](/images/2015-04-28-open-sourcing-your-apps/sprint-planning-issue.png)

We found that people would use our issue structure to [ask](https://github.com/artsy/eigen/issues/324) [questions](https://github.com/artsy/eigen/issues/313) about Eigen itself. This was an unexpected positive outcome. It gave us a chance to re-think decisions and try to understand how we came to certain decisions that might not be documented anywhere.

Our culture improved by open sourcing our app. As individuals, it's great to know that our work goes towards helping the larger community and all engineers love having a green profile.

<center>
<img src="/images/2015-04-28-open-sourcing-your-apps/staying-green.png" alt="Staying Green">
</center>

If you've not explored the idea of open sourcing your app, you should. We're happy to help out - [create an issue](https://github.com/artsy/mobile/issues/new). Or contact me personally, my email is on my [github profile](https://github.com/orta).
