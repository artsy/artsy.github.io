---
layout: epic
title: "Servers for Everyone: Review Apps @ Artsy"
date: 2020-08-21
categories: [devops, hokusai, kubernetes, communication]
author: daniel
---

This blog post is going to motivate and describe Artsy's adoption and evolution
of the usage of review apps.

This first part of this post covers a couple of common problems where
topic-specific servers (i.e. review apps) are useful.

The rest of the post describes Artsy's history with review app automation via
incremental problem solving and the composition of a few well-known technologies.

<!-- more -->

## Problem 1.0: A Single Shared Staging Environment

At Artsy, we have a sizable engineering organization: ~40 engineers organized
across many teams. Engineers on those teams work on many codebases, some are
exclusive to a team, but many codebases are worked on by engineers across many
teams. Artsy's website (www.artsy.net), [Force][force-homepage], is a good example of such a shared
service.

These different teams of developers working on a shared service have (mostly
hidden) dependencies upon each other, most visible when a shared service is being
deployed to production.

Let's work the following example:

- Team A is hard at work finishing up a new feature (say a new search
  page for a list of art auctions) on Service S and is now doing a final round
  of QA before deploying to production
- Team B is fixing a bug in an unrelated part of Service S
- Team B confirms that the bug was squashed on staging
- Team B deploys Service S to production

Artsy's production deployment flow is rooted in a GitHub Pull Request, meaning
that the commits that differ between staging (on the `staging` Git branch) and
production (on the `release` Git branch) are clear to whomever is managing a
deploy ([example][example-force-deploy-pr]).

While it's great that our deploys are easy to understand, ensuring that a deploy
of a service is safe _requires communicating with the teams that contributed
code to ensure that their work is "safe to deploy"_.

"Safe to deploy" might mean different things depending on the nature of the
work.

For example, Team A's new list of art auctions might require an API endpoint in
another Service Z to be deployed for their part of the deploy of Service S to
be safe to deploy. Team B's bugfix might just requires a quick visual confirmation.

Suffice to say, it's _hard to independently confirm that another team's work is
safe to deploy_.

Despite the mitigation strategies discussed next, there's risk of deploying unsafe
code whenever a single staging environment is used across many teams.

#### Shared Staging Mitigation Strategies

There are a couple of ways Artsy mitigates against the possible pitfalls of a
shared staging environment:

1. Having a culture of quickly deploying code to production

	By building a culture that views frequent deploys positively, there's, on average,
less diff in every deploy, mitigating the risk of unintentionally deploying code
that's not safe to deploy.

2. Using automated quality processes geared towards a stable staging environment

	We do our best to feel as confident as possible in a change _before it is deployed
	to staging_ by creating automated tests for changes, sharing visual changes over
	Slack and in PRs, and other strategies relevant to the work at hand.

3. Communicating deploys

	When deploying a service, Artsy engineers typically send a message to our #dev
Slack channel notifying of their plan to deploy a particular service, cc'ing the
engineers that are involved in other PRs that are part of the deploy. In the example
above, an engineer on Team B would notify relevant stakeholders of Team A, giving
that team the opportunity to flag if their work is not yet safe to deploy.

While these strategies are impactful:

- Semi-unstructured communication is prone to breakdown: the notified engineers
  on Team A might be pairing or in a meeting and Team B deploys anyways.

- Without a true continuous delivery model, it's a challenge to operationalize
  very frequent production deploys. Moreover, the problem compounds as the team
  grows and the velocity of work increases.

- Particularly when working in a large distributed system, automated testing at
  the individual service level can only provide a certain level of safety for a
  change. Visual changes which require correctness on different viewports and devices
  are, pragmatically, often best to test manually.

If only there was a way to allow Team A and B to work without risking stepping
on each other toes!

We'll discuss how review apps provide this safety, but first another related
problem.

## Problem 2.0: Complex Work Needs Many Eyes

But before it gets better, it's going to get a bit worse.

While working on any mature distributed system is a challenge, some work is
particularly challenging or risky. Generally, risk is reduced when many
skilled eyes can review the risky thing in an environment that closely mimics
the production environment.

