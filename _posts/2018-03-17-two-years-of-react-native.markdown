---
layout: epic
title: "React Native, 2 years later"
date: 2018-03-17
author: orta
categories: [Technology, emission, reaction, reactnative, react, javascript]
css: what-is-react-native
series: React Native at Artsy
comment_id: 420
---

[@alloy][alloy] first mentioned React Native as an option for Artsy back [in March 2015][22], and in February 2016 he
made [our first commit][1st] to get the ball rolling. Since then, we've grown a new codebase, [Emission][emission],
which has slowly taken over the responsibility for creating the UIViewControllers presented inside our iOS app.

We've come quite far from where we started, and I was asked if I could give a talk to summerize what we've learned in
the last 2 years as a set of native developers using React Native.

The [slides are on speakerdeck][sd], and I've [opened comments][comments] for this post if people have questions. Jump
through to get to the video or watch it [on Prolific's site][prolific] for [iOSoho][iosoho].

<!-- more -->

Table of Contents for the Video:

<ul id="timers">
  <li><a href="#video" data-time="330">Why move? 5:30</a></li>
  <li><a href="#video" data-time="520">Why not Swift? 8:40</a></li>
  <li><a href="#video" data-time="590">What we expected vs what we have: 9:50</a></li>
  <li><a href="#video" data-time="960">Downsides: 16:00</a></li>
  <li><a href="#video" data-time="1235">Artsy Omakase: 20:35</a></li>
  <li><a href="#video" data-time="1420">Upsides: 23:40</a></li>
  <li><a href="#video" data-time="1645">In-App demo of Emission: 27:25</a></li>
  <li><a href="#video" data-time="2195">RN Brownfield Apps: 36:35</a></li>
  <li><a href="#video" data-time="2379">Our Deployment: 39:30</a></li>
</ul>

<center id="video">
  <iframe src="https://player.vimeo.com/video/260417482" width="100%" height="600" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
</center>

<script src="https://player.vimeo.com/api/player.js"></script>
<script>
  $(() => {
    $('#timers a').click( function(e) {
      var time = $(this).attr("data-time");
      var iframe = document.querySelector('iframe');
      var player = new Vimeo.Player(iframe);
      player.setCurrentTime(time)
      e.stopPropagation()
    });
  })
</script>


[alloy]: https://twitter.com/alloy/
[22]: https://github.com/artsy/mobile/issues/22
[1st]: https://github.com/artsy/emission/commit/b9154d4145feb49b38e713ee84594de04ea377e3#diff-9879d6db96fd29134fc802214163b95a
[emission]: https://github.com/artsy/emission/
[sd]: https://speakerdeck.com/orta/react-native-2-years-later
[comments]: https://github.com/artsy/artsy.github.io/issues/420
[prolific]: https://www.prolificinteractive.com/iosoho/
[iosoho]: https://www.meetup.com/iOSoho/
