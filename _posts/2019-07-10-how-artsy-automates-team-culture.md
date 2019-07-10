---
layout: epic
title: "How Artsy Automates Team Culture"
date: "2019-07-10"
author: [ash]
categories: [culture, team, automation, peril, danger]
---

(This blog post was originally presented at mDevCamp 2019. [The video recording is available][recording], and this
blog post serves as a kind of pseudo-transcript.)

Hi there! I'm Ash, an engineer with Artsy. Our vision is a world where everyone is moved by art everyday, and we're
working to achieve that vision by expanding the art market. A bigger art market means more people buying art, more
artists producing art, and more art in the world generally. Over the past nine years, Artsy has achieved a degree
of success in our mission:

- We have built and scaled a successful galleries listing business.
- We have created the world's [most-read online arts publication][editorial].
- We have partnered with top auction houses to bring their sales to anyone with an internet connection.

And we've done this with, at most, 33 engineers. This is extra-impressive when you consider how reluctant the art
world has been to embrace the internet – our engineering team has played a huge role in building trust with our
partners.

One of the reasons that we've been so successful, with such a small and focused team, is our culture. And today, I
want to talk about some of the automation tooling that we've built to support that culture.

I want you to keep in mind how small changes can have a larger impact. Automation isn't like building other
software because once you automate something, it can become a platform for further automation. So investments in
automation infrastructure accrue benefits, like compound interest. I've [covered this subject in another
post][automation] if you'd like to read more.

And while this post is about how _Artsy_ automates _Artsy's_ culture, I've tried to select examples that fit within
the [Agile Manifesto][agile] so that you can apply them to your own team.

Okay, let's dive in!

<!-- more -->

## Step One: Document your Culture

Documenting your team's culture is the first step towards automating it. I encourage you to take your time here –
the more forethought you put in to your culture, the less actual code you'll end up writing to automate it.

But this raises an important question: what even is culture? **Culture is everything about how your team works**.
Your culture is the tools your team uses, it's your vacation policy, it's the tone your team uses in pull request
reviews. How long it takes to compile your app is your culture.

Everything is culture, really.

I take this expansive definition because, when thinking about team dynamics and culture, it's rarely helpful to
limit the scope of our ambitions. Keeping our definition open helps us keep our minds open, too.

Your goal, as a team, is to instill a sense of **cultural continuity**. Think about the most critical person on
your team, and now think about what happens when they go on vacation. Does your team continue to work the same way?
Do people fill-in for the missing team member? Or does your team change how it works? If your team's culture
depends on a single person, then it isn't a very strong culture. So keep that goal of continuity in mind as we go
forward.

Let's take a look at an example of documenting culture. A few years ago, I wanted to increase my impact, so I
decided to start running our engineering team's weekly standup. The standup is our only mandatory meeting, so I
quickly realized that I was becoming a bottleneck for the team; if I were out that day, then who would run the
standup? So I documented the process so that others could run the meeting. In fact, I documented the process so
that others _would_ run the meeting. (The [docs are open source][docs] and [I wrote a whole blog post about
this][standup], so check those out for more info.)

Today, we all take turns running the meeting. This has two key benefits:

- The last step of the documentation is to review the documentation for improvements. This is really important: I
  think of it as our culture folding in on itself.
- Because everyone helps run the meeting, everyone feels like the _own_ the meeting. We are all invested in its
  success, and in our own success.

The really cool thing here is that part of our documentation is a step to _improve_ that documentation. This is a
kind of automation! And it's not the kind of automation that a computer could do.

**Humans are really good at following instructions**. And while we think of computers as being the targets for our
automation infrastructure, people are a great automation target, too. People are better than machines when it comes
to automating some things, like following ambiguous instructions or even _improving_ the instructions as they go.

So with only a single markdown file in GitHub, we had not only _documented_ part of our culture, but we had also
_automated_ part of our culture. That was a little bit of effort – now let's see what happens when we add a little
bit _more_ effort.

## Step Two: Infrastructure Investments

## Step Three: Amplify Norms using Code

[recording]: https://slideslive.com/38916507/how-artsy-automates-team-culture
[editorial]: https://www.artsy.net/articles
[automation]: https://artsy.github.io/blog/2019/01/08/automation-encourages-more-automation/
[agile]: https://agilemanifesto.org
[docs]: https://github.com/artsy/README/blob/master/events/open-standup.md
[standup]: https://artsy.github.io/blog/2018/05/07/fully-automated-standups/
