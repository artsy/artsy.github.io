---
layout: post
title: 'Teaching Swift at Artsy'
date: 2016-01-26T00:00:00.000Z
comments: false
categories: [ios, mobile, review, video, code, swift, oss, teaching]
author: ash
series: Swift at Artsy
---

While the Artsy engineering team includes many disciplines, tech stacks, and personalities, we all share a few things in common: a respect for each other, an appreciation of art-meets-science, and a celebration of learning. These are actually traits shared with our entire company, even non-engineers. So last Summer when Orta and I had some down time, it occurred to us how we could do something super-productive that was congruent with our values: we could teach the company Swift.

<!-- more -->

Like most project ideas, the first step was to create a [GitHub repo](https://github.com/orta/Swift-at-Artsy). We made it open source because [why not](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html). Orta and I chatted and realized that to teach the company Swift, we would need two tracks:

- A track for newcomers who may have never programmed before.
- A track for anyone who could explain what "object-oriented programming" meant.

It was really important to us to include beginners who had no exposure to programming – the digital marketing and genoming teams specifically were keen to learn how to program. 

I'm a big believer in using "newcomer" and "informed" to describe the two groups of developers – it helps prevent newcomers from feeling inadequate and better describes the expectations for students.

We also focused on Swift-only, no iOS. That allowed us to focus on the language – which was fun because it let us focus on us learning new stuff, too – and we kept the course to five one-hour sessions (per track).

Next step was obviously to create a Slack chatroom. We re-purposed the oft-neglected room dedicated to Taylor Swift and turned it into a place where anyone could ask questions and share resources. It's also a helpful place to @channel everyone to remind them about the classes.

{% expanded_img /images/2016-01-26-swift-at-artsy/chatroom.png %}

Orta taught the beginner course and I TA'd it, answering questions as he instructed and offering suggestions when I felt something should be clarified (kind of like pair-programming except for teaching). We switched roles for the informed class. Preparing course materials was done through GitHub pull requests, which integrated well into our existing workflow on the mobile team.

We ran into some troubles in the first classes of both tracks: Swift 2 was in beta, and getting everyone on the correct versions of Xcode proved... difficult. Keeping them up-to-date as Xcode betas continued to be released over five weeks was also challenging. This was a problem in both tracks, but some problems were track-specific.

Explaining fundamental concepts like variables and for-loops to beginners is challenging. It reminded me of when I TA'd intro-to-Java courses in University (while the code then was obviously much uglier, `javac` is arguably more user-friendly than Xcode). Having the pair-programming approach worked well to help explain these concepts.

The biggest challenge with the informed class was rounding everyone up to actually attend the classes. Engineers are addicted to being busy, and like most side-projects, everyone was initially very excited about the course, but that interest dropped off quickly. Orta would help by physically going to our colleagues' desks and gently reminding them.

Regardless of the challenges, the course had a significant impact, both within Artsy and in the larger Swift community. Some of the course materials have been [translated into Chinese](https://github.com/orta/Swift-at-Artsy/blob/master/Beginners/Lesson%20One/README_ZH.md) and we regularly received suggestions (and occasionally corrections) about our content. Newcomers to programming gained insights into _what exactly engineers do_ and why bugs happen, while informed colleagues saw parallels between Swift and their own favourite languages (most often Scala). The course materials have also helped other mobile team members (who usually write only Objective-C) get started with Swift. 

The beginner students really appreciated [lesson three](https://github.com/orta/Swift-at-Artsy/tree/master/Beginners/Lesson%20Three) because we used real-world (scaled down) data structures that Artsy actually uses. We presented problems to solve – problems our colleagues were familiar with from their day-to-day work – and we showed how they can be solved with programming. [Lesson four ](https://github.com/orta/Swift-at-Artsy/tree/master/Beginners/Lesson%20Four) was the most well-received lesson as it featured some concrete "making the computer do cool stuff" material.

Finally, there was just a great sense of accomplishment. Orta and I had taken time during a downtime in engineering work and turned it into something that helped the company and helped the community. We got thanked internally and externally, and that felt great; helping others has a lot of tangible benefits, but feeling good about it is one of my favourites.

