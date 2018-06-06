---
layout: epic
title: "My First Week On Call"
date: 2018-05-30
author: [ash]
categories: [team, people, best practices, culture]
---

As I write this, I have completed my first ever engineering on-call rotation at Artsy, so naturally I had to write a blog post about some of the things I learned.

<!-- more -->

A year ago, I would have been terrified to be one of two engineers responsible for handling everything from re-sending automated emails to fixing total site outages, but [I have grown a lot](https://ashfurrow.com/blog/perspective-of-the-polyglot/) so being on-call was only _regular_-level intimidating. And indeed, with supportive documentation and a good partner, I didn't experience any situations where I felt truly lost about what to do next.

But I did learn a few things. So let's discuss a few things that weren't immediately obvious to me.

## Ignore My Instinct to Fix Things Right Away

This sounds really counterintuitive, right? I mean, a server is down, let's reboot it so it's up again! It's got a little red X next to it in AWS, let's make it a green checkmark again! I want that checkmark!

But that's not always the best course of action. Sometimes, fixing something right away would deprive us of the opportunity to figure out _why_ it broke in the first place. For example: we had Rails servers running out of disk space, and rebooting those servers would have refreshed their drives and fixed the problem, but one of our platform engineers asked me to wait so they could ssh in and examine the contents of the filesystems. In the mean time, the load balancer had already routed traffic around the servers, so there was no need to rush to fix anything.

My instinct to fix things right away was at odds with the team's desire to understand why something broke.

## What is an Incident, Even?

One thing became really clear to be, really quickly: people have many different, valid perspectives on what an "incident" is. Our support documentation goes into detail about what our responsibilities as on-call engineers are responsible for, and what should be routed through product teams to be prioritized, but my support partner and I still hit cases where we weren't quite sure if we should take action.

Sometimes, issues of critical importance were brought to our #incidents Slack channel, but weren't _really_ incidents, from an Engineering perspective. We erred on the side of helping our colleagues, but it's difficult. I want to help people! But I also have responsibilities. Balancing the two is a skill every engineer has to develop, and being on-call highlighted the importance of balance in a new way for me.

My first ever jobs were retail, where I helped rural Canadians learn to use their first ever cell phones, and IT helpdesks; both taught me how to handle support requests in a way that makes the other person feel like things are going to be okay. I had to reapply those skills when on-call because sometimes what people were bringing to my attention fell outside the scope of an "incident". Consider the response:

> What you've reported isn't an incident, talk to your PM.

... and contrast it with:

> This falls outside the scope of immediate support, so I've opened a ticket for you. You can talk to the team PM about prioritization.

This kind of reply also aligns with Artsy's [values](https://github.com/artsy/meta/blob/master/meta/what_is_artsy.md#artsy-values) of **Positive Energy** and **People are Paramount**. Everyone working at Artsy is here to make art a bigger part of culture, and that shared understanding helped.

## We Need to Improve our Automated Alerts

For a few months now, Artsy Engineering has been discussing how to consolidate our automated alerts. I somehow got it in my head that anything in our #alerts channel needed immediate engineer attention, when in fact, our #alerts channel is often noisy. By the final day of my rotation, I learned that not everything needed immediate attention.

That's a bit of a problem. There are alerts that need immediate intervention ("the API servers are all down") and there are alerts that need no intervention ("this server is responding slowly, oh wait, it's back to normal, never mind"), and then there are the tricky ones: the ones that need _eventual_ intervention ("gosh, our image processing API out of disk space for the third time in a month, we need to look into that"). Figuring out how to sort mid-level, important-but-not-urgent automated alerts from critical ones will be a critical part of our long-term support process.
