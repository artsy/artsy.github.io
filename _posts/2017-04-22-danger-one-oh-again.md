---
layout: post_longform
title: Danger 1.0, 2.0.
date: 2017-22-14
categories: [culture, danger]
author: orta
---

# Welcome Danger 1.0, again.

- Original Problem
  Danger came out of two needs. One from the needs of a growing dev team working together full-time, and the other from the needs of a completely asymmetric large Open Source project.
  
  - A work environment  dev team is a complex place.
  - You grow, and to grow safely you add process.
  - Process is a mixed bag, it's a net benefit at the tradeoff of individual's time.
  - You want to grow your team guided by smart applications of process. 

  On the other hand, working on a large open source project, its very easy to feel overwhelmed at the amount of work you have to do on a daily basis. When you don't want to be maintaining it as a 2nd full-time job.

  So what do you do? Well in a work environment you don't really have a choice, as a team you hold each other to the rules that you set. In OSS, you sacrifice your spare time or you can find time at work, you could stop or you could burn out.

And this is the environment in which the idea of Danger was incubated.

Today mark version 1.0 of the second version of Danger. I'm going to cover what they are, how they continue to grow and what I see their trajectory as.

<!-- more -->

Danger came from a need to customise the GitHub workflow for pull requests. In a work context, we wanted to add process like CHANGELOGs and be more thorough about testing. In Open Source, we needed to stop asking the same things to drive-by contributors. Their patches are valuable for sure, but asking for the same changes each time gets tiring.

In both cases you want a way to give instant feedback for things that are not use "Unit Tests have failed" or "Code could not compile". However, it's hard to give feedback that says "You have not added a CHANGELOG entry in the right format", typically CI would only provide a binary: true or false response to the changes for review. We want a more shades of grey.

### What does Danger _really_ do?

Danger acts as a way of creating unit tests at code review level. It gives you the ability to write tests that say: "was this file changed", "did the contents of new files include this string", "does the build log include a warning we know is bad news" then the results of those tests are moved back into the place you're talking about the code.

To do this, you need to be able to create your own rules. Every team has different dynamics, and while it makes sense to offer a set of a set of standard rules that can work across a lot of projects - I'm pretty sure that the needs of the Artsy engineer team is different from the needs of your team.

Danger runs your code, and provides a set of easy to use APIs for you to build these useful culture rules. Similar to how a testing framework would give a set of expectations. The general gist is:

* Changes inside from Git
* Changes from GitHub/GitLab/BitBucket
* Interacting with Danger

By making per-project rules with these APIs, you can pretty much cover most rote tasks involved in code review. To make it easy for anyone to run Danger in on every pull request Danger was made to run during continuous integration.

## OK, so "2 versions of Danger"?


