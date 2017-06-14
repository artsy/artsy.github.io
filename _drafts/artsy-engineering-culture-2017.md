---
layout: post_longform
title: Artsy's Culture Stack, 2017
date: 2017-03-05
categories: [Technology, eigen, force, gravity]
author: [orta, artsy_engineering]
series: Artsy Tech Stack
---

<!-- This comes out of the tech stack 2017, and isn't up for review yet -->

# People and Culture

## Open Source by Default

By the end of 2016, almost every major front-end application at Artsy was [Open Source by Default](http://code.dblock.org/2015/02/09/becoming-open-source-by-default.html). This means looking for reasons for something to be closed-source as opposed to reasons to be open. Our entire working process is done in the open, from developer PRs to QA. This post was also written collaboratively and in the open as you can see [here](https://github.com/artsy/artsy.github.io/pull/325).

Sometimes it makes sense to keep some details private for competitive reasons. We therefore also create a private GitHub repository for front-end teams that require cross-project issues and team milestones. This is done using [ZenHub](https://www.zenhub.com), and is managed by Engineering leads and Product Managers.

## Developer Workflow

Most development workflow tries to mimic large open-source project development where most work happens on forks and is pull-requested into an Artsy repository shared by everyone. Typically an engineer will start a project, application or service and is automatically its benevolent dictator. They will add continuous integration and will ask other engineers on the team to code review everything from day one. Others will join and entire teams may take over. Continuous deployment and other operational infrastructure will get setup early.

In some of our newer apps we have switched to PR based deployments via CIs. In this case, on Artsy's repository, we would have _master_ and _release_ branches where _master_ is the default branch and all the PRs are made to master. Once a PR is reviewed and merged to _master_ it will automatically get deployed on staging. Production deployment is a pull request from _master_ to a _release_ branch, this way we know what commits are going to be deployed in this release. Once merged, CI will automatically deploy the _release_ branch to production.

## Slack

Originally the engineering team used IRC, but in 2015 we switched to Slack and encouraged its use throughout the whole company. We're now averaging about 16,000 Slack messages a day inside Artsy.

Slack usage started out small, but as the Artsy team grew, so did the number of locations where people worked. Encouraging people to move from disparate private conversations in different messaging clients to using slack channels has really made it easier to keep people in the loop. It's made it possible to have the serendipitous collaboration you get by overhearing something important nearby physically.

## Global Engineering 

While most Engineers live in New York, our Engineering team has contributors in Amsterdam, Berlin, Seattle, Minneapolis, Boston and London. We've not shied away from hiring regardless of locations. 

To help people know each-other across the company we developed and open-sourced a [team navigator](https://github.com/artsy/team-navigator). We also facilitate weekly meetings between any three people across the company with a tool called [sup](https://github.com/ilyakava/sup).



> Maybe worth mentioning that most of the channels shared between developers and other people at artsy(specialists, designers, product people, etc) which encourages collaboration and integration of art+technology as well. Also maybe worth mentioning that we have dedicated help channels per product team and well as company wide help channel.
