---
layout: epic
title: "Strategies For Small, Focused Pull Requests"
date: 2021-01-06
categories: [tools, github, team, community, engineering]
author: steve-hicks
---

A common suggestion for improving pull requests (PRs) is to "make your PR small and focused". I myself gave this suggestion in [a recent article on this very blog about including context in PRs](https://artsy.github.io/blog/2020/08/11/improve-pull-requests-by-including-valuable-context/). 

Like most internet advice, this can feel like the ["draw the rest of the owl"](draw-the-rest-of-the-owl) meme. Even if we're in agreement that I _should_ make a PR smaller...**_how_** do I do it? How do I avoid a big PR when there's a lot of cross-cutting changes to make? How do I create small, focused units of work when I'm building a large feature? How can I overcome my perfectionism and submit a PR that feels incomplete to me because the edges aren't all polished?

<!-- more -->

## What is "small and focused"? 

Not all small PRs are focused. I might sneak five unrelated one-line changes into a PR. While it feels like that will enable me to move quickly, it also runs the risk of four unrelated changes being held up in review because one of them is controversial.

Not all focused PRs are small. I might put an entire feature in one PR, and while it is focused, it's still going to be difficult for you to review the large amount of changes thoroughly. 

To make our PR reviewers' jobs easier, we're looking for the intersection of small _and_ focused. Changes that are cohesive and without distractions. Code that accomplishes one thing. TODO: find some examples that show the extremes?

Note that the recommendation for "small and focused" PRs does **not** include the word "complete". I'm as much a perfectionist as anyone and I like my work to be very polished before it's done, but when we're iterating quickly the polish can come in a follow-up PR. This is the biggest challenge I've had as an Artsy engineer — finding the balance between polish and iteration. Artsy's core values include [Impact Over Perfection](https://github.com/artsy/README/blob/ccfbba13ead7cb6586d2d9bf088e5180907be07b/culture/what-is-artsy.md#impact-over-perfection) but my personal values include "make things _real good_" and it can be hard for me to navigate that tension. 

### Integrating code a little at a time

A caveat: the recommendations in this article assume you can integrate code a little bit at a time. I've worked on teams and projects where we used very long-lived branches for features or even epic — I know those environments exist. This article is probably not the one that will convince you to move to [trunk-based development](https://trunkbaseddevelopment.com/); it also might be less useful without trunk-based development.

Having said that, even with long-lived feature branches you can introduce code _into those branches_ a little bit at a time. PRs can be opened against _any_ branch, not just `main`. 

Some strategies we use at Artsy for integrating code a little bit at a time:

* **[Feature toggles](https://trunkbaseddevelopment.com/feature-flags/)**. [Ash wrote about Echo](https://artsy.github.io/blog/2020/12/31/echo-supporting-old-app-versions/), a service for toggling features on mobile devices, but we have additional ways for enabling/disabling features at the system _or_ user level. When we introduce new code we can hide it behind a feature flag until we're ready for everyone to see it.
* **"Hidden" routes**. Often when we redesign or modernize an existing route on Artsy.net we'll create a _second_ similar route. We hide the in-progress page behind that new route and don't share it until it's ready. 🤫
* **TODO** maybe other ways?

Armed with tools for integrating code incrementally, here are some strategies for reducing the size and scope of a PR.

## Start with small scope — slice your stories small

One of the most valuable lessons I learned as a consultant with a company focused on agile development is that you can almost always slice a story smaller. You can do this by sacrificing quality, but you can also (and probably should) do it by cutting scope. We can ship a new screen for our app sooner if we focus on building the most absolutely critical features first, and follow up with the valuable-but-not-critical features later.

There are many ways to break a story smaller, and all of them enable you to integrate code sooner in the form of smaller PRs: 

- Separate CRUD (Create, Read, Update, Delete) operations and ship them one at a time
- Separate by user role
- Separate individual edge cases
- Separate a simplified experience from an enhanced version


Think of these smaller scoped features as self-contained vertical slices of functionality. As each one is released, users can take advantage of them, and your team can start building the next slice. 

## PR by architectural layer

Rather than building an entire feature end-to-end before creating a pull request, consider integrating one layer at a time. Embrace the boundaries between the front and back ends of your code — submit a PR to introduce changes to the API, and once it's merged follow up with another PR to introduce changes to the UI. 

Depending on the architecture of your system, you might already be forced to this. At Artsy, our [web app lives in one repo](force), our [GraphQL endpoint lives in another](metaphysics), and many services are separated into repositories behind that. We _have_ to integrate our features one layer at a time. TODO: link to examples

The suggestion to PR by architectural layer is not in conflict with slicing stories small — in fact, these two strategies complement each other nicely. A PR that contains multiple features but only one layer is probably large enough to be difficult to review; so is a PR that contains one feature end-to-end. A PR containing one layer of one feature is easier to review.

## Build a walking skeleton

A [walking skeleton](walking-skeleton) is a bare-bones, stripped down implementation of your feature from end-to-end. It connects the UI all the way to the data source. Very little of the feature is presented, but what is there is fully functional.

Start a new feature with a walking skeleton PR to demonstrate connectivity of the pieces involved. It won't do very much — maybe it only displays one field — but that's okay because no one's going to see it yet. The important thing is that the moving pieces are all connected — the database, the API, the UI. 

Once a walking skeleton PR is merged, you can start filling in the skeleton. Each new sub-feature can be its own PR. 

This is a great approach if your team is looking to swarm on a feature. If we all work on our own sub-features without first merging a walking skeleton, we're likely to face some intense merge conflict headaches when we realize we've all connected the full stack in slightly different ways. Starting with a walking skeleton removes a lot of those merge conflicts, because we're mostly bolting fields on to existing infrastructure along the way. 

TODO: an example, either in words or linking to real PRs (I think I have one in the relay workshop repo)

## Separate risky/controversial work from routine work

It's not always possible to identify ahead of time which work will prompt more discussion during review, but sometimes it's obvious. Novel work that takes thoughtful consideration of multiple approaches is much more likely to invite feedback than work that follows existing patterns. 

Routine implementation can be a noisy distraction in a PR that also contains a unique function that you really want reviewers to see. You can definitely point out the unique bits in the PR body if they're combined, but you also might consider separating the less-interesting implementation into its own PR.

The worst review you can get on a PR that contains both novel and routine work is "LGTM!" (looks good to me). It likely means the reviewer couldn't separate the signal from the noise and overlooked the bits you put a lot of thought and effort into. 

## Separate foundational/infrastructural work from implementations
    - separate dependency updates into its own PR
    - separate work that makes a seam for a feature (ex: anna's canonical url stuff)
    - separate refactoring into its own PR
      - example (which I didn't extract but should have): 
        - https://github.com/artsy/eigen/pull/4356/commits/0cb7b9d075469f6830772a1e48d82f925f104a09
        - https://github.com/artsy/eigen/pull/4356/commits/6f0ff46a98c6df0918b1e230e864091f1d608cb1
    - separate polish work

## Common barriers to separating PRs 


### I'm working on a feature, but I want to clean up this unrelated issue and include it in my branch. 
    - submit a PR for the offshoot, rebase off that branch

### I've realized I could split this work into multiple PRs, but my commits are intermingled. 

    - interactive rebase
      - speaks to the importance of granular _commits_ --- so you can move them, reorder them, ...
