---
layout: epic
title: Deploying canaries with auto
date: 2020-02-20
categories: [tools, road and bridges, packages, npm, node]
author: justin
---

Coordinating changes across many packages in the node ecosystem can be quite the challenge. You can use `npm link`
or `yarn link` to create a symlink of the package you're developing on into another package, but it
[has some drawbacks](https://github.com/yarnpkg/yarn/issues/1761#issuecomment-259706202). If you're doing local
development and need to rapidly see updates and `yarn link` isn't working out there's always tools like
[yalc](https://github.com/whitecolor/yalc#yalc) to help you out. That's really only for local development though.

What if you need to test packages together in a staging environment? Generally the approach would to be to deploy a
[canary](https://martinfowler.com/bliki/CanaryRelease.html) version to npm that you can use in your staging
environment. I'll go over how to do that and how Artsy automates it.

<!-- more -->

Publishing a canary isn't necessarily very hard. It's just a regular publish to npm with a few more steps.

For example, if we were wanting to publish a canary version of `@artsy/reaction`

1. Update `package.json`, set version to a canary version, e.g. `2.0.0-canary-<PR#>`, `3.1.5-canary-<PR#>`, ...
2. Run `npm publish --tag canary` in `reaction` to publish the package under the canary tag
3. Run `yarn add @artsy/reaction@canary` to install canary package in the consuming system

_Tip: Running `npm dist-tag ls` can be helpful to see what tagged packages are available_

For a lot of people, that'd be enough. End blog post. Here at Artsy, we like things to be a little more
frictionless.

We're already big fans of [Auto](https://github.com/intuit/auto), Intuit's tool for automatically deploying
releases on PR merges. Orta wrote an awesome blog post on how we
[migrated to auto](https://artsy.github.io/blog/2019/01/03/label-based-prs/) from semantic-release a while back.

As a short recap, `Auto` makes the deployable units of a package be a PR instead of a commit. It uses labels like
`Version: Major`, `Version: Minor`, etc to determine how the PR will affect the package version. When a PR is
merged it'll automatically cut a released based on that label.

As a testament to how awesome `Auto` is, it already supports
[canary deployments](https://intuit.github.io/auto/pages/generated/canary.html) out of the box!

Essentially when we're on a branch that isn't master our CI runs this command:

```
auto canary
```

and auto takes care of publishing a canary version to NPM _and_ updating the PR description with the version and
instructions on how to use it.

You can [check out the PR](https://github.com/artsy/reaction/pull/3168) where I enabled it on reaction to see it in
action. The CI configuration itself is layered behind some
[CircleCI Orb](https://circleci.com/docs/2.0/orb-intro/)s. You can find all that configuration in
[artsy/orbs](https://github.com/artsy/orbs) if you're curious.

Ultimately the culmination of this work means that every PR to a library at Artsy gets a canary. It's incredibly
simple to test changes in another system now.

There is, however, one caveat. Being as canaries are being deployed to NPM, they need our NPM token. We can't just
share that with everyone, so this functionality doesn't work on forks. Given how CircleCI works, this includes
forks from folks who even have write access to the repository. We're thinking about how to solve that problem but
that'll be another blog post for another day.
