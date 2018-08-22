---
layout: epic
title: "Open Source by Default: Docs"
date: 2018-08-21
author: [orta]
categories: [potential, artsy, culture, docs]
series: Open Source by Default
---

Artsy is growing up. We have thousands of subscriber galleries paying 3 to 4 figure monthly fees. As we're starting
to see a real market-fit, and have started to mature our organization. For example, this year we introduced product
managers into our 8 year old company to help us figure out how to build the right things. We actually started having
open headcount on Engineering again, for the first time _in years_.

As a part of maturing, our team has really had to start considering how to make parts of our culture explicit
instead of implicit. We have new, awesome folks wanting to understand why things are the way they are as well as
folk who are raising up to new responsibilities only to find them completely un-documented.

In-part, having a consistent team for so long hasn't made it worth the time to document things everyone knows, but
growth is very happy to disrupt that balance. Now we're shipping documentation updates weekly, to all sorts of
places. In trying to write an awesome document, which I'll cover later, I looked at how we had consolidated our
documentation over the last few years, and saw that we had fragmented due the tensions around wanting to write
publicly.

This post covers that tension, and how we came about to the new docs setup.

<!-- more -->

## Fragmentation

Prior to today, we had 4 main repos for documentation:

- 🔒 `artsy/potential` (2015) - Our onboarding repo, and general docs hub
- [`artsy/mobile`][a_m] (2015) - The mobile team's repo
- [`artsy/guides`][a_g] (2016) - A place for standards and guides
- [`artsy/meta`][a_mt] (2017) - Externally-facing docs for non-Artsy folk

Now we have two:

- 🔒 `artsy/potential` - Support docs, and private documentation
- [`artsy/README`][a_rm] - Documentation Hub, split into sections

When we created potential, it started as an open repo with the focus of on-boarding information. Over time it's
scope grew to cover more general team, repo and setup documentation. We ended up debating whether it should be a
private repo instead though.

The key arguments for closing it were:

- There are sensitive things we want to document
- We can to write about info which lives in other private repos with full context
- By making potential private we could have one, authoritative source of truth for Artsy engineering newcomers

These are all great, reasonable arguments and so we made the repo private - but with hindsight, closing the repo
split contributors to our documentation. For example, the mobile team split moved their documentation into separate
repo the week potential was made private. The web team used the blog, or kept notes in a per-project basis.
Culturally, potential was considered the domain of our platform team. The platform team had the most cross-cutting
concerns, and were also the team with the strongest need for documenting private information like domain models,
outages, system failures, server access details and contact details.

