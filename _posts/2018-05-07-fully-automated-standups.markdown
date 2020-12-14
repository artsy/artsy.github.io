---
layout: epic
title: "Fully Automated Standups"
date: 2018-05-07
author: [ash]
categories: [team, people, best practices, culture]
---

When I began working at Artsy four years ago, remotely, I really didn't like the weekly engineering standup. I'd sit in front of my computer and strain to hear a dozen people gathered around a laptop with Google Hangout. They'd discuss implementation details for projects I wasn't familiar with, and then I'd do the same to them (our mobile team was still very separate from our web team). Twenty minutes would pass and I didn't feel like my work experience at Artsy had been enriched in any way.

The first time I came to New York to visit the office – before moving here – I sat down with [Dylan](https://github.com/dylanfareed) and [Orta](https://github.com/orta). Dylan ran the weekly standup, and Orta was also not a fan of the meeting. Dylan was clear: if the standup wasn't working for the two of us, then it wasn't working for anyone. So let's fix it together.

<!-- more -->

And we did. We installed new sound-baffling ceiling tiles to help remote workers hear the boardroom more clearly. We restructured updates, moving from individual updates to team updates. We introduced a section for people to ask and offer help. All kinds of changes. I started looking forward to standup.

At Artsy, when you see something that could be improved about the way that we work, you are expected to help improve it. Dylan taught me that lesson, and I still take it to heart.

Last summer, I started taking on more responsibilities for the Artsy Engineering team, including running the weekly standup meeting. It was previously run by a single engineer, [Craig](https://github.com/craigspaeth), who was juggling a lot of team-wide responsibilities. I was happy to help him out and run the meeting, but I had only replaced _myself_ as a single-point-of-failure for standup; even with Orta running things sometimes, the process itself was still as brittle as when Craig was running things alone. After a few months, Orta and I decided to fix things.

Our goal: fully automated standups. No single person should ever be a point-of-failure for our team. We moved through a few distinct steps.

First, we had to document the process of running the standup. This was crucial: standups should be run as a function of the documentation, so that any engineer at Artsy can run an effective standup. The docs should not only help the engineer run the meeting, but help them feel _capable_ of running the meeting. And once documentation is in place, anyone can help improve the docs (and consequently, improve the process). The current [docs are open source](https://github.com/artsy/meta/blob/master/meta/open_standup.md).

Next, we had to get other engineers running the meeting. We split up the responsibilities of the meeting into two roles: a talking part, and a note-taking part. Both are integral, and different people gravitate towards differently roles. Splitting things up not only made running the meeting easier, but it made running the meeting more appealing to newcomers. 

Once the meeting was a two-person responsibility, we started bringing on other engineers to help. I would ask around to see who was interested in helping running a meeting, giving choice of role to the other person. After each meeting, I'd ask the person about how we could improve the docs. Each week, the docs got better and better.
  
The next phase was moving to having standup run entirely by other engineers. I had a list of engineers who had never run a standup, and worked down the list to get as many engineers having run a meeting as possible. I made [this pull request](https://github.com/artsy/meta/pull/21) making it clear that running the standup meeting is a responsibility that every member of the team _shares_.

Eventually, I felt we were ready to move to a self-perpetuating standup. At the end of each standup, we would solicit volunteers to run next week's meeting. Fully-automated standups! We'd done it! Things were working, though we did recently decide to [integrate the standup schedule into our new support on-call schedule](https://github.com/artsy/meta/pull/32); the engineers beginning their rotation were responsible for running the standup. This eliminated the kind of awkward "okay who wants to do this next week?" part of our meeting.

At each step, we improved the process. Through effective documentation and positive energy, we reduced the [bus factor](https://en.wikipedia.org/wiki/Bus_factor) for our engineering team's management. And more importantly, I think, we made it clear to every Artsy engineer that managing our team and improving how we work is a responsibility we have, together.
