---
layout: epic
title: "Why we added an RFC process to Artsy"
date: "2019-04-11"
author: [orta]
categories: [culture, process, mvp]
comment_id: 554
---

Growth is tricky. Whether in terms of raw headcount or people's evolving career stages. As a team you want to
provide ways in which members can experiment with new ideas, and provide tools to help them offer new perspectives.
One of our greatest tools for instituting change at Artsy is our RFC process.

An RFC is a Request For Comments, and it is a structured document (in the form of GitHub issue normally) which
offers a change to something. The format is used in large open source projects like: React
([Overview](https://github.com/reactjs/rfcs/blob/master/README.md),
[Template](https://github.com/reactjs/rfcs/blob/master/0000-template.md)), Swift
([Overview](https://github.com/apple/swift-evolution/blob/master/process.md#how-to-propose-a-change),
[Template](https://github.com/apple/swift-evolution/blob/master/0000-template.md)) and Rust
([Overview](https://github.com/rust-lang/rfcs#rust-rfcs),
[Template](https://github.com/rust-lang/rfcs/blob/master/0000-template.md)). To give core & non-core contributors a
chance to propose an idea to everyone before implementing a change.

We [took][] this idea and applied to the process of making any cultural change in the company. Read on to find out
why we needed it, how we refined it, some of the tooling we built around it, and what other options are available.

<!-- more -->

## Why did we create an RFC process?

We created the RFC process in parallel with [Peril][peril] being [introduced at Artsy][intro_peril]. Prior to
Peril, most changes to culture were localised in different teams. However, once Peril gave us the ability to create
cultural rules across all engineering repos in GitHub we also needed a way to let people know and provide feedback
about these changes.

We started with the [smallest possible implementation][rfc1] of an RFC and a [notification service][notif1]🔒. You
would write an issue with this template:

```
Title: "RFC: Add an emoji for when a node package is version bumped"

Proposal: If the repo has a `package.json`, we should look to see if its version has
          changed and then submit a tada emoji.

Reasoning: A release is important, we should cherish them.

Exceptions: None
```

This RFC came with a Peril rule that would post a notification into slack about an RFC being created:

![](/images/intro-rfcs/first-rfc.png)

Which meant everyone had the chance to know in-advance that a change was being discussed because it crossed team
communication boundaries. Here's [the first RFC][first_rfc1] used at Artsy.

This was specifically built to be the minimum possible to get an idea of what we actually wanted from an RFC
process for cultural changes.

## How did it evolve?

Version 2 of our RFC process is what we've stuck with for the last 2 years. The second version expanded the scope
from just making Peril changes to being comprehensive enough to cover most cultural changes we wanted.

```
Title: "RFC: Add a Markdown Spell Checker to all Markdown docs in PR"

## Proposal:

Apply a spell checker to every markdown document that appears in a PR.

## Reasoning

We want to have polished documents, both internally and externally. Having a spellcheck
happening without any effort on a developers part means that we'll get a second look at
any documentation improvements on any repo.

## Exceptions:

This won't be perfect, but it is better to get something working than to not have it at all.
I added the ability to ignore files: so CHANGELOGs which tend to be really jargon heavy will
be avoided in every repo.

Other than that, we can continue to build up a global list of words to ignore.

## Additional Context:

You can see our discussion [in slack here](/link/to/slack.com)
```

This version also came with a recommendation on how to resolve the RFC, after a week you would add a comment and
close the issue:

```
## Resolution
We decided to do it.

## Level of Support
3: Majority acceptance, with conflicting feedback.

#### Additional Context:
Some people were in favor of it, but some people said they didn't want to do it for project X.

## Next Steps
We will implement it.

#### Exceptions
We will not implement it on project X. We will revisit the decision in 1 year.
```

We've evolved the closing an RFC process since then:

- To [be more specific on how/when to close an RFC][time]. Which introduces a stalled state. Turns out some
  discussions take longer to resolve than a week
- Peril would post [multiple notifications][notifs] over the course of a week to make sure people don't miss the
  chance to contribute
- We added a weekly summary of open RFCs into Slack for our [team standup][standup]

![/images/intro-rfcs/summary.png](/images/intro-rfcs/summary.png)

## What are the alternatives?

This RFC process is not without it's trade-offs.

An RFC is built with an action in mind, and it explicitly defaults towards this. This process purposely bakes in
silence as positive indifference from observers. When being used as a consensus device, an RFC process really isn't
that great. It's an asynchronous, flat conversation, which makes it hard to discuss all avenues with many
simultaneous voices and can sometimes feel like whoever posts the most often kinda wins.

For consensus tools you really are better off with a meeting. There are all sorts of structured meetings which do a
great job of finding agreement across many opinions.

For example, we wanted to try and get consensus on how to build APIs at Artsy. The RFC for that would probably have
been something like "Move to use GraphQL in all new APIs", which is a nuanced technical mandate that would require
buy in from many people. While it does have an direct action, trying to feel like everyone agrees and will work
this way in the future would have probably not worked out in a single-threaded long-form issue. Instead, we opted
to use a [town-hall style][th] meeting, where people who had strong opinions would have time to present them - then
at the end all developers would have the chance for feedback.

## Where does it work best?

This RFC process is good for "I would like to improve this, does that make sense?" - and it's a really great case
of [Minimum Viable Process][mvp] where one issue can spark a great team discussion. Here's some of my favourite
ones from Artsy:

- [Provide explicit recommendations when PDDE should take time off ][time-off]
- [Document the rationale for why Artsy's various closed source repositories aren't open][doc-oss]
- [Relaunch the Platform practice][plat]
- [New Hire Buddies][hires]
- [All GraphQL API servers have a root `_schema.graphql` file ][gql]
- [New dependencies to Emission/Reaction go through the RFC process][deps]
- [Creating a public facing status page][status]
- [Updates to On-Call Process: Jira Ops + Status Page][on-call]
- [Rename the Artsy Omakase to [Something]][oma]

We sometimes have RFCs which we don't want to discuss in public, for those we use our private version of README
called potential. That said, our notification system works on any repo, so if it makes sense to have an RFC on a
repo specifically, that's no problem too.

You can see all of our [current open RFCs on the Artsy org here][open-issues], and I've opened comments for folks
to talk below about whether they've enacted something similar - would love to see how this can be improved.

[took]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#own-your-dependencies
[peril]: https://github.com/danger/peril
[intro_peril]: /blog/2017/09/04/Introducing-Peril/
[rfc1]: https://github.com/artsy/peril-settings/pull/4
[notif1]: https://artsy.slack.com/archives/C02BC3HEJ/p1503690782000372
[first_rfc1]: https://github.com/artsy/artsy-danger/issues/5
[time]: https://github.com/artsy/README/issues/162
[notifs]: https://github.com/artsy/peril-settings/pull/46
[standup]: https://github.com/artsy/README/blob/master/events/open-standup.md#during-standup
[mvp]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#minimal-viable-process
[time-off]: https://github.com/artsy/README/issues/171
[deps]: https://github.com/artsy/README/issues/117
[doc-oss]: https://github.com/artsy/README/issues/131
[hires]: https://github.com/artsy/README/issues/76
[on-call]: https://github.com/artsy/README/issues/130
[status]: https://github.com/artsy/README/issues/108
[plat]: https://github.com/artsy/README/issues/86
[oma]: https://github.com/artsy/README/issues/10
[gql]: https://github.com/artsy/README/issues/31
[open-issues]: https://github.com/search?q=org%3Aartsy+is%3Aissue+label%3ARFC+is%3Aopen
[th]: https://en.wikipedia.org/wiki/Town_hall_meeting
