---
layout: epic
title: How we designed our Engineering On-Call Process
date: 2018-05-25
author: [sarahweir]
categories: [support, on-call]
---

Over the past few months, we've been working on formalizing an on-call support process for our engineering team. This post details our current state and how we decided what system would work best for us.

<!-- more -->

# Motivation: Why formalize support?

At Artsy we care about building robust, maintainable, and scalable systems. We like to have good test coverage and address regressions when they happen so we can prevent them in the future. For years we supported our systems informally, relying on engineers to notice and address issues as they came up. People tended to monitor apps that they had created (or recently worked on) closely, and that was generally enough to keep our systems running smoothly.

We’ve also seen a couple of team configurations, each with its own effect. When I started at Artsy in 2014, engineers were organized into “practice” teams, meaning the work we did corresponded roughly to the systems we maintained. After that, we organized by “business unit”, meaning there were more teams sharing systems, but non-engineers at Artsy had a clear group of people who they could ask for help. For client-facing systems it was easier to route questions to the right people, but ownership of shared internal systems was less clear.

Our ad-hoc support practice was working, but also had some drawbacks:

1.  Answering support issues took a lot of time/focus away from engineers working on sprint tasks, and this responsibility was not uniformly distributed.
2.  Bugs and maintenance items weren’t always prioritized or worked on consistently.
3.  Knowledge about how systems work or how decisions were made was siloed in individuals or small teams.
4.  Issues related to features that were not “owned” by an obvious product area often went ignored.

We wanted to create a system that would ensure stable, constantly improving services in spite of all of Artsy’s growing and changing.

# Goals/Research

We first identified the goals of our ideal support process:

1.  People who report issues have full confidence that their issue will be resolved, or understand why not.
2.  Engineers feel empowered and able to fix issues and understand when it is their responsibility to do so.
3.  We evolve our systems to require less support and spread knowledge among engineers so there are fewer bottlenecks.
4.  All consumers of Artsy (employees, users, and partners) feel confident that our systems are stable and we will address any issues that arise.

With those goals in mind, we researched both externally (looking at how other companies tackled this common problem) and internally (talking to members of the engineering team and various business/product stakeholders).

Out of this effort, we learned that people had some shared concerns:

* The same few people tended to address most of the support questions, meaning the responsibility was imbalanced.
* People felt wary about the idea of having to answer to support requests from areas they were unfamiliar with.
* People wondered how support duty might fit into their product work.
* People desired a more consistent and accountable process for triaging and prioritizing bug fixes.

We then identified a few potential solutions:

* We could hire or dedicate people to handle support as a full-time job.
* We could have a rotating set of engineers who are exempt from product-related work and tasked with both answering immediate support requests and fixing small bugs or improving the state of our infrastructure/monitoring.
* We could have engineers on an on-call rotation who are responsible for addressing immediate issues but remain engaged with their product team.

# Our Plan

We worked with the product management team to identify an escalation path for different types of issues. At the least-urgent level were basic feature requests, and at the most-urgent were critical bugs or “incidents”. We decided to focus on building out a process whereby certain engineers could be available to address urgent incidents, and other, less-urgent bugs or issues could be triaged and added to teams’ workloads as part of a normal sprint.

Out of the solutions above, we chose the on-call approach where engineers remain part of product sprints but prioritize responding to critical issues. We felt it was important for on-call engineers to stay involved with their team’s ongoing work and also to encourage everyone to share responsibility for our system health.

In order to make the idea of an “on-call” shift concrete and get feedback from the entire engineering team, we put a document up for review that describes the “support plan” in detail. Here’s an abbreviated version of that document:

## Process Overview

Two engineers are on-call each week. The rotating schedule is published in a Google calendar at least a month in advance and engineers are encouraged to trade shifts as necessary.

During work hours, on-call engineers are responsible for responding to issues in our #incidents slack channel. Outside of work hours, they are only responsible for downtime issues.

## On-Call Responsibilities

While on-call, you are accountable for investigating and fixing timely issues, escalating to additional point-people and/or routing to team-specific backlogs where appropriate.

Your top priority during an on-call period is to address critical issues. Use your judgment about joining ongoing sprint and team activities.

1.  Be available to answer requests and respond to immediate issues.
2.  Investigate and address critical issues using documentation and pulling in point-people where necessary.
3.  Track incidents’ status (we track incidents on a Trello board, and if an issue requires attention by a product team we’ll add it to our team’s Jira board).
4.  Improve the support process and resources for the next rotation (this includes our playbooks for fixing issues and docs about the support process).

## Handing Off

We do our handoff after our team-wide standup every Monday. The previous on-call members and the current ones make sure to resolve any outstanding items so the week begins fresh.

# Current State

We're currently in the middle of our first round of on-call shifts and have already had to deal with every edge case/situation we could imagine. The question of "what qualifies as an incident" keeps coming up and we've been steadily refining the process as we go.

As a result of implementing this process, we’ve seen a few wins:

* Since we also archived slack channels that tended to “collect” issues in the past, we’ve successfully consolidated issues into the #incidents channel. Recently, we had a major issue in a shared service that resulted in multiple, disparate effects across our systems. Seeing these all in one place helped us diagnose the underlying problem and provide a consistent message to stakeholders.
* Engineers get to learn about parts of the Artsy ecosystem that they had been previously unfamiliar with. This isn’t trivial and often requires point-people for those systems to help out, but as a result we’ve been able to spread more knowledge and contribute to a shared documentation base.
* In addition to a single intake for critical issues, we have a single intake for minor requests and bugs that get triaged and addressed by our product teams. This means it’s more obvious when the same issue comes up, and since this is part of our same ticketing system we use for new products and features, we know the status at all times.

We've also seen some challenges and identified things to improve on:

* It’s not easy to tell someone that the thing they reported in #incidents isn’t “urgent” or worth looking into.
* We don’t use an external service for scheduling or routing incidents, which means we rely on slack notifications for waking people up at night if there’s an issue. At some point, we may need to make our escalation path a little more robust.
* Given that a potential post in #incidents could wake someone up, we have to be careful about which alerts get piped directly to that channel. Instead of putting every alert there and tuning where necessary, we’ve been trying to elevate alerts opportunistically. The result is we have few alerts going directly to #incidents right now, and most issues are reported by humans.
* Depending on the severity of the on-call week, it can be exhausting. With our open vacation policy and general flexibility with time, people are expected to watch their sanity and take time off as necessary, but in practice people may just end up working extra during their rotation. It would be good to formalize this.
* Scheduling is difficult and still very manual. We have many different factors that affect when someone should be on-call and with whom (such as which team they are on, when they were last on-call, etc.), and it may be worth attempting to automate this in the future.

Our on-call process was born out of research and conversations, but it’s the first time we’ve formalized anything related to support, so it begs to be iterated on. We have a retrospective scheduled for the end of this round and will hopefully be able to adapt based on our changing needs.
