---
layout: epic
title: Danger
date: 2017-06-30
categories: [culture, danger]
author: orta
css: danger
---

Danger came out of two needs. One from the needs of a growing dev team working together full-time, and the other from the needs of a completely asymmetric large Open Source project.

A work environment dev team is a complex place. You naturally grow, and to grow safely you add process. Process is a mixed bag, it's a net benefit at the trade-off of individual's time vs team cohesion. You want to grow your team guided by smart applications of process. 

On the other hand, working on a large open source project, it's easy to feel overwhelmed at the amount of work that needs to get done on a daily basis. The growth of your OSS team probably doesn't tie to the amount of work that needs to be done. Especially if you're like me, and you don't want to be maintaining OSS as a 2nd full-time job.

So what do you do? Well in a work environment you don't really have a choice, as a team you hold each other to the rules that you set. In OSS, you sacrifice your spare time or you can find time at work, you could stop or you could burn out.

And this is the environment in which the idea of Danger was incubated.

Today mark version 1.0 of the second version of Danger. I'm going to cover what they are, how they continue to grow and what I see their trajectory as.

<!-- more -->

# Why?

Danger came from a need to customise the GitHub workflow for pull requests. In a work context, we wanted to add process like CHANGELOGs and be more thorough about testing. In Open Source, we needed to stop asking the same things to drive-by contributors. Their patches are valuable for sure, but asking for the same changes each time gets tiring. We want to work at a higher level of abstraction.

In both cases you want a way to give instant feedback for things that are "Unit Tests have failed" or "Code could not compile". However, it's hard to give feedback that says "You have not added a CHANGELOG entry in the right format." 

Typically CI would only provide a binary: true or false response to the changes for review. We want a more shades of grey.

## What does Danger do?

Danger acts as a way of creating unit tests at code review level. It gives you the ability to write tests that say: "has this file changed?", "does the contents of new files include this string?", "does the build log include a warning we know is bad news?" then the results of those tests are moved back into the place you're talking about the code.

To do this, you need to be able to create your own rules. Every team has different dynamics, and while it makes sense to offer a set of a set of standard rules that can work across a lot of projects - I'm pretty sure that the needs of the Artsy engineering team is different from the needs of your team.

Danger runs your code, and provides a set of easy to use APIs for you to build these useful culture rules. You write your rules in code, we call these files Dangerfiles. Similar to how a testing framework would give a set of expectations. The general gist is Danger provides access to:

* Changes from Git
* Changes from GitHub/GitLab/BitBucket
* Interacting with Danger

By making per-project rules with these APIs, you can cover most rote tasks involved in code review. To make it easy for anyone to run Danger on every pull request, Danger was made to run during continuous integration.

# OK, so "2 versions of Danger"?

I first implemented Danger in Ruby. Ruby is a great language for building terminal apps, in the iOS community it's the language in which the largest OSS projects are built in. So, as someone used to building apps in that space, it wasn't really a debate what language to work with.

The Ruby build of Danger is now at 5.x with almost 100 releases, it's a solid exploration into code review automation. Ultimately though, I started to feel three main pain-points:

* At Artsy, we moved our mobile team to React Native, and other teams were also consolidating on JavaScript everywhere. It felt weird using a Ruby inside a strictly JS only context. 

* Trying to re-create the environment of a PR was tricky from inside the CI. For example most providers are good at about saving on space and bandwidth during a run, and Danger often has to ruin that in order to replicate the PR locally.

* I wanted to explore server-side Dangerfiles. I wouldn't feel comfortable hosting a server that allows anyone to run their own Ruby code. Ruby isn't built with sandboxing in mind.

## JavaScript

