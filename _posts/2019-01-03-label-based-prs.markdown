---
layout: epic
title: Migrating to PR Label based deployments
date: 2019-01-03
author: [orta]
categories: [build tools, deployment]
---

In the JavaScript world the idea of deploying your libraries on every PR is pretty common. As someone who runs a
dependency manager but comes from the native world, it's easy for me to imagine the strain this puts on NPM's
servers.

However, that is where the eco-system is and it can be really useful. So, we started moving a lot of our libraries
to do this at Artsy too; starting with our most critical dependencies

- Reaction (our React components for many web apps)
- Palette (our design system)

We started off using a commit message based workflow, but have just finished the migrating to a GitHub Label based
workflow that is less workload on individual contributors to these repos. This post will cover how, and why.

<!-- more -->

## Why?

We were using [semantic-release][sem-rel] to handle commit message based deploys. The way this works is in a PR in
which you wanted to trigger a deploy, you would add a commit that had a prefix like
`[PATCH artwork] Fix safari mail issue`.

This is their ideal flow, but the reality for us is that a lot of people would forget to do this, or write commits
like: `[PATCH] bumpity bump`. Even worse, these kind of commits were the perfect reason for pushing to master and
skipping code review to speed things up. We could have added a pre-commit hooks that enforced the messaging on
commits, but that's not very [Minimum Viable Process][mvp] - where we try to map new tool/process improvements to
existing behavior instead of regimenting new behavior when possible.

Instead we re-grouped and tried to come to a conclusion on what could be a better mapping to our existing workflow.
Our answer was: PR Label based deploys.

The idea is: You write a PR exactly as you used to, when you create a new PR then you can either apply a label
saying whether it is a major, minor, patch or trivial PR and when it is merged then deploy could be made for you.

To match our existing behavior completely, we would automatically add the "patch" label to any PR which doesn't
declare what type of deployment it is.

You can see how this was pitched in my RFC ["Change rules around automatic deploys, and add a CHANGELOG"][rfc] on
the topic.

## How?

#### Deployment

We started building this ourselves inside [our app Reaction][pr_1]. Our implementation was a PR that lasted a few
months, and it wasn't a fun ride and didn't really seem to have an end in sight. This changed last week when we
discovered the work going on over at [auto-release][auto-rel] by the team at Intuit.

They had taken the same problem and worked to apply it generically, making it a useful tool for everyone rather
than just for one type of project. Perfect. To try it out, I took our upcoming CLI for the [Artsy Omakase][om] JS
stack - which is a [Lerna][lerna] mono-repo. ( This means it's a single repo for many JS packages, which makes it a
bit more complex than a normal repo for a node project. )

Auto-release handled this setup out-of-the-box, 10/10 - so it was likely to handle our simpler repos. In the
process we made a bunch of PRs back and were quickly iterating on making it work well for Artsy also. Collaborating
on projects like this is our bread and butter, it means we don't have to build tools from scratch and can highlight
great work by others.

To use it, we needed to set up two environment variables:

- `NPM_TOKEN` - used to deploy your package to NPM
- `GH_TOKEN` - used to create GitHub releases

and you need to make sure your CI has write access to your repo, so it can push tags and the CHANGELOG entries back
to your repo.

#### Downsides

Both the commit message and PR label based continuous deployment structure comes with one annoying flaw, if you're
merging many PRs at once - then you can get into trouble with versioning. We've been discussing ideas around this
in the [auto-release issues][ar_iss]. We already had this flaw, so it just propagated to the new technique.

#### Peril

With auto-release you can have set an option to treat no release label as a patch, this is a great setting but an
ideal workflow for us is to showcase what is happening every time. This makes the understanding of our deployments
explicit, and is a good reminder to highlight how you can change the deployment.

We're currently at `9.1.59` - meaning 58 patches in a row, so it's pretty rare for a minor or major. By making it
obvious how to change that during the PR (by highlighting that it's classed as a patch each time) we can maybe make
the version number change a bit closer to reality.

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
    description: "A label to indicate that Peril should merge this PR when all statuses are green"
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
implementation][add_patch] is a bit more complicated because it will create all of the different labels too, so
that it can be consistent across all our repos as we expand this setup.

Introducing auto-release meant introducing our first automatically generated changelog (something I'm not sold on,
I see changelogs as user-facing, but I'm open to giving this a shot as the users are contributors to the repo)
which broke one of our global Peril rules. This rule would detect a if a repo has a changelog, and ask you to
update it if you've made any app changes. We [amended that rule][peril_pr2] to detect auto-release on the repo
first.

## So, how do I get this set up?

For the automatic deployment:

1. Install auto: `yarn add -D auto-release-cli`
2. Run `yarn auto init` and go through the questions
3. Add a `release` script to your `package.json`: `"release": "auto shipit"`
4. In your CI, set both `NPM_TOKEN` and `GH_TOKEN`
5. In your deployment phase run: `yarn release`

For the Peril rule:

1. Add `"pull_request.opened": "artsy/peril-settings@repos/reaction/addPatchLabel.ts"` to your
   `peril.settings.json`

This is a little bit risky, because we can change our implementation anytime. If that's an issue, implement it
yourself in your settings repo. You got this.

You can get the full details for [auto-release in their docs][ar-docs], and you can use both [`artsy/reaction`][ar]
and [`omakase/omakase-js`][om] as references for how to set it up with Circle CI 2.0. I specifically want to call
out [@hipstersmoothie][hs] for their great work on auto-release (and [jimp][].) You did great work here.

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
