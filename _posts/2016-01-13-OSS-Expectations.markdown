---
layout: post
title: "Open Expectations"
date: 2016-01-13 11:09
author: orta
categories: [mobile, oss, meta]
series: Open Source by Default
---

The Artsy engineering team has been moving towards Open Source by Default. In 2015 the Mobile team managed to get there. Since then, we've been writing up our process on this blog and offering advice to anyone would would ask for it.

I've been in talks with lots of companies you've heard of, on the how and the why of this. Recently [Ello](https://ello.co) got in touch, and we tried to [capture the process](https://en.wikipedia.org/wiki/Dyson_sphere).  They came out with a great post that I'd strongly [recommend reading](https://ello.co/jayzes/post/tqLL-Z8U8GfbDySRk6wbKg). I'd like to try and come from the other side, and address what are the questions people ask. Consider this a FAQ for how the mobile team does/got to OSS by default.

<!-- more -->

<img src = "https://d324imu86q1bqn.cloudfront.net/uploads/asset/attachment/3421690/ello-optimized-08acbd80.gif">

### Really, is _everything_ Open Source?

No, and it probably never will. There are companies who are (e.g. [Buffer](https://buffer.com/transparency) & [Automattic](https://automattic.com)) however Artsy is considerably less transparent in-comparison. We have code-bases that will stay closed, and we have data that could stay closed.

Companies revolve around ideas, and understanding what your core value is important. A company who make money purely off selling their apps could be easily copied, and OSS by default won't work for them. Artsy is a platform, but OSS by default can work for us because a technical platform is just one aspect of what we offer.

### How did we start the process?

We're lucky to have [technical](http://www.forbes.com/special-report/2014/30-under-30/art-and-style.html) [co-founders](https://www.linkedin.com/in/sebastiancwilich), and a CTO with a strong belief in [Open Source](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html). So we had a head-start, I respect that.

Like all big ideas, it started out small. We'd abstract out shared concerns into libraries. This is something that anyone who has heard a little bit about Open Source can get behind. "We're building on top of _x_, so we really should give back out _x_+_y_" it's low-risk, and potentially high reward. Getting the company on-board with your OSS libraries is about acclimatisation.

This works best by taking small incremental steps. You need buy-in from everyone involved through-out the process. Moving to OSS by Default is 30% technical work and 70% political relationships. There has to be infrastructure in place in order to not leak secrets, but you also need to ensure that the entire company doesn't feel threatened by the insight offered by opening the development process. There is no shortcut here.

For me, this process involved talking with everyone involved in each project. Setting aside 1-on-1 time specifically on the subject to answer question about the ramifications for OSSing it. This ranged from "we will need to change the flow around _x_ and _y_." to "Yes, the competition will be able to see how we do _x_ and _y_." I came very prepared to these meetings.

For our mobile apps, we progressively introduced Open by Default to our apps based on their age. We started out by creating a whole [new project](/blog/2014/11/13/eidolon-retrospective/) as Open Source. Then started applying what we had learned to [older](/blog/2015/04/28/how-we-open-sourced-eigen/) [projects](/blog/2015/08/06/open-sourcing-energy/). They had more risk, given that they were mature apps.

### Couldn't someone make a business copying me?

It's also worth remembering that an app being OSS does not stop it [being copied](http://venturebeat.com/2014/03/30/threes-vs-2048-when-rip-offs-do-better-than-the-original-game/). Or, well, your [entire business](http://www.bloomberg.com/bw/articles/2012-02-29/the-germany-website-copy-machine).

Code only represents the _past to almost present_ of your business, losing a valuable colleague hurts because of their ability to move your business forwards. A "fresh replacement" has a while to go in terms of being able to make the change you want. Someone trying to build off your source, has to learn to understand your motivations, your aspirations and then try build what they'd like around that. It's not good business sense.

### License Selection

I covered this in [Licensing for OSS](/blog/2015/12/10/License-and-You/). If you want the TL:DR for Apps on app stores, jump to "Viral".

We use the [MIT license](https://en.wikipedia.org/wiki/MIT_License) on all Open Source projects. It's worked out so far for us, because as a platform each individual component can exist standalone. Having a fork of all our projects does not make you a competitor to us.

### I have code that _has_ to stay hidden

So do we! In the iOS world, we use API compatible Open/Closed CocoaPods that allow for us to mock out for OSS consumers and let us use [private implementations](/blog/2014/06/20/artsys-first-closed-source-pod/). If you're trying to hide secret API calls, it's probably easier for someone to run a [proxy](http://www.charlesproxy.com) than it is to find the section of code calling it.

Having the core of your application Open Source doesn't mean you cannot develop features in private. I [built a WatchOS app](https://github.com/artsy/eigen/pull/302) for Eigen entirely on a private repo, where once a week for 2 months I rebase'd changes from the main repo. When we felt comfortable about making it known publicly we were working on it - I brought it over to a public repo and initiated the [code review](https://github.com/artsy/eigen/pull/302).

### Our expectations of OSS contributors

We don't expect people to contribute to our apps. For libraries, that's different. I think [Ello's write-up](https://ello.co/jayzes/post/tqLL-Z8U8GfbDySRk6wbKg) really nailed this point, so I'll just quote jayzes:

> On one hand, we have library and infrastructure code — things that are more generic and reusable. These are the sort of thing that we can more easily envision starting to grow communities around, albeit small ones.

> On the other hand, we have custom-built applications, which are likely to have limited utility outside of their current purpose due to size and coupling to other parts of Ello’s infrastructure (the Ello API, for one). We don’t envision these apps building much of a community around themselves in the way that most open source tools and libraries do, and see the primary value in opening them up coming as a result of increased transparency. That having been said, we’ll certainly accept pull requests that fit our product roadmap and engineering standards, should anyone feel like jumping in and contributing!

Beautiful. This is exactly how I feel, and in over a year these expectations have been met. Some of our libraries have become big, and our apps have received small feature PRs. We're pleasantly surprised when it happens, but we don't expect it.

### What didn't we expect?

I didn't expect to be told face to face how many people have read, and learned from our codebases. We get around 120 unique clones of our iOS apps every week. People tell us that it's where they found a certain technique, or that they could see how the trade-offs were made for certain decisions.

I also under-estimated how useful open code is in encouraging a culture of writing. Ash once quoted [me in a tweet](https://twitter.com/ashfurrow/status/676814159363842048) saying:

> Order of importance: blog posts > types > tests

While it is a joke against functional programmers, in general; having these huge codebases gives a lot to talk about. A commit says the what, a pull request the how and a blog post gives the why. Writing about our code allows us to provide documentation for future employees with the context around how decisions were made. Nobody _wants_ to ship messy code, but a lot of the time you choose to in order to provide something positive.

### How does Open Source affect security

Artsy has a [security policy](https://www.artsy.net/security), with bounties and ways to report issues. From our perspective so far, having this open has not affected the reports we receive. If 1Password [can say](https://teams.1password.com/white-paper/1Password%20for%20Teams%20White%20Paper.pdf)

> We believe that openness always trumps “security through obscurity”.

Then show off their algorithms that keep passwords safe, then so long as we're careful about our keys and stick to best security practices. We seem to be doing alright.


### What is a good approach to talk to the legal team?

I have a friend who works in a very large company. He told me that he was aiming to Open Source his app. He had had a few meetings with the legal team that didn't really go anywhere. After a few meetings, he explained that they weren't aiming for community-building with this, but aiming to develop in the open. This change of perspective, changed the tone of the meetings from then on in. It became much easier to start the political work necessary to even begin working on the technical aspect.

### Alright, so I'm gonna need ammo for these meetings.

Looking back at the last year, here's been some highlights:

#### Personal

* It's gratifying to give back to communities who help you get things done.
* It's so much easier to talk about [technical challenges](https://github.com/artsy/eigen/issues/586), and [achievements](/blog/2015/12/15/Automating-Testflight-Deploys/) when you can let people explore; before, the code review, and after.
* The code you write does not become unavailable to you when you leave the company. Carry your best ideas between jobs.

#### Company-wide

* You can structure in a way so that contributions within your team reflect how working in the OSS community is. Lowering the barrier of entry for your team to contribute back to their dependencies. There is little cultural differences between being a high-level contributor to CocoaPods and working in the Artsy mobile team.
* Working in the open is a great way to raise the profiles of your team, and the individuals on it. This opens extra potential for personal growth for individuals. Not just professional.
* It can make it easier to hire, because you can "[show](https://github.com/artsy/mobile/)", not "[tell](https://www.artsy.net/article/artsy-jobs-mobile-engineer)" the positives in your team culture.
* You open the doors to potential contributors. Those contributors could eventually become hires.

This is still pretty new, there's a lot to explore in the space. The mobile team at Artsy is always happy to talk with people interested in doing it themselves. Send us an email at [mobile@artsy.net](mailto:mobile@artsy.net), tweet to [@ArtsyOpenSource](https://twitter.com/ArtsyOpenSource) or DM me [@orta](https://twitter.com/orta).