First I explored the idea of having JavaScript based Dangerfiles inside the Ruby version of Danger. I did this by [bridging Danger's Ruby objects into a JavaScript context](https://github.com/danger/danger/pull/422) and allowing bi-directional communication between the two. This handled some of the immediate needs, but proved inadequate when working with JavaScript's simple system library and it ignored all other JavaScript tooling. 

After enough time, I came to the conclusion that realistically, to use JavaScript properly, you need node modules and npm.

So 10 months ago I decided it was worth starting from scratch and re-created Danger in JavaScript. I had time to consider what I would do differently, and this time I added one key additional restraints on the system: Data can only come from an API.

This constraint negates one of the key problems with running running a Dangerfile on a server - having to have a copy of the code and the PR's environment. 

In addition, JavaScript has a much simpler model for evaluating, importing and exporting code and so whitelisting modules and functions can be feasible for a hosted version of Danger. 

<center><img src ="/images/danger/danger.png" style="width:50%"></center>

# 1.0 is my middle name

Any software project used in production should probably be 1.0, but in addition to production use a library needs documentation to be 1.0.

Calling Danger production ready means doing the entire [Defensive OSS][defense] process: Documentation, Guides, API Reference, Website and Branding.

Once each version of Danger had started to mature to a point that the user-facing aspect stopped changing I started focusing on the documentation engine and website. In both cases, a considerable amount of documentation is generated from the source code of Danger. I'm a big fan of keeping that inside the source code and building documentation sites which import it directly.

# So what can I do with Danger?

In one way this is a bit like asking, so what can I test with unit tests? Anything, within the scope of: the PR, build artifacts and introspecting the codebase.

I'll cover a quick API overview, then talk about how you can work with these:

### Git

* What files have been added, removed or changed.
* Changes specific to a file.
* Looking into Commits.
* Exploring the Diff.

### GitHub / GitLab / BitBucket

* Access to the PR's JSON representation.
* Consistent access for PR body, title, author across all platforms.
* Util functions for linking to files.

### Danger

* Handle running other Dangerfiles.
* Handles plugin management.
* Provides a set of utility functions that would often get used.

### Messaging

* Leave warnings, messages and markdown comments.
* Leave errors, marking the build as failed.
* Post any of the above of the above inside a file.
* Create a GitHub review, and use the above messaging.

### Plugins

* Infrastructure for shared rules.
* Opens up the ability to validate tricky things with an easy API.

The API differs between the JS and Ruby version, not drastically - but there are no plugins for Danger JS yet. That's still a bit away.

## OK, got it.

Let's cover a few examples of the kind of tests can you write.

#### Checking for changes to a specific file

Checking for a CHANGELOG. This was the first rule imagined for Danger, I add it to every project.

The first implementation of this rule can just be a check if the file `CHANGELOG.md` is modified in any PR, that can then be
revised to also check whether there are git changes related to your app. Then documentation, README, tooling updates
don't require an entry. We also check if the PR title says "trivial" and skip the CHANGELOG check.

If you're interested in standardizing on the [keepachangelog.com][usechange] format there is [danger-changelog][danger-changelog].

Some other examples around this is pinging specific people when a file has changed, or failing if a file that's never meant
to be modified is changed, warning about potential semantic version updates for changes to specific files.

#### Checking the results of command-line tools

The Artsy developer blog runs both a spell checker, and a prose linter. These report back on files added or 
modified during the PR. As someone known for writing loose and quick, having a machine provide some automatic feedback
makes it easy to not waste my reviewers time.

This is done by the [danger-prose][prose] plugin, which wraps both an [npm module][mdspell] and a [python egg][proselint]. 
The plugin handles installing and running the CLI, then converts the output into markdown for github.

#### Handling build artifacts

If Danger runs after the build process, you can read build logs to provide better feedback. This can range from taking 
the results of a test run and posting what has failed (e.g. [danger-junit][junit]), to finding specific strings inside
build logs and highlighting them. 

In our native iOS app, when a developer accidentally adds code which accesses the network in a test. That is logged out
during the build. Then later, danger will read the logs to find any mentions of this and post it in the comment.

#### PR Metadata

Every team's workflow is different, but it's pretty common to use a tool other than code review for keeping track of a project's momentum. You can use Danger to warn people that they haven't included a Trello, or JIRA ticket reference on
every PR.

A similar approach could be to warn if someone is sending a PR to a branch other than the preferred branch. This works
well if you use the git-flow model for branches.

We nearly always add a check to see if someone is assigned to a PR, and warn it it's unassigned in front-end projects. 

#### Using the platform API

There's no limits here, by using the API from your platform you can perform any sorts of checks. In the Danger repo
we use the GitHub API to note whether someone is in the Danger org, to remind the core team to invite them to the org
after submitting a PR.

## Introducing Danger

OK, maybe that's got you thinking _"ah, I know a process I can automate"_.

It can be easy to try and jump straight from no Dangerfile to a many-hundred lined complex set of cultural rules. I'd advise against introducing a long list of rules for Danger all at once. In my experience, gradual integration works better. The entire team may have agreed on the changes upfront, but slower adoption has worked better for teams new to working with Danger.

At Artsy we've found that first just integrating Danger with a single simple rule (like checking for a CHANGELOG entry) then starting to introduce them piece-meal from different contributors has made it easier to go from "Ah, we shouldn't do that again" to "Oh, we could make a Danger rule for that" to "Here's the PR". 

## Which Danger should I use?

This definitely depends on the project, there's a longer discussion [on the site](http://danger.systems/js/js-vs-ruby.html) too, but here's the main gist:

* **Danger Ruby** is more mature, has more features, a solid plugin eco-system and covers more platforms. It's in a great place and is unlikely to have breaking changes from this point onwards.

* **Danger JS** has a bigger potential for growth, is "stable enough", you can create plugins and will be able to do things that the Ruby version could not - eventually. Right now it only works with GitHub.


## Onwards and Upwards

With the JavaScript version of Danger in a great place ready for production, I can start more serious work on [Peril][peril]. Peril is a hosted web-service that runs Dangerfiles against GitHub events, see [the VISION.md][peril-vision]. Those events span from a new user being created, to a new issue on a repo. Peril lets you run your own complex rules across an entire org. This can be a really powerful way to audit and improve entire-company culture.

We started using Peril in Artsy [last week][peril-reaction]. So it's starting to become a thing internally. It'll be awesome to explore the idea of org-wide rules. I think we're starting with making sure we assign someone on a PR. 

So give Danger a shot, and if you're bold. give [Peril][peril] a shot.

---

This post uses the CC license image from [this tweet](https://twitter.com/CloudyConway/status/880426417024114688) with some changes to make it fit with the design of the blog. Thanks [Vexorian](https://www.patreon.com/vexorian). 
 
[prose]: https://github.com/dbgrandi/danger-prose 
[proselint]: https://github.com/amperser/proselint/
[mdspell]: https://github.com/lukeapage/node-markdown-spellcheck
[junit]: https://github.com/orta/danger-junit
[usechange]: http://keepachangelog.com/en/0.3.0/
[danger-changelog]: https://github.com/dblock/danger-changelog
[defense]: http://artsy.github.io/blog/2016/07/03/handling-big-projects/
[peril-vision]: https://github.com/danger/peril/blob/master/VISION.md
[peril]: https://github.com/danger/peril#peril
[peril-reaction]: https://github.com/artsy/reaction-force/pull/184
