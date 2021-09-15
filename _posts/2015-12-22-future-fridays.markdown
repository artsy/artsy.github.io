---
layout: post
title: "Future Fridays"
date: 2015-12-22 11:09
comments: true
author: joey
categories: [Team]
---

Artsy's Platform engineering team is responsible for much of our shared infrastructure and services. Some of that responsibility is naturally focused on the very near term, such as diagnosing service interruptions and fixing bugs. However, we must regularly balance that with more long-term-focused work such as evaluating new technologies, paying off technical debt, and devising foundational improvements to our platform.

This is a tricky balance! Near-term work is appealing. It's well-understood, more easily scoped, and often promises a satisfying "quick fix." Sometimes, there's even a customer (internal or external) eagerly awaiting the result. We recently introduced "Future Fridays" to help dedicate time to longer-term, open-ended work despite these urgent temptations.

<!-- more -->

The Rules
---

The rules are simple. Each Friday, we give ourselves permission to suspend our usual work. Instead, we zoom out and try to answer:

* What are the patterns emerging in our work--repeated smells or obstacles--that could be addressed at the root?
* What new technologies might we want to have in place 6, 12, or 18 months from now?
* What will we need to get to 10x the scale of data, traffic, or revenue?

Finally, we try to share our goals and our results. This usually takes the form of a simple announcement in the team's chat room.

Some examples of topics we've pursued:

* Migrating a slow, failure-prone component in our analytics stack to a more scalable data warehouse
* Learning a promising new programming language or framework
* Testing alternative continuous integration services
* Extracting email generation from our main API into a dedicated service
* Migrating to a more performant background queue

The Results
---

Future Friday has become a well-loved part of our weekly rhythm as a team.

Throughout the week, we constantly wonder "what if..." (as teams like ours tend to do). Some of the more "out there" notions quickly enter the Future Friday parking lot. (We might even include a _#FF_ hashtag for easy searching of chat transcripts.) And then we get back to solving the problem at hand.

When Friday arrives, we have a list of ideas but must weigh their potential value and radically narrow their scope to fit the time constraint.

Tips
---

Borrow some lessons from our Future Friday experiment:

**Build a backlog.** It took a few weeks to accumulate a healthy backlog of ideas that were both pertinent and exciting to individuals on the team. Start now!

**Protect the time.** It's tempting to keep pushing forward your regular work ("I'll just deploy that thing I was working on yesterday"), but Future Friday only works if you create some slack capacity. We suspend our usual stand-up meetings, expect that folks may decline meetings or be slower to respond, and _everyone_ (including managers) participates.

**Go your own way.** Work on something you're excited about. Fridays are fun and productive when everyone explores something they're personally energized about (_not_ just something their pointy-haired boss is excited about). As a result, each week's efforts are diverse (and sometimes, plain weird).

**It's not "20% time."** Fridays aren't totally open-ended. They're protected time for work that's relevant and valuable to the business, but with an explicitly longer time horizon.

**Call it.** Don't _pre_-judge ideas, but when something doesn't pass muster, share any lessons and move on. (E.g., a platform isn't fully baked, transition costs are too high, or results don't match hype.) The bar for _exploring_ an idea is low on Friday, but our standard for _shipping_ production software is not.

To our surprise, though, often the result has been exactly the opposite. Given a few undisturbed hours of attention, some ideas quickly become feasible and even production-worthy. Even more projects have hatched into full-fledged, rest-of-the-week projects, using Future Friday to overcome an initial learning curve.

Now, Future Friday is anticipated each week. We've gotten a head start on some projects that were daydreams a little while ago. And other teams have launched Future Fridays of their own.

We hope you found our experiment interesting. Let us know your questions, and especially your own experiences, below!

&nbsp;

P.S. [Artsy is hiring](https://www.artsy.net/jobs).
