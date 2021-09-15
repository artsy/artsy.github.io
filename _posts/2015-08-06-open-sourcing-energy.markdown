---
layout: post
title: "Open Sourcing Energy"
date: 2015-08-06 13:54
comments: false
categories: [ios, mobile, energy, open source, oss]
author: orta
series: Open Sourcing Your App
---

The Artsy Mobile team is pretty aggressive in our stance on
[Open Source by Default](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html). We've talked
about it at [conferences](https://www.youtube.com/watch?v=2DvDeEZ0NDw&spfreload=10)
[around](https://www.youtube.com/watch?v=SjjvnrqDjpM) [the](https://www.youtube.com/watch?v=zPbLYWmLPow)
[world](https://speakerdeck.com/orta/ios-at-artsy), in
[renowned magazines](http://www.objc.io/issues/22-scale/artsy) and on
[our blog](http://artsy.github.io/blog/2015/04/28/how-we-open-sourced-eigen/).

It's worth mentioning that we don't just talk externally about Open Source. Internally, the Mobile team runs talks
about Open Source for the rest of the Artsy staff. As well, we discuss the tooling and business implications of
having our work in public repos. Artsy strives for an open culture, in this case the development team, on the
whole, is just further along in the process.

The Open Source app idea started with an experiment in the Summer of 2014, asking, "What does a truly Open Source
App look like?" The outcome of that was our Swift Kiosk app, [Eidolon](https://github.com/artsy/eidolon/). Open
from day one. We took the knowledge from that and applied it to our public facing app,
[Eigen](https://github.com/artsy/eigen/). Open from day 806. That made 2/3rds of our apps Open Source.

I'm going to talk about our final app, [Energy](https://github.com/artsy/energy). Open from day 1433 and ~3500
commits.

<!-- more -->

---

![ENERGY](/images/2015-08-01-open-sourcing-energy/ENERGY.png)

Energy is commonly known as [Artsy Folio](http://folio.artsy.net). It's a tool for Artsy's Partners to showcase
their artworks on the go, and quickly email them. Here's a beautiful splash showing it in action.

{% expanded_img /images/2015-08-01-open-sourcing-energy/cover-f1aa2339.jpg Folio overview %}

This app comes from the pre-CocoaPods, pre-ARC, pre-UICollectionView and pre-Auto Layout days. It spent 3 years
with no tests, but has come up to over 50% code coverage in the last year. It's testing suite is super fast, given
that we learned a lot with Eigen's tests we stuck with five main principals:

- No un-stubbed HTTP requests.
- Avoid `will`s in a test as much as possible.
- Never allow access to the main Core Data instance in tests
- Dependency Inject anything
- Use snapshots to test view controller states

### On Opening Folio

Folio is interesting in that it has competitors. To some extent the Kiosk app does too, but the cost of entry there
is really high in comparison. Folio on the other hand, has a handful of competing businesses who exist to _only_
build a Gallery/Museum/Collector portfolio app. In opening the code for Folio, we're not making it easy for people
to copy and paste our business, it's very directly tied to Artsy's APIs and
[CMS](http://www.dylanfareed.com/projects/artsy-cms/).

I commonly get questions about the process of Open Sourcing an app, so here's what happened after I decided it was
time. First, I emailed my intent:

{% expanded_img /images/2015-08-01-open-sourcing-energy/oss-energy-email.png %}

The concepts I wanted to cover were: "This is a codebase is worthy of art", "We know what we're doing", "This
doesn't make it simple for someone to create a business off our product" and "I've managed to get a lot of the
source out already." I gave a month or so to ensure that I could have corridor chats with people, in order to be
very certain around opinions. We had some discussions in the email thread about ways in which an open source'd
Energy would impact the team, and overall the reaction was positive. This wasn't surprising, the non-technical
parts of the team are regularly kept up to date on thoughts like this.

After the internal announcement I started looking at the codebase, what should be cleaned up. I don't believe a
codebase is ever perfect ( just look at Eigen's
[HACKS.md](https://raw.githubusercontent.com/artsy/eigen/3f29f61f2b96f516e9ecf407818b82911b268694/HACKS.md) ) but
one thing I learned from the launch of Eigen is that we need a lot of beginner docs to help people get started. So
I went into Energy's [docs](https://github.com/artsy/energy/tree/master/docs) directory and started comparing it to
[Eigen](https://github.com/artsy/eigen/tree/master/docs)'s.

With the docs ready, we anticipated the repo change as we did
[with Eigen](/blog/2015/04/28/how-we-open-sourced-eigen/). This means making sure all loose pull requests were
wrapped up. All code comments were audited. Then we used
[github-issue-mover](https://github.com/google/github-issue-mover) to migrate important issues to the new repo.
Then we deleted the `.git` folder in the app, and `git init` to create a new repo.

Given that we have three Open source apps now, I wanted to give them a consistent branding when we talk about the
apps from the context of the codebase. It's like programming, if you're writing a similar thing 3 times, definitely
time to refactor.

{% expanded_img /images/2015-08-01-open-sourcing-energy/oss-design-sketch.png %}

Finally, I started working on the announcement blog post. Which you're reading. I'll send a
[pull request](https://github.com/artsy/artsy.github.com/pull/119) for this blog post, then when it's merged. I'll
make one more final look over how everything looks, then make the new Energy repo public.

### On more than just Opening Source

Eigen, the public facing iOS app, allows people to log in with a trial user account. We also have a known API Key +
Secret for the [OSS app](https://github.com/artsy/eigen/blob/master/Makefile#L41-L42). With this, any developer can
run a few commands and have a working application to play around in. This makes it easy to look around and see how
things are done.

Energy, however, requires you have a Artsy partner account. So opening it up would mean that an OSS developer hits
the login screen and is stuck. In developing this app, I've slowly been creating my own partner gallery account
based on my paintings and photography. So now when you set up the app to be ran as an OSS app, it will pre-load a
known database of artworks and metadata from my test gallery.

{% expanded_img /images/2015-08-01-open-sourcing-energy/ios-sim.png %}

Its easy to imagine that Open Sourcing something is an end-point, but from our perspective it is a journey. We want
to make sure that anyone can download this app, learn how and why it's structured and then run through the app with
a debugger to get a deeper sense of how everything connects. Just releasing the code would have been underwhelming.
Instead we're aiming high.

I think that there is no higher compliment to your team and your code than opening it to the public.

You should Open Source your app.
