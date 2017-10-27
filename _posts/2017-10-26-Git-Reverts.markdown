---
layout: post
title: "Git Reverts: Rolling Forward While Rolling Back"
date: 2017-10-26 14:18
comments: true
author: alan
github-url: https://www.github.com/acjay
twitter-url: http://twitter.com/AlanJay1
blog-url: http://acjay.com
categories: [Git, GitHub, version control]
---

I don’t revert code changes often. Usually, I’m a fan of "rolling forward" with a fix, rather than rolling back. But sometimes, revert-and-fix is just the ticket. I had to do so recently, and it brought up some interesting challenges, so I thought I’d share.

<!-- more -->

Here’s the scenario. Some recent changes I was making to Gravity, our core API service, had a pretty big ripple effect. Gravity is a big app, with over 100k LOC, so the tests take a long time to run. For this reason, we have our CI server set up to only run the tests it thinks are applicable for the changes in each commit in a pull request. That way, we can get pretty fast feedback on individual commits. But because Ruby is dynamic, the detection of which tests to run is imperfect. So, we run all the tests when a PR is merged to `master`, as a blocking step before the changes are actually deployed to our staging environment.

This makes it possible to “break the build”, where the `master` branch no longer is valid with respect to its tests, which is exactly what happened. The staging build of my changes failed, and it rendered our whole team unable to ship changes until the build was fixed.

> Eek!

No big deal, that’s what reverts are for, and GitHub makes it quite easy to revert a pull request. If nobody merged anything to `master` that required conflict resolution with the changes in your PR, you can pretty much painlessly and immediately revert. Which I did.

> Great!

Now I had time to fix those tests, without worrying about blocking anyone. I checked out the original branch and pretty quickly figured out what changes I needed to make to fix the tests. Then I pushed that branch up to origin to make a new PR.

> Drat! Merge conflicts. Right, I need to either merge or rebase from `master` to get everything up-to-date.

And that’s when I hit the problem. Now that I had reverted my original changes, those _undos_ are considered the canonical history, rather than the original changes I had tried to make! So both `git merge master` and `git rebase master` left me with only the tiny fixes to the failing tests, but my actual meaningful changes still removed.

> Conundrum.

The solution I came up with was to _revert my revert_. The PR that the original revert button created also presented a revert button after it was merged. So I hit that button, and it created an amusingly titled `Revert "Revert “My original title””`. I `git stash`d my fixes, `git fetch`d the branch GitHub created for this newest PR down to my local, and `git checkout`d the this branch. This effectively was my original changes on top of their rollback, on top of those same changes — crucially, with changes other developers had made in the meantime mixed in there somewhere. I then `git stash pop`d my fixes.

> Phew!

In conclusion, rolling back presents some interesting challenges, in the context of how Git considers history. If I've messed up a local branch, I might just give up and `git reset --hard` to get it back to a known good commit. But when it comes to the `master` branch, you have to be able to wiggle your way out of tricky situations. GitHub’s reverts are a viable option for keeping the _history_ rolling forward as you undo and redo work.
