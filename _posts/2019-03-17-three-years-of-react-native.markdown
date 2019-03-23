---
layout: epic
title: "React Native, 3 years later"
date: "2019-03-17"
author: [orta]
categories: [react-native, ios, community, roads and bridges]
comment_id: 521
---

On Valentine's day in 2014, @alloy made our first commit moving the Artsy Mobile team to JavaScript, and paving the
way to the shared Omakase JS stack across web + iOS. We've done a write-up at [6 months], [1 year], [2 years] and
at 2.5 years we collaborated on a React Native conference with Facebook which features a [very long Q&A][q_a]
session with the people who worked on, and with our React Native stack.

Our experience has been really positive building a single platform data-driven app. We've been able to drastically
increase the number of contributors to the codebase and we barely need to train web-developers to have them be
productive in shipping features to our iOS apps.

That said, for this 3 year anniversary, I want to dive deep into some of the less positive aspects aspects of our
transition. We think these trade-offs are worth it, and that this may be what a successful cultural transition
eventually looks like for some companies.

<!-- more -->

## De-nativification

When adopting React Native, we the de-empathized iOS as a unique platform for Artsy.

From an engineering team's perspective, we think of it as skill [de-siloing][desilo]. Prior to the move, if you
were on the mobile team you only worked on the iOS apps. This meant you had a limited scope to make change at
Artsy. This comes from two factors:

- Skills in Obj-C and Swift are only useful in the context of a single platform.
- Internally and externally, Artsy is considered a website

Within 2 years we had de-siloed mobile engineering completely. We started with a team of 5 experts in iOS native
and by the end everyone had very solid skills across the board in React, Node, GraphQL and the build tools we'd
need to make it all come together. These engineers kept their native skills, but they were blunted with less need
for them.

With time, we redistributed the native engineers across many teams, with the native Engineers effectively acting as
a conduit for ensuring that we keep quality high and providing guidance to the rest of that team on how to make it
feel right. A simple way to think of it, is that the native engineer's job was to make sure we still conformed to
the Apple Human Interface Guideline.

We're reasonably lucky here tpp, the mobile team at Artsy has pre-dominantly hired folks interested in improving
[Roads and Bridges][rnb] style infrastructure. With the move we effectively took all of our native product/feature
developers and moved them into infrastructure roles for JavaScript developers.

This was one of the major blocking points for AirBnB's adoption of React Native, their native teams felt
uncomfortable at the introduction of JavaScript and a whole new toolchain inside their apps. There are people who
really love being a product developer in a native codebase and React Native as a technology de-values that, because
React can make it easy to go from data to screen so much better.

