---
layout: post
title: "Helping the Web Towards OSS by Default"
date: 2016-09-06 12:17
author: orta
categories: [force, node, microgravity, js, JavaScript, web]
series: Open Source by Default
---

The main Artsy.net website for the desktop, [Force][force_gh], was our first Artsy application to open its source code, [Craig][craig] and [Brennan][brennan] did it [back in 2014][force_oss]. Force's public offering laid the groundwork for the iOS OSS projects to come afterwards: [Eidolon][eidolon_oss], [Eigen][eigen_oss], [Energy][energy_oss] and [Emergence][emergence_oss].

Though Force wasn't quite Open Source by Default, it represented a _really_ important step for  Artsy's OSS perspective but was not the end goal. We were opening our source, but not opening our process.

This month both [Force][force_gh], the desktop version of [Artsy.net][artsy_net] and [Microgravity][mg_gh], the mobile version - moved to being built entirely in the open. Read on to find out how.

<!-- more -->

## Force

Over the course of the last month, I've sat on and off with Charles "[Cab][cab]" Broskoski, and figured out what it would take to migrate Force to work in the public. Previous to this, work happened on a private repo, and we would push that code to the public.

We scoped out what it would require, creating an issue that summarized the work. Then we waited for 2 weeks, to give people the chance to discuss the idea and to offer examples for why we should delay or not move. Not all projects _should_ be OSS, and everyone should have a say when it affects them - giving some time let the team speak their mind. Especially during summer, when people were less active at work.

{% expanded_img /images/oss-milestone/force-oss.png %}

It had been 9 months since the last commit to the public repo, and so auditing the commits was a matter of investigating into configuration files, and seeing what's changed since the last public commit.

Next up, we renamed the current `force` repo to `force-private`. This was to keep the old issues and PRs around after we moved to working in the public. With `force` now available we re-named the already public project.

We then ensured all outstanding PRs were merged or closed, and pushed the commits from `force-private` to the now OSS `force`.

### CI

To get back up to speed we needed to set up CI, figuring this out took time.

We got testing up and running in no time. However, Force is deployed via [Semaphore CI][semaphore], and to deploy we needed to push compiled assets to S3. To pull that off, we needed access to an S3 key, and token.

In our iOS projects, [we do not expose environment variables][eidolon_pr] to PRs from forks, so we don't expect them to pass from external contributors. This is fine, because we have [different expectations][oss_expectations] for OSS apps vs libraries. We do this to ensure that we don't receive a PR that adds `printenv` to the CI scripts, exposing our secret keys.

As we couldn't add the keys to our testing environment, we added them to our heroku environment then took them from that. Semaphore sets up our heroku environment only during deployment, so in the deployment phase, we can use a line like:

```sh
export FORCE_S3_KEY=$(heroku config:get FORCE_S3_KEY --app force-production)
```

This sets up the environment like we used to have it when force was private.

### Team

We needed to move all the team members to using the OSS version of our apps. This is a little bit complicated as [we work from forks][forks]. [Roop][roop], an engineer on the web team, created a "Force OSS Dance Script" ( sidenote: [his site][roop] is worth a visit, there's 15 years of interesting maps. )

```sh
## RENAME THE OLD REPO

# on GitHub

# - Go to my fork https://github.com/<username>/force
# - Go to Settings tab
# - Rename repo to "force-private"

# on my local machine

mv force force-private
cd force-private
git remote set-url upstream git@github.com:artsy/force-private.git
git remote set-url origin git@github.com:<username>/force-private.git


## FORK AND CLONE THE NEW REPO

# back to GitHub

# - Go to the new Force repo https://github.com/artsy/force
# - Fork it to my account

# back to my local machine

git clone git@github.com:<username>/force.git
cd force
git remote add upstream git@github.com:artsy/force.git
cp ../force-private/.env ./
cp ../force-private/node_modules ./ # or just 'npm install' again


# all good now - both repos on local machine with correct remotes, envs, deps
```

For Force, all the same commits existed in both repos, so it would be difficult to push secrets to the open repo by accident. However, individuals did to sync up a new version of their forks.

And that, is how we moved force into OSS by Default. :+1: - We'll cover the issues migration later.

## Microgravity

I have a lot of love for Microgravity. It's the web project that made [Eigen][eigen_tag] possible. Once Force had moved, I started spending time with Craig trying to understand what it would take to open up Microgravity.

{% expanded_img /images/oss-milestone/micrograv-oss.png %}

It is no surprise to find a lot of overlap, both projects are based on the same foundations: [Ezel.js][ezel].

We didn't trust the commit history for microgravity, so we nuked it. Same as our native OSS apps.

We came up with a pattern to make it easier for people to migrate issues, we created a `migrate` GitHub label that anyone can apply to an issue in a private repo. Then we use [Issue Mover for GitHub][issue_mover] with some inline JavaScript to loop through all our issues to migrate. As it's applying a label we can ask product owners and designers to choose ones that are important to them too.

--

I love that I got to help make these changes, the web team started the process of opening our apps at Artsy, then the mobile team took the next big step. Now the teams are both in lock-step, and if you work on the front-end at Artsy - OSS by Default is the way we all work now.

[brennan]: http://artsy.github.io/author/brennan
[craig]: http://artsy.github.io/author/craig
[cab]: http://charlesbroskoski.com/_/
[force_oss]: /blog/2014/09/05/we-open-sourced-our-isomorphic-javascript-website/
[eidolon_oss]: /blog/2014/11/13/eidolon-retrospective/
[eigen_oss]: /blog/2015/04/28/how-we-open-sourced-eigen/
[energy_oss]: /blog/2015/08/06/open-sourcing-energy/
[emergence_oss]: /blog/2015/11/05/Emergence-Code-Review/
[force_gh]: https://github.com/artsy/force
[mg_gh]: https://github.com/artsy/microgravity
[semaphore]: https://semaphoreci.com/
[eidolon_pr]: https://github.com/artsy/eidolon/pull/607
[oss_expectations]: http://artsy.github.io/blog/2016/01/13/OSS-Expectations/
[force_deploy]: https://github.com/artsy/force/blob/40741bfbff48f6851749eb9c3e5014b0702c8402/Makefile#L79
[forks]: /blog/2012/01/29/how-art-dot-sy-uses-github-to-build-art-dot-sy/
[roop]: http://www.anandarooproy.com/portfolio
[eigen_tag]: /blog/2015/04/28/how-we-open-sourced-eigen/
[ezel]: https://github.com/artsy/ezel
[issue_mover]: https://github-issue-mover.appspot.com
[artsy_net]: https://www.artsy.net/
