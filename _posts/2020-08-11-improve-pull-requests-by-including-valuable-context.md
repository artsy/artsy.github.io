---
layout: epic
title: "Improve Pull Requests By Including Valuable Context"
date: "2020-08-11"
author: [steve-hicks]
categories: [tools, github, team, community, engineering]
comment_id: 621
---

Code review is an engineering process that has benefited greatly from a move toward asynchronous communication.
Long ago, engineering teams would sit in a room with code on a projector to review changes together. 😱 For many
teams this led to batching code reviews or even skipping them altogether. 😱😱

Today, most engineering teams use incredible tools like GitHub or GitLab to review changes through Pull Requests
(PRs). The greatest advantage of PRs is that the review can happen when it's convenient for the reviewer:
asynchronously. Asynchronous communication isn't all sunshine and unicorns, though. Notably, it lacks the ability
to course-correct when context is misunderstood.

<!-- more -->

When you're in a synchronous conversation with someone, it doesn't take much time for them to let you know you've
forgotten to include context. Their brow furrows. They look confused. You notice this and quickly add the missing
context to keep the conversation moving forward. It takes a lot longer to identify missing context when
communicating asynchronously. The non-verbal cues are missing.

Worse, lack of context when _reviewing code_ asynchronously has a reverb effect. I create my PR when it's
convenient for me, you ask a clarifying question when it's convenient for you, I respond when it's convenient for
me, etc. Suddenly my PR has been open for three days and we haven't yet made it to a common understanding of why
I've made these changes.

It's extremely important to include all available context when drafting a PR. It saves incredible amounts of time
by cutting out slow round-trip conversations to clarify.

