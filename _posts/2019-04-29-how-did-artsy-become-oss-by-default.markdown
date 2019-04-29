---
layout: epic
title: "How did Artsy become OSS by Default?"
date: "2019-04-29"
author: [orta]
categories: [community, oss, culture]
---

One of the defining cultural features of the Artsy Engineering team is that we strive to be Open Source by Default.
This didn't happen over-night and was a multi-year effort from many people to push Artsy's engineering culture to
the point where it was acceptable and living up to the ideals still requires on-going effort today.

I think to understand this, we need to dive into the archives of some of member's older posts to grok their
intentions and ideas. Yes, this is a re-cap episode. Let's go.

<!-- more -->

# What is "Open Source by Default"?

In short, it's the idea that working in the open should be your starting position for a new project and when
creating a new project you need to argue the value of closing the project instead. This turns into an axiom which
powers quite a lot of the [Engineering Principles][principles] which Artsy holds dear.

In 2015, as we were nearing working entirely in the open - our CTO at the time, [dB.][db] wrote what became our
Open Source by Default north-star:

> When starting a new service, library or application I am going to default to open. I am going to weigh whether
> there’s any advantage of keeping a project closed-source, knowing and presuming that there’re numerous
> disadvantages.

> Team heads, including myself, are making open-source their foundation. This means building non-core intellectual
> property components as open source. That’s easily 2/3 of the code you write and we all want to focus on our core
> competencies. Hence open-source is a better way to develop software, it’s like working for a company of the size
> of Microsoft, without the centralized bureaucracy and true competition.

> By default, I contribute to other people’s generic open-source solutions to save time and money by not
> reinventing the wheel. Taking this further, I spend significant amount of time extracting non-domain-specific
> code into new or existing open-source libraries, reducing the footprint of the proprietary applications I work
> on.

→ [Becoming Open Source by Default][oss-default]

# How Did We Get There?

In 2011 Artsy hired [dB.][db] to be our Head of Engineering, You can get a sense of his frustration in trying to do
Open Source work in prior companies via a post from 2010 on opensource.com.

> Armed with a healthy dose of idealism, I went to executive management and proposed we open source the tool. I was
> hoping for a no-brainer and a quick decision at the division level. To my surprise, it took two years, a vast
> amount of bureaucracy, and far more effort than I ever anticipated.

→ [Corporate change: Contributing to open source][osscom]

In contrast today, in the culture he set up for Artsy Engineering - you actually have a ([tiny!][rfc_priv]) bit more
bureaucracy if you wanted to create a new _closed_ source project than an open source one.

## 2011 - First steps

Towards the end of 2011, Artsy's first step into contributing to open source was via a project called [Heroku
Bartender][hb] (dB. has a [write up on it][hb-db]).

Artsy is lucky because both of our co-founders have a technical background ([computer science at
Princeton][carter], and [AT&T Labs][seb]) because our CEO then sent a team email which really hammered the internal
value of writing OSS and letting people know it exists:

> "Team, The Engineering team just open sourced an awesome tool called Heroku-Bartender. It was mentioned on Hacker
> News with a link to its GitHub repository. It made it into the top posts. I want everyone to check it out and
> read through the comments. Open source is a great way for us to establish engineering credibility while
> contributing to the community-at-large. -Thank you and congratulations to Engineering."

dB. reflects on how different the mentality for open source is different in a modern startup in contrast to
existing large corporations.

> My CEO has made giving back to the community and building karma part of our company culture. Investors look for
> this because it attracts those top engineers who will ultimately execute the company’s vision. Open source is no
> longer the way of the future—it is the way the new CEOs are wired.

> The companies that don’t embrace these open movements will simply fail, because the culture of secrecy and fear
> is a thing of the past.

→ [Thinking open source: How startups destroy a culture of fear][destroy]

## 2012 - Open Communications

While Artsy started to ship a lot more libraries in 2012, probably the most important step we took during this
first year was creating this blog, and publishing 33 ([!][33_posts]) blog posts by 8 authors (close to the entire
team!).

