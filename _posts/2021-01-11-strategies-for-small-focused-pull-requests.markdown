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

To make our PR reviewers' lives easier, we're looking for the intersection of small _and_ focused. Changes that are cohesive and without distractions. Code that accomplishes one thing. TODO: find some examples that show the extremes?

Note that the recommendation for "small and focused" PRs does not include the word "complete". I'm as much a perfectionist as anyone and I like my work to be very polished before it's done, but when we're iterating quickly the polish can come in a follow-up PR. This is the biggest challenge I've had as an Artsy engineer — finding the balance between polish and iteration. Artsy's core values include [Impact Over Perfection](https://github.com/artsy/README/blob/ccfbba13ead7cb6586d2d9bf088e5180907be07b/culture/what-is-artsy.md#impact-over-perfection) but my personal values include "make things _real good_" and it can be hard for me to navigate that tension. 

### Integrating code a little at a time

A caveat: the recommendations in this article assume you can integrate code a little bit at a time. I've worked on teams and projects where we had very long-lived branches for features or even epic — I know those environments exist. This article is probably not the one that will convince you to move to [trunk-based development](https://trunkbaseddevelopment.com/); it also might be less useful without trunk-based development.

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


Think of these smaller scoped features as self-contained vertical slices of functionality. As each one is released, users can take advantage of them, and your team can start building the next module. 

## PR by architectural layer

Rather than building an entire feature end-to-end before creating a pull request, consider integrating one layer at a time. Embrace the boundaries between the front and back ends of your code — submit a PR to introduce changes to the API, and once it's merged follow up with another PR to introduce changes to the UI. 

Depending on the architecture of your system, you might already be forced to this. At Artsy, our [web app lives in one repo](force), our [GraphQL endpoint lives in another](metaphysics), and many services are separated into repositories behind that. We _have_ to integrate our features one layer at a time. 

The suggestion to PR by architectural layer is not in conflict with slicing stories small — in fact, these two strategies complement each other quite nicely. A PR that contains multiple features but only one layer is probably large enough to be difficult to review; so is a PR that contains one feature end-to-end. A PR containing one layer of one feature is easier to review.

## Build a walking skeleton


  - walking skeleton
    - start with a PR that just connects the different pieces end-to-end
    - once that's merged, start filling in the skeleton with PRs
  - separate riskiest/most controversial from the more routine work
    - separates the signal from the noise for reviewers
  - separate preparation/cleanup work
    - separate dependency updates into its own PR
    - separate work that makes a seam for a feature
    - separate unrelated refactoring into its own PR
    - separate polish work
- common problems
  - what happens if I start work thinking its a standalone PR but find bits I can separate? 
    - submit a PR for the offshoot, rebase off that branch
  - what happens if I'm halfway through the work when I realize I committed different kinds of work?
    - interactive rebase
      - speaks to the importance of granular _commits_ --- so you can move them, reorder them, ...