I'm personally proud of and impressed by the job we do at Artsy in including context in our PRs. We start early, by
giving our engineers
[some reading about how we work with PRs during their onboarding](https://github.com/artsy/README/blob/master/playbooks/engineer-workflow.md#pull-requests).

But beyond that our engineers lead by example. This article presents a handful of examples from Artsy repositories
demonstrating how you can add context to your PRs to avoid unnecessary clarifying conversation.

## Explain Your Reasoning

You've been thinking a lot about the problem you're solving - probably significantly more than your reviewers.
You'll save everyone time by describing the problem and sharing how you're thinking about it.

### Define the problem and solution

Why does this PR exist? Explain the problem it solves and describe your solution, as
[Sarah](https://github.com/sweir27) does [in this PR](https://github.com/artsy/force/pull/3095). For bonus points,
include alternative approaches you considered.

As you are writing up the problem and solution, you might find that you've missed on the scope of your PR. Are
there _many_ problems this PR is solving? Maybe this should be broken into smaller PRs. Is it hard to describe the
problem because it requires multiple other PRs? Maybe those should be consolidated into one cohesive set of
changes.

### Explain interesting lines of code

The reviewers aren't the only ones who can comment on lines of code.
[Give them](https://github.com/artsy/emission/pull/2085#discussion_r378228269) some
[additional information](https://github.com/artsy/emission/pull/2085#discussion_r378230196) about
[why a particular line was written](https://github.com/artsy/emission/pull/2085#discussion_r378231974), as
[David](https://github.com/ds300) does [in this PR](https://github.com/artsy/emission/pull/2085). Maybe you want
feedback focused on that line or maybe the line has side-effects and implications that aren't obvious.

### Give a guided tour of the changes

[Devon](https://github.com/dblandin) takes the idea of adding context to individual lines to the next level
[in this PR](https://github.com/artsy/reaction/pull/2774#pullrequestreview-288095754). He takes advantage of
markdown to give us a virtual tour of the changes, at each stop providing helpful information and a link to the
next change. It's like he's sitting next to you!

## Show Your Work

If your PR contains work that is beyond trivial, show your reviewers how you thought about the problem. Demonstrate
the effects of the changes. Give them confidence that you've worked through this problem thoroughly, and you've
brought receipts.

### Make small, self-contained commits

A good PR starts with good commits. Good commits are small, self-contained, and leave the codebase always in a
working state. With good commits, reviewers can see exactly how you worked through the problem you were solving.
[Here's a PR](https://github.com/artsy/convection/pull/645) from [Jon](https://github.com/jonallured) that
demonstrates the use of small, self-contained commits to describe his approach to refactoring code before fixing a
bug.

_Bonus tip_: it can be easier to review PRs with many small commits via the
[_Commits_](https://github.com/artsy/convection/pull/645/commits) tab instead of the
[_Files changed_](https://github.com/artsy/convection/pull/645/files) tab.

### Demonstrate the results

Pictures are a worth a thousand words. Animated gifs are worth a thousand pictures (uhhhh, in file size too 😬). An
animated gif showing the outcome of your PR gives reviewers a demo, and confidence that you've verified your
changes.

[Here's a PR](https://github.com/artsy/force/pull/5817) from [Ashley](https://github.com/ashleyjelks) that includes
animated gifs of the changes she's made. The effects of the changes might not be obvious by looking only at the
code, but seeing them in action makes it clear.

### Document the unseen

Sometimes a PR's changes have effects outside of the UI. There are still ways to give reviewers proof that the
changes have the desired effects.

[Here's a PR](https://github.com/artsy/eigen/pull/3206) from [Yuki](https://github.com/yuki24) that not only
demonstrates what's happening in the UI, but also assures me that the back-end data is getting updated properly
through a Rails console.

[Christina](https://github.com/xtina-starr) authored [this PR](https://github.com/artsy/reaction/pull/3441) which
shows the UI changes in addition to some output from her browser console, demonstrating that analytics tracking
calls are firing correctly.

### Share your progress

One mistake many engineers make with non-trivial pull requests is to wait to open them until they're "done". If
there are changes you'd like to get people's eyes on quickly, open a WIP PR before the work is done: mark it as a
draft in GitHub, or put `WIP` in the title. Extra work up front avoids rework by starting early discussions about
your approach.

Let reviewers know in the body that your work isn't complete. As you continue your work, use a `TODO:` list in the
body to illustrate your progress, as in [this PR](https://github.com/artsy/palette/pull/464) from
[Sepand](https://github.com/sepans).

Is this PR part of a larger scope of work? Is there followup work that will need to be done after it's merged? Are
there PRs in other systems that need to merge in a specific sequence? Any migration details or timing that should
be known before merging? Call these details out to avoid another round-trip conversation.

## Spread knowledge

Pull requests should not be one-sided - they aren't just about collecting feedback from the reviewer. They're also
an opportunity to spread knowledge from the author.

### Share your learnings

Maybe you learned some things about the system you're working with, or you learned a new feature of the language.
Share this new information with your team. [Roop](https://github.com/anandaroop) shares some findings about
disabled tests [in this PR](https://github.com/artsy/metaphysics/pull/2130).

We introduced a new state management library shortly before [I](https://github.com/pepopowitz) opened
[this PR](https://github.com/artsy/eigen/pull/3526), and I had to do some reading about how to add types to
something. I [shared my learnings with the team](https://github.com/artsy/eigen/pull/3526#discussion_r451161406).

### Share development tips

Did you learn a new technique while building this feature? Share it with your team!

In [this PR](https://github.com/artsy/reaction/pull/3279#discussion_r395461329),
[Chris](https://github.com/damassi) shared with us his technique for grabbing fixture data from his locally running
environment.

---

When your team embraces the pull request process, you reap rewards that extend far beyond the lines of code.
Providing context up-front shortens the feedback loop and surfaces important discussions sooner, allowing you to
ship changes more quickly. Sharing knowledge in PRs grows individuals and spreads expertise across your team. Every
PR becomes an artifact for retracing history. You can look back and see not only _which_ decisions were made, but
_why_ they were made.

If you'd like to know more about how we work with pull requests at Artsy, take a look at our
["Engineer workflow" playbook](https://github.com/artsy/README/blob/master/playbooks/engineer-workflow.md#pull-requests),
or poke around [our GitHub repositories](https://github.com/artsy). Check out
[the PR that created this article](https://github.com/artsy/artsy.github.io/pull/619). And if you've got examples
of great PRs to share with the rest of us, leave a comment!
