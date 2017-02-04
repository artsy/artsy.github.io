---
layout: post
title: "Postmortem: Swift at Artsy"
date: 2017-01-22 12:18
author: orta
categories: [swift, eigen, eidolon, javascript, emission, reactnative]
series: React Native at Artsy
---

<center>
<img src="/images/swift-in-rn/swift-in-react-native.svg" style="width:300px;">
</center>

Swift became public in June 2014, by August we had started using it in Artsy. By October, we had [Swift in production][eidolon-postmortem] channeling hundreds of thousands of dollars in auction bids. 

It is pretty obvious that Swift is the future of native development on Apple platforms. It was a no-brainer to then build an [appleTV app][emergence] in Swift, integrated Swift-support into our key app Eigen and built non-trivial parts of that [application in Swift][live-a].

We first started experimenting with with React Native in February 2016, and by August 2016, we announced that [Artsy moved to React Native][artsy-rn] effectively meaning new code would be in JavaScript from here onwards.

We're regularly asked _why_ we moved, and it was touched on briefly in our announcement but I'd like to dig in to this and try to cover a lot of our decision process. So, if you're into understanding why a small team of iOS developers with decades of experience switched to JavaScript, read on. 

This post will cover: what are Artsy's apps?, swifts positives and negatives for us, React Native, and our 1-year summary.

<!-- more -->

We were finding that our current patterns of building apps were not scaling as the team and app scope grew. Building anything inside Eigen rarely re-used existing native code, and progressively took longer to build features. Our app and test target build times were increasing, till eventually it would take 2 iOS engineers to build a feature in a similar time-frame as a single web engineer. Our iOS engineers have a lot of experience across many platforms, are well versed in best practices and understand the value of building better tools to make it faster. We had the knowledge, but we weren't finding ourselves in a great position product development wise.

By [March 2015][gave_up], we gave up trying to keep pace with the web.

Once we came to this conclusion, our discussion came to "what can we do to fix this?" Over the course of the 2015 winter break we explored ideas on how we could write more re-usable code.    

# What are Artsy's apps?

We have different apps with different trade-offs.

[Eigen][eigen] is an app where we taken JSON data from the server, and convert it into a user interface. Each view controller can nearly always be described as a function taking data and mapping it to a UI. [Eidolon][eidolon] (our Auctions Kiosk app) which contains a lot of Artsy-wide unique business logic which is handled with local state like card reader input, or unique user identification modes. [Emergence][emergence] is a trivial-ish tvOS app which has a few view controllers, and is mostly handled by Xcode's storyboards.

{% expanded_img /images/emission/eigen.svg %}

Eigen is where we worry, other apps are limited in their scope, but Eigen is basically the mobile representation of Artsy. We're never _not_ going to have something like Eigen.

We eventually came to the conclusion that we needed to re-think our entire UIKit stack for Eigen. Strictly speaking, Objective-C was not a problem for us, our issues came from abstractions around the way we built apps.

Re-writing from scratch was not an option. That takes [a lot of time and effort][rewrite], which will happily remove technical debt, but that's not our issue. We also don't need or have a big redesign. However, a lot of companies used the Objective-C -> Swift transition as a time to re-write from scratch. We asked for the experiences from developers who had opted to do this, they said it was a great marketing tool for hiring - but was a lot of pain to actually work with day to day. They tend to talk abut technical debt, and clean slates - but not that Objective-C was painful and Swift solves major architectural problems. With the notable exception of Functional Programmers.

