---
layout: epic
title: "Engineering Highlights"
date: 2018-10-18
author: [orta]
categories: [concepts, teams, engineering, culture, meta]
comment_id: 487
---

Engineering is an inherently long-term process. The Artsy engineering team has been around for 7 years, and that's
quite a lot of time to get things done. We use software that keeps track of changes over time thanks to source
control, but tools like git only help keep track of small passages of time. I want to keep track of events that
could take months to ship.

We've been doing a lot of long-term introspection as a team in 2018. Externally, this has been visible through
things like opening our docs and creating our engineering principles. I'm expanding on this with an idea that I
took from my work in building large open source projects: [Highlight docs][docs].

<!-- more -->

I've been the main contributor for [Danger][] and [Peril][] for about three years, working mostly solo, and it can
be hard to feel like you're actually getting things done. There's an infinite backlog of people's requests for
improvements, and polite mentions of the flaws in your work. So, as a counter-balance it's nice to take stock of
events you're proud of. I initially mocked this out as [an issue in the peril repo][peril-repo] but when I
re-applied the idea to the whole of Artsy I used our existing open documentation repo [`artsy/README`][readme]
instead.

The core idea isn't complicated, however it's somewhat time-consuming and requires collaborators. I used the best
method I know for getting a lot of people's attention: spamming slack threads asking folks what were some of their
highlights. I used these to fuel the main arcs of the doc.

A lot of the time, just starting something like this and putting some effort in up-front means others will start to
participate. The trickiest part was finding the right definitive links for a particular event. Ideally we have open
links (so people without private GitHub access (internally and externally) can enjoy them) but sometimes the right
link is private and that's ok. It's not open source by diktat.

Trying to find the right balance between an "Artsy" event vs an "Engineering" event can sometimes be a bit vague,
but I like to believe that more is more. It's about pointing out important events, so more is always a net
positive. With that in mind, here's a few of ours, the rest is a click away:

<a href="https://github.com/artsy/README/blob/master/culture/highlights.md#readme"><img src="/images/highlights/highlights.png"></a>

I think I'm going to make one of these with every new large scale project I work on, I kinda wish we had one for
the Artsy iOS app now. Maybe I'm going to need to do that now. Ergh, this is what I get for writing blog posts.

I'd love to see some other companies or OSS projects using this idea - let me know in the comments if you are!

[danger]: https://danger.systems/
[peril]: https://github.com/danger/peril
[peril-repo]: https://github.com/danger/peril/issues/235
[readme]: https://github.com/artsy/README/
[docs]: https://github.com/artsy/README/blob/master/culture/highlights.md#readme
