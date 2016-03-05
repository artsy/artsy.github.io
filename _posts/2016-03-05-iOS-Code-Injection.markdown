---
layout: post
title: "Code Injection for Xcode"
date: 2016-03-05 12:09
author: orta
categories: [mobile, xcode, swift, video]
---

I have been writing code for roughly a decade. A large chunk of that time has been sitting waiting for my project to compile. It's a nice excuse to [practice sword fighting](https://xkcd.com/303/) in the office, but really, deep down. It's frustrating. It's so easy to become [nerd-sniped](https://xkcd.com/356/) when you wait for a long time.

As we integrate Swift into our projects, I've been seeing our compile times increase. So, I took some time to look at ways to improve this. The best option, so far, has been dynamic code injection via [Injection Plugin for Xcode](https://github.com/johnno1962/injectionforxcode). In a gist: This means that we don't recompile and re-launch, instead we inject new bits of code into a running application. This reduced the compile cycle on Eigen from 7 seconds to 1 second.

I took some time over the weekend to try and put together a video showing how I used code injection on a trivial app to create a view controller in code. It covers the technique I've [started using in Eigen](https://github.com/artsy/eigen/pull/1236) and talks a little bit about how the pieces come together.

Jump [to YouTube](https://www.youtube.com/watch?v=uftvtmyZ8TM) for the video, or click more for a smaller inline preview.

<!-- more -->

{% youtube uftvtmyZ8TM %}