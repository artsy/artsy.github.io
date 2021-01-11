---
layout: epic
title: "Strategies For Small, Focused Pull Requests"
date: 2021-01-06
categories: [tools, github, team, community, engineering]
author: steve-hicks
---

- advice for better PRs is always "make it small & focused"
  - including https://artsy.github.io/blog/2020/08/11/improve-pull-requests-by-including-valuable-context/
  - also including the RFC from Adam about squashing? (can't remember where that is)
  - what does "small & focused" mean?
    - more specifically, what does a small, focused PR _look like_?
    - find an example of a set of small/focused PRs vs one large one
    - probably some traits i can list here
  - also maybe something about being a perfectionist & how that makes it hard to submit what feels like an "incomplete" PR.
- caveat: breaking up PRs assumes you can integrate code a little bit at a time
  - long-lived branching schemes _might_ make this harder
    - though you can still PR & review into branches that aren't `main`
  - feature toggles is a nice way to accomplish this 
    - could talk about our different levels of feature toggles (echo, user admin flags or whatever from gravity, whatever comes before an echo flag)
  - in web we use alternate routes when replacing an app (/search2 vs /search)
    - find an example PR
  - there are probably other ways I could list here
- strategies for reducing size & scope of a PR
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
