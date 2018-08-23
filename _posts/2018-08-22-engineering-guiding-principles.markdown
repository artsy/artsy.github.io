---
layout: epic
title: "Defining Our Engineering Guiding Principles"
date: 2018-08-22
author: [ash]
categories: [concepts, teams, engineering, culture, meta]
---

The Artsy Engineering team recently underwent the process of defining our guiding principles; you can read through the pull request [here][pr] and the finished principles [here][principles]. In this blog post, I'd like to use our experience of defining these to answer the following questions:

- Why define engineering guiding principles?
- What makes principles different from company values?
- How to define guiding principles?

Let's dive in.

<!-- more -->

## Why Define Engineering Principles?

Artsy's CEO has a [blog post][company_values] that discusses why you should define company values and, unsurprisingly, a lot of the same rationale applies to an engineering team's guiding principles. In summary:

- Undefined principles lead to cultural debt (similar to technical debt, but in terms of a team's culture).
- Defined values lead to greater empowerment (engineers feel safe making decisions on their own, based on the principles).
- Defined values reduce the risk of unconscious bias (we help our decisions get made consistently).
- Values are your brand (this is true for Artsy Engineering, but our [contributions][gh] to the software industry are also a significant part of brand).

I think each of these reasons applies to defining guiding principles as well. Over the past four years, I've seen the Artsy Engineering team encounter situations related to the reasons outlined above and, while the company values have helped us navigate disagreement, they haven't been entirely satisfactory.

The two biggest shortcomings of the values have been an **inconsistent practice** and a **difficulty making team-based decisions**.

Artsy Engineering supports the business primarily through product teams, which each have their own responsibilities and KPIs. Over time, different teams have developed their own subculture. In earnest, I think this is really cool, but it _has_ eventually led to two teams taking radically different approaches to similar problems, or even repeating work that another team is already working on.

That missing consistency also led to difficulties making team-based decisions: how can teams make decisions _as a team_ without having a clear set of guidelines with which to evaluate a decision? As I'll explain in the next section, the Artsy company values often left us without a clear answer.

## What Makes Guiding Principles Different from Company Values?

Artsy's [five core values][values] are as follows:

- Art meets Science
- People are Paramount
- Quality Worthy of Art
- Positive Energy
- Openness

Those have been an incredibly useful framework for guiding Artsy's growth, for three years now. They're good values. But they are _very_ general, designed specifically to be inclusive of every member of, and every team in, our company.

That can lead to challenges when applying the values to specific teams, including engineering. In our day-to-day work, the values can help guide our general actions (being positive in pull request reviews, for example), but lack the specifics necessary to drive decision-making on a team level. The values also sometimes conflict with one another, and navigating those conflicts is difficult without a set of down-to-Earth guiding principles.

Let's take a look at an example. "Quality Worthy of Art" is a really great value – personally, it motivates me to build software that would be worthy of hanging in a studio or gallery. However, the process of _getting_ to that quality is often very messy; we might try one approach, switch to another, ship with `TODO` comments left in, etc. Real artists ship, after all. When [developing software in the open][obd], which value wins? The openness value, or the quality value?

Our CEO has encouraged the company to lean into these tensions and use them to grow and learn together, which was a motivating factor in defining our guiding principles.

## How to Define Guiding Principles?

This is a very tricky question, since so much of the answer for Artsy Engineering is specific to us at Artsy (your process will necessarily be different) and specific to our team _within_ Artsy (engineers make up less than 15% of Artsy's employee headcount). Orta helped define the values by looking at [artefact's of our mobile team's culture][objcio] (since our mobile team _did_ have a strong culture) and by talking to engineers privately to ask them for input. That was only half the work, though.

Orta opened [the pull request][pr] with the guiding principles that he had synthesized from past documentation and from conversations with engineers, but explicitly marked the PR as a work-in-progress. The values he had were a good starting point, but we iterated extensively on them. We also added many more that had been missed by Orta's starting work (we had to start somewhere, after all). The whole process took about two weeks, and I learned a lot about how other engineers work at Artsy.

Most of my experience at Artsy has been engineering front-end systems, and through the process of defining these principles, I learned a lot about how our back-end engineers work. We don't always work in the same way (remember, tensions?) but I value those differences; we have so much to learn from each other! Now with the guidelines, I'll be able to appreciate the back-end perspective.

---

So with all that said, what are the Artsy Engineering Guiding Principles? You can read the [current principles here][principles] (they are a living set of guidelines), but the principles we decided on are:

- Open Source by Default
- Own Your Dependencies
- Incremental Revolution
- Being Nice is Nice
- Minimum Viable Process
- Leverage Your Impact
- De-silo Engineers
- Build for 10x
- Done Means Done

I encourage you to read the document for explanations of what each of these mean.

Day-to-day, I don't expect _that_ much to change now that we have these defined. But the differences they make will be key to the longevity and growth of our engineering team's culture.

Remember that earlier example of openness-vs-quality? That is answered explicitly by the principles. The principles are _actionable_, they are _specific_, and they are _ours_.

[pr]: https://github.com/artsy/meta/pull/41
[company_values]: https://www.artsy.net/article/carter-cleveland-why-define-company-values
[values]: https://github.com/artsy/README/blob/master/culture/what-is-artsy.md#artsy-values
[obd]: http://artsy.github.io/series/open-source-by-default/
[objcio]: https://www.objc.io/issues/22-scale/artsy/
[principles]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md
[gh]: https://github.com/artsy
