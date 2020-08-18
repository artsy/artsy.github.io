---
layout: epic
title: Servers for Everyone: Review Apps @ Artsy
date: 2020-08-20
categories: [devops, communication, culture, deployment]
author: daniel
---

This blog post:

1. Details some problems that review apps attempt to solve.
1. Details how Artsy implements review apps, the history of our tooling and where
   we might go from here.

<!-- more -->

 -- consider striking --
## So what's a review app?

Popularized by [Heroku][heroku-review-app-docs], review apps refer to deployment
targets (think staging, production) that are:

1. Not staging or production
1. Are as usable as staging or production
1. Temporary

Concretely, a review app for a website (say, www.artsy.net) would manifest as
a website (say review.artsy.net or www.artsy-review.net) that is accessible for a
limited period of time. It will look and feel just like www.artsy.net, except for
the specific changes that we are "review"-ing!

## Wait, but why?

Sounds like another thing to think about? Why should I deal with these review app
app things?

Great question!
-- consider striking --

### Problem: A Single Shared Staging Environment

At Artsy, we have a sizable engineering organization: ~40 engineers organized
across many teams. Engineers on those teams work on many codebases, some are
exclusive to a team, but many codebases are worked on by engineers across many
teams. Artsy's website (www.artsy.net), Force, is a good example of such a shared
service.

These different teams of developers working on a shared service have (mostly
hidden) dependencies upon each other, most visible when a shared service is being
deployed to production.

Let's work the following example:

- Team A is hard at work finishing up a new feature (say a new search
  page for a list of art auctions) on Service S and is now doing a final round
  of QA before deploying to production.
- Team B is fixing a bug in an unrelated part of Service S.
- Team B confirmed that the bug was squashed on staging
- Team B deploys Service S to production.

Artsy's production deployment flow is rooted in a GitHub Pull Request, meaning
that the commits that differ between staging (on the `staging` Git branch) and
production (on the `release` Git branch) are clear to whomever is managing a
deploy ([example][example-force-deploy-pr]).

While it's great that our deploys are easy to understand, ensuring that a deploy
of a service is safe _requires communicating with all teams involved to ensure
their work is "safe to deploy"_.

"Safe to deploy" might mean different things depending on the nature of the
work.

For example, Team A's new list of art auctions might require an API endpoint in
another service to be deployed for the their part of the deploy of Service S to
be safe to deploy. Team B's bugfix might just requires a quick visual confirmation.

Suffice to say, it's _hard to independently confirm that another team's work is
safe to deploy_.

#### Mitigation Strategies

There are a couple of ways Artsy mitigates against the possible pitfalls of a
shared staging environment:

1. Having a culture of quickly deploying code to production

By building a culture that views frequent deploys positively, there's, on average,
less diff in every deploy, mitigating the risk of unintentionally deploying code
that's not safe to deploy.

2. Communicating deploys

When deploying a service, Artsy engineers typically send a message to our #dev
Slack channel notifying of their plan to deploy a particular service, cc'ing the
engineers that are involved in other PRs that are part of the deploy. In the example
above, an engineer on Team B would notify relevant stakeholders of Team A, giving
that team the opportunity to flag if their work is not yet safe to deploy.

Semi-unstructured communication is prone to breakdown: the notified engineers
on Team A might be pairing or in a meeting and Team B deploys anyways.

Moreover, _some work really needed to be deployed to a shared server to
determine its safety/completeness_: think re-designs of existing pages or large
overhauls of system internals (i.e. a Node upgrade).

*These types of changes are typically risky enough already -- the added risk of
having a single deploy target that is not production magnifies that risk of:

1. Deploying such a change before it's safe, or
2. Blocking other teams from deploying other, safe, changes to production while
the risky change is being assessed.*

Reviews apps are really just other topic-specific staging environments.

Instead of performing performance testing and other QA tasks for a Node upgrade
on a shared staging environment, given recent investments in our tooling, any Artsy
engineer can deploy such a change to a new review app "server" (Kubernetes
service scaled out to a few pods) given a `git push` to any branch that matches
a certain regex (more on this later).

This enables the engineer to take on the risky task with the space to safely share work in progress
with other technical or non-technical stakeholders without risking an unsafe or blocked deploy scenario.

How does this all work?

## Solution: Review App Tooling

TBD - description of Artsy's history of review apps: pre hokusai, post hokusai,
force bash script, git based automation, organic growth to other services.

[heroku-review-app-docs]:https://devcenter.heroku.com/articles/github-integration-review-apps
[example-force-deploy-pr]:
