---
layout: epic
title: "Unstructured Knowledge Sharing"
date: 2021-04-21
categories: [teams, culture, people]
author: steve-hicks
---

Something something why is knowledge sharing important? blah blah blah we emphasize it at Artsy. 

We have a handful of regularly scheduled meetings in place at Artsy devoted to knowledge sharing: 

- [Team-based knowledge share meetings][knowledge-shares]
- Open office hours for anyone to join when they want help with something
- Lunch & learns for presenting across all of Artsy engineering
- Show & tell, where attendees bring recent learnings or explorations to demo to the group
- Peer learning groups that are dedicated to learning a specific topic in development

As [Ash][ash] mentioned in [the article on knowledge shares][knowledge-shares], these are all great _structured_ opportunities for us to share knowledge. Learning is easy to de-prioritize in the face of shipping features, and scheduling these meetings reinforces learning as a priority.

But what about the _unstructured_ ways in which we share knowledge? Structured sharing time demonstrates that the team is interested in spreading knowledge; _unstructured_ sharing time demonstrates that the spreading of knowledge has become _the default_ mode for the team. Instead of the team forming habits of working in isolation or hoarding expertise, they've formed habits of learning from and teaching each other. 

This article descibes a few things we do that are unstructured, all of which demonstrate our emphasis on learning at Artsy.

## The #dev-help Slack Channel

embed tweet
https://twitter.com/ArtsyOpenSource/status/1357819867638812672

This comment from [Chris](chris) is what prompted this article!!

We've got many dev-specific channels set up in the Artsy Slack, but one in particular has become a massively important knowledge-base for the entire team: the #dev-help channel.

This channel is a place for engineers to post when they're stuck. All engineers watch the #dev-help channel (to some degree) and offer support when they can. Each issue is threaded to avoid noise in the channel. When the question is answered, it gets marked as "solved" by applying a ✅ reaction. (mention solved bot & link to it)

(example screenshot)

The cumulative result of the questions asked and answered in this channel is an incredible knowledge base for all engineers. When I run into a new issue, the first place I search is #dev-help. More often than not I find my exact problem already solved.

This knowledge base is so important and powerful that it's no longer only a place to _ask_ for help. Engineers will also share problems they've _already solved_ in a new thread in the channel, in case someone else runs into the problem. Usually we'll tag these problems up front with "[already solved]" or similar, to make it obvious no one should spend cycles trying to _solve_ this problem.

(example screenshot)

One other important thing to say about the #dev-help channel: as engineers it's tempting to solve problems with new and novel tooling, but in the case of #dev-help we found a way to use our existing tooling in a slightly different way. Sometimes the best solution is one you already have. We could have investigated dedicated software like a StackOverflow for Teams, or we could have built our own knowledge-base tool. Instead we put some rules around how we would use a channel in Slack, and gained a huge benefit at a fraction of the cost.

## Internal Live-Streaming

Occasionally an Artsy engineer will broadcast that they're taking on work that is ripe for knowledge-sharing, and they'll spin up a Zoom call for others to join. It might be something they know how to solve — like when [Roop][roop] spun up a call to walk through how he'd use [ObservableHQ][observablehq] to explore search index weighting. There might be more uncertainty to the problem, like when [Pavlos][pavlos] started up a call to investigate a CI build failure using [`git bisect`][git-bisect]. Or somewhere in between, like when [Adam][adam-b] was doing some refactoring of our React Native navigation. 




- Firing up ad hoc zooms - we've been doing more and more of this lately and it's what prompted me to request this post. 
  - Sometimes they're more informative, like when @anandaroop recently spun up a zoom to walk through how he'd use observable to explore artist search index weighting.
    - kind of like streaming but for your coworkers
  - Sometimes they're more of a mobbing exercise, like when @admbtlr recently spun one up to work on some react-native navigation refactoring.
  - Pavlos spinning up a zoom to do git bisect to identify the cause of a build failure
  - In all cases they're a "push" instead of a "pull"
    - radiating intent on what you plan on working on
    - giving the rest of the team an opportunity to learn
      - or contribute if they've got expertise
- Pairing - this isn't an unusual practice and @yuki24 wrote it about in 2018 (/blog/2018/10/19/pair-programming/)
  - but I think we're pretty good at it as an org and it's a big part of our unstructured knowledge sharing
  - What _is_ different from many places is that we don't just do it when we're stuck, we do it to build features
  - Knowlege-sharing of more than just code & product -- how do I approach a problem, what's my tooling, what are my techniques for debugging/testing/tightening my feedback loop
  - We tend to focus on pairing within a team; could probably do more cross-team pairing
- Sharing via PRs
  - link to article on context in PRs



[knowledge-shares]: https://artsy.github.io/blog/2020/12/09/share-your-knowledge/