---
layout: epic
title: "The Checklist for Deploying a Scary Change"
subtitle: "What to expect when you're expecting to break things"
date: 2023-09-13
categories: [Ruby on Rails, data migrations, deploy process]
author: [matt-dole]
comment_id: 754
---

Lately, I've been getting involved with some sketchy stuff. You know what I'm
talking about–data migrations.

I've been rolling out changes that have a significant risk of breaking our
production environment for mission-critical services. It's been exciting work
(keep your eyes out for more posts on the exact project, coming soon™️), but
I've definitely caused a couple incidents along the way.

After accidentally taking down a key service for a couple hours, I decided I
needed to have a better pre-deploy process for these changes. I did some
thinking and came up with a short checklist to run through before I press the
shiny green button.

<!-- more -->

Here's the checklist I came up with:

- [ ] What is your plan if something goes wrong?
  - [ ] Run through ramifications of rolling back. If there's a reason you're
        worried about rolling back, then you're not ready to deploy the change
        yet!
  - [ ] Figure out exactly what command(s) you will need to run to roll back. At
        Artsy, this is usually a
        [one-liner using Hokusai](https://github.com/artsy/hokusai/blob/main/docs/Command_Reference.md#how-to-do-a-rollback),
        our command-line Docker/Kubernetes CLI
- [ ] How will you tell if something is going wrong after you deploy?
  - [ ] Error rate (DataDog)
  - [ ] Specific error reporting (Sentry)
  - [ ] Latency (DataDog)
  - [ ] Logs (Papertrail)
  - [ ] Functionality (does it still work? Are people using it successfully?
        Important for things where errors may not be bubbled up correctly or
        reported immediately)
  - [ ] Sidekiq (are there lots of jobs queued to retry that are failing?)

With this checklist in hand, I'm deploying more confidently and causing fewer
incidents along the way.

Do you have something similar? Are there things you think this checklist should
include? Let me know in the comments!
