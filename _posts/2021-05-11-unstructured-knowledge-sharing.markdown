---
layout: epic
title: "Unstructured Knowledge Sharing"
date: 2021-05-11
categories: [teams, culture, people]
author: steve-hicks
comment_id: 690
---

We have a handful of regularly scheduled meetings in place at Artsy devoted to knowledge sharing.

But what about the _unstructured_ ways in which we share knowledge? If structured sharing time demonstrates that a
team is _interested_ in spreading knowledge, _unstructured_ sharing time demonstrates that spreading knowledge is
the default mode for the team. Instead of the team forming habits of working in isolation or hoarding expertise,
they've formed habits of learning from and teaching each other.

<!-- more -->

Regularly scheduled meetings we have for knowledge sharing include:

- Team-based knowledge share meetings
- Open office hours for anyone to bring questions
- Lunch & learns for presenting across all of Artsy engineering
- Show & tell, where attendees bring recent learnings or explorations to demo to the group
- Peer learning groups that are dedicated to learning a specific topic in development

As [Ash][ash] mentioned in [his article on knowledge shares][knowledge-shares], these are all great opportunities
for us to share knowledge. Learning is easy to de-prioritize in the face of shipping features, and scheduling these
meetings reinforces learning as a priority.

Recently [Chris Pappas][chris] pointed out the incredible value we get out of one specific Slack channel:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Shortest blog post of all time:<br>“Add a <a href="https://twitter.com/hashtag/dev?src=hash&amp;ref_src=twsrc%5Etfw">#dev</a>-help channel to your slack where devs can pose questions to the wider team. You won’t regret it!”<br>-- Chris Pappas</p>&mdash; Artsy Open Source (@ArtsyOpenSource) <a href="https://twitter.com/ArtsyOpenSource/status/1357819867638812672?ref_src=twsrc%5Etfw">February 5, 2021</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

This piqued my interest. What unstructured/unscheduled things do we do at Artsy to demonstrate our emphasis on
learning?

## The #dev-help Slack Channel

We have many dev-specific channels set up in the Artsy Slack, but one in particular has become a massively
important knowledge-base for the entire team: the #dev-help channel.

This channel is a place for engineers to post when they're stuck. All engineers watch the #dev-help channel (to
some degree) and offer support when they can. Each issue is threaded to avoid noise in the channel. When the
question is answered, it gets marked as "solved" by applying a ✅ reaction. [Pavlos][pavlos] set up a Slack app
that auto-applies the ✅ reaction when someone says "solved" in the thread.

![A question asked and answered in our #dev-help slack](/images/2021-05-11-unstructured-knowledge-sharing/dev-help.png)

The cumulative result of the questions asked and answered in this channel is an incredible knowledge base for all
engineers. When I run into a new issue, the first place I search is #dev-help. More often than not I find my exact
problem already solved.

This knowledge base is so important and powerful that it's no longer only a place to _ask_ for help. Engineers will
also share problems they've _already solved_ in a new thread in the channel, in case someone else runs into the
problem. Usually we'll tag these problems up front with `[already solved]` or similar, to make it obvious no one
should spend cycles trying to solve this problem.

![An already-solved thread in our #dev-help slack](/images/2021-05-11-unstructured-knowledge-sharing/already-solved.png)

One other important thing to say about the #dev-help channel: as engineers it's tempting to solve problems with new
and novel tooling, but in the case of #dev-help we found a way to use our existing tooling in a slightly different
way. Sometimes the best solution is one you already have. We could have investigated dedicated software like Stack
Overflow for Teams, or we could have built our own knowledge-base tool. Instead we put some rules around how we
would use a Slack channel, and gained a huge benefit at a fraction of the cost.

## Internal Live-Streaming

Occasionally an Artsy engineer will broadcast that they're taking on work that is ripe for knowledge-sharing, and
they'll spin up a Zoom call for others to join. It might be something they know how to solve — like when
[Roop][roop] spun up a call to walk through how he'd use [Observable][observablehq] to explore search index
weighting. There might be more uncertainty to the problem, like when [Pavlos][pavlos] started up a call to
investigate a CI build failure using [`git bisect`][git-bisect]. It might be somewhere in between, like when
[Adam][adam-b] was doing some refactoring of our React Native navigation.

Sometimes this looks like a pairing or mobbing session, but sometimes it looks more like live-streaming. An
engineer is demonstrating by solving a real problem. If audience members can contribute, great — but they are also
welcome to tag along and learn.

## Pairing

[Yuki][yuki] wrote on this blog [about pair-programming at Artsy][yukis-article]. Pairing isn't an unusual practice
for development teams....but there is something notable in regards to knowledge-sharing.

We're somewhere in the middle on the pairing frequency spectrum at Artsy. We don't have dedicated pairs working on
problems together all day/every day. But we also don't only pair when we're stuck.

Pairing when you're stuck is great, and it can help move you forward on a problem. If that's the only time you
pair, though, you're missing out on a massive learning opportunity.

Pairing to build a feature gives you exposure to an entire toolbox you might never have used before. How does your
pair approach a problem? How do they manage their time? What development tools do they use? What techniques do they
use for testing and debugging? How do they tighten their feedback loop? This is knowledge-sharing beyond the code
or the product you're building — it's knowledge-sharing of tools, skills, and habits.

---

What are the unstructured/unscheduled ways in which your team shares knowledge? Leave us a note in the comments!

[ash]: https://twitter.com/ashfurrow
[chris]: https://github.com/damassi
[knowledge-shares]: https://artsy.github.io/blog/2020/12/09/share-your-knowledge/
[roop]: https://github.com/anandaroop
[observablehq]: https://observablehq.com/
[pavlos]: https://github.com/pvinis
[git-bisect]: https://git-scm.com/docs/git-bisect
[adam-b]: https://github.com/admbtlr
[yuki]: https://github.com/yuki24
[yukis-article]: https://artsy.github.io/blog/2018/10/19/pair-programming/
