---
layout: epic
title: Artsy Mobile 2025 Wrapped
date: 2026-01-09
author: mounir
categories: [mobile, react-native, ios, android]
---

The past year has been an exciting one for our mobile apps (Artsy, Folio and Palette Mobile) and we started to finally get closer to where we want to be: **High-performing and developer-friendly React Native applications, enabling rapid feature iteration and a superior user experience.**

We would like to share with you some of the improvements we did and that might be also applicable on your react-native app.

<!-- more -->

## CI

Thanks to being an open source project, Eigen was eligible to use Github Actions for free! Thanks to having our script separated, and Github Actions and Circle CI having a more or less similar language/concept, this was a trivial migration for us that saved us a good amount of CircleCI tokens.


## Infra

### Expo!

At the end of 2024, after an open RFC named [RFC: Trial Expo in Energy and/or Palette-Mobile, Spike on Eigen Risks, Rewards and Effort](https://github.com/artsy/README/issues/543) , we decided that we are going ahead with Expo. Quickly afterwards, we added Expo with Prebuild on 2 out of 3 of our Apps: The CMS App, named Folio and our design system app, named Palette-Mobile.

For our main app, Eigen, adding `expo` sdk happened faster than we thought after [Microsoft decided to retire VS App Center](https://learn.microsoft.com/en-us/appcenter/retirement). We needed an alternative for code-push, and we settled for Expo over-the-air updates.

Eigen still has a lot of native code us blocking us from fully migrating to CNG. However, our experience from Energy and Palette-mobile has been so far positive. apart from we needed to patch stuff, and we could imagine CNG in Eigen! We will definitely share more about this if it happens.

### The new architecture

Yes! we did it. Expect a blog post about this!.

## Tech Debt

Eigen is an old repo, it's probably one of the oldest react-native apps out there. This comes with a price though. The industry changed a lot the the past years and a lot of the old code can now be done so much more easily (and efficiently).

To address that, we identified some weakness we had and prioritised them and decided to address them. Some notable mentions here include:

### Refactor our navigation

Not long time ago, it was hard for us to imagine our navigation infra all handled in react-navigation. But with more and more screens being rewritten in react-native and RN becoming more performant, it actually finally became possible! and we were so happy to do it. This refactor helped us make it easier to add routes, made our `navigate` helper method go from `320ms` to `70ms`, and most importantly consolidated our Android and iOS navigation infra.

### Our city guide is now fully built with React Native - and is available for Android

The city guide is an old RN component with lots of logic we had in the native side. Although we rarely had issues with it, it was pretty tricky to make any changes there.

### Refactor our push notifications

Our push notifications handling logic differed between iOS and Android, making it tricky to keep the same logic across both platforms because you would need to implement everything twice.

While migrating to the new architecture, we were able to consolidate both platforms thanks to `Notifee` - PR [here](https://github.com/artsy/eigen/pull/12668)

### Better Keyboard handling

This is a favourite for me because proper keyboard handling in mobile apps is an important factor in mobile apps UX, and it was never easy. Until `react-native-keyboard-controller` came for the rescue!

If you haven't already, I recommend you check out this talk from the author Kiryl Ziusko on youtube: [https://www.youtube.com/watch?v=W_Y0Y18aFV8](https://www.youtube.com/watch?v=W_Y0Y18aFV8)

## DX

### Rozenite

You hear a lot of good stuff about RN, but debugging was never a strong point until the last few versions when the new [RN debugger was announced over at React Universe Conf 2024](https://www.youtube.com/watch?v=OwivVpg6Luc) . It was something everyone in the community welcomed and it enabled other additions like Rozenite, that helped us do a lot more from the debugger and bring us "closer" to the web debug experience.

So far, we have plugins to debug navigation events, to inspect our bundle size, networks and monitor performance. See PRs [here](https://github.com/artsy/eigen/pull/12716) and [here](https://github.com/artsy/eigen/pull/12731) and watch the [announcement talk](https://www.youtube.com/watch?v=J0rXmTIGGRk) from this year's React Universe Conf

### Mise

This is not specific to our mobile apps, but it's something we did in all our repos after: [RFC: Migrate from `asdf` to `mise`](https://github.com/artsy/README/issues/550) If you haven't tried it already, you are missing out on a lot. It just works, no drama!

### Yarn doctor and Yarn repair

The most pain we had over the years in our major repo (Eigen), is when devs who don't work often in the repo get back to it. Quite often, something new came out and it isn't trivial. It's why we added these commands to help with some of the failures.

### Better Betas overview

One annoyance we always had when working on branches that require creating multiple betas, is getting the build number. Since we moved our build process to happen on Github Actions, it was only natural to us that while we are at it, to comment the build number on Github.

### Reduce Android build time by 75%

Sometimes, you can make a major improvement with one line of code. This was the case here. Thanks to [Speeding up your Build phase](https://reactnative.dev/docs/build-speed#build-only-one-abi-during-development-android-only) we were able to reduce our build time by 75%. The idea is simple here, instead of building all 4 ABIs (`armeabi-v7a`, `arm64-v8a`, `x86` & `x86_64`), we build only the one that is relevant for us: `arm64-v8a`

## Performance

Last year, we did a lot of work to improve our mobile vitals. The most clear one was TTI. That was so fun to work on, and we think the changes we brought can be applied anywhere.

What we did was pretty simple:

- Fetch only what you need
- Fetch before you need it
- Fetch things separately when possible

**Example:**

Let's think of how we can optimise the fair screen query: This is a query that fetches the fair metadata, overview, exhibitors, and artworks.


<img src="/images/2026-01-09-artsy-mobile-2025-wrapped/fair-screen.gif" />

1. Define a query that fetches only the artist image and metadata
2. Prefetch that query whenever there is an artist visible - before the user taps it!
3. Define the other tabs queries and apply the same concept to the tabs queries


**Example:**
To render the exhibitors tab, we don't need just one query. In our case, because getting the artwork for each exhibitor was taking a long time, we had multiple queries, one to get the exhibitor metadata, and another query to get the artworks, that is only triggered when the exhibitor rail is close to the viewport

<img width="600" src="/images/2026-01-09-artsy-mobile-2025-wrapped/query-optimization.png">
   

**Bonus:** Because the first query result is the same to all users (the artist name and image is always the same) - we can actually cache that query in our cloudflare CDN and return it immediately.

We applied the same concept to most of our major screens and in many cases, we were able to bring the TTI to under 100ms thanks to hitting the cache, making the navigation in the app feel seamless.

In addition to making our main queries faster, we also went through a rabbit hole investigating high CPU issues affecting fps. Traditional memoization fixes were not enough. What helped us was Xcode View Hierarchy, which showed that we were always loading skeletons behind our image, even after the image was loaded. 

<img width="600" src="/images/2026-01-09-artsy-mobile-2025-wrapped/view-hierarchy.png">



## What's next?

We're excited for what's ahead in 2026! The React Native ecosystem continues to mature, and we're looking forward to more stable releases that'll make our lives easier 🤞

One area we're particularly excited about is improving our developer experience with AI tooling. We've started experimenting with Claude and leveraging Skills to make AI assistants more effective in our repos. The idea is simple: instead of the AI having to figure out our conventions every time, we can document our patterns, architecture decisions, and common tasks in a way that makes collaboration seamless. Early results have been promising, and we're excited to see how this evolves.

If you're interested in any of the topics we covered here, feel free to reach out! We will be happy to share more details about it.