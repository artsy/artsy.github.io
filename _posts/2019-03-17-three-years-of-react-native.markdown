---
layout: epic
title: "React Native at Artsy, 3 years later"
date: "2019-03-17"
author: [orta]
categories: [reactnative, ios, community, roads and bridges]
series: React Native at Artsy
comment_id: 521
---

On Valentine's day in 2014, @alloy made our first commit moving the Artsy Mobile team to JavaScript, and paving the
way to the [shared Omakase JavaScript stack across web + iOS][oma]. We've done a write-up at [6 months], [1 year],
[2 years] and at 2.5 years we collaborated on a React Native conference with Facebook which features a [very long
Q&A][q_a] session with the people who worked on, and with our React Native stack.

Our experience has been really positive building a single platform data-driven app. We've been able to drastically
increase the number of contributors to the codebase and with minimal guidance, web-developers are able to be
productive and ship features to our iOS apps.

That said, for this 3 year anniversary, I want to dive deeper into some of the less positive aspects of our
transition. We think these trade-offs are worth it, and that this may be what a successful cultural transition
eventually looks like for some companies.

<!-- more -->

## De-nativification

When adopting React Native, we de-emphasized iOS as a unique platform for Artsy.

From an engineering team's perspective, we think of it as skill [de-siloing][desilo]. Prior to the move, if you
were on the mobile team you only worked on the iOS apps. This meant you had a limited scope to make change at
Artsy. This comes from two factors:

- Skills in Obj-C and Swift are only useful in the context of Apple's platforms.
- Internally and externally, Artsy is considered a website first.

Within 2 years we had de-siloed mobile engineering completely. We started with a team of 5 experienced native iOS
developers and by the end everyone had very solid skills across the board in JavaScript, React, GraphQL and the
build tools we'd need to make it all come together. These engineers kept their native skills, but they became
frozen in time.

With time, we redistributed the native engineers across many teams, with the native Engineers effectively acting as
a conduit for ensuring that we keep quality high and providing guidance to the rest of that team on how to make it
feel right. A simple way to think of it, is that the native engineer's job was to make sure we still conformed to
the [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) to ensure
the user experience is consistent with the platform and the user’s expectations.

We're reasonably lucky here too, the mobile team at Artsy has pre-dominantly hired folks interested in improving
behind-the-scenes ([Roads and Bridges][rnb] style) infrastructure. Once we had wrapped up the move, we effectively
took all of our native product developers and moved them into JavaScript platform infrastructure roles.

This was one of the major blocking points for AirBnB's adoption of React Native, specifically their native teams
felt uncomfortable at the introduction of JavaScript and a whole new toolchain inside their apps. There are people
who really love being a product developer in a native codebase, and React Native as a technology will de-value that
as more work would happen in JavaScript.

