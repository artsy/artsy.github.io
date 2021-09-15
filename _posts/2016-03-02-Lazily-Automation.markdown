---
layout: post
title: "Being a Better Programmer When You're Actually Lazy."
date: 2016-03-02 12:09
author: orta
categories: [automation, culture, teams]
---

I juggle a bunch of projects, both in Artsy and in the Open Source community. If you don't work with me directly, you'd be mistaken for believing that I was an organized person. I'm pretty far from that, and [don't really](https://github.com/artsy/mobile/issues/68) plan on changing that.

However, I work with other people and very strongly believe that programming is mostly a social problem once you're good enough at writing code. It'd be hypocritical of me to not improve the people process side, so I try to automate processes that makes me a better team-mate.

I'm going to cover four things I've worked on lately to improve this: [Danger](https://github.com/danger/danger/), [GitHub-Clippers](https://github.com/orta/github-clippers) and improving how I write commits and prefixing my name on branches.

<!-- more -->

### Danger

[Danger](https://github.com/danger/danger/) is a tool I co-created with a friend ([Felix Krause](https://github.com/krausefx/)), and it's namesake, [Gem "Danger" McShane](https://github.com/dangermcshane). It came out of frustration that we couldn't easily hold ourselves accountable to better team processes. Requiring a code-reviewer to  also remember details like "Add a CHANGELOG Entry" isn't much to ask, but it is "Yet Another Thing To Remember" for both the submitter and reviewer.

It's turning into a really important part of our code-review, and the ideas it generates once we had it in place make it fun to add new rules. It means we can fail fast, and not have to think about process so much. Danger will tell us if we've missed something.

![Danger Example](/images/2016-03-02-Lazily-Automation/danger.png)

I expect to write a more serious post on [Danger](https://github.com/danger/danger/) once it's more fleshed out. For now though, the README covers what it does well.

### Clippers

In every big team I operate in, other people care about keeping the repo clean of merged branches. I totally respect their opinion, but it's so low on things I care about that I just don't register the "Delete Branch" button on a GitHub pull request. I'd rather be finding a [good response GIF](https://github.com/orta/gifs).

So I created [a Safari Extension](https://github.com/orta/github-clippers) that handles automatically deleting branches on specific repos for me. It's not a biggie, it's not fancy, it's under a [hundred lines of code](https://github.com/orta/github-clippers/blob/master/GitHub-Clippers.safariextension/github_clippers.js) - but it automates something that annoyed others about my behavior. That counts for something.

### Commit Automation

I write _reasonable_ commit messages, they're not [amazing](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), they're [not terrible](http://www.whatthecommit.com). They're just, [alright](https://github.com/artsy/energy/commits/master?author=orta). I wanted to start trying to hold everyone accountable for doing better, so I advocated for copying the person with the [best commit style](https://github.com/artsy/eigen/commits/master?author=alloy) on our team.

Their style is to have commits in a format like `[Context] Thing I did.` - it is much better that `Thing I did.`. So I looked into how I could automate this, because I would very quickly forget to do this. Here's what I did:

``` sh

// Helper function to get the branch info
function git_branch_info() {
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  echo "${ref#refs/heads/}"
}

function branch() {
  git checkout master;
  git pull upstream master;
  git checkout -b $1
  git config branch.$1.description $2
}

function commit() {
  local BRANCH=$(git_branch_info)
  local INFO=$(git config branch.$(echo $BRANCH).description)
  git commit -m "[$(echo $INFO)] $argv"
}

// And if I forget to set my context
function context() {
  local BRANCH=$(git_branch_info)
  git config branch.$(echo $BRANCH).description $1
}
```

Or if you're a fish user like me, [this gist](https://gist.github.com/orta/902d8e576a2b75afe2df).

I created two shell functions, one that makes a branch that includes a context type. So for example, say I'm working on artwork notifications, I'd start a new branch with `$ branch artwork_notifications Notifications`. This saves the context as `Notifications` on the git branch metadata. Then everytime I want to commit my changes, I use `$ commit This is the thing I changed.` - and it will be prefixed with `[Notifications]`. It makes it easier for someone looking through the history to have an idea about the context, and makes me feel like I'm improving my process without remembering the context.

### Branch Prefixes

We use a Makefile in all our projects to try and help automate per-project simple tasks like running [mogenerator](https://github.com/artsy/energy/blob/e5db035225490fb53c65c74a6c1bdd660f305ab6/Makefile#L44), updating [storyboard identifiers](https://github.com/artsy/energy/blob/e5db035225490fb53c65c74a6c1bdd660f305ab6/Makefile#L49) and updating [embedded resources](https://github.com/artsy/eigen/blob/12fe9de4d927eea27f4942d15e74b89016a6345f/Makefile#L102-L103).

I also applied some standard make commands in our projects so that I can prefix my [branches with my name](https://github.com/artsy/eigen/blob/10106210196f096a27412a70af61dcae7fda285c/Makefile#L110-L117).

``` sh
LOCAL_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
BRANCH = $(shell echo host=github.com | git credential fill | sed -E 'N; s/.*username=(.+)\n?.*/\1/')-$(shell git rev-parse --abbrev-ref HEAD)

pr:
	if [ "$(LOCAL_BRANCH)" == "master" ]; then echo "In master, not PRing"; else git push upstream "$(LOCAL_BRANCH):$(BRANCH)"; open "https://github.com/artsy/eigen/pull/new/artsy:master...$(BRANCH)"; fi

push:
	if [ "$(LOCAL_BRANCH)" == "master" ]; then echo "In master, not pushing"; else git push upstream $(LOCAL_BRANCH):$(BRANCH); fi

fpush:
	if [ "$(LOCAL_BRANCH)" == "master" ]; then echo "In master, not pushing"; else git push upstream $(LOCAL_BRANCH):$(BRANCH) --force; fi
```

This works by some funky shell work to pull out your current branch into `LOCAL_BRANCH`, then to do the same thing but prefixed with your login name for `BRANCH`. Then the make commands handle pushing to the server. This means that everyone in the team can provide have logically named branches without having to have their local repo filled with `[my_name]-thing` branches.

## On-going

This is a work in progress, as the mobile team grows, we need to add more process when it's appropriate. This _doesn't_ mean that we have to sacrifice speed, and we can continue thinking about the problem at hand rather than devoting energy to process.

It's a time trade-off that has worked out well for me so far, and I'd love to know other people's hacks for having useful process, but automating it so that it's not considered overhead.
