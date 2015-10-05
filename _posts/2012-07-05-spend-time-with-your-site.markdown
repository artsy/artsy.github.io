---
layout: post
title: "Spend Time With Your Site"
date: 2012-07-05 10:51
comments: true
categories: [Heroku, EC2, Product Management]
author: joey
---

Empathy with end users is critical when developing consumer-facing software. Many go [even](http://innonate.com/2011/03/09/hackers-the-canon-of-consumer-facing-products/) [further](http://www.uie.com/articles/self_design/) and argue that you should _be_ your own user to effectively deliver the best experience.

> _I'd encourage anyone starting a startup to become one of its users, however unnatural it seems._
>
> &mdash; Paul Graham [Organic Startup Ideas](http://paulgraham.com/organic.html)

In practice, though, this can be difficult:

* As a developer, you're just not representative of the intended audience.
* You're [appropriately] focused on the product's next iteration, while your audience is occupied with the current state.
* You spend countless hours focused on product details&mdash;of course it's a challenge to empathize with a casual visitor's first impression.

Keeping it Real
---------------

We've tried some best practices to overcome these tendencies. User feedback is emailed to everyone in the company. Engineers share customer support responsibilities. But one simple tool has been surprisingly useful: we stole a page from the agile development handbook and built an [information radiator](http://alistair.cockburn.us/Information+radiator). Like a [kanban board](http://en.wikipedia.org/wiki/Kanban_board), news ticker, or [analytics wall board](https://demo.geckoboard.com/dashboard/B6782E562794C2F2/), our information radiator gives us an ambient awareness of end users' experiences. How?

<!-- more -->

**It's our site, as a slideshow.**

{% include expanded_img.html url="/images/2012-07-05-spend-time-with-your-site/slideshow_screenshot.jpg" title="Artsy as a slideshow" %}

That's all. Our wall-mounted display shows the same web page that a visitor to our site recently requested. Every 20 seconds, it refreshes and shows a new, more recently requested page.

Without much effort, this gives us a sense of where users spend time on the site (_nudes seem popular today_). The impact of events such as email blasts or celebrity mentions is immediately apparent (_did [@aplusk](https://twitter.com/aplusk) just tweet us?_). And when problems happen, we notice them as soon as errors pop up on the screen (_[AWS down again?](http://gigaom.com/cloud/some-of-amazon-web-services-are-down-again/)_).

Of course, this doesn't replace proper user research, analytics, or monitoring. And the approach might need tweaking to work for your site. The lesson, though, is _find a way to spend time with your site_.

Implementation Notes
--------------------

Using [knife-solo](https://github.com/matschaffer/knife-solo) and [chef](http://www.opscode.com/chef/), we spawned an [EC2](http://aws.amazon.com/ec2/) instance and configured it to [drain our main site's logs from heroku](https://devcenter.heroku.com/articles/logging#syslog_drains). A single, static web page contains a full-screen iframe and a bit of javascript that periodically requests the most recent URL from a tiny [sinatra](http://www.sinatrarb.com/) app, loading the resulting URL into the iframe. The sinatra app performs an ugly bash command to grep the last appropriate GET request from the drained log, filtering out requests from Artsy HQ and other uninteresting cases. Via a special flag, our site suppresses the usual tracking and analytics when loaded in this context (you didn't want to juice your stats, right?).

Have other tricks for keeping it real? Let us know in the comments.

_Update:_ See a gist with [sample code for the slideshow app](https://gist.github.com/3073907).
