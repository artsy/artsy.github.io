---
layout: post_longform
title: Danger 1.0, 2.0 and 3.0.
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

Danger runs your code, and provides a set of easy to use APIs for you to build these useful culture rules. You write your rules in code, we call these files Dangerfiles. Similar to how a testing framework would give a set of expectations. The general gist is Danger provides access to:

* Changes inside from Git
* Changes from GitHub/GitLab/BitBucket
* Interacting with Danger

By making per-project rules with these APIs, you can pretty much cover most rote tasks involved in code review. To make it easy for anyone to run Danger in on every pull request Danger was made to run during continuous integration.

## OK, so "2 versions of Danger"?

* First version was in Ruby
* Used due to familiarity of tools + hard iOS community tooling tends to get built in Ruby
* Exploration of
  * feedback techniques
  * tools necessary to get things done

Ultimately I started to feel three main pain-points:

* At work, we moved our mobile team to React Native, and other teams were also consolidating on JavaScript everywhere.

* Trying to re-create the environment of a PR was tricky from the CI. For example most providers are good at about saving on space and bandwidth during a run, and Danger often has to ruin that in order to replicate the PR locally.

* I wanted to explore server-side Dangerfiles.

## JavaScript

I explored the idea of having JavaScript based Dangerfiles inside the Ruby version of Danger. I did this by bridging Danger's Ruby objects into a JavaScript and allowing bi-directional communication between the two. This handled some of the immediate needs, but proved inadequate when working with JavaScript's limited API and ignored all other JavaScript tooling. Realistically, to use JavaScript properly, you need node modules and npm.

So 8 months ago I decided it was worth starting from scratch and re-created Danger in JavaScript. I had time to consider what I would do differently, and this time I added one key additional restraints on the system. Data can only come from an API.

This constraint negates one of the key problems with running running a Dangerfile on a server - having to have a copy of the code and the PR's environment, the other being sandboxing.

# 1.0 is my middle name

Any software project used in production should probably be 1.0, but a library needs documentation to be 1.0.

As both Danger's 

# So what can I do with Danger?

In one way this is a bit like asking, so what can I test with unit tests? Anything, within the scope of: the PR, build artifacts and introspecting the codebase.

I'll cover a quick API overview, then talk about how you can work with these:

### Git

* What files have been added, removed or changed.
* Changes specific to a file.
* Looking into Commits
* Exploring the Diff

### GitHub / GitLab / BitBucket

* Access to the PR's JSON representation
* Consistent access for PR body, title, author across all platforms
* Util functions for linking to files

### Danger

* Handle running other Dangerfiles
* Handles plugin management
* Provides a set of utility functions that would often get used

## OK, got it.

So, what kinds of tests can you write?

* Checking for changes to a specific file
  
  For example, checking for a CHANGELOG. This was the first rule imagined for Danger, and the first rule ever run.

  The first implementation of this rule can just be a check if `CHANGELOG.md` is modified in any PR, that can then be
  revised to also check whether there are git changes related to your app. Then documentation, README, tooling updates
  don't require an entry. We also check if the PR title says "trivial" and skip the CHANGELOG check.

  Another example around this is pinging specific people when a file has changed, or failing if a file that's never meant
  to be modified is changed.

* Checking the results of command-line tools

  The Artsy developer blog runs both a spell checker, and a prose linter. These report back on files added or 
  modified during the PR. As someone known for writing loose and quick, having a machine provide some automatic feedback
  makes it easy to not waste my reviewers time.

  This is done by the [danger-prose][prose] plugin, which wraps both an npm module and a python egg. It handles installing
  and running the CLI, then converts the output into markdown for github.

* 

[prose]: https://github.com/dbgrandi/danger-prose 