In the end, for Eigen, we came to the conclusion that we wanted to work with a component-based architecture. This architectual  choice comes from studying how other larger apps handle code-reuse. We were considering building the structure from based on JSON ( which would have ended up like Spotify's ([hub][hub]) or Hyperslo's ([Spots][spots]) ) or inspired by React ( like Bending Spoons's ([Katana][katana]) ).

# Swift's upsides

Had we continued with native apps via native code, we'd have put more resources behind Swift, which had quite a bit running for it:

* **It was consistent with our existing code.** We wrote hundreds of thousands of lines of code in Objective-C and maybe around a hundred thousand of Swift. The majority of the team had 5+ years of Cocoa experience and no-one needs to essentially argue that _continuing_ with that has value.

* **Swift code can interact with Objective-C and can work on it's own.** We can write Swift libraries that can build on-top of our existing infrastructure to work at a higher level of abstraction. Building a component-based infrastructure via Swift could allow easy-reuse of existing code, while providing a language difference for "new app code" vs "infra." 

* **People are excited about Swift.** It's an interesting, growing language, and one of the few ones non-technical people ask about. "Oh you're an iOS developer, do you use Swift?" is something I've been asked a lot. The rest of the development team  have signed up multiple times for Swift workshops and want to know what Swift is, and what it's trade-offs are.

* **It's evolving** the language changes at a fast rate, with new ideas coming from, and influencing other languages. People inside the community influence and shape it's growth. There are some great claims being made [about Swift][swift-excite] by people we respect.

* **Swift improves on a lot of Objective-C.** Most of the patterns that we use in Objective-C are verbose, and they can become extremely terse inside Swift. Potentially making it easier to read and understand. 

* **We would be using the official route.** Apple obviously _want_ you to be using Swift, they are putting a _lot_ of resources into the language. There are smart people working on the project, and it's becomes more stable and useful every year. There aren't any _Swift-only_ APIs yet, but obviously they'll be coming.

* **It's a [known-unknown][known-known] territory.** We have a lot of knowledge around building better tooling for iOS apps. From libraries like [Moya][moya], to foundational projects like [CocoaPods][cocoapods]. Coming up with, and executing dramatic tooling improvements is possible. Perhaps we had overlooked a smarter abstraction elsewhere and it was worth expanding our search.

  This is worth continuing here, because if we end up building something which gains popularity we get the advantage of working with a lot of perspectives, and being able to gain from other people working on the same project. It's a pattern Basecamp discuss when they [talk about rails][rails] by beginning with a real project and abstracting outwards.

# Native Downsides

The dominant two issues come from differences in opinions in how software should be built

* **Types.** Types are useful. Overly strict typing systems make it to hard to build _quick_ (not easy) to change codebases.

  Strictly typed languages work _really_ well for [building systems][systems], or completely atomic apps - the sort Apple have to build on a day to day basis. When I say an atomic app, I mean one where the majority of the inputs and outputs exist within the domain of the application. Think of apps with their own filetypes, that can control inputs and outputs really easily.

  Even in Objective-C, a looser-typed language where you were not discouraged from using meta--programming, handling JSON required _a tonne_ of boilerplate laden, inelegant code when working with an API. Considering how bread-and-butter working with an API is for most 3rd party developers it should come as no surprise that the most popular CocoaPods are about handling JSON parsing, and making network requests.  

  Problems which Apple, generally speaking, don't have. They use iCloud, or CloudKit, or whatever, and expect you to too aswell. The official Apple opinion was neatly summed up on the official Swift blog on how to handle JSON parsing [exhibits the problem well][swift_blog].

  > Swift’s built-in language features make it easy to safely extract and work with JSON data decoded with Foundation APIs — without the need for an external library or framework.

  They do, but it's not great code to write nor maintain. I don't know anyone who does what they recommend in production.

* **Slow.** Native development when put next to web development is slow. Application development requires full compilation cycles, and full state restart of the application that you're working on. A trivial string change in Eigen takes [25 seconds][eigen_25] to show up. When I tell some developers that time, they laugh and say I have it good.

  The moment that this really stood out for me was when I [re][injection-twentytwelve]-discovered [Injection for Xcode][injection_twitter] which ruined my appetite for building apps the traditional way. It reduced an iteration cycle to about [a second][injection_time]. With Apple's resources, and the fact that Injection for Xcode has existed for years by a single developer, it's embarrasing that iOS is a [mobile platform][instant-run] with no support code reloading. I filed bug reports ([radars][what-is-radar]), they were marked as duped with no comment. I talked to Apple engineers at WWDC, the idea was dismissed as "didn't work" when it was [tried before][fix-and-continue].
  
  I've heard developers say they use using Playgrounds to work around some of these problems, and the Kickstarter app has probably the closest I've seen to an [actual implmentation of this][kickstart_play], so check that out if you're hitting these issues.

  The Swift compiler is slow. Yes, it will improve. One argument that it won't ever be as fast as Objective-C comes from Swift being a more complicated language to compile - it's doing more work. There is nothing like a constrained generic with an associated type, or nested classes with protocol extensions in the Objective-C world. One amazing feature that can catch you out on compile time is the type inference system, which can make it feel arbitrary about what will take longer to compile or not. We eventually [automated having our CI warn us][danger-eigen] whether the code we were adding was slow as it felt indeterminate.

# React Native

You may want to read our announcement of switching to [React Native][artsy-rn] in anticipation of this. However the big three reasons are:

* Better developer experience.
* Same conceptual levels as the rest of the team.
* Ownership of the whole stack.

However, the key part of this post is how does this compare to native development? Also, have these arguments stood up to the test of time a year later? 

_Sidenote:_ I found it hard to write this without being able to comprehensively reference what we are doing now, and so, I'll be referencing a sibling article: [JS 2017][js-2017]. 

### Developer Experience

The JavaScript ecosystem cares about how someone using the tool will feel. This is a part of what separates the good from the great in the community. It's not enough to just provide a great API, and comprehensive documentation but it should substantially improve the way you work. 

> References from JS 2017: [Relay][relay], [Jest][jest]

As _everyone_ inside the community has both the ability and the tools to contribute to the ecosystem you get better tools. 

Apple make _great_ tools. I do miss Xcode sometimes. It's cohesive, beautifully designed and doesn't show it's age. It's a perfect Mac citizen.

Though it's important to note that they make tools for Apple first and then for us 3rd party devs. Outside influence obviously exists, but they're shipping whatever _they_ want and you can only influence that via Radars and through going to a conference once a year and talking directly to the dev tools team. Only the Swift language is Open Source (and [SwiftPM][swiftpm])

There are so few well built, large developer tools for the Apple eco-system. Developers are wary [of][stack] [being copied by Apple][https://twitter.com/mattt/status/473544723118837760] - something so prevalent that there is a common word for it, being [Sherlocked][sherlocked]. The project I've worked on for 5 years, CocoaPods, had an announcement of being sherlocked in late-2015 - you just have to deal with it. The idea that only Apple should be shipping these kind of things kills community momentum.

If you're going to build something amazing, only to have all support pulled out from under you once it gets popular because apple copied it and made it for free and with a full time team behind it - why bother? 

This makes it tough for us, as the 3rd party community, to build useful tools on the kind of scale that is normal in other developer eco-systems. Think of Fastlane, which _needs_ a company like Twitter/Google to behind to handle the scale of usage because no-one else is fixing toolchain issues.

### Better Abstractions, Better Developer Experience

I've mentioned that the apps we build have problems specific to API-driven applications. This means that the majority of our work tends to be that we have the full data already, and need to iterate to get the right styling and logic mapping correct, in doing so we want to also make it easy to re-use code.

The React component-oriented architecture makes it very easy to build these types of applications. Born out of the [JavaScript primordial soup][js-soup], where conceptual frameworks come and go every year or so. React has been around for a while now, and seems to have a lot of stopping power.

All of these frameworks have the same domain problems that our iOS apps have, external API stores, complex user device state and a mature end-of-line API (either the DOM, or UIKit.) 

With React, the core concept of a virtual DOM means that you can simplify a lot of complicated state-management for your application. It becomes trivial, removing the need for more complicated state-handling ideas like functional or reactive programming. 

With Relay, we got an genuinely ground-breaking change in how interactions get handled with our API. I don't want to ever work against an API without a tool like Relay.

> References from JS 2017: [React][react], [Relay][relay]

Both of these tools provide a developer experience better than iOS native tooling. React's strict state management rules allow external tools to extend a React application easily, so the onus is not on the React team to make better tools. Other projects provide tools like:[debuggers][rn-debugger], [external state viewers][reactotron], [runtime code injection][hrm], [component storyboarding][storybook] all of which can be running simulatiously at runtime. 

A single press of save would take your changes, inject it into your current running application, keep you in the exact same place, depending on the type of change it could re-layout your views, and so you can stay in your editor and make your changes. <em>From 25 seconds, to less than one</em>. For a lot of my work, I can put my tests, debuggers and the application on another screen, and just move my head to watch changes propogate on save.

So, you're thinking _"Yeah, but JavaScript..."_ - well, we use [TypeScript][what_is_ts] and it fixes pretty much every issue with JavaScript. Add in with that it's no problem for us to write native code when we need to. The last project I did on our React Native codebase required JS <-> Swift communication. 

React Native feels like the best of both worlds: Elegant, fast to work with application code, which the whole dev team understands. Falling back to native tooling when we think it will be best for the project.

> Reference from JS 2017: [TypeScript][typescript]

There's one more thing that I want to really stress around developer experience, it's really easy to write tests for our React components. Testing in JavaScript is night-and-day better than native testing. Because we can run our tests outside of the simulator (due to React's virtual DOM) we have all tests related to all the changes in git running on save.

#### Same Tools, Different Dev

We wanted to stop being highly unique inside the dev team. Artsy has around 25 developers, the majority of which work with Ruby and JavaScript on a day-to-day basis. The mobile team was the single development team that didn't make their own API changes, used different toolchains and were much slower in shipping anything.

This isn't a great position to be in.

We wanted all developers to feel like they can contribute to any area of the company. For the past 5 years, the native mobile projects had close to zero contributions from anyone outside of the mobile team. Due to differences in tooling, and the idea that there was a cultural difference between us. Since the mobile team moved to Reach Native we have received features and bug fixes from the web team, and fit in better overall.

This expansion of a mobile team developer's scope has made it much easier for us to reason about finding better ways to share code with the web team. At the end of 2015, the Collector Web team introduced GraphQL to Artsy. I wrote about how this affected the [mobile team][mobile-graphql]. This acts as an API layer owned by the front-end side of Artsy. Meaning that it could contain a lot of API-derived client-specific logic. Previously, this work was done by the web team, and then consumed by mobile - now both teams build their APIs and consume them.

> Reference from JS 2017: [GraphQL][graphql]

This is not something we have explored too deeply, however we expect to be able to port a lot of our React Native to Android. I got a rough prototype ported in 2 days work. By working at React-level, and allowing the React Native bindings to handle the interactions with the host OS, we've been writing cross-platform code.

We consider ourselves blocked on Android support, specifically by not having an engineer in our team with _deep_ experience in Android. Moving to React Native does not obviate our native skills, you're going to be significantly better in that environment with those skills than without. As we mentioned in our announcement:

> If you’re not already knowledgeable about iOS development, are not motivated to put in the time to learn about the
  platform specific details, and think making rich iOS applications with React Native will be a breeze, you’ll
  [come home from a very cold fair](http://www.dwotd.nl/2008/06/443-van-een-kouwe-kermis-thuiskomen.html) indeed. 

We need someone with a similar depth of knowledge in the Android eco-system, but we may need one or two for the entire team. The rest can continue to be a mix of Web and iOS engineers. You gain a subset of cross-platform skills using React Native. Had we continued down the path of using Swift, our skills would continue to be siloed.

There is an argument that Swift will be running servers soon, and so you can re-use Swift code across platforms. I could see myself writing server-side back-end code in Swift (you're writing systems, not apps) but it has a [long way to go][ssswift]. It also isn't an argument towards using it in our native apps, we'd have to re-write servers and implement our own GraphQL and Relay stack. This also would not impact the front-end code for the web - they would still be using JavaScript.

With respect to Swift on Android, potentially, logic code could be shared between platforms but realistically for our setup that's just not worth it. We're moving that kind of logic into the GraphQL instance and sharing across _all_ clients, not only native platforms. If you're sharing model code, you could generate that per-project instead from the server. Since GraphQL is strongly-typed, we're doing this for both [TypeScript + GraphQL][gql2ts] and [TypeScript + Relay][vscode-relay].

We don't know where this will end, but we've prototyped porting one of our view controllers from React Native [to a website][relational-rnw]. It's almost source-compatible. This such a completely different mind space from where we were a year ago.

#### Owning the stack

Pick an abstraction level of our application above UIKit and we can fork it. All our tools can be also be forked. We can fix our own issues.

In native, there are no concepts like, _"We'll use Steipete's fork of UIKit for UIPopover rotation fixes"_ or _"My version of Xcode will run tests when you press save."_. Well, hopefully the latter [may be fixed][xcode-extensions] in time, but the "you have no choice but to wait, and maybe it won't happen" aspect is part of the problem. You have your tools given to you, in a year you get some new ones and lose some old ones. In contrast, we've built [many][vscode-jest] [extensions][vscode-rns] [for][vscode-relay] [VS][vscode-common] [Code][vscode-danger] for our own use, and helped out on [major ones][flow-vscode]. When the VS Code didn't do what I wanted, I started using [use my own fork][essence].

> Reference from JS 2017: [VS Code][code]

In the last year, we have submitted code to major JavaScript dependencies of ours: React Native, Relay, VS Code, Jest and a few libraries in-between - fixing problems where we see them, offering features if we need them. Some of these changes are [small][vscode-toolbars], but some [are][relay-id] [big][jest-editor] [moves][react-shadow]. Being able to help out on any problem makes it much easier to live with the [593 dependencies](/blog/2016/08/15/React-Native-at-Artsy/) that using React Native brings.

It's worth highlighting that all of this is done on GitHub, in the open. We can write issues, get responses, and have direct line to the people who are working on something we depend on. This is a stark contrast to the Radar system used internally at Apple, and which external developers have write-only access to. For external contributors radar is opaque, and [totally feels like a waste of time][tnw-radar]. On the other hand, a GitHub issue doesn't have to have to wait for the repo maintainers, others can get value from it and it's publicly indexed. If we had put all our effort into Radars instead of [issues like][eigen_launch] this, the whole community would be worse off.

This isn't all doom and gloom. With Swift the language, and SwiftPM the package manager, Apple are more open with the feedback cycle using tools like Slack, Mailing Lists, JIRA and Twitter.

One aspect of working with JavaScript that has been particularly pleasant is the idea that your language is effectively a buffet. If you want to use the latest features of the language you can opt-in to it. We've slowly added language features, while retaining backwards compatibility. First using [Babel][babel-site], then [Flow][flow-site] and finally with [TypeScript][typescript-site]. 

In contrast, and this may be the last major time it happens, but people refer to the time it took to migrate [in][weeks1] [the][weeks2] [scale][weeks3] [of][weeks4] _weeks_ during the Swift 2 -> 3 migration. Having the language evolve is great, sometimes in ways that you [agree with][swift-api] and sometimes in ways [you don't][closed]. Being able to use your own version of your tools frees you to make it work for you and your business.

# React Native, one year later

In our announcement we talked about the lack of nuanced post-mortems on React Native. We're now a year in, we can at least try to help out in that space. We're sticking with React Native for the foreseeable future. It would take some _drastics_ changes in the Apple ecosystem for us to re-consider this decision. So here's our summary after 1 year.

* We can share concepts with web
* Tools are built for our apps like ours
* To do it right requires engineers willing to dive deep in JS
* You need native experience to have a polished app
* Dependency stack is still obscenely big
* Opens native engineers to more projects, makes yours more welcoming to others
* Problems do, and will occur, but everything is fixable by forking
* Extensive communication with native code gets tricky to test and maintain
* It makes working in native code feel like a bad job for someone to do

So, should you use React Native? Maybe. If you have an API driven app, probably.

# Want to get started?

- Here's the [official site][rn].
- These [two][eggheads1] [series][eggheads2] are high-quality. I studied JavaScript by watching hours of egghead videos.
- Run through the [f8 app][f8] series on  [makeitopen.com][f8-open].
- Clone our React Native app, [Emission][emission].
- Read the rest of our [series on React Native][series].


[js-2017]: SFSDFSDDF
[relay]: ASDASDASD
[jest]: GSGSDGS
[graphql]: SDFSDFSDF
[react]: ASDASDASSD
[typescript]: ASDASDASSD

[eidolon-postmortem]: http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/
[emergence]: https://github.com/artsy/emergence
[live-a]: http://artsy.github.io/blog/2016/08/09/the-tech-behind-live-auction-integration/
[artsy-rn]: /blog/2016/08/15/React-Native-at-Artsy/
[what-is-artsy-app]: /blog/2016/08/24/On-Emission/#Why.we.were.in.a.good.position.to.do.this
[eigen]:  https://github.com/artsy/eigen
[eidolon]: https://github.com/artsy/eidolon
[spots]: https://cocoapods.org/pods/Spots
[hub]: https://cocoapods.org/pods/HubFramework
[katana]: https://cocoapods.org/pods/Katana
[gave_up]: https://github.com/artsy/mobile/issues/22
[known-known]: https://en.wikipedia.org/wiki/There_are_known_knowns
[moya]: https://github.com/moya/moya
[cocoapods]: https://cocoapods.org
[rails]: https://signalvnoise.com/posts/660-ask-37signals-the-genesis-and-benefits-of-rails
[systems]: http://mjtsai.com/blog/2014/10/14/hypothetical-objective-c-3-0/#comment-2177091
[swift_blog]: https://developer.apple.com/swift/blog/?id=37
[eigen_25]: https://twitter.com/orta/status/778242899821621249
[injection_twitter]: https://twitter.com/orta/status/705890397810257921
[kickstart_play]: https://github.com/kickstarter/ios-oss/tree/master/Kickstarter-iOS.playground/Pages
[danger-eigen]: https://github.com/artsy/eigen/pull/1465
[swiftpm]: https://github.com/apple/swift-package-manager
[sherlocked]: https://www.cocoanetics.com/2011/06/on-getting-sherlocked/
[stack]: https://twitter.com/orta/status/608013279433138176
[cp-sherlock]: https://twitter.com/Objective_Neo/status/474681170504843264
[js-soup]: /blog/2016/11/14/JS-Glossary/#javascript-fatigue
[rn-debugger]: https://github.com/jhen0409/react-native-debugger
[reactotron]: https://github.com/infinitered/reactotron
[hrm]: https://github.com/gaearon/react-hot-loader
[storybook]: https://github.com/storybooks/react-storybook
[mobile-graphql]: http://artsy.github.io/blog/2016/06/19/graphql-for-mobile/
[ssswift]: https://ashfurrow.com/blog/swift-on-linux/
[gql2ts]: https://github.com/alloy/relational-theory/pull/18
[vscode-relay]: https://github.com/alloy/vscode-relay
[closed]: http://mjtsai.com/blog/2016/07/17/swift-classes-to-be-non-publicly-subclassable-by-default/
[rewrite]: https://www.joelonsoftware.com/2000/04/06/things-you-should-never-do-part-i/
[injection-twentytwelve]: https://twitter.com/orta/status/271559616888967168
[instant-run]: https://developer.android.com/studio/run/index.html#instant-run
[injection_time]: https://twitter.com/orta/status/706165678177390592
[what_is_ts]: http://typescriptlang.org
[relational-rnw]: https://github.com/alloy/relational-theory/pull/16
[fix-and-continue]: http://stpeterandpaul.ca/tiger/documentation/DeveloperTools/Conceptual/XcodeUserGuide/Contents/Resources/en.lproj/06_06_db_fix_and_continue/chapter_44_section_1.html
[essence]: https://github.com/orta/Essence
[vscode-jest]: https://github.com/orta/vscode-jest#vscode-jest-
[vscode-rns]: https://github.com/orta/vscode-react-native-storybooks
[flow-vscode]:https://github.com/flowtype/flow-for-vscode/blob/master/CHANGELOG.md
[vscode-relay]: https://github.com/alloy/vscode-relay
[vscode-danger]:  https://github.com/orta/vscode-danger
[vscode-common]: https://github.com/orta/vscode-ios-common-files
[vscode-toolbars]: https://github.com/Microsoft/vscode/pull/12628
[relay-id]: https://github.com/facebook/relay/issues/1061
[jest-editor]: https://github.com/facebook/jest/pull/2192
[react-shadow]: https://github.com/facebook/react-native/pull/6114
[xcode-extensions]: https://twitter.com/orta/status/790589579552296966
[what-is-radar]: https://forums.developer.apple.com/thread/8796
[eigen_launch]: https://github.com/artsy/eigen/issues/586
[tnw-radar]: https://thenextweb.com/apple/2012/04/13/app-developers-frustrated-with-bug-reporting-tools-call-on-apple-to-fix-radar-or-gtfo/
[babel-site]: https://babeljs.io
[flow-site]: https://flowtype.org
[typescript-site]: http://www.typescriptlang.org
[weeks1]: https://engblog.nextdoor.com/migrating-to-swift-3-7add0ce0655#.rvyrohyhq
[weeks2]: https://tech.zalando.com/blog/app-migration-to-swift-3/
[weeks3]: https://github.com/kickstarter/ios-oss/pull/26 
[weeks4]: https://twitter.com/guidomb/status/817363981216129025
[closed]: http://mjtsai.com/blog/2016/07/17/swift-classes-to-be-non-publicly-subclassable-by-default/
[swift-api]: https://swift.org/documentation/api-design-guidelines/
[eggheads1]: https://egghead.io/courses/react-native-fundamentals
[eggheads2]: https://egghead.io/courses/build-a-react-native-todo-application
[f8]: https://github.com/fbsamples/f8app/
[f8-open]: http://makeitopen.com/
[emission]: https://github.com/artsy/emission/
[series]: /series/react-native-at-artsy/
[rn]: https://facebook.github.io/react-native/
[swift-excite]: https://twitter.com/wilshipley/status/565001293975257091
