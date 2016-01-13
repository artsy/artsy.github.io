---
layout: post
title: "Open Expectations"
date: 2016-01-13 11:09
author: orta
categories: [mobile, oss, meta]
---

The Artsy engineer team has been moving towards Open Source by Default. In 2015 the Mobile team managed to get there. Since then, we've been writing up our process on this blog and offering advice to anyone would would ask for it.

I've been in talks with lots of companies you've heard of, on the how and the why of this. Recently [Ello](https://ello.co) got in touch, and we tried to [capture the process](https://en.wikipedia.org/wiki/Dyson_sphere).  They came out with a great post that I'd strongly [recommend reading](https://ello.co/jayzes/post/tqLL-Z8U8GfbDySRk6wbKg). I'd like to try and come from the other side, and address what are the questions people ask. Consider this a FAQ for how the mobile team does/got to OSS by default.

<!-- more -->

<img src = "https://d324imu86q1bqn.cloudfront.net/uploads/asset/attachment/3421690/ello-optimized-08acbd80.gif">

### Really, is _everything_ Open Source?

No, and it probably never will. There are companies who are (e.g. [Buffer](https://buffer.com/transparency) & [Automattic](https://automattic.com)) however Artsy is considerably less transparent in-comparison. We have code-bases that will stay closed, and we have data that could stay closed.

Companies revolve around ideas, understanding what your core value is important. A company who make money purely off selling their apps could be easily copied, and OSS by default won't work for them. Artsy is a platform, OSS by default can work for us because a technical platform is just one small aspect of what we offer.

### How did we start the process?

We're lucky to have [technical](http://www.forbes.com/special-report/2014/30-under-30/art-and-style.html) [co-founders](https://www.linkedin.com/in/sebastiancwilich), and a CTO with a strong belief in [Open Source](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html). So we had a head-start, I respect that.

Like all big ideas, it started out small. We'd abstract out shared concerns into libraries. This is something that anyone who has heard a little bit about Open Source can get behind. "We're building on top of _x_, so we really should give back out _x_+_y_" it's low-risk, and potentially high reward in hiring.

Getting the company on-board with your OSS libraries is about acclimatisation. This works best by taking small incremental steps. You need buy-in from everyone involved though-out the process. Moving to OSS by Default is 30% technical work and 70% political relationships. You need to have infrastructure in place in order to not leak secrets, but you also need to ensure that the entire company doesn't feel threatened by the insight offered by opening the development process. There is no shortcut here.

### Couldn't someone make a business copying me?

It's also worth remembering that an app being OSS does not stop it [being copied](http://venturebeat.com/2014/03/30/threes-vs-2048-when-rip-offs-do-better-than-the-original-game/). Or, well, your [entire business](http://www.bloomberg.com/bw/articles/2012-02-29/the-germany-website-copy-machine).

Code only represents the _past to almost present_ of your business, losing a valuable colleague hurts because of their ability to move your business forwards. A "fresh replacement" has a while to go in terms of being able to make the change you want. Someone trying to build off your source, has to learn to understand your motivations, your aspirations and then try build what they'd like around that. It's not good business sense.


### License Selection

I covered this in [Licensing for OSS](/blog/2015/12/10/License-and-You/). If you want the TL:DR for Apps, jump to "Viral". We use MIT everywhere. It's worked out so far.

### I have code that _has_ to stay hidden

So do we! In the iOS world, we use API compatible Open/Closed CocoaPods that allow for us to mock out for OSS consumers and let us use [private implementations](/blog/2014/06/20/artsys-first-closed-source-pod/). If you're trying to hide API secret calls, it's probably easier for someone to run a [proxy](http://www.charlesproxy.com) than it is to find the section of code calling it.