This really helped established a baseline that external communications could be a foundation of openness, it might
not yet be code, but blog posts are an awesome start. I know my first blog during this time was specifically built
because I had solved a hard problem which I expected others would have. My answer wasn't generic enough to warrant
making a library but it was big enough to write a [blog post sharing the code][search] and providing context.

We structured write-ups as being an important part of our work, and dB. as Head of Engineering started leading by
example by shipping about 2/3rds of our posts. Writing this many blog posts in our first year of creating a blog is
a pretty solid achievement in my opinion, and the blog has always represented Artsy's Engineering team in one way
or another:

> I consider our blog, and the rest of the site, to be the canonical representation of the Artsy Engineering team
> online. We've carefully grown an Artsy Engineering aesthetic around it.

→ [Why We Run Our Own Blog][why-run]

Getting people into a space where they feel like contributions to this blog are not _big deals_ but are _iterative
improvements_ was step one towards OSS by Default.

> A commit says the what, a pull request the how and a blog post gives the why. Writing about our code allows us to
> provide documentation for future employees with the context around how decisions were made. Nobody _wants_ to
> ship messy code, but a lot of the time you choose to in order to provide something positive.

→ [OSS Expectations][oss-expectations]

<!--
require 'yaml'
a = YAML.load_file("config.yml")
a["oss_projects"].select { |o| o["created"].include? "2012" }.map { |o| '[' + o["title"] + '](' + o["repository"] + ')'  }.join(", ")
-->

