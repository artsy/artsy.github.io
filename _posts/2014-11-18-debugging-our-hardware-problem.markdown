---
layout: post
title: "Close to the Metal: Debugging Our Hardware Problem"
date: 2014-11-18 08:33
comments: true
categories: [iOS, mobile]
author: ash
---

For the past few months, Artsy’s mobile team has been working on [Eidolon](https://github.com/artsy/eidolon), a bidding kiosk for Artsy’s auctions platform. While we’ve written a [retrospective](http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/) on the process of making Eidolon from the software side of things, we didn’t really touch on how our software is being used.

<!-- more -->

For typical iOS applications, you create an archive with Xcode and send it to users via the Internet. Maybe it’s an App Store release that goes to Apple before being downloaded by your users. Maybe it’s a beta release that goes to [Hockey](http://hockeyapp.net/) before being downloaded by your users. Maybe it’s an enterprise build that goes to your own servers before being downloaded by your users. In any case, there is one thing in common: your users download the software themselves and run it on their own devices.

Eidolon is different. We develop the software and package it using enterprise distribution and use Hockey to download it to our own iPads. These iPads are managed by the Artsy auctions team at events; they are housed in these nifty little stands which hold the iPad in place and also allow room for the credit card readers.

![Eidolon at our first auction](/images/2014-11-18-debugging-our-hardware-problem/first_auction.jpg)

At our first auction, everything went great – no major glitches or crashes. Awesome!

A few weeks later, on the morning of our second auction, things were no so great. We were having issues with our credit card processor, [CardFlight](https://getcardflight.com) and spent a lot of time on the phone with them sorting out the problem. As a precaution, [Orta](http://twitter.com/orta) pulled of an extraordinary feat of engineering to produce a manual card entry interface in a matter of hours. The card processing was working, but it would’ve been better to be safe than sorry.

That evening, the auctions team was preparing, and they discovered a problem: *some* of the Kiosks were experiencing a new problem processing cards. That was strange because earlier that day, the first issue was affecting *all* kiosks. Because we had had problems earlier that day with CardFlight, we assumed that this new problem was also on their end. We didn’t have time to debug the problem, but the event itself went fine because we had that manual entry interface. However, we definitely needed to find the cause of the problem later.

Orta tried over the next several days to diagnose the issue, but he couldn’t reproduce it at all. Different code, different build settings, different distribution methods – nothing could reproduce the problem.

![Debugging the issue](/images/2014-11-18-debugging-our-hardware-problem/desk.jpg)

Eventually, we decided that the issue must have resolved itself somehow and hopefully wouldn’t pop up again. We simply didn’t have time to keep trying to reproduce a phantom bug.

Fast forward to last night at the [third auction](https://artsy.net/feature/ici-benefit-auction-2014) facilitated with Eidolon. We get there, and some of the kiosks are exhibiting the same behaviour, even though our tests earlier in the day didn’t show the problem. We tried over and over again: disassembling a problematic kiosk, discovering it worked outside the housing, then reassembling it to see it no longer working. What could the problem be?

Well, let’s take a look at the kiosks we used last night.

![Kiosk housing](/images/2014-11-18-debugging-our-hardware-problem/housing.jpg)

Notice anything different from our first auction kiosk?

In between the first and second auctions, the white faceplates we had ordered arrived. The auctions team put them on the Kiosks for the second auction, which is when the problem first presented. When Orta tried to reproduce the problem, the iPads he used weren’t in the housings – they were just on his desk.

It turned out that faceplate had some foam to provide resistance against the housing to prevent them from slipping apart. Take a look and see.

![Kiosk disassembled](/images/2014-11-18-debugging-our-hardware-problem/disassembled.jpg)

When the faceplate was slid onto the housing, the foam was catching on the rubber padding of the card reader (which plugs into the headphone jack of the iPad). Sliding the faceplate onto the housing was sometimes pushing the card reader a few millimetres out of the headphone jack, causing our problem.

![The problem](/images/2014-11-18-debugging-our-hardware-problem/catching.jpg)

The solution was simple: tear off the rubber padding from the card reader and cut off some foam from the faceplate.

![Our solution](/images/2014-11-18-debugging-our-hardware-problem/solution.jpg)

After that, the faceplate would slide on without issue and all of the kiosks worked fine. It took some time to disassemble all of the kiosks, but we got it working in time for the auction. Eidolon’s third performance was a success.

As I said earlier, Eidolon is different from typical iOS applications – our experience writing typical apps left us ill-equipped to debug what turned out to be a hardware problem. We learnt that, when reproducing bugs that only happen in production, it’s crucial to reproduce the *physical* context that the bug is occurring in as closely as possible. We also learnt that jumping to the conclusion that CardFlight was responsible for our issues was, while a natural gut reaction, deserved closer scrutiny when later trying to reproduce the problem.

Our auctions team was happy that we solved the phantom card-swiping problem and our users were none-the-wiser to the hurried use of Allen keys backstage to disassemble and reassmble kiosks. Eidolon, the software that we had poured so much time into, was almost defeated by a errant piece of foam. But we prevailed.

<div style="text-align:center;">
<a href= "http://www.thebos.co/p/XUJNAY"><img src = "/images/2014-11-18-debugging-our-hardware-problem/success.gif"></a>
</div>