(Note: this is a gross simplification, you should read from the horses mouth and check out [their posts][airbnb]
(and [Ash's continuation][ash_airbnb] on the subject ))

After a year of adopting React Native, we used to joke that no-one enjoyed working in the native codebase anymore.
They still did. Three years down the line, with most screens now in React Native, that's not a joke anymore.

This has consequences.

## Platform Concerns

De-siloing our mobile team obviously wasn't without its risk. In expanding the scope of our mobile engineering
team, and opening up the iOS app for contributions to the rest of the company we:

- Moved the engineers with a native focus to act more like platform engineers vs product engineers
- Had iOS native platform engineers with the skills to also work on the web's platform

This is what started to make our third year tricky. In Artsy, web is the [squeaky wheel][wheel].

On the web side, we saw the most amount of growth in hiring and complexity needed to handle that. After figuring
out the JS infrastructure for React Native on iOS, we replicated that infrastructure on the web to consolidate
tooling and ideas across all of Artsy. We call that infrastructure for both [the Artsy Omakase][oma]. Maintaining,
and keeping the infrastructure up-to-date on the web side is much bigger task and requires a lot more engineering
time.

The web-aspect of Omakase has more client consumers (1 iOS app vs 3 large websites), and it's corresponding repo
have more than double the of commits per month. The web team has it's own people running and improving
infrastructure, which affects the iOS side too.

We kinda set ourselves up for this stress, we explicitly worked towards shared common infrastructure across all
front-end at Artsy. It wasn't surprising when the aspect with the most company focus became much larger. What
creates tricky constraints are that the few people with the interest and skills to work on our React Native
infrastructure also happen to have the skills to work on the web problems too.

Those web problems tend to be a lot more valuable to the business.

There's some work that can be done to benefit both, but in the last year it has been hard to prioritise
iOS-specific platform work. For example, it took almost a year to get around to upgrading our version of React
Native. This is a pretty risky place to be for a platform which we care about.

At the end of 2018, we came to the conclusion that this was something we wanted to work to improve. So, we
specifically brought back an explicit iOS-specific culture to Artsy - when we split our front-end practice into web
and [iOS][fe-ios].

Maybe this is a small admission of failure to the idea of a purely de-silo'd team, but realistically while product
work across the two front-ends teams is consistent - the platform concerns just aren't.

## Keeping up with the Jobs'

As individual developers, it's much less important for us to keep up to date with the latest Apple developer news.
WWDCs and iOS releases just kinda happen, and we keep moving independently. We still support iOS 9, and have very
little incentive to bump it - new APIs from Apple just aren't that interesting anymore.

This is a side-effect to the openness of the JavaScript toolchain, and our ability to contribute and fix a lot of
our own problems at JavaScript level instead of needing to dive deeper into the native side to work on problems.

Without a focused iOS team, it's not easy to pitch for iOS specific projects. This means that features like moving
to Apple's new app store review API or using iOS features which don't exist on web gets talked about in meetings,
but never started. This lack of a focused team makes it really hard to implement fixes to bad App Store reviews

That said, in the last year we did manage to ship a pretty hefty [ARKit feature][arkit] - which a positive example
of an iOS-specific feature which is both forward-thinking tech and a super great fit for Artsy's product. React
Native basically played no part in that.

## Community Disconnection

There are maybe four communities at play if you're doing React Native:

- Node (Babel/TypeScript/Storybooks/VSCode)
- React (Hooks/Relay/Styled Components)
- React Native (Mostly people creating cross-platform tools)
- Native (Obj-C/Swift/CocoaPods/Fastlane etc)

It's hard to keep on-top of any one community, and it's very hard to keep on track of four. Realistically, if you
want to be writing apps at the level of quality we do - you need to though.

Being involved in so many communities, as a part of owning [the Omakase][oma] stack means that it's hard to engage
in the native community with too much excitement anymore. Most of their problems aren't the same as ours.

## Universal Issues?

Are these the kind of problems most teams would have? It depends, with React Native at Artsy our focus on:

- Offering a consistent way to write code across web and iOS, which didn't water down either platform
- Ensuring we were able to own our dependencies across the stacks

Meant that we took some technical and cultural debt specifically around the platform aspect of our native
codebase.There are a few levers we can use to fix some of these issues:

- Let iOS be a bit more webby, by using more JS instead of enforcing stricter platform standards
- Use more of the React Native communities infra-structure, we generally don't use React Native JS dependencies
  These dependencies usually are cross-platform on Android and iOS which tends to mean making compromises
  per-platform. Often we are forcing ourselves into extra work to ensure platform consistency
- Find a way to ensure clearer engineering and product ownership for iOS at Artsy
- Have a lower mix of iOS infrastructure engineers to product engineers

How and if we'll tweak these levers will make for an interesting retrospective. Till then, I'd like to finish with
a showcase of some of the React Native work we shipped over the course of the last 4 months:

{% include epic_img.html url="/images/react-native-3/rn_3_1.jpg" title="" style="width:100%;" %}

{% include epic_img.html url="/images/react-native-3/rn_3_2.jpg" title="" style="width:100%;" %}

A lot of this probably wouldn't have happened had we not switched to React Native.

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
[rnb]: https://www.fordfoundation.org/about/library/reports-and-studies/roads-and-bridges-the-unseen-labor-behind-our-digital-infrastructure/
[fe-ios]: https://github.com/artsy/README/commit/95c9b93ab966ed269b5ebd9f0bdec8d2434bab52#diff-342d3433f36fbedadc5a8f167985fdf3
<!-- prettier-ignore-end -->