This class of work might include changes to authorization flows, page
redesigns or infrastructural upgrades (e.g. a NodeJS upgrade).

For example, to feel safe deploying [a major version upgrade of Artsy's design
system in Force][styled-systems-upgrade-pr] the most pragmatic way forward was
to deploy that PR to a server where other engineers could collaborate on QA.

*If a single shared staging environment is the only non-production server to
deploy to, the chances that work lands on staging in an unsafe state is high*. While
staging being unsafe isn't _itself_ a bad thing, many bad things can result:

1. [Bad] Blocked Deploys

	If staging is unsafe and this dangerous state is discovered, then top priority
is getting a service back into a safe state. While working to get a service
back to a healthy state, new features can't be delivered.

	In aggregate, this can be a sizeable productivity loss.

2. [Worse] Unsafe Deploys

	If staging is unsafe and this dangerous state is not discovered before a production
deploy (for example, the unsafe code might be from another team, as described above),
then end-users might interact with a service that just isn't working. No good.

3. [Terrible] Fear

	> Fear is the mind-killer.
	[Dune][dune-fear-quote]

	Alright, a bit over the top, but the risk of unsafe or blocked deploys can
implicitly or explicitly result in teams shying away from complex work.

	This avoidable fear might result in increased technical debt or not taking on
certain projects.

	It's generally bad for business and does not lead to a pleasant work environment!

## Problem Recap & Review App Introduction

To recap, there is an increased risk of unsafe or blocked deploys whenever there
is a single staging environment for a shared service. Certain types of
(incredibly useful) changes require interactive review on a live server
before we feel comfortable with those changes, which magnifies the risk of a unsafe or
blocked deploy.

Review apps are simply other staging environments that are easy to spin up and
are deployed with the version of the service that you are working on.

By QA-ing on a review app instead of a shared staging environment, teams can
take their time ensuring the safety of their changes, removing the risks
detailed above.

Larger infrastructure upgrades (including upgrades to the
underlying K8s configuration, in addition to app-level changes) can sit on a
server for hours or days, allowing any slow-moving issue to show itself in a
lower risk environment.

Artsy has iterated on its review app tooling to the point where Team A and Team B
can each deploy their changes to isolated servers of our main website, Force,
on a single `git push` to a branch matching a naming convention.

The rest of this post describes Artsy's evolution of its review app tooling
and areas for continued improvement.

## Review App Tooling

### Heroku Days

In the beginning, Artsy deployed most services on Heroku. There were fewer engineers
and teams, so the engineering organization was less impacted by the problems described above.

[Heroku review apps][heroku-review-app-docs] were used on some teams sparingly.

### Enter Kubernetes and Hokusai

For many reasons outside of the scope of this post, Artsy began migrating
services off of Heroku and onto an AWS-backed Kubernetes (K8s) deployment model
starting in [February 2017][introduction-of-hokusai-to-force].

In order to allow application engineers to reasonably interface with K8s-backed
services, Artsy developed a command line interface,
[`hokusai`][hokusai-gh-homepage], to provide a Heroku CLI-like interface for
configuring and deploying these services.

Check out some [prior][related-bp-1] [posts][related-bp-2] discussing the experience of working with Kubernetes
and `hokusai`.

About a year after `hokusai`'s initial release, the tool released [its initial
support for review apps][hokusai-review-app-pr].

Via subcommands within the `hokusai review_app` namespace, developers were able to:

* Create the needed K8s YAML configuration file from an existing staging configuration file
* Execute this configuration: creating a running server within a dedicated namespace
* Perform other server management tasks: re-deploying to the server, setting ENV variables, etc

### Problem: More Steps Needed

While `hokusai`'s official review app feature handles much of the core infrastructure
needed to get a service deployed to a new server, additional tasks are required
to have a working review app, which can be categorized into:

