---
layout: epic
title: "Echoes From the Past: Supporting Old App Versions"
date: 2020-12-31
categories: [teams, mobile, ios]
author: ash
---

[In, a recent blog post](https://artsy.github.io/blog/2020/03/02/ios-deploys-super-weird-totally-normal/), I discussed a fundamental difference between web and iOS deployments. Web software is deployed to servers that are under your control, while iOS software is deployed to users' devices that you have _no_ control over. This distinction really changes how you think about the code that you ship, because that code could be running indefinitely on devices that never get updated.

The previous post focused on this distinction through the lens of accidentally shipping (and then fixing) a bug. This focus on bugs is important, but focusing _only_ on bugs left me unable to articulate an important, nuanced distinction between hosting code and shipping app binaries. So let's dive in.

<!-- more -->

Software, ideally, is made up of more than just bugs; it has working code, too! Just like with (accidentally) shipping bugs, you need to be aware that the working code you ship is _also_ going to be running indefinitely. That puts pressure on developers to make sure that the code in their apps will continue to function correctly, even as (for example) the web APIs that the apps rely on get updated over time.

## A Case Study

Artsy's iOS app relies on a services we call "[Echo](https://github.com/artsy/echo)" to serve remote configuration. This lets Artsy do things like selectively disable features (for example, to make non-backwards-compatible API changes), provide changes to URL-routing (to match corresponding changes to web URLs), or even to _require_ users on older versions of the app to update (which we have never had to do). Echo has helped Artsy meet its business goals and building this remote configuration for the app was a great idea.

However... Echo was built as a general-purpose remote-configuration-as-a-service, in anticipation of being used by other apps. That use never materialized. It had a web portal and a database and an API, all to only ever serve a single JSON response to the app. That's fine, sometimes engineers build things that don't end up getting used widely as we expected. Echo did one thing, and it did it really well. It ran on a Hobby Dyno on Heroku without incident for years.

If you think about what I've discussed so far in this post, you may realize that the app _depends_ on Echo. If Echo changes in some non-backwards-compatible way, then the app could break. For example, if Echo happened to stop working entirely, then the app could stop working too.

The Echo service went without being deployed for several years. It worked, so why update it? The problem was that at some point, its major dependencies got yanked, so we could no longer build it locally or even deploy it at all. Yikes. I asked a web colleague for help and our conclusion was that it would take more effort to get Echo working with its existing code than it would be to rebuild the whole thing. Double yikes. And finally, Echo was running on the [Cedar-14 Heroku stack](https://devcenter.heroku.com/articles/cedar-14-stack), which was already at end-of-life and had stopped receiving security updates. Triple yikes.

(I have to note here that most of services at Artsy are deployed almost constantly – Echo was an odd one out. Echo never needed any updates, so it never needed to be deployed. However, we should have been keeping its dependencies up to date and deploying it regularly, which would have uncovered its problems sooner when they were still easily fixed. Anyway!)

So we have a service, Echo, that we can't develop, and can't deploy, and isn't getting security updates from our cloud provider. And the app depends on it. Since Echo had always been a bit over-engineered for what it ended up being, I wondered what the minimal replacement could be. My plan was to replace the Echo server with an S3 bucket, an Artsy-controlled CNAME DNS record, and a small shell script that runs automatically on CI.

Seriously! [It worked](https://github.com/artsy/echo/pull/39)! I made a proof-of-concept and then another engineer, [Pavlos](https://github.com/pvinis), finished building the new infrastructure. Changes to the app's configuration are now done via GitHub pull requests ([here is an example PR](https://github.com/artsy/echo/pull/63)), which we can track over time (unlike the old web interface). 

I can't stress enough how much worry I had had about Echo's degrading status and the app's dependency on it. But! Everything about the change to S3 went smoothly.

Okay, so new versions of app are now referring to the S3 bucket instead of the old Echo API. Great! But what about the older versions of the app that are still out there? They're still hitting the Echo API as intended, right?

## The Problem

Echo's API was still functioning, albeit on an EOL stack that we couldn't make any changes to. Since we can't rely on Heroku continuing to run the Echo API indefinitely, what could we do? Well, the easiest way to fix this would be to change Echo's Artsy-controlled CNAME record to point from the old Cedar-14 Heroku app to a new server app, which could pretend to be the old API for the sake of older app versions.

This leads me to one of the most scary lines of code in the entire Artsy iOS codebase. See if you can spot the problem.

```objc
NSURL *url = [[NSURL alloc] initWithString:@"https://echo-api-production.herokuapp.com/"];
```

For whatever reason, we never created an Artsy-controlled CNAME DNS record for Echo. We were just hitting the bare Heroku URL directly. That means that there are _seven years'_ worth of Artsy app versions out there that _need_ to be able to continue hitting _that specific_ Heroku URL.

😬

This is what I meant earlier about how you need to think about properly-working code differently when you develop software that runs on someone else's hardware. If this was a server, this whole problem of old-code-hitting-outdated-APIs wouldn't exist. But because we ship apps as binaries that get ran on someone _else's_ hardware, we need to be aware of this kind of issue.

That URL was fine when the code was written and it worked as intended for years. No one could have predicted, when it was added, that it would cause us headaches much later. Nor could we have anticipated that the Echo server's codebase would end up in such a state.

## The Solution

This is the part of the blog post where I get to be a hero (at least in my head). The Heroku app running Echo was on Cedar-14 and while we couldn't make any changes to its code, we _could_ replace the code entirely. This would give us a new server running at the old URL. So I wrote up a small Express server to proxy HEAD and GET API requests from old iOS app versions to return the response body and headers that were expected. [The work is here](https://github.com/artsy/echo/pull/59#) if you're curious. The nice thing about Heroku, at least, is that if this had gone horribly wrong we still could have reverted back to the Cedar-14 app while we figured out our next steps.

We will still need to keep this Heroku app running, indefinitely, which isn't ideal. Perhaps Artsy's migration to Kubernetes will never be _quite_ 100% complete, but that's a small price to pay for keeping users of our app happy.

## Conclusion

It's not just bugs that you need to be aware of _accidentally_ shipping in your app binaries. You have to think about how the code that's running _as intended today_, because it will continue to run for the foreseeable future. This means adding checks for non-200 response codes from APIs, being careful about third-party APIs, and thinking carefully about everything you ship. Apps are more than just their code; apps are everything that their code depends on, too.

This is a lesson that I've been teaching engineers for a long time, but it's only with our recent Echo changes that I've come to understand, at a deeper level, what it means to take ownership of code. Yes, the bugs, and of course, the happy little accidents, but also the mundane interconnected dependencies that make software systems so complex. And, if I'm being honest, that make software systems so much fun to work on, too.
