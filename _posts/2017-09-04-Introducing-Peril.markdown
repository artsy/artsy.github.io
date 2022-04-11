---
layout: epic
title: Introducing Peril to the Artsy Org
date: 2017-09-04
categories: [danger, peril, javascript, typescript, culture]
author: [orta]
---

Once Danger Ruby was stable enough for everyday use in 2015, it became obvious that running Danger on CI was both a 
positive and a negative. On the positive side, Danger has access to all artifacts created during testing - and on the negative 
side it takes a long time to get feedback. It was obvious that Danger could [run on a server][hosted], but it was a big unknown what that could look like.

Eventually, [I came to the conclusion][danger_1] that we would need a JavaScript replacement of Danger - and so I applied
constraints to Danger JS that made a server-side version of Danger a possibility. It was a stroke of luck that around the 
time Danger JS became usable for day to day usage, that GitHub introduced [GitHub Apps][github_apps] - so I started work on Peril. Peril is server-side Danger. The rest of this post talks about how we use it Artsy today, how you can use it yourself and where it's heading.

<!-- more -->

In December 2016, I built out Peril in a sandbox org: [PerilTest][periltest], this gave me the chance to get a lot of things wrong safely. My biggest worry around Peril was leaking data though someone abusing the ability to evaluate a Dangerfile.

In May 2017, I introduced Peril into Artsy's org, GitHub apps have the ability to pick and choose which repos to work with. 
I scoped the repos to existing open source projects which I was familiar with ([Emission][], [Reaction][] and [Positron][])
which gave a space to ensure stability and handle production edge-cases.

In August 2017, I created a new Peril instance for CocoaPods. I then finally flipped the switch to turn Peril on for all 
repos on the Artsy org and formalized the RFC process for changes. This is where we are now. 

## Getting Set Up

For our Artsy org, I followed and improved the guide: [Setup for Org][peril_org]. There are three key components:

* Creating a GitHub app for your Org
* Hosting a Peril server
* Making up a Peril settings repo

The guide covers the initial setup, but I'd like to cover the third part of our setup.

## How Artsy's Peril works

The Artsy Peril settings are all on [artsy/artsy-danger][artsy-settings]. The Artsy Peril heroku instance has the ENV var
`"DATABASE_JSON_FILE"` set to `"artsy/artsy-danger@peril.settings.json"`, so Peril will use [that file][settings_json] as the source of truth for all config. Here's what it is today:

</article>
<article class='split-desktop-only'>
<div style='flex:1; display: block;'>

```json
{
  "settings": {
    "modules": [
      "danger-plugin-spellcheck", 
      "danger-plugin-yarn", 
      "@slack/client"
    ],
    "env_vars": ["SLACK_RFC_WEBHOOK_URL"]
  },
  "rules": {
    "pull_request": "artsy/artsy-danger@org/all-prs.ts"
  },
  "repos" : {
    "artsy/reaction": {
      "pull_request": "danger/pr.ts"
    },
    "artsy/positron": {
      "pull_request": "dangerfile.ts"
    },
    "artsy/artsy-danger": {
      "issues.opened": "artsy/artsy-danger@danger/new_rfc.ts"
    }
  }
}
```

</div>
<div style='flex:1; display: block; padding:0 20px;'>

<p><code>"settings":</code> These settings which conform to today's <a href='https://github.com/danger/peril/blob/752afeb37e3c1fdec512eb91687747d9a8a29337/source/db/index.ts#L26-L31'>GitHubInstallationSettings</a>, here's the <a href='https://github.com/danger/peril/blob/master/source/db/index.ts'>current version</a>. These are org-wide settings
that require a new deploy of the server to re-create.</p>

<p><code>"rules":</code> These are rules which are applied to every repo that Peril has access to. So in this case, every Pull Request in the org will make Peril run the Dangerfile at <code>"artsy/artsy-danger@org/all-prs.ts"</code>.</p>

<p><code>"repos":</code> These are repo-specific overrides, so a Pull Request to artsy/reaction would trigger both the org-wide Dangerfile, and one on the reaction repo.</p>

</div>
</article>
<article class='post'>

## Events

A Dangerfile evaluation occurs once a GitHub webhook is sent. In the above examples there are two events that Danger supports: 
`"pull_request"` and `"issues.opened"`. These are qualifiers that GitHub provide as a [Webhook EventTypes][events]. 

There's a lot of them: `commit_comment`, `create`, `delete`, `deployment`, `deployment_status`, `fork`, `gollum`, `installation`, `installation_repositories`, `issue_comment`, `issues`, `label`, `marketplace_purchase`, `member`, `membership`, `milestone`, `organization`, `org_block`, `page_build`, `project_card`, `project_column`, `project`, `public`, `pull_request`, `pull_request_review`, `pull_request_review_comment`, `push`, `release`, `repository`, `status`, `team`, `team_add`, `watch`. 

Some of these events also have unique sub-actions too:

* For an `issue` event there is: `assigned`, `unassigned`, `labeled`, `unlabeled`, `opened`, `edited`,  `milestoned`, `demilestoned`, `closed`, or `reopened`

