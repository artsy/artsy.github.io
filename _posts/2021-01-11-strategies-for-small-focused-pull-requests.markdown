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

A caveat: the recommendations in this article assume you can integrate code a little bit at a time. I've worked on teams and projects where we had very long-lived branches for features or even epics, I know those environments exist. This article is probably not the one that will convince you to move to [trunk-based development](https://trunkbaseddevelopment.com/); it's also probably not going to help much in those environments. 

On the other hand, ...???




- caveat: breaking up PRs assumes you can integrate code a little bit at a time
  - long-lived branching schemes _might_ make this harder
    - though you can still PR & review into branches that aren't `main`
  - feature toggles is a nice way to accomplish this 
    - could talk about our different levels of feature toggles (echo, user admin flags or whatever from gravity, whatever comes before an echo flag)
  - in web we use alternate routes when replacing an app (/search2 vs /search)
    - find an example PR
  - there are probably other ways I could list here
- strategies for reducing size & scope of a PR
  - start with small scope -- make small stories
    - TODO: strategies for story-splitting
  - PR by layer
    - probably taken for granted at artsy because our layers are different services/repos (and therefore _require_ separate PRs)
  - walking skeleton
    - start with a PR that just connects the different pieces end-to-end
    - once that's merged, start filling in the skeleton with PRs
  - separate riskiest/most controversial from the more routine work
    - separates the signal from the noise for reviewers
  - separate the work that makes a seam from the work that introduces the new feature
    - separate refactoring into its own PR
    - separate dependency updates into its own PR
- common problems
  - what happens if I start work thinking its a standalone PR but find bits I can separate? 
    - submit a PR for the offshoot, rebase off that branch
  - what happens if I'm halfway through the work when I realize I committed different kinds of work?
    - interactive rebase
