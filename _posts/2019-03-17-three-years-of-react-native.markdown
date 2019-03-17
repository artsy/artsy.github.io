---
layout: epic
title: "Three Years of React Native"
date: "2019-03-17"
author: [orta]
categories: [react-native, ios, community]
comment_id: 521
---

On Valentine's day in 2014, @alloy made our first commit moving the Artsy Mobile team to JavaScript, and paving the
way to the shared Omakase JS stack across web + iOS. We've done a write-up at [6 months], [1 year], [2 years] and
at 2.5 years we ran a React Native conference which features a [very long Q&A][q_a] session.

Our experience has been really positive building a single platform data-driven app. We've been able to drastically
increase the number of contributors to the codebase and we barely need to train web-developers to have them be
productive in making our iOS apps.

That said, for this 3 year anniversary, I want to dive deep into some of the less positive aspects. It's important
to note up-front that we're not planning on moving away from React Native - and for the business, these trade-offs
are worth it.

<!-- more -->

## De-nativification

The largest change that came out of React Native was the de-empathizing of iOS as a platform for Artsy. From an
engineering team's perspective, we think of it as [de-siloing][desilo]. Prior to the move if you were on the mobile
team you had a limited scope to make change at Artsy, and a pretty short . This comes from two facts:

- To most of the world, and internally to the company, we're considered a website
- Skills in Obj-C and Swift are only useful in the context of a single platform. E.g. you can't contribute to the
  many back-ends, or sites

If your company is a mobile-first company, being on the team working on the iOS or Android platforms means you've
got a lot of space for personal growth. This was one of the major blocking points for AirBnB's adoption of React
Native, their native teams felt uncomfortable at the introduction of JavaScript and a whole new toolchain inside
their apps. (This is a gross simplification, check out [their posts][airbnb] (and [Ash's continuation][ash_airbnb]
))

Within 2 years we had de-siloed mobile completely, we started with a team of 5 experts in iOS native and by the end
everyone had very solid skills across the board in React, Node, GraphQL and the build tools we'd need to make it
all come together. As people from the original native team left Artsy (most of which now use these new skills in
their careers instead) we didn't backfill those posts as native, but from the web world - because that was what we
as a business needed.

It took till the end of 2019, for us to decide to bring back an explicit iOS-specific culture to Artsy - when we
split our front-end practice into web and [iOS][fe-ios]. Not as an admission of failure, but that our front-end
practice meetings rarely covered iOS agendas.

## Platform Concerns

De-siloing obviously wasn't without its risk. In expanding the scope of our mobile engineering team, and opening up
the iOS app for contributions to the rest of the company we:

- Moved the engineers with a native focus to act more like platform engineers vs product engineers
- Had iOS native platform engineers with the skills to also work on the web's platform

This is what started to make our third year tricky. In Artsy, web is the [squeaky wheel][wheel]. The iOS app, and
it's infra are particularly stable because we are extremely conservative about dependencies, and systems change
much less often.

On the web side, we saw the most amount of growth in hiring and complexity needed to handle that. After figuring
out the infrastructure for iOS, we replicated that infrastructure on the web to consolidate tooling and ideas
across all of Artsy, that infrastructure is much bigger and requires a lot more engineering time. The tooling has
more client consumers, and a more than double the of commits a similar time-frame.

This is a bit disingenuous, in part because sometimes infra for web and "front-end" infra (which affects both
platforms) can be hard to de-tangle. However, it's been hard to find time and space to do iOS-specific platform
work like upgrading React Native, deployment improvements and quality-of-life iOS user experience work.

We kinda set this up ourselves, our web infra is also an really interesting problem - and the few people with the
skills to work on our React Native infrastructure also happen to have the skills to work on those problems to.

## Keeping up with the Jobs'

As individual developers, it's much less important for us to keep up to date with the latest Apple developer news.
WWDCs and iOS releases just kinda happen, and we keep moving independently. We still support iOS 9, and have very
little incentive to bump it - new APIs from Apple just aren't that interesting.

This is a side-effect of the openness of the JavaScript toolchain, and our ability to contribute and fix a lot of
our own problems at JavaScript level instead of needing to dive deeper into the native side to work on problems.

Without a focused iOS team, it's not easy to pitch for iOS related projects. We find it hard to respond issues
which come from App Store reviews, because the ownership can be murky.

That said, in the last year we did manage to ship a pretty hefty [ARKit feature][arkit] - which a positive example
of an iOS-specific feature that is both forward-thinking tech and a super great fit for Artsy's product. React
Native basically played no part in that.

## Community Disconnection

There are maybe four communities at play if you're doing React Native:

- Node (Babel/TypeScript/Storybooks/VSCode)
- React (Hooks/Relay/Styled Components)
- React Native (Mostly people creating cross-platform tools)
- Native (Obj-C/Swift/CocoaPods/Fastlane etc)

It's hard to keep on-top of any one community, and it's very hard to keep on track of four. For the top two, we can
banter with the web side, but we tend to be a lot more native focused vs the React Native side. We've not put much
time and effort towards cross-platform libraries, as we aim to have as little compromises as possible.

Being involved in so many communities, as a part of owning [the Omakase][oma] stack means that it's hard to engage
in the native one with too much excitement. Most of their problems aren't ours anymore.

## Universal Issues?

Are these the kind of problems most teams would have? It depends, as a team put quite a lot of focus on community
work and put in a lot of time to de-silo the mobile team at Artsy. You could definitely focus on

[6 months]: /blog/2016/08/15/React-Native-at-Artsy/
[1 year]: /blog/2017/02/05/Retrospective-Swift-at-Artsy/
[2 years]: /blog/2018/03/17/two-years-of-react-native/
[q_a]: http://artsy.net/x-react-native
[desilo]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#de-silo-engineers
[airbnb]: https://medium.com/airbnb-engineering/react-native-at-airbnb-f95aa460be1c
[ash_airbnb]: https://ashfurrow.com/blog/airbnb-and-react-native-expectations/
[wheel]: https://en.wikipedia.org/wiki/The_squeaky_wheel_gets_the_grease
[arkit]: /blog/2018/03/18/ar/
[oma]: https://www.youtube.com/watch?v=1Z3loALSVQM

<!-- prettier-ignore-start -->
[fe-ios]: https://github.com/artsy/README/commit/95c9b93ab966ed269b5ebd9f0bdec8d2434bab52#diff-342d3433f36fbedadc5a8f167985fdf3
[publishers]:  http://www.niemanlab.org/2018/05/medium-abruptly-cancels-the-membership-programs-of-its-21-remaining-publisher-partners/

<!-- prettier-ignore-end -->