That said, the team wasn't sitting on our hands in terms of making shared infrastructure, we built libraries within
the Ruby and iOS communities: [ARAnalytics](https://github.com/orta/ARAnalytics),
[resque-heroku-scaling-canary](https://github.com/aaw/resque-heroku-scaling-canary),
[heroku-forward](https://github.com/dblock/heroku-forward), [Garner](http://github.com/artsy/garner),
[spidey](https://github.com/joeyAghion/spidey), [guard-rack](https://github.com/dblock/guard-rack),
[rspec-rerun](https://github.com/dblock/rspec-rerun),
[hyperloglog-redis](https://github.com/aaw/hyperloglog-redis),
[cartesian-product](https://github.com/aaw/cartesian-product),
[space-saver-redis](https://github.com/aaw/space-saver-redis) &
[mongoid-cached-json](https://github.com/dblock/mongoid-cached-json).

Some of which we still use today.

## 2013 - Tools & Libraries

In 2013 Artsy took its first steps towards separating our front-ends from our back-ends. From a perspective of OSS
by Default this lowers the barriers a lot. We have been conservative with opening the source code for back-end
services, as they tended to contain more valuable business infrastructure.

As the web team explored building websites in Node, we took opportunities to use marketing websites like
[iphone.artsy.net][iphone] ([flare](https://github.com/artsy/flare)) and [2013.artsy.net][2013]
([artsy-2013](https://github.com/artsy/artsy-2013)) to explore building a website in the open. These projects were
small, self contained and well scoped. I wasn't involved in the decision to make them open, but I'm pretty sure it
went something like _"Should this be private? Nah. Ok."_ A single page web-app wasn't a risk.

The team also started exploring working on some more fundamental OSS infrastructure, we built out a framework for
building Node apps called [Ezel][ezel] (which we still use today [in Force][ezel_force]) and started work to
co-maintain CocoaPods and CocoaDocs.

## 2014 - New Apps

### artsy.net

In 2014 we [open-sourced the Artsy website][oss_force]. This was a major step forward in OSS by Default, we played
it safe by having the open source aspect as being a public fork that engineers would push changes to. This meant
that GitHub issues and Pull Request discussion could happen in private. It was a good, safe, incremental step. We
took an application which was very dear to us, and found a way to reduce the risk in moving to be open.

We could move our main website to be open source because we had successfully shipped prior art. The problems were
more or less the same, just at a larger scale. We had to worry about leaking secrets in code and commits, but those
best practices we had baked into the website from its inception 10 months prior.

### Editorial CMS & Bidding Kiosk

We scoped out building a [new CMS][pos] for our editorial team, this new app started as open source from day one.

This step inspired the iOS team who were also exploring trying to move to be more open in their work. By this point
we had two large private iOS apps, but had the need for a new iOS app for covering bidding at auctions on-site.

> Orta and I met some friends over a weekend in Austria and, during our drive across the country, discussed the
> possibility of developing this new iOS app as a completely open source project. We were both excited about the
> prospect and had the support from dB. to make it open.

→ [Developing a Bidding Kiosk for iOS in Swift][eid-retro]

We built out some necessary community infrastructure for iOS apps to be built in the open, and worked exclusively
in the open on this project. Working in the open on the bidding kiosk proved to be very useful when communicating
with others about hard problems we were seeing with new tooling, as well as providing reference implementations for
community ideas.

## 2015 - Backtracking to move iOS to OSS by Default

We were really starting to see what OSS by Default looks like by 2015. You can feel it in dB's and the mobile
team's writing:

> First, I recognize that becoming open-source by default is emotionally, organizationally and, sometimes,
> technically hard. As such, this post is not a manifesto, it’s a step in the right direction that will guide my
> career and technology choices in the future.

> When starting a new service, library or application I am going to default to open. I am going to weigh whether
> there’s any advantage of keeping a project closed-source, knowing and presuming that there’re numerous
> disadvantage

> I am going to default to the MIT License for all new projects, because it’s short and clear and protects everyone
> [...]

> Despite overwhelming evidence, many non-technical people are worried about risks surrounding open-source. I am
> convinced that any business success depends a lot more on your ability to serve customers and partners, the brand
> and culture and the commitment to hiring the best of the best in all fields, than on the hypothetical risks that
> a competitor might gain by taking advantage of your open-source software.

→ [Becoming Open Source by Default][db-oss]

> The Artsy mobile team is small, especially in contrast to the other teams in this issue of objc.io. Despite this,
> we’re notable for our impact on the community. Members of our iOS development team are — and have been — involved
> in almost all major open-source projects in the Cocoa community.

> At the start of 2015, we finished open sourcing the Artsy iOS app, eigen. This is a process that took many
> months; we needed to take considered, incremental steps both to prove that there was business value in open
> sourcing our consumer-facing app, and to disprove any concerns around letting others see how the sausage is made.

> Earlier, we said that being open source by default means that everything stays open unless there is a good reason
> to keep it secret. The code we do share isn’t what makes Artsy unique or valuable. There is code at Artsy that
> will necessarily stay closed forever.

> Working in the open isn’t so different from typical software development. We open issues, submit pull requests,
> and communicate over GitHub. When we see an opportunity to create a new library, the developer responsible for
> that library creates it under his or her own GitHub account, not Artsy’s.

> People often ask why we operate in the open as we do. We’ve already discussed our technical motivations, as well
> as the sense of purpose it gives individual team members, but honestly, working in the open is just smart
> business.

→ [iOS at Scale: Artsy][objc-artsy]

2015 was the year where the mobile team went back and open-sourced our previous iOS apps. We had two of them, we
started with the app the team worked on daily: Artsy for iOS (Eigen). We opened the repo in january, and had a
write-up on the process and changes needed to make it work a few months later once the dust has settled.

> Credit where credit is due, when we were working on Eidolon [the Bidding Kiosk], our CTO dB. just casually tossed
> the idea that, really, Eigen should be open source too.

> We devoted time at the end of 2014 to understand what the constraints were for getting the app opened. [...] We
> opted to go for a total repo switch, removing all history. There were a lot of places where keys could have been
> hiding within the app.

> One of the things that we found a bit sad about the transition to a new repo, is that it's hard to give past
> contributors recognition for their work.

> It's one thing to think that it's possible, it's another to do it. I'm glad that I am in a position where I can
> enact change. I felt no resistance in the process. I kept offering potential avenues for someone to stop me, too.
> I emailed the entire team as I started the process 2 weeks before it happened, I talked to anyone who might write
> issues or contribute from the design team. As I got further along the process and sent another email out that it
> was going to happen tomorrow. All I got were 👍 and 🎉s in GIF form.

→ [How we Open Source'd Eigen][oss-eigen]

Going through the process, and being certain in the trade-offs meant for the project gave the mobile team the
confidence to take the time to open source their oldest iOS project - a gallery portfolio tool, Folio.

> It's worth mentioning that we don't just talk externally about open source. Internally, the Mobile team runs
> talks about open source for the rest of the Artsy staff. As well, we discuss the tooling and business
> implications of having our work in public repos. Artsy strives for an open culture, in this case the development
> team, on the whole, is just further along in the process.

> The open Source app idea started with an experiment in the Summer of 2014, asking, "What does a truly open source
> App look like?" The outcome of that was our Swift Kiosk app, Eidolon. Open from day one. We took the knowledge
> from that and applied it to our public facing app, Eigen. Open from day 806. That made 2/3rds of our apps Open
> Source. I'm going to talk about our final app, Energy. Open from day 1433 and ~3500 commits.

> Folio is interesting in that it has competitors. To some extent the Kiosk app does too, but the cost of entry
> there is really high in comparison. Folio on the other hand, has a handful of competing businesses who exist to
> only build a Gallery/Museum/Collector portfolio app.

> Energy, however, requires you have a Artsy partner account. So opening it up would mean that an OSS developer
> hits the login screen and is stuck. In developing this app, I've slowly been creating my own partner gallery
> account based on my paintings and photography. So now when you set up the app to be ran as an OSS app, it will
> pre-load a known database of artworks and metadata from my test gallery.

> Its easy to imagine that open sourcing something is an end-point, but from our perspective it is a journey. We
> want to make sure that anyone can download this app, learn how and why it's structured and then run through the
> app with a debugger to get a deeper sense of how everything connects. Just releasing the code would have been
> underwhelming. Instead we're aiming high.

→ [Open Sourcing Energy][oss-energy]

This one is a good read, but extra worth the click because it includes an email I wrote to the entire of Artsy with
the intent of priming the company about opening the source code.

dB. and myself spent quite a lot of time talking to the rest of the company about the OSS ideals, our company's
values and open source fit. Here's [a 5m video][db-vimeo] which is a great example of how we presented open source
internally:

> "Are there any advantages in keeping something closed? If there are no advantages, default to open."

> "Instead of asking for permission, just communicate what you are doing and let other people suggest better ways
> of doing it. Maybe sometimes a better way is closed."

> "Artsy will stand behind your open source contributions as a team."

> "Open Source will create more value, and it will positively impact our culture."

## 2016 - Web OSS by Default

In 2016 we had really started to understand the differences in how we interact with the open source community:

> ...and in over a year these expectations have been met. Some of our libraries have become big, and our apps have
> received small feature PRs. We're pleasantly surprised when it happens, but we don't expect it.

> I didn't expect to be told face to face how many people have read, and learned from our codebases. We get around
> 120 unique clones of our iOS apps every week. People tell us that it's where they found a certain technique, or
> that they could see how the trade-offs were made for certain decisions.

> I also under-estimated how useful open code is in encouraging a culture of writing.

→ [Open Source Expectations][oss-expect]

Once we had proved that we could safely port our large, private iOS codebases to be public. That we could safely
work in the open on mobile project, we [brought that back to web][oss-force]. We went back to take artsy.net from
being an open fork to working in the open:

> Though Force wasn't quite Open Source by Default, it represented a really important step for Artsy's OSS
> perspective but was not the end goal. We were opening our source, but not opening our process.

> ... the web team started the process of opening our apps at Artsy, then the mobile team took the next big step.
> Now the teams are both in lock-step, and if you work on the front-end at Artsy - OSS by Default is the way we all
> work now.

→ [Helping the Web Towards OSS by Default][web-oss-default]

## 2017-2019 Moving the Platform forward

As a gross simplification, Artsy is split between back-end and front-end engineers. With most all of the
front-end as open (well, maybe 90%, which is *good enough*™️) then the only space for improvement towards Open
Source by Default was within the back-end. We call the collection of engineers with the skill-sets for building
APIs and shared infrastructure the Platform team.

Our platform teams have always had a weaker stance towards opening their codebases. Most of our APIs are almost
100% business logic, and there's a good reason for a lot of our APIs to be closed source. Though in the the last
two years though there's been movement towards writing new services in the open:

**2017** - [artsy/bearden](https://github.com/artsy/bearden) & [artsy/rsvp](https://github.com/artsy/rsvp)

**2018** - [artsy/APR](https://github.com/artsy/APR), [artsy/exchange](https://github.com/artsy/exchange/) &
[artsy/kaws](https://github.com/artsy/kaws/)

**2019** - [artsy/volley](https://github.com/artsy/volley)

Which over the course of the last two years seems to be about half of the new systems we've built. This is great!
Examples of private tools are analytics parsers, GDPR infrastructure and machine learning services. These had good
reasons to be closed and [have documented rationales for being closed][rfc-closed].

## 2019+

However, asking where do we go from here is a pretty tricky question. Most of the code that would be opened is now
open, and the projects which could move into the public be are very reasonably contentious.

## Does that mean we **are** Open Source by Default?

For people that joined post-2016, it certainly feels like it. People who apply to Artsy cite Open Source by Default
as being a strong factor in their decisions.

I'm not too sure personally though, maybe only in the axiomatic sense. Artsy operate by the rule of open by
default, but it takes time and effort to do the extra work which is derived from that idea: e.g. improving our
community engagement.

That's Artsy's biggest space for cultural growth now.

[intro_peril]: /blog/2017/09/04/Introducing-Peril/
[peril_readme]: https://github.com/artsy/README/blob/master/culture/peril.md
[settings-contrib]: https://github.com/artsy/peril-settings/graphs/contributors
[peril]: https://github.com/danger/peril
[db]: https://code.dblock.org
[leave_ms]: https://code.dblock.org/2012/03/05/why-you-should-leave-microsoft-too.html
[osscom]: https://opensource.com/life/10/12/corporate-change-contributing-open-source
[rfc_priv]: https://github.com/artsy/README/issues/131
[33_posts]: /blog/archives/
[search]: /blog/2012/05/11/on-making-it-personal--in-iOS-with-searchbars/
[why-run]: /blog/2019/01/30/why-we-run-our-blog/
[hk_cmd]: /blog/2013/02/01/master-heroku-command-line-with-heroku-commander/
[chairs]: /blog/2013/03/29/musical-chairs/
[ms]: https://github.com/mongoid/mongoid-shell
[garner]: /blog/2013/01/20/improving-performance-of-mongoid-cached-json/
[analytics]: /blog/2013/04/10/aranalytics/
[iphone]: https://iphone.artsy.net
[2013]: https://2013.artsy.net
[oss-expectations]: TODO
[ezel_force]: /blog/2017/09/05/Modernizing-Force/
[ezel]: /blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/
[oss_force]: /blog/2014/09/05/we-open-sourced-our-isomorphic-javascript-website/
[eid-retro]: https://artsy.github.io/blog/2014/11/13/eidolon-retrospective/
[pos]: https://github.com/artsy/positron
[db-oss]: https://code.dblock.org/2015/02/09/becoming-open-source-by-default.html
[objc-artsy]: https://www.objc.io/issues/22-scale/artsy/
[oss-eigen]: https://artsy.github.io/blog/2015/04/28/how-we-open-sourced-eigen/
[oss-energy]: https://artsy.github.io/blog/2015/08/06/open-sourcing-energy/
[db-vimeo]: https://vimeo.com/136554627
[seb]: https://www.technyc.org/leadership-council/sebastian-cwilich
[carter]: https://www.forbes.com/special-report/2014/30-under-30/art-and-style.html
[hb]: https://github.com/sarcilav/heroku-bartender
[hb-db]: https://code.dblock.org/2011/03/20/continuous-deployment-with-heroku-bartender.html
[destroy]: https://opensource.com/business/11/5/thinking-open-source-how-startups-destroy-culture-fear
[oss-force]: https://artsy.github.io/blog/2016/09/06/Milestone-on-OSS-by-Default/
[web-oss-default]: https://artsy.github.io/blog/2016/09/06/Milestone-on-OSS-by-Default/
[oss-expect]: https://artsy.github.io/blog/2016/01/13/OSS-Expectations/
[oss-default]: https://code.dblock.org/2015/02/09/becoming-open-source-by-default.html
[principles]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#engineering-principles
[rfc-closed]: https://github.com/artsy/README/issues/131