* For a `pull_request` event there is: `assigned`, `unassigned`, `review_requested`, `review_request_removed`, `labeled`, `unlabeled`, `opened`, `edited`, `closed`, or `reopened`

The way that you define rules in Peril gives you the ability to either focus on one action for an event type: `"issues.opened"` or all actions
on an event: `"pull_request"`. Once you get your head around this, you start to get a sense of the scope of Peril. At Artsy, we've barely scratched the surface.

### Growth

I've always advocated that Danger, and Peril should be [applied incrementally][culture]. This applies even more when you're
making org changes that affect every developer - at least with Danger you can see the Pull Request that changes 
the Dangerfile. With Peril you get none of that.

So, we introduced [an RFC process for Peril changes][peril_rfc]. There's not much to it, if you want to add a rule that 
affects everyone then you need to make an issue following a template and then wait a week. If you make a new issue that
includes the title `RFC:` then Peril sends a slack message to our developer Channel 

![/images/peril/peril-rfc.png](/images/peril/peril-rfc.png)

This was simple to build via Peril, I first added the npm module: `"@slack/client"` to the `"modules"` array, making it available to a Dangerfile. Then I added an environment variable to Peril for a newly minted Slack Incoming Webhook URL, and exposed it to Dangerfiles via: `"env_vars": ["SLACK_RFC_WEBHOOK_URL"]`.

Then I added a per-repo rule:

```json
    "artsy/artsy-danger": {
      "issues.opened": "artsy/artsy-danger@danger/new_rfc.ts"
    }
```

This means the Dangerfile is only ran on `"issues"` with an `"opened"` action. I didn't want the discussion around a rule spamming our slack with webhooks from the other actions. The file `danger/new_rfc.ts` looks like this:

```ts
import { schedule, danger } from "danger"
import { IncomingWebhook } from "@slack/client"
import { Issues } from "github-webhook-event-types"

declare const peril: any // danger/danger#351

const gh = danger.github as any as Issues
const issue = gh.issue

if (issue.title.includes("RFC:")) {
  var url = peril.env.SLACK_RFC_WEBHOOK_URL || "";
  var webhook = new IncomingWebhook(url)
  schedule( async () => {
   await webhook.send({
      unfurl_links: false,
      attachments: [{
        pretext: "🎉 A new Peril RFC has been published.",
        color: "good",
        title: issue.title,
        title_link: issue.html_url,
        author_name: issue.user.login,
        author_icon: issue.user.avatar_url
      }]
    })
  })
}
```

For events that are not a `"pull_request"` the `danger.github` object is the JSON for the event.  You can get TypeScript types available for every GitHub event via the NPM module [github-webhook-event-types][event-types] which makes it much easier to work with.

## Where to go from here?

Right now we have [a few RFCs][rfcs], and I don't spend all day making Peril rules, I've gotta [do work y'know][con_ios]. We're going to slowly build out our Peril infrastructure.

I'm interested in exploring two ideas big for peril at the moment:

- What a Peril plugin system looks like: You can include modules which can listen to events and react themselves. An org-wide spellcheck on markdown files could be as easy as including `"modules": ["peril-plugin-spellcheck"]`.

- What [scheduled jobs][scheduled] could look like for Peril: We have a bunch of checks I'd like to make on a a regular occasion, and then passing back feedback via slack or making an issue on the repo.

 For example if a repo has an owner who isn't in Artsy anymore, we should highlight that it needs a new owner.

If you're interested in using Peril in large OSS projects, take a look at how Peril is used in CocoaPods via [CocoaPods/peril-settings][cp-peril].

If you're interested in using Peril in your org, run through the [Setup for Org][peril_org] guide and help improve it when you inevitably have some weird issues.

[hosted]: https://github.com/danger/danger/issues/42
[danger_1]: /blog/2017/06/30/danger-one-oh-again/
[github_apps]: https://developer.github.com/changes/2016-09-14-Integrations-Early-Access/
[periltest]: https://github.com/PerilTest
[Emission]: https://github.com/artsy/emission
[Reaction]: https://github.com/artsy/reaction
[Positron]: https://github.com/artsy/positron
[peril_org]: https://github.com/danger/peril/blob/master/docs/setup_for_org.md
[artsy-settings]: https://github.com/artsy/artsy-danger
[settings_json]: https://github.com/artsy/artsy-danger/blob/master/peril.settings.json
[events]: https://developer.github.com/v3/activity/events/types/events
[culture]: http://danger.systems/js/usage/culture.html
[peril_rfc]: https://github.com/artsy/artsy-danger/#rfcs
[event-types]: https://www.npmjs.com/package/github-webhook-event-types
[rfcs]: https://github.com/artsy/artsy-danger/issues?utf8=✓&q=is%3Aissue%20RFC
[con_ios]: https://github.com/artsy/emission/pulls?utf8=✓&q=consignments%20
[cp-peril]: https://github.com/CocoaPods/peril-settings
[scheduled]: https://github.com/danger/peril/issues/138