1. Service Agnostic Tasks

	These include:

	- Pushing a Docker image of the Git revision in question to the appropriate
	  Docker registry
	- Editing the generated YAML configuration file to reference this Docker image
	- Sourcing the appropriate ENV variables (typically from the shared staging
	  server)

	Check out [`hokusai`'s review app docs][hokusai-review-app-docs] for more
	details.

2. Service Specific Tasks

	In addition, certain services have service-specific operational requirements that
	need to be met before a review app is fully functional.

	For example, in Force, we need to:

	- Publish front-end assets to S3 for the specific revision being deployed, and
	- Tweak some ENV variables from the values copied over from the shared staging
	  server


**Impact**: Due to the manual labor required to (re)-learn and execute the
commands needed to build a review app, they were used sparingly by a few engineers
that already invested time in learning up on them.

### Solution: A bash script

While these tasks described above are tedious, they don't really require a
decision-making human behind the computer and can be automated.

In August 2019, we [automated][force-review-app-pr] these tasks via a Bash script.

**Impact**: A developer is able take a Force commit and get it deployed to K8s
by running a single script on their laptop. Folks became excited about review
apps and started to use them more for Force development.

### Problem: Depending upon a developer's laptop doesn't scale

The increased excitement and usage of review apps in Force revealed a new problem:

Building and pushing >2 GB Docker image across home WiFi networks can be incredibly
slow, decreasing the usefulness and adoption of the Bash script.

### Solution: Run the bash script on CI

After discussions within Artsy's Platform Practice, a possible solution
emerged: build the review app by running this Bash script on CircleCI upon push
to a branch starting with `review-app`.

This means that a developer's laptop is then only responsible for pushing a
commit to a branch and CircleCI does all the heavy lifting.

Moreover, the process of centralizing the review app creation into CI helped us realize
the subsequent requirement: updating, not creating, review apps when a review app
already exists for a given branch.

Check out the [pull request][review-app-on-circle-pr] for the nitty gritty on how
we leveraged CircleCI branch filtering and more Bash to move this workload into
CircleCI and intelligently determine when to update or create a review app.

**Impact**: Any developer can spin up a Force review app in ~15 minutes on a `git push`.
Review app are being used often for major and minor changes alike.

## Future Iterations

Artsy has come far with its tooling for review applications, but, as always,
there's areas for us for to grow in, including:

1. Automating the de-provisioning of review apps that no
   longer useful.

2. Automating the creation of DNS CNAME records within Cloudflare, removing one
   final manual step.

3. While the improvements to review app infrastructure has sparked similar
   investments in other codebases, there's a lot of work we could do to bring
   this Git-CircleCI-Bash based approach to other shared services we deploy at
   Artsy.

## On Incremental Improvement

One of Artsy's Engineering Principles is ["Incremental
Revolution"][artsy-eng-principles], which begins with:

> Introduce new technologies slowly and incrementally.

I think Artsy's approach to review apps is a great example of this principle
implemented.

As opposed to finding a silver bullet technology or strategy, our approach has
been to build off of a working current state, layering on a new component to
solve the next problem.

At each point along our solution journey, we're left with a working and more valuable
solution to the problem at hand.

Thanks for reading!

[heroku-review-app-docs]:https://devcenter.heroku.com/articles/github-integration-review-apps
[introduction-of-hokusai-to-force]:https://github.com/artsy/force/pull/953
[hokusai-gh-homepage]:https://github.com/artsy/hokusai
[hokusai-review-app-pr]:https://github.com/artsy/hokusai/pull/62
[hokusai-review-app-docs]:https://github.com/artsy/hokusai/blob/master/docs/Review_Apps.md
[force-review-app-pr]:https://github.com/artsy/force/pull/4412
[review-app-on-circle-pr]:https://github.com/artsy/force/pull/5370
[styled-systems-upgrade-pr]:https://github.com/artsy/force/pull/5697
[dune-fear-quote]:https://www.goodreads.com/quotes/2-i-must-not-fear-fear-is-the-mind-killer-fear-is
[artsy-eng-principles]:https://github.com/artsy/README/blob/master/culture/engineering-principles.md#incremental-revolution
[example-force-deploy-pr]:https://github.com/artsy/force/pull/6106
[force-homepage]:https://github.com/artsy/force
[related-bp-1]:https://artsy.github.io/blog/2019/10/18/kubernetes-and-hokusai/
[related-bp-2]:https://artsy.github.io/blog/2018/01/24/kubernetes-and-hokusai/
