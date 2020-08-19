---
layout: epic
title: Servers for Everyone: Review Apps @ Artsy
date: 2020-08-20
categories: [devops, communication, culture, deployment]
author: daniel
---

<!--

TODO:

- Maybe extract a separate problem section for the distinct, but related, problem
  of a healthy development process for work that needs to accessed on shared server
  before deploying

- Finish out implementation section

-->

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

Reviews apps are really just topic-specific staging environments.

Instead of performing performance testing and other QA tasks for a Node upgrade
on a shared staging environment, given recent investments in our tooling, any Artsy
engineer can deploy such a change to a new review app "server" (Kubernetes
service scaled out to a few pods) given a `git push` to any branch that matches
a certain regex (more on this later).

This enables the engineer to take on the risky task with the space to safely
share work in progress with other technical or non-technical stakeholders
without risking an unsafe or blocked deploy scenario.

How does this all work?

## Solution: Review App Tooling

### Heroku Days

In the beginning, Artsy deployed most applications directly on Heroku.

[Heroku review apps][heroku-review-app-docs] were used on some teams sparingly.

### Enter Kubernetes and Hokusai

For many reasons outside of the scope of this post, Artsy began migrating
services off of Heroku and onto an AWS-backed Kubernetes (K8s) deployment model
starting in [February 2017][introduction-to-hokusai-to-force].

In order to allow application engineers to reasonably interface with K8s-backed
services, Artsy developed a command line interface,
[`hokusai`][hokusai-gh-homepage], to provide a Heroku CLI-like interface for
configuring and deploying these services.

About a year after `hokusai`'s initial release, the tool released [its initial
implementation of review apps][hokusai-review-app-pr].

In essence, via subcommands within the `hokusai review_app` namespace, this
feature enables developers to easily:

* Create the needed K8s YAML configuration file from the existing staging configuration file
* Execute this configuration: creating a running server within a dedicated namespace
* Perform other server management tasks: re-deploying to the server, setting ENV variables, etc.

### Problem: More Steps Needed

While `hokusai`'s official review app feature handles much of the core infrastructure
needed to get a service deployed to new location, additional steps are required
before to have a working review app, which can be categorized into:

1. Service Agnostic Tasks

These include:

- Pushing a Docker image of the Git commit/branch in question to
  the appropriate Docker registery
- Editing the generated YAML configuration file to reference this Docker image
- Sourcing the appropriate ENV variables (typically from the shared staging
  server)

Check out [`hokusai`'s review app docs][hokusai-review-app-docs] for more
details.

2. Service Specific Tasks

In addition, certain services have specific K8s-level needed which require
considerating to build a fully functional review app.

For example, in Force, we need to:

- Publish front-end assets to S3 for the specific revision being deployed, and
- Tweak some ENV variables from the values copied over from the shared staging
  server

before the review app is fully functional.

*Net Effect*: Due to the manual labor required to (re)-learn and execute the
commands needed to build a review app, they were used sparingly by a few engineers
that already invested time in learning up on them.

### Solution: A bash script

While these tasks described above are tedious, they don't really require a
decision-making human behind the computer and are automatable.

In August 2019, I took an [initial stab][force-review-app-pr] at a Bash script for Force that
executes these commands.

*Net Effect*: A developer is able take a Force commit and get it deployed to K8s
by running a single script on their laptop. Folks became excited about review
apps and started to use them more for Force development.

### Problem: Depending upon a developer's laptop doesn't scale

The increased excited and usage of review apps in Force revealed a new problem:

Building and pushing >1 GB Docker image across WiFi networks can be incredibly
slow, decreasing the usefulness and adoption of the Bash script.

### Solution: Run the bash script on CI

After discussions within Artsy's Platform Practice, we thought of solution to
the problems introduced by running this Bash script locally: build the review
app by running this Bash script on CircleCI upon push to a branch starting with
`review-app`.

This means that a developer's laptop is then only reponsible for pushing a commit
to a branch (which laptops and home networks re :ok-hand: at) and let's CircleCI
do all the heavy lifting.

Moreover, the process of centralizing the review app creation into CI triggered
by Git branching helped us realize the subsequent dev UX feature: updating, and
not creating, review apps when a review app alreay exists for a given branch.

Nothing some more Bash and CircleCI configuration couldn't handle.

Check out the [pull request][review-app-on-circle-pr] for the nitty gritty.

*Net Effect*: Any developer can spin up a Force review app in ~15 minutes. Review
app are being used often for major and minor changes alike.

[heroku-review-app-docs]:https://devcenter.heroku.com/articles/github-integration-review-apps
[introduction-of-hokusai-to-force]:https://github.com/artsy/force/pull/953
[hokusai-gh-homepage]:https://github.com/artsy/hokusai
[hokusai-review-app-pr]:https://github.com/artsy/hokusai/pull/62
[hokusai-review-app-docs]:https://github.com/artsy/hokusai/blob/master/docs/Review_Apps.md
[force-review-app-pr]:https://github.com/artsy/force/pull/4412
[review-app-on-circle-pr]:https://github.com/artsy/force/pull/5370
[example-force-deploy-pr]:
