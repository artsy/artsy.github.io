---
layout: post
title: "Handling Large OSS Projects Defensively"
date: 2016-07-03 12:00
author: orta
categories: [mobile, oss, culture, danger]
series: Open Source by Default
---

I help maintain big OSS projects: from a third-party [dependency manager][cocoapods] used in most iOS apps ([CocoaPods][cocoapods_org]), to the most popular Objective-C [testing framework][specta] and the most popular Swift [networking API client][moya]. I've been doing this for years.

Projects with this much impact are big time-sinks. This time comes from ensuring infrastructure continues to work, support tickets need replies, new code needs reviewing and releases need coordinating.

![](/images/2016-07-03-big-oss/danger_logo_black@2x.png)

Last September, almost a year ago, I started work on a new project, [Danger][danger_gh]. Danger fixes a problem we were seeing in the Artsy mobile team around adding "[process][process]" to our team.

As a part of discussing Danger internally, I've referenced that building CocoaPods has greatly influenced Danger. This blog post is about the way I've built Danger, knowing fully well that I cannot afford the level of time to maintain it at the scale it may get to.

<!-- more -->

---

Danger is a project that could end up with a lot more users than CocoaPods. So I want to be cautious about how I create the community around Danger. If you're interested in some of the baseline setup required to run a popular project, the post "[Building Popular Projects][building_pop_projects]" by [Ash][ash] is a great place to start, this builds on that.

My maintenance time on CocoaPods resolves around:

* Handling new issues
* Keeping infrastructure running
* Requests around user data
* Keeping disparate communities together

## Issues

From the ground up, Danger could not end up as complex as CocoaPods, the domain they cover is different and CocoaPods sits atop of an annually moving (and _somewhat_ hostile) [platform][dev_news].

However, get enough people using a product and you end up with three types of issues: Bug Reports, How Do I X? and Feature Requests.

I wanted to keep bug-reports down, as much as possible, and so I built a system wherein the default error reporting system would also search GitHub issues [for similar problems][gh_inspector]. Knowing this was a generic problem, I built it with [other][fastlane_gh] [large][cocoapods_gh] ruby projects in mind too.

`How do I X?` are issues that haven't appeared much on Danger. For CocoaPods we request people use the CocoaPods tag on StackOverflow. That saves us from 5 to 6 issues a day, and provides others a great place to get internet points by responding instead.

Feature Requests issues are always fascinating, it gives you a chance to really see the difference between what you imagined a project's scope is, and how others perceive it. One thing that helps here is that Danger has a [VISION.md][vision] file. This helped vocalise a lot of internal discussion, and let contributors understand the roadmap:

> The core concept is that the Danger project itself creates a system that is extremely easy to build upon. The codebase for Danger should resolve specifically around systems for CI, communication with Peer Review tools and providing APIs to Source Control changes. For example: Travis CI - GitHub - git.

As well as providing a heuristic for determining whether something should be added to Danger:

> This means that decisions on new code integrated into Danger should ask "is this valid for every CI provider, every review system and source control type?" by making this domain so big, we can keep the core of Danger small.

### Infrastructure

CocoaPods has about 6 web properties, 3 of which are critical. The others can go down, or be behind the Xcode update schedules and people's projects will work fine. The 3 the critical projects are all simple, focused projects: [trunk][trunk] (provide auth, and submitting new libraries) [cocoapods.org][cocoapods_org], and [search][search]. We control everything there.

Meanwhile the less critical ones like [cocoadocs.org][cocoadocs_org] have dependencies all over the show: AppleDoc, CLOC, Xcode, Carthage, Jazzy - every one of these can, and has, been a source of unreliability for infrastructure that I maintain.

With Danger, I wanted to avoid building any infrastructure that does not sit on top of solid, mature projects. The website is statically created in [Middleman][middleman], using [boring][slim] [old][sass] technology, this means no server to host.

To support dynamic content on the website, I have a rake command to use [a decade old][yard] documentation formatter to pull content from a [13 year old][rubygems] dependency manager - that lets others describer their project's. In order to let them keep it up to date, I have a tiny 35 line web-server that allows specific projects to trigger a new CI build.

### Plugins

<center>
<blockquote class="twitter-tweet" data-lang="en-gb"><p lang="en" dir="ltr">Summary of every big OSS project. Monolith -&gt; Plugin support.<a href="https://t.co/7x4vuW4bRd">https://t.co/7x4vuW4bRd</a></p>&mdash; Orta Therox (@orta) <a href="https://twitter.com/orta/status/748561323164864512">30 June 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</center><br/>

It's almost inevitable that once a project becomes big, maintainers have to become a lot more conservative about how they introduce new code. You become good at saying 'no', but a lot of people have legitimate needs. So, instead you end up converting your tool into a platform.

Some of the most interesting ideas in the CocoaPods ecosystem come from plugins.

I wanted plugins to be a first class citizen within Danger from day one. It's in the [VISION][vision] file, and it's applied into how I've designed a lot of the user-facing site. I was [torn][plugins_1] after a few months of development [where things][plugins_2] should go. Now the core of Danger is [built as plugins][plugins_3].

### Documentation

My second big project on CocoaPods was collating documentation and scoping different types of documentation. In CocoaPods I ended with:

* **Highlight pages** (intro pages, app pages, team pages)
* **Guides** (tutorials, overviews, FAQs)
* **Reference** (Command-line interface, APIs for developers)

These 3 buckets for documentation makes it pretty easy to separate where people should look depending on what they're looking for. This pattern I'm stealing outright for Danger. Just not quite yet, it's a blocker on 1.0 though.

One trick I took from CocoaPods is to have as much documentation as possible generated from the source code. With Danger, all of the work that's gone into documenting the code is turned into public API documentation for end-users. This makes it really easy to ensure it's consistent and up-to-date. The same tools used to generate documentation for Danger are used for plugins. Any improvements there helps everyone.

## User Data

Not storing any, phew! Though if [Danger as a Service][daas] happens, then it will.

## People

People are hard, Ash said in [Building Popular Projects][building_pop_projects]:

> The biggest existential threat to your library is this: you get burned out and stop working on it – and no one else contributes to it –

Understanding motivations, encouraging ownership and accommodating multiple viewpoints are vital parts of anyone who wants to make a project bigger than themselves. There [are lots of times][danger_contributions] when I'm not the lead developer on Danger.

I owe a lot of this to the policy Ash and I created with Moya, the wordy "[Moya Community Continuity Guidelines][moya_guidelines]" which define the expectations of the maintainers of a project towards contributors.

It's helped let a lot of other contributors make an impact. In the future, I hope those are the people that I get to hand Danger off to. Danger is bigger than me.

---

Maintaining big projects is a learned activity, for most people it's a spectator sport, but it's not too hard to jump from writing issues to helping out. It's how I ended up contributing to CocoaPods.


[cocoapods]: https://cocoapods.org
[specta]: http://cocoapods.org/pods/Specta
[moya]: http://cocoapods.org/pods/Moya
[danger_gh]: https://github.com/danger/danger/
[process]: https://github.com/artsy/mobile/issues/31
[dev_news]: https://developer.apple.com/news/
[gh_inspector]: https://github.com/orta/gh_inspector
[fastlane_gh]: https://github.com/fastlane/fastlane/releases/tag/1.96.0
[cocoapods_gh]: https://github.com/CocoaPods/CocoaPods/pull/5421
[vision]: https://github.com/danger/danger/blob/master/VISION.md
[trunk]: https://github.com/CocoaPods/trunk.cocoapods.org
[cocoapods_org]: https://github.com/CocoaPods/cocoapods.org
[search]: https://github.com/CocoaPods/search.cocoapods.org
[cocoadocs_org]: https://github.com/CocoaPods/cocoadocs.org
[middleman]: https://middlemanapp.com
[slim]: https://rubygems.org/gems/slim
[sass]: https://rubygems.org/gems/sass
[yard]: https://rubygems.org/gems/yard/versions
[webhooks]: https://github.com/danger/danger.systems/blob/master/webhooks/server.rb
[rubygems]: https://en.wikipedia.org/wiki/RubyGems
[plugins_1]: https://github.com/danger/danger/issues/74
[plugins_2]: https://github.com/danger/danger/pull/156#issuecomment-205907128
[plugins_3]: https://github.com/danger/danger/pull/227
[daas]: https://github.com/danger/danger/issues/42
[building_pop_projects]: https://ashfurrow.com/blog/building-popular-projects/
[danger_contributions]: https://github.com/danger/danger/graphs/contributors
[moya_guidelines]: https://github.com/Moya/contributors
[ash]: /author/ash
