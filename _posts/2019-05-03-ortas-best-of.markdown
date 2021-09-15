---
layout: epic
title: "Orta's best of"
date: "2019-05-03"
author: [orta]
categories: [everything]
# comment_id: 554
---

Today is my last day at Artsy, it's been 8 years and I figured a nice way to book-end my time here is to make a
post that tries to talk over [the last ~90 blog posts I've shipped](https://artsy.github.io/author/orta/). My posts
tell the story of a junior-ish engineering solving problems on successive larger scales, until their decisions
impact whole industries.

These posts cover so many topics that the right way to give them justice is to try group them in terms of general
themes and provide a larger context about why they were written.

<!-- more -->

I used to occasionally write before I came to Artsy, but inside the environment of Artsy's Engineering team I could
consider it _"work work"_ and not just _"things I should do, but in my own spare time."_ Writing for Artsy on the
blog is [very similar to writing code in our repos][why-we-write], you assign an editor (thanks [Ash][thx-ash] for
taking the lion's share!) and request reviews. This lowered the barriers considerably.

# Career Growth

I started working at Artsy with about 2-3 years of professional programming experience at the end of 2011. When
people ask about how career progression tends to work I TLDR it as:
</br>`Feature -> Section of Codebase -> Codebase -> Codebases -> Systems -> Businesses -> Industry`<br/>

This echoes how Artsy used to handle [an IC career ladder][career-ladder] ([current][current-ladder]). At that
point I joined, I sat somewhere around `Section of Codebase`. Each progression is more responsibility, and can
sometimes be about making decisions and not necessarily being the person to put the work in.

- **2012 - Building Features** - <br/>[On Grid Thumbnails][gridt] & [On Making It Personal in iOS with
  Searchbars][search]

- **2013 - Creating Libraries** - <br/>[ARAnalytics - Analytics for iOS Apps][aranal] & [Musical Chairs][chairs]

- **2014 - Supporting Team Infra** - <br/>[Using CocoaPods Caching with Travis CI][travis], [Building the Xcode
  Plugin Snapshots][snaps] & [Testing Core Data Migrations][test-cd]

- **2015 - Long term iOS Software Architecture and OSS** - <br/>[Dependencies][d1], [Dropped Design Patterns][d2],
  [Hybrid Apps][d3], [ARSwitchboard][d4], [ARRouter][d5] and [Open Sourcing Energy][oss-energy], [How we Open
  Source'd Eigen][oss-eigen] & [Licenses for OSS Code][oss-licenses]

- **2016 - Consolidating web + iOS** - <br/>[On our implementation of React Native][emis], [GraphQL for iOS
  Developers][gql-for-ios], [Using VS Code for JavaScript][vscode-js] & [JavaScript Glossary for
  2017][glossary-2017]

- **2017 - Process at Scale (OSS/All of Artsy)** - <br/>[C4Q&A][c4q], [Introducing Peril to the Artsy Org][peril],
  [Danger][danger] & [Artsy's Technology Stack, 2017][artsy-stack]

- **2018 - Cementing Artsy Culture** - <br/>JavaScriptures ([React][j6], [TypeScript][j5], [Tooling][j2],
  [Relay][j3], [Local State][j2], [Styled Components][j4]), [Engineering Highlights][highlights] & [Announcing:
  Artsy x React Native][axrn]

- **2019 - Archivist** - <br/>[Why we added an RFC process to Artsy][rfc], [Why does Artsy use Relay?][relay], [Why
  We Run Our Own Blog][blog], [Peril Architecture Deep Dive][peril-a] & this post.

# iOS

While I was originally expecting to be working on Ruby apps at Artsy, I very quickly ended up working on our iOS
app [Artsy Folio][folio] and eventually owned it post-1.0. This makes sense because I had a few years of macOS
native experience and I knew the project lead ([Ben Jackson][benj].)

Over time, I grew to own the iOS team at Artsy. In doing so I became a manager with 3-4 reports and tried to really
make a name for Artsy's iOS team in the industry. We built more apps, and started to need to think through our
larger I found our [old job posting][job-mob] from just before we consolidated with web. It echoes a lot of the
idea on how I framed our team's responsibilities being in that we should build Artsy in a way that improves the
industry for everyone too.

> [Dependencies][d1], [Dropped Design Patterns][d2], [Hybrid Apps][d3], [ARSwitchboard][d4] & [ARRouter][d5]

I think the pinnacle of my writing in this phase comes from a collaboration with the entire iOS team the magazine
[obcj.io][objcio] - [iOS at Scale: Artsy][scale-artsy].

As we hired, it became important to find ways to teach each other how our native codebases work. So, we have a set
of open codebase walk-throughs which explain the high level architecture and occasionally deep-dive on specific
features.

> Code Review: [Emergence][cr-em], [Energy][cr-en], [Energy Sync][cr-en-sy]

As we started to adopt React Native at Artsy, we really needed a different structure for our entire team and
technology stack. We had to re-think how we build apps, interact with the open community and what we were as
engineers.

> [On our implementation of React Native][emis], [Retrospective: Swift at Artsy][retro-swift], [Intro to React
> Native for an iOS Developer][rn-ios], [React Native, 2 years later][rn2], [Making a React Native Components
> Pod][rn-pod] & [React Native at Artsy, 3 years later][rn3]

Re-defining ourselves as native engineers who support JavaScript via our iOS silos was tricky, I think both
[Ash][ash-on-js] & [Maxim][maxim-talk-culture] have great write-ups on the topic. For me, the move to the
JavaScript came at a perfect time: the iOS community was fragmenting because of competing dependency managers and
the introduction of Swift which made infrastructure work less valuable.

We still needed to be up-to-date with the latest tools and ideas from the native world, but mainly from "iOS as
Platform" instead of features development (though my non-technical [ARKit post][arkit] is a great read).

> [Deploying your app on a weekly basis via fastlane + Travis CI][emis-travis], [What is fastlane match?][match],
> [It's time to use Swift Package Manager][spm], [Accessing the app's Source Code from your Simulator][src], [Why
> does my team's Podfile.lock Podspec checksums change?][checksum], [Code Injection for Xcode][inject], [Artsy's
> first closed source Pod][closed-pod], [CocoaPods-Keys and CI][cpkeys]

# JavaScript

To get experience in JavaScript, I took one of my large open source projects and [re-create it from
scratch][danger]. Which eventually turned into [Peril][peril], which solves [some interesting
problems][peril-state] at Artsy and in the rest of my OSS work.

For Artsy, we needed to consider: What is the right tech to build for both React Native and React on web? We had a
good guess [back in 2016][fejs2017] and that slowly evolved over the course of a few years into what we now call
the [Artsy Omakase][a-om]. Making sure that the rest of the team agreed, and that new people could go see our
reasoning was important when making foundations which could last 5-10 years.

> [Exploration: Front-end JavaScript at Artsy in 2017][fejs2017], [Using VS Code for JavaScript][vscode], [GraphQL
> for iOS Developers][gql-ios], JavaScriptures ([React][j6], [TypeScript][j5], [Tooling][j2], [Relay][j3], [Local
> State][j2], [Styled Components][j4]), [Why does Artsy use Relay?][why-relay]

# Open Source

Artsy had a rich relationship with Open Source before I arrived, and I devoted a lot of time and effort to making
this world-class. There is an entire blog post on how Artsy became [Open Source by Default][ossd], but I made sure
to make it easy for people interested in following Artsy's footsteps. I believe the world will be a lot richer as
more people work in the open.

> [Open Expectations][oss-exp], [Open Source FAQ for Engineers][oss-faq], [Licenses for OSS Code][oss-lic], [Open
> Sourcing Energy][oss-energy], [How we Open Source'd Eigen][oss-eigen], [Helping the Web Towards OSS by
> Default][oss-web], [Open Source by Default: Docs][oss-docs]

# Teaching

To quote myself:

> Open Source is important to me because I grew up outside of an urban center in Britain where I had very little in
> the way of community mentorship. Open Source gave me the ability to see how difficult things were built. I moved
> from being a beginner to an intermediate programmer by reading the source code that others had opened up.

→ [5 Questions with Orta Therox][nytimes-oss] _(open.nytimes.com)_

I use Open Source, and Artsy's leverage, to help make sure that the next generation of programmers feel like they
have so much more insight into how we build hard things. I know it's not easy getting started, so I've tried to
take common questions and wrap them up into larger sets of documentation on how I went through those phases.

> [Interviewing, applying and getting your first job in iOS][starting-ios], [Help! I'm becoming
> Post-Junior][post-junior], [JavaScript Glossary for 2017][js-gloss], [C4Q&A][c4qa1] & [C4Q&A 2][c4qa2]

# So, What Next?

If you want to keep on top of what I'm up-to, I'm starting [a personal mailing list][mail]. You should join, it'll
be roughly monthly - so pretty low key.

Well, I built a system for doing guest posts in this blog, so maybe I'll appear again on this blog now that I can't
write "we" when talking about Artsy. In the mean time there's a lot of engineers at Artsy writing really cool
things!

<p align="right"><code>./orta</code></br><code>x</code></p>

[gridt]: https://artsy.github.io/blog/2012/09/13/on-grid-thumbnails/
[search]: https://artsy.github.io/blog/2012/05/11/on-making-it-personal--in-iOS-with-searchbars/
[aranal]: https://artsy.github.io/blog/2013/04/10/aranalytics/
[chairs]: https://artsy.github.io/blog/2013/03/29/musical-chairs/
[travis]: https://artsy.github.io/blog/2014/08/08/CocoaPods-Caching/
[snaps]: https://artsy.github.io/blog/2014/06/17/building-the-xcode-plugin-snapshots/
[test-cd]: https://artsy.github.io/blog/2014/06/11/testing-core-data-migrations/
[oss-energy]: https://artsy.github.io/blog/2015/08/06/open-sourcing-energy/
[oss-eigen]: https://artsy.github.io/blog/2015/04/28/how-we-open-sourced-eigen/
[oss-docs]: https://artsy.github.io/blog/2018/08/21/OSS-by-Default-Docs/
[oss-web]: https://artsy.github.io/blog/2016/09/06/Milestone-on-OSS-by-Default/
[d1]: https://artsy.github.io/blog/2015/09/18/Cocoa-Architecture-Dependencies/
[d2]: https://artsy.github.io/blog/2015/09/01/Cocoa-Architecture-Dropped-Design-Patterns/
[d3]: https://artsy.github.io/blog/2015/08/24/Cocoa-Architecture-Hybrid-Apps/
[d4]: https://artsy.github.io/blog/2015/08/19/Cocoa-Architecture-Switchboard-Pattern/
[d5]: https://artsy.github.io/blog/2015/08/15/Cocoa-Architecture-Router-Pattern/
[oss-licenses]: https://artsy.github.io/blog/2015/12/10/License-and-You/
[emis]: https://artsy.github.io/blog/2016/08/24/On-Emission/
[gql-for-ios]: https://artsy.github.io/blog/2016/06/19/graphql-for-mobile/
[vscode-js]: https://artsy.github.io/blog/2016/08/15/vscode/
[glossary-2017]: https://artsy.github.io/blog/2016/11/14/JS-Glossary/
[c4q]: https://artsy.github.io/blog/2017/10/10/C4Q-QandA/
[peril]: https://artsy.github.io/blog/2017/09/04/Introducing-Peril/
[danger]: https://artsy.github.io/blog/2017/06/30/danger-one-oh-again/
[artsy-stack]: https://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017/
[j1]: https://artsy.github.io/blog/2018/06/15/JavaScriptures-5-Babel-Webpack/
[j2]: https://artsy.github.io/blog/2018/06/15/JavaScriptures-4.2-Local-State/
[j3]: https://artsy.github.io/blog/2018/06/13/JavaScriptures-4.1-Relay/
[j4]: https://artsy.github.io/blog/2018/05/04/JavaScriptures-3-Styled-Components/
[j5]: https://artsy.github.io/blog/2018/05/02/JavaScriptures-2-TypeScript/
[j6]: https://artsy.github.io/blog/2018/05/01/JavaScriptures-1-React/
[highlights]: https://artsy.github.io/blog/2018/10/18/long-term-highlights/
[axrn]: https://artsy.github.io/blog/2018/06/03/Announcing-Artsy-x-React-Native/
[relay]: https://artsy.github.io/blog/2019/04/10/omakase-relay/
[rfc]: https://artsy.github.io/blog/2019/04/11/on-an-rfcs-process/
[blog]: https://artsy.github.io/blog/2019/01/30/why-we-run-our-blog/
[peril-a]: https://artsy.github.io/blog/2019/04/04/peril-architecture-deep-dive/
[career-ladder]: https://artsy.github.io/blog/2016/09/10/Help!-I'm-becoming-Post-Junior/
[current-ladder]: https://github.com/artsy/README/blob/master/careers/ladder.md
[folio]: https://folio.artsy.net
[benj]: https://twitter.com/benjaminjackson
[job-mob]: https://www.artsy.net/article/artsy-jobs-mobile-engineer
[thx-ash]: https://github.com/artsy/artsy.github.io/pulls?utf8=✓&q=is%3Aclosed+is%3Apr+author%3Aorta+
[why-we-write]: https://artsy.github.io/blog/2019/01/30/why-we-run-our-blog/
[scale-artsy]: https://www.objc.io/issues/22-scale/artsy/
[objcio]: https://www.objc.io/
[retro-swift]: https://artsy.github.io/blog/2017/02/05/Retrospective-Swift-at-Artsy/
[rn-ios]: https://artsy.github.io/blog/2017/07/06/React-Native-for-iOS-devs/
[rn2]: https://artsy.github.io/blog/2018/03/17/two-years-of-react-native/
[rn-pod]: https://artsy.github.io/blog/2018/04/17/making-a-components-pod/
[rn3]: https://artsy.github.io/blog/2019/03/17/three-years-of-react-native/
[ash-on-js]: https://ashfurrow.com/blog/learning-from-other-programming-communities/
[maxim-talk-culture]: https://www.youtube.com/watch?v=zqnJBksguVI
[peril-state]: https://artsy.github.io/blog/2018/06/18/On-Obsessive-Statelessness/
[fejs2017]: https://artsy.github.io/blog/2017/02/05/Front-end-JavaScript-at-Artsy-2017/
[a-om]: https://www.youtube.com/watch?v=1Z3loALSVQM
[vscode]: https://artsy.github.io/blog/2016/08/15/vscode/
[gql-ios]: https://artsy.github.io/blog/2016/06/19/graphql-for-mobile/
[why-relay]: https://artsy.github.io/blog/2019/04/10/omakase-relay/
[cr-em]: https://artsy.github.io/blog/2015/11/05/Emergence-Code-Review/
[cr-en-sy]: https://artsy.github.io/blog/2016/02/12/Code-Review-Energy-Sync/
[cr-en]: https://artsy.github.io/blog/2016/02/11/Code-Review-Energy/
[oss-exp]: https://artsy.github.io/blog/2016/01/13/OSS-Expectations/
[oss-faq]: https://artsy.github.io/blog/2017/01/04/OSS-FAQ/
[oss-lic]: https://artsy.github.io/blog/2015/12/10/License-and-You/
[nytimes-oss]: https://open.nytimes.com/five-questions-with-orta-therox-d5bb9659c50b
[starting-ios]: https://artsy.github.io/blog/2016/01/30/iOS-Junior-Interviews/
[post-junior]: https://artsy.github.io/blog/2016/09/10/Help!-I'm-becoming-Post-Junior/
[js-gloss]: https://artsy.github.io/blog/2016/11/14/JS-Glossary/
[c4qa1]: https://artsy.github.io/blog/2017/10/10/C4Q-QandA/
[c4qa2]: https://artsy.github.io/blog/2018/01/10/C4Q-QandA-two/
[arkit]: https://artsy.github.io/blog/2018/03/18/ar/
[emis-travis]: https://artsy.github.io/blog/2017/07/31/fastlane-travis-weekly-deploys/
[match]: https://artsy.github.io/blog/2017/04/05/what-is-fastlane-match/
[spm]: https://artsy.github.io/blog/2019/01/05/its-time-to-use-spm/
[src]: https://artsy.github.io/blog/2016/10/14/Accessing-the-Source-Code-from-your-Simulator/
[checksum]: https://artsy.github.io/blog/2016/05/03/podspec-checksums/
[inject]: https://artsy.github.io/blog/2016/03/05/iOS-Code-Injection/
[closed-pod]: https://artsy.github.io/blog/2014/06/20/artsys-first-closed-source-pod/
[cpkeys]: https://artsy.github.io/blog/2015/01/21/cocoapods-keys-and-CI/
[ossd]: https://artsy.github.io/blog/2019/04/29/how-did-artsy-become-oss-by-default/
[mail]: https://buttondown.email/orta