By 2016, we had successfully [de-silo'd][desilo] mobile engineering at Artsy via React Native, so the mobile team
wasn't a centralized team with resources anymore. This meant that new docs shouldn't really live inside the
artsy/mobile repo. The front-end teams had been using the blog posts and public gists to keep track of
documentation, which isn't really a good pattern. GitHub gists get lost, and blog posts aren't living documents.

This eventually caused enough dissonance that the front-end folk called it quits and started a new docs repo. Our
discussion on what we want a GraphQL schema to look like definitely didn't fit in the [`artsy/mobile`][a_m] repo and
we wanted to share it with the other GraphQL folk we were talking to, so having it in a private repo didn't make
sense. We couldn't do editorial review against a gist, and we eventually just started a new documentation repo:
[`artsy/guides`][a_g].

Once we had a space, then new docs started coming. We documented the RFC process, and how to run retrospectives in
the guides repo. As a guide on _how-to-do-x_ - these all made sense. What didn't make sense was that we were
regularly repeating ourselves when talking about Artsy Engineering to the public.

There wasn't a good space for that in mobile nor guides, and so a new repo was created: [`artsy/meta`][a_mt].

Soon, this became the home of docs from anyone that preferred writing in the public. [`artsy/meta`'s][a_mt] domain
was vague enough that anyone could document any internal processes as being something externally facing. For example
documentation on how to run [our Lunch & Learn][rlnl], or [Open Stand-up][ros].

## Open Docs by Default

This came to an inflection point when I joined the platform team, and felt the need to write cross-team
documentation that really didn't fit with of our existing domains for documentation. I believe in [leveraging my
impact][lev], so any time writing docs should be industry grade-stuff, not only available to those lucky enough to
be in [our GitHub org][jobs].

So I spent some time debating the merits of our current infrastructure for docs:

```diff
+ New folk know to start at artsy/potential
+ The platform team have a private space for writing any private details about architecture and security
+ The wiki is well used as a source for all information on our engineering support process
- By having our primary source of docs being private, we fragmented into many sources
- New people have to figure out what team may have wrote docs to guess where docs might be
- The number of contributors is low to artsy/potential
```

I wanted to imagine what a world looked like where the docs were [open by default][ossbd]. So, I consulted our
friends in openness: [Buffer][buffer]. I found that they had [`bufferapp/README`][buf] - which looked an awful lot
like what I was thinking.

I wondered about if we moved Artsy to have an open space for the initial docs, and treated potential as it's private
sidekick:

```diff
+ New folk know to start at artsy/README
+ We can migrate all sources of docs into one place
+ artsy/potential can still be used as a place for writing private details
+ Our methodology for docs aligns with our methodology for source code
+ By consolidating, we can improve working via scripts/tooling to make it feel good
- It gives up on the idea that you can have a single source of documentation
- You have to be a bit more cautious about what you write in docs
- It's a bunch of work, and you have to deprecate a lot of docs and handle re-directs for URLs
```

I opted to use our [RFC process][rfc] to discuss the idea of splitting, yet consolidating, documentation. We talked
about it for two weeks with some great points for and against. Mostly summed up above, but we also discussed the
idea of moving private docs into [notion.so][not]. We're still figuring out what the scope of notion is in

The RFC passed and I started work on a new docs hub last weekend. It was a nice shallow task I could do to keep my
mind busy. It'd been a hard week.

I wasn't aiming to rock the boat, so I created a new private repo on GitHub ( turns out we were at our GitHub limit
for private repos, so I [open sourced another][lic] to give us a free private slot - hah ) and [made a PR][rd1].
This [artsy/README#1][rd1] outlined my thoughts on how the merge can work, and gave a chance for others to say "this
doc shouldn't be public."

I focused on making minimal changes, but on making sure that all docs were back up to date with whatever they were
covering. However, I set up tooling like [prettier][], [commit-hooks][] for tables of contents and [danger][] to
make life easier for anyone wanting to make larger changes, see the [`CONTRIBUTING.md`][cont].

Once the opening PR was merged, I converted the repo to be public, sent off PRs closing [meta][md_s], [guide][g_s]
and [mobile][m_s], then marked them as archived, and started debating how to announce that this happened. What
better form than a blog post? So I started writing:

> Artsy is growing up. We have
> thou<img src="/images/ossdocs/small_blinking_text_cursor_by_neripixu-d6lwqe9.gif" height=28 width=4 style="width:4px; margin:0; top:5px; margin-left:2px;">

[a_m]: https://github.com/artsy/mobile
[a_mt]: https://github.com/artsy/meta
[a_g]: https://github.com/artsy/guides
[a_rm]: https://github.com/artsy/README
[mob_playbook]: https://github.com/artsy/mobile/blob/06a47871ef9fdc3da2bdbe2696987828e80aa82f/playbook.md#team-goals
[desilo]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#de-silo-engineers
[lev]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#leverage-your-impact
[jobs]: https://www.artsy.net/jobs#engineering
[buf]: https://github.com/bufferapp/README
[rfc]: https://github.com/artsy/README/blob/master/playbooks/rfcs.md
[lic]: https://github.com/artsy/node-artsy-licenses/
[rd1]: https://github.com/artsy/README/pull/1
[ossbd]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#open-source-by-default
[not]: https://www.notion.so/
[md_s]: https://github.com/artsy/meta/pull/45
[g_s]: https://github.com/artsy/guides/pull/8
[m_s]: https://github.com/artsy/mobile/pull/106
[rlnl]: https://github.com/artsy/README/blob/master/playbooks/running-lunch-and-learn.md#running-a-lunch--learn
[ros]: https://github.com/artsy/README/blob/master/events/open-standup.md#dev-team-standup-at-artsy
[buffer]: https://buffer.com
[prettier]: https://prettier.io
[commit-hooks]: https://github.com/typicode/husky#husky---
[danger]: https://danger.systems
[cont]: https://github.com/artsy/README/blob/master/CONTRIBUTING.md
