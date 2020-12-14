---
layout: epic
title: Migrating to PR Label based Continuous Deployment
date: 2019-01-03
author: [orta]
categories: [build tools, deployment, road and bridges]
comment_id: 515
---

In the JavaScript world, the idea of deploying your libraries on every PR is pretty common. As someone who runs a
dependency manager but comes from a native background, it's easy for me to cringe and imagine the strain this puts
on NPM's servers. However, that is where the ecosystem is and [continuous deployment][cd] can be really useful. So,
about a year ago [we started][add_sr] moving a lot of our libraries to do this at Artsy too. Starting with our most
critical dependencies:

- [Reaction][ar] (our React components used in many of our web apps)
- [Palette][pl] (our [design system][ds])

We started off using a commit message based workflow, but have just finished the migrating to a GitHub Label based
workflow that is less workload on individual contributors. This post will cover how, and why.

<!-- more -->

## Why?

We started using [semantic-release][sem-rel] to handle commit message based deploys. The way semantic-release works
is you would add a specially formatted commit that included a version prefix indicating you wanted a deploy. For
example, `[PATCH artwork] Fix safari mail issue` would mean that by merging a PR with this commit into master
should trigger a patch release.

This is their ideal flow, but the reality for us is that a lot of people would forget to do this, or write commits
like: `[PATCH] bumpity bump`. Even worse, these kind of commits were the perfect reason for pushing to master and
skipping code review to speed things up.

We could have added a pre-commit hooks that enforced the messaging on commits, but that's not very [Minimum Viable
Process][mvp] - where we try to map new tool/process improvements to existing behavior instead of regimenting new
behavior when possible.

The problem felt like the idea of declaring your version changes at commit time felt like a disconnect from how
people thought about deploys. The code unit for a review is a Pull Request, not per-commit. To try improve on our
deployment, we re-grouped and discussed what could be a better mapping to our existing workflow. Our answer was: PR
Label based deploys.

The idea is: You write a PR exactly as you used to, when you create a new PR then you apply a label saying whether
it is a major, minor, patch or trivial PR and when it is merged then deploy could be made for you.

To match our existing behavior completely, we would automatically add the "patch" label to any PR which doesn't
declare what type of deployment it is up-front.