(Note: this is a gross simplification, and me reading between the lines, you should read from the horse’s mouth and
check out [Airbnb’s posts][airbnb] (and [Ash's continuation][ash_airbnb] on the subject ))

After a year of adopting React Native, the ex-mobile team used to joke that no-one enjoyed working in the native
codebase anymore. They still did. Three years down the line, with most screens now in React Native, that's not a
joke anymore.

This has consequences.

## Platform Concerns

De-siloing our mobile team obviously wasn't without its risk. In expanding the scope of our mobile engineering
team, and opening up the iOS app for contributions to the rest of the company we:

- Moved the engineers with a native focus to act more like platform engineers vs product engineers.
- Had iOS native platform engineers with the skills to now also work on the web's platform.

This is what started to make our third year tricky. In Artsy, web is the [squeaky wheel][wheel].

After figuring out the JavaScript infrastructure for React Native on iOS, we replicated that infrastructure on the
web to consolidate tooling and ideas across all of Artsy. We call that infrastructure for both [the Artsy
Omakase][oma]. Maintaining, and keeping the infrastructure up-to-date on the web side is a much bigger task and
requires a lot more engineering time.

The web-aspect of the Omakase has more client consumers (1 iOS app vs 3 large websites), and its corresponding repo
has more than double the number of commits per day on average. The web team has its own people running and
improving infrastructure, which affects the iOS side too.

We explicitly worked towards shared common infrastructure across all front-end at Artsy. It wasn't surprising when
the aspect with the most company focus became much larger and more complex. What creates tricky constraints are
that the few people with the interest and skills to work on our React Native infrastructure also happen to have the
skills to work on the web problems too.

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
WWDCs and iOS releases just kinda happen, and we keep moving independently. We still write native code to make use
of any iOS API available when we need to, but right now we don’t go out of our way to try to make use of all the
shiny new things when they are released.

This is a side-effect to the openness of the JavaScript toolchain, and our ability to contribute and fix a lot of
our own problems at JavaScript level instead of needing to dive deeper into the native side to work on problems. We
still support iOS 9, and have very little incentive to bump it - new APIs from Apple just aren't that interesting
anymore.

Without a focused iOS team, it's not easy to pitch for iOS specific projects. This means that features like moving
to Apple's new app store review API or using iOS features which don't exist on web get spoken about in meetings,
but never started. This lack of a focused team makes it really hard to implement fixes to e.g. bad App Store
reviews.

That said, in the last year we did manage to ship a pretty hefty [ARKit feature][arkit] - which is a positive
example of an iOS-specific feature which is both forward-thinking tech and a super great fit for Artsy's product.
React Native basically played no part in that.

## Community Disconnection

There are maybe four communities at play if you're doing React Native:

- JavaScript (Babel/TypeScript/Storybooks/VSCode)
- React (Relay/Styled Components)
- React Native (Mostly people creating cross-platform tools)
- Native (Obj-C/Swift/CocoaPods/fastlane etc)

It's hard to keep on-top of any one community, and it's very hard to keep on track of four. Realistically, if you
want to be writing apps at the level of quality we want to - you need to, though.

Artsy's principle of [owning our dependencies][owning] means involved in all of these communities, however it's
hard to engage in the native community with too much excitement anymore. Most of their problems aren't the same as
ours anymore, and the dependencies we want to improve live in the JavaScript realms.
4
## Universal Issues?

Are these the kind of problems most teams would have? It depends, with React Native at Artsy our focus on:

- Offering a consistent way to write code across web and iOS, which doesn’t water down either platform.
- Ensuring we are able to meaningfully own our dependencies across the stacks.

Means that we took on some technical and cultural debt, specifically around the platform aspect of our native
codebase. There are a few levers we can use to fix some of these issues:

- Let iOS be a bit more webby, by using more JavaScript instead of enforcing stricter platform standards.
- Use more of the React Native community’s infra-structure, we generally don't use React Native JavaScript
  dependencies. These dependencies usually are cross-platform on Android and iOS which tends to mean making
  compromises per-platform. Often we are forcing ourselves into extra work to ensure platform consistency.
- Find a way to ensure clearer engineering and product ownership for iOS at Artsy.
- Hire more iOS infrastructure engineers to allow for a better mix of native infra vs JavaScript product engineers.

How and if we'll tweak these levers will make for an interesting retrospective. Till then, I'd like to finish with
a showcase of some of the React Native work we shipped over the course of the last 4 months:

{% include epic_img.html url="/images/react-native-3/rn_3_1.jpg" title="" style="width:100%;" %}

{% include epic_img.html url="/images/react-native-3/rn_3_2.jpg" title="" style="width:100%;" %}

We wouldn't have been able to ship this without React Native.

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
[owning]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#own-your-dependencies

<!-- prettier-ignore-start -->
[rnb]: https://www.fordfoundation.org/about/library/reports-and-studies/roads-and-bridges-the-unseen-labor-behind-our-digital-infrastructure/
[fe-ios]: https://github.com/artsy/README/commit/95c9b93ab966ed269b5ebd9f0bdec8d2434bab52#diff-342d3433f36fbedadc5a8f167985fdf3
<!-- prettier-ignore-end -->
