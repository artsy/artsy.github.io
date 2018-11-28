---
layout: epic
title: Keeping Artsy's dependencies up to date
date: 2018-11-26
author: justin
categories: [best practices, dependencies, javascript, node, roads and bridges]
---

Hey everyone! I'm Justin, a senior engineer here at Artsy. I've been here for about 6 months and I'm a bit overdue
on my first blog post. This will be one of a series of posts I'm dubbing _roads and bridges_ ([thanks Orta][rnb])
describing infrastructure and tooling work here at Artsy.

### Backstory

Here at Artsy we have a lot of internal dependencies. Keeping these dependencies up to date across all of our
projects can be a bit of a headache. For example, there's [Palette][palette] (our [design system][design-system])
which is consumed by [Reaction][reaction] (our react component/app library), [Emission][emission] (our React Native
application), [Force][force] (our main site), and [Positron][positron] (our editorial creation tool). That's not
even an exhaustive list. As you can imagine, after making an update to [Palette][palette] we have to make a lot of
Pull Requests to get everything synced up across our many projects. And that's just _one_ dependency.

<!-- more -->

### Evaluating the problem

There are a few services out there that connect to GitHub and helps you keep your dependencies up to date. I'd
personally used [Greenkeeper][greenkeeper] in the past and it seemed to work fairly well for my uses. I'd also
heard about [Renovate][renovate] which is another option that actually supports more package managers than just
yarn/npm. Great! Plenty to evaluate here. Anytime I'm evaluating a new service there are a few questions I ask
myself upfront to help a good decision:

1. What are my exact needs
2. Can this solution scale to meet future needs

The first point is straight-forward, but there's a little twist. We have a _lot_ of dependencies. If we got PRs for
all of them we'd be pretty much unable to do anything. In this case we wanted to specifically limit it to packages
that are published by Artsy (on the `@artsy` npm namespace).

The second you have to be a bit careful with. Don't try to project too far or you'll end up choosing a solution far
too complex for your current needs. In this case, I wanted something that we could selectively extend in the future
to cover other dependencies. Things like `react` and `react-dom` or `typescript`. Incremental increases without a
ton of noise.

### Picking a solution

First things first... we have to have a solution that can update only Artsy's dependencies. I started digging
through [Greenkeeper][greenkeeper]'s docs and found a reference to an [ignore][greenkeeper-ignore] option.
Essentially any package that you don't want [GreenKeeper][greenkeeper] to automatically update you can put in this
ignore list. That's not really doable in our usecase because we want to ignore everything but a small subset of
packages.

Checking out [Renovate][renovate]'s docs I found a more promising option:
[excludePackagePatterns][renovate-exclude]. All I really want to do is include Artsy packages, but this sounded
like I could do the inverse by excluding all non-Artsy packages. Being as it had that option, supported more
package managers, and had a more friendly pricing scheme than [Greenkeeper][greenkeeper] I decided to give
[Renovate][renovate] a shot.

### Making it happen

I began by enabling [Renovate][renovate] on [Force][force]. You can see the PR [here][renovate-pr].
[Renovate][renovate] has a _really_ excellent on-boarding experience. It first creates a PR that adds its own
configuration. It shows you what packages will be updated based on that configuration. As you update the config,
Renovate will update the PR body to show you the results of your changes. This gives you the opportunity to update
the configuration before it officially activates. If you click the edited dropdown on the PR body you'll see all
the changes Renovate made to the issue while I was trying to figure out the configuration.

![GitHub PR edit history](/images/2018-11-26-keeping-dependencies-updated/issue-history.png)

It took me a while to figure everything out, just take a look at the [commit history][pr-commits]. I'm going to
work through the final setup just to give you an idea of our setup.

First, I extended [Renovate][renovate]'s base config.

```
{
  "extends": [
    "config:base"
  ],
  ...
}
```

If you've worked with [eslint][eslint], [babel][babel-extends], or other tools in the js ecosystem, you've probably
seen this type of configuration extension. It essentially allows us to use their best practices out of the box.
Check out their [presets repo][renovate-presets] if you want to know what it adds specifically.

Next, I set the [assignees][assignees]. When [Renovate][renovate] opens a new PR, it'll assign it to these people
so that the PR doesn't get missed.

The actual meat of the change is the `packageRules` setup.

```
{
  ...
  "packageRules": [{
    "packagePatterns": ["*"],
    "excludePackagePatterns": ["^@artsy"],
    "enabled": false
  }],
  ...
}
```

[Renovate][renovate] allows you to set up multiple different `packageRules` and there's a lot of configuration for
them. I'm not going to go through more than I did, but feel free to read more in their
[docs][renovate-packagerules-docs]. In the `packageRule` that I setup, I specified `packagePatterns` with an
asterisk to select all dependencies. Then using `excludePackagePatteners` I excluded anything that started with
`@artsy`. Finally (and most importantly), I set `enabled` to `false` to disable the dependencies matching those
combinations of rules. That last part took me a while to figure out. When you're building package rules in
[Renovate][renovate], think of it as building out a list of operations to perform.

The last few pieces of config are a little more straight-forward and you can read about those in the docs. The one
thing that I'll mention is that [vulnerabilityAlerts][renovate-vulnerabilityalerts] _ignores_ `packageRules` and
triggers update PRs for anything that's reported to have a vulnerability. You'll have to explicitly disable it if
you only want reports on certain packages. Though, having it on probably isn't a bad idea...

### Wrapping up

So, that's how we configured [Renovate][renovate] to automatically update npm dependencies in Artsy's namespace.
It's been extremely useful already. I also went ahead and pulled our configuration out into a [shared
repo][artsy-renovate-config] so that we didn't have to copy these configurations across all of our projects. That's
a blog post for another day.

Be well friends.

<!-- prettier-ignore -->
[design-system]: https://www.uxpin.com/studio/blog/design-systems-vs-pattern-libraries-vs-style-guides-whats-difference/
[positron]: https://github.com/artsy/positron
[palette]: https://github.com/artsy/palette
[force]: https://github.com/artsy/force
[emission]: https://github.com/artsy/emission
[reaction]: https://github.com/artsy/reaction
[renovate]: https://renovatebot.com/
[renovate-pr]: https://github.com/artsy/force/pull/3086
[renovate-exclude]: https://renovatebot.com/docs/configuration-options/#excludepackagepatterns
[greenkeeper]: https://greenkeeper.io/
[greenkeeper-ignore]: https://greenkeeper.io/docs.html#ignoring-dependencies
[pr-commits]: https://github.com/artsy/force/pull/3086/commits
[assignees]: https://help.github.com/articles/assigning-issues-and-pull-requests-to-other-github-users/
[renovate-packagerules-docs]: https://renovatebot.com/docs/configuration-options/#packagerules
[artsy-renovate-config]: https://github.com/artsy/renovate-config
[renovate-vulnerabilityalerts]: https://renovatebot.com/docs/configuration-options/#vulnerabilityalerts
[babel-extends]: https://babeljs.io/docs/en/options#extends
[eslint-extends]: https://eslint.org/docs/user-guide/configuring#extending-configuration-files
[eslint]: https://eslint.org

<!-- prettier-ignore -->
[rnb]: https://www.fordfoundation.org/about/library/reports-and-studies/roads-and-bridges-the-unseen-labor-behind-our-digital-infrastructure/

<!-- prettier-ignore -->
[renovate-presets]: https://github.com/renovatebot/presets/blob/ef6a6e2e6d3e6ba25239d57d808b0e4dc64f32a3/packages/renovate-config-config/package.json#L19-L34