I summarized our ideal state, and turned it into an RFC on our Reaction repo: ["Change rules around automatic
deploys, and add a CHANGELOG"][rfc] .

## How?

#### Deployment

We started building this infrastructure inside [our app Reaction][pr_1]. Our implementation was a PR that lasted a
few months. It was a hard project to prioritize, and didn't really seem to have an end in sight. This changed last
week when we discovered the work going on over at [auto-release][auto-rel] by the team at [Intuit][int].

The team at Intuit had taken the same problem and worked to apply it generically, making it a useful tool for
everyone rather than just for one type of project. Perfect.

To try it out, I set it up on our upcoming CLI for the [Artsy Omakase][om] JS stack - which is a [Lerna][lerna]
mono-repo. This means it's a single repo for many JS packages, which makes it a bit more complex than a normal repo
for a node project.

Auto-release handled this setup out-of-the-box, `10/10` - so it was likely to handle our simpler repos. In the
process we made a bunch of PRs back and were quickly iterating on making it work well for Artsy also. Collaborating
on projects like this is our [bread and butter][own-deps], it means we don't have to build tools from scratch and
can improve upon great work by others.

To use it, we needed to set up two environment variables:

- `NPM_TOKEN` - used to deploy your package to NPM
- `GH_TOKEN` - used to create GitHub releases

and you need to make sure your CI has write access to your repo, so it can push tags and the CHANGELOG entries back
to your repo.

#### Downsides to Continuous Deployment

Both the commit message and PR label based continuous deployment structure comes with one annoying flaw, if you're
merging many PRs at once - then you can get into trouble with versioning. We've been discussing ideas around this
in the [auto-release issues][ar_iss]. We already had this flaw, so it just propagated to the new technique. We've
been wondering if deploying via [GitHub actions][actions] may fix this.

#### Peril

With auto-release you can have set an option to treat having no release label on your PR as a being a "patch"
release. This is a great setting, but an ideal workflow for us is to showcase what is happening every time. This
makes the understanding of our deployments explicit, and is a good reminder to highlight that you might want to
change the type of deployment. You can see this happening to me [in this PR][dont_deploy].

We're currently at `9.1.59` - meaning 58 patches in a row, so it's pretty rare for a minor or major. By making it
obvious how to change that during the PR (by highlighting that it's classed as a patch each time) we can maybe make
the version number change a bit closer to _some form_ of "semantic reality".

We wanted to first roll this out on one repo, so we scoped [our Artsy Peril changes][peril_pr] to just the
`artsy/reaction` repo

```diff
{
  "rules": {
    // Keep a list of all deployments in slack
    "create (ref_type == tag)": "org/newRelease.ts",
    ...
  },
  "repos": {
    "artsy/reaction": {
      "pull_request": "danger/pr.ts",
+     "pull_request.opened": "artsy/peril-settings@repos/reaction/addPatchLabel.ts"
    },
    "artsy/force": {
      "pull_request": "dangerfile.ts"
    },
    ...
  },
}
```

The simplest implementation for adding the label is this:

```js
// repos/reaction/addPatchLabel.ts
//
export default async () => {
  const pr = danger.github.pr

  const patchLabelName = "Version: Patch"
  const requiredPrefix = "Version: "

  // Someone's already made a decision on the version
  const hasAlreadyGotLabel = danger.github.issue.labels.find(l => l.name.startsWith(requiredPrefix))
  if (hasAlreadyGotLabel) {
    console.log(`Skipping setting the patch label, because the PR author already set one.`)
    return
  }

  // Create or add the label if it's not being used
  const label = {
    name: patchLabelName,
    color: "247A38",
    description: "Indicates that you want this PR to trigger a patch release"
  }

  const repo = {
    owner: pr.base.user.login,
    repo: pr.base.repo.name,
    id: pr.number
  }

  console.log("Adding the label:", label.name)
  await danger.github.utils.createOrAddLabel(label, repo)
}
```

This will dynamically add your label if it doesn't exist on the repo yet. Our [production
implementation][add_patch] is a bit more complicated because it will create all of the different labels too. This
means as we roll out the PR Label based workflow to other repos, the labels will be consistent.

Introducing auto-release meant introducing our first automatically generated changelog (something I'm not sold on,
I see changelogs as consumer-facing. Most PR title/descriptions aren't aimed at downstream consumers, but I'm open
to giving this a shot as today the consumers are also contributors to the repo) which broke one of our global Peril
rules. This rule would detect a if a repo has a changelog, and ask you to update it if you've made any app changes.
We [amended that rule][peril_pr2] to detect auto-release on the repo first.

## So, how do I get this set up?

For the automatic deployment:

1. Install auto: `yarn add -D auto-release-cli`
2. Run `yarn auto init` and go through the questions
3. Add a `release` script to your `package.json`: `"release": "auto shipit"`
4. In your CI, set both `NPM_TOKEN` and `GH_TOKEN`
5. Add `echo "//registry.npmjs.org/:_authToken=$NPM_TOKEN" >> ~/.npmrc` to "log in" to NPM in our deploy steps
6. In your deployment phase run: `yarn release`

For the Peril rule:

1. Add `"pull_request.opened": "artsy/peril-settings@repos/reaction/addPatchLabel.ts"` to your
   `peril.settings.json`

This is a little bit risky, because we can change our implementation anytime. If that's an issue, implement it
yourself in your settings repo. You got this.

You can get the full details for [auto-release in their docs][ar-docs], and you can use both [`artsy/reaction`][ar]
and [`omakase/omakase-js`][om] as references for how to set it up with Circle CI 2.0.

To wrap this up, I specifically want to call out [@hipstersmoothie][hs] for their great work on auto-release (and
[jimp][].) It's been really easy to get started and already covered nearly all the cases we needed. You did great
work here.

<!-- prettier-ignore-start -->
[add_patch]: https://github.com/artsy/peril-settings/blob/db492b5f9213faee3e5d8659c55b84c635240f0c/repos/reaction/addPatchLabel.ts
<!-- prettier-ignore-end -->

[mvp]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#minimal-viable-process
[sem-rel]: https://semantic-release.gitbook.io/semantic-release/
[auto-rel]: https://github.com/intuit/auto-release#readme
[ar]: https://github.com/artsy/reaction#readme
[rfc]: https://github.com/artsy/reaction/issues/1095
[pr_1]: https://github.com/artsy/reaction/pull/1407
[om]: https://github.com/omakase-js/omakase#readme
[lerna]: https://github.com/lerna/lerna#readme
[peril_pr]: https://github.com/artsy/peril-settings/pull/88
[peril_pr2]: https://github.com/artsy/peril-settings/pull/89
[ar-docs]: https://intuit.github.io/auto-release/
[jimp]: https://github.com/oliver-moran/jimp
[hs]: https://github.com/hipstersmoothie
[pl]: https://github.com/artsy/palette#readme
[cd]: https://github.com/artsy/reaction/issues/388
[add_sr]: https://github.com/artsy/reaction/pull/521
[ds]: https://palette.artsy.net
[int]: https://github.com/intuit/
[own-deps]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#own-your-dependencies
[actions]: https://github.com/features/actions
[dont_deploy]: https://github.com/artsy/reaction/pull/1787
