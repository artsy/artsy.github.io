---
layout: epic
title: "On the obsessive statelessness of Peril"
date: 2018-06-18
author: [orta]
categories: [danger, peril, state]
css: danger
---

We're at 9 months of serious usage [of Peril in Artsy][peril_at_artsy]. However, I've been worried.

To get you up to speed on Peril, Peril is a tool that takes GitHub webhooks, and makes it easy to build one-off
actions. It does this by having a per-account settings JSON, that connects JavaScript files to events from webhooks.
So, for example, you can write a rule which runs when closing an issue in GitHub that looks for associated Jira
tickets and resolves them. Peril provides no implicit actions like that, it instead offers a JavaScript runtime
environment optimised to this domain so you can make actions to fit your needs. Like a collection of single-file
[probots][probots].

Three months ago I started building out a "true" staging environment for Peril, one that allows any user or org on
GitHub to click a button and have Peril running on their account. Pulling this off has two real interesting
problems. Problem number one, security. Problem number two, my wallet.

Both of these issues stem from one simple problem: I need to run other people's code on my machines and I think they
should be able to store data. Which to be quite frank, is horrifying for a side-project. So, this post explores one
of main aspects which I've architected Peril to make this problem tractable. Avoiding storing state in the form of
data.

<!-- more -->

## Evaluation Context

Let's start with grounding how Peril works. The GitHub term for when someone adds Peril to their account is that it
creates an "Installation" of the
[GitHub App](https://blog.github.com/2016-09-14-a-whole-new-github-universe-announcing-new-tools-forums-and-features/#integrate-seamlessly-with-github).
When a webhook from GitHub is sent to Peril, Peril grabs the installation metadata (env vars, settings repo
addresses, cached config etc) out of a mongo database (yeah, I know, [how early-2010s][nosqliscool]) and pulls out a
set of rules. These rules are a map of Webhook events and actions to files. For example:

```json
{
  "rules": {
    "issues.opened": "artsy/peril-settings@danger/new-rfc.ts",
    "issue_comment": "artsy/peril-settings@org/markAsMergeOnGreen.ts",
    "pull_request.closed": "artsy/peril-settings@org/closed-prs.ts"
  }
}
```

This [custom JSON DSL][json_dsl] maps opening an `issue` on GitHub to the evaluation of
[`artsy/peril-settings@danger/new-rfc.ts`][rfc]. Peril runs the code which is declared as the `default export` with
the JSON contents of the webhook. Then the file can execute with the DSL provided in both [danger-js][] and
[peril][ext]'s extensions. Peril's runtime is a reasonably normal nodejs environment, so it supports working with
`node_modules` to get stuff done. Here's what [`artsy/peril-settings@danger/new-rfc.ts`][rfc] looks like:

```js
import { danger, peril } from "danger"
import { Issues } from "github-webhook-event-types"

export default async (issues: Issues) => {
  const issue = issues.issue

  const slackify = (text: string) => ({
    unfurl_links: false,
    attachments: [
      {
        pretext: text,
        color: "good",
        title: issue.title,
        title_link: issue.html_url,
        author_name: issue.user.login,
        author_icon: issue.user.avatar_url
      }
    ]
  })

  if (issue.title.includes("RFC:") || issue.title.includes("[RFC]")) {
    console.log("Triggering slack notifications")

    await peril.runTask("slack-dev-channel", "in 5 minutes", slackify("🎉: A new RFC has been published."))
    await peril.runTask("slack-dev-channel", "in 3 days", slackify("🕰: A new RFC was published 3 days ago."))
    await peril.runTask("slack-dev-channel", "in 7 days", slackify("🕰: A new RFC is ready to be resolved."))

    console.log("Triggered slack notifications")
  }
}
```

Implementation-wise, there is a single Peril API which recieves webhooks from GitHub. This triggers a "Runner" which
is a hosted docker container (think, like, serverless) which hosts the runtime. The runner will then run the
Dangerfile, triggering things like comments on PRs or any other interesting side-effect.

<img src="/images/peril-state/peril-stack.png">

This is where things get tricky, I first explored running code inside a tightened [virtual machine for node][vm2]
but eventually found enough holes that it was definitely not going to work against malicious user-code in the same
process as Peril. I lucked out to a potential answer to this when building out documentation for [danger-js][],
which could [feed many birds with one bowl][birds]. I could separate out the execution context (think: the runtime
DSL, the webhook JSON, and a bunch of installation specific config) as JSON and then pass that servers/processes
then turn that back into a useful runtime again in a separate client which runs the Dangerfile (the name for a
`js`/`ts` file running in the Peril JavaScript Environment. )

This idea was so compelling that I first used it to create a version of Danger that runs
[native to swift](https://github.com/danger/danger-swift) to figure out the kinks of what actually needs to be
transmitted. For Peril, this meant I could explore having the evaluation of user-code inside a completely different
server. I initially explored [using AWS Lambda][lambda] to run user-code, it's cheap, fast and mature. However, it's
possible for lambda instances to communicate with each other, as each run is not [a fresh process][lambda-reuse].
Making it not a secure platform for un-trusted code.

Not deterred, I explored the world of docker hosting as a service - first exploring running my own cluster [on AWS
ECS][ecs] and then settling [on Hyper][hyper] which offered sandboxed runs that booted in a few seconds. This is
where my first real dive into obsessive statelessness comes in. The docker container, and the hyper environment
contains no config by default. There is no Peril information available inside that runtime environment.

The information about a Peril run comes exclusively from Peril. In my head, I call this dependency injection for the
runtime environment. You can get a sense for what the full JSON looks like in this
[fixtured file generated by tests](https://github.com/danger/peril/blob/master/source/github/events/handlers/_tests/fixtures/PerilRunnerEventBootStrapExample.json).
It contains everything from (temporary) GitHub access tokens (only for your installation), to environment variables
for your run and the webhook JSON. The runtime environment only knows that information for the duration of the
process then all access tokens expires after 30 seconds of it starting regardless.

## User Sessions are ephemeral

With the runtime security figured out, and reasonably stable, I could start thinking about how people can understand
what's happening on their installations inside peril.

<img src="/images/peril-state/peril-dashboard.png">

I know, a beauty right? Taking ideas from Ashkan's [post on JWT's][jwts] I explored using JWTs to fix a few user-y,
database-y related problems.

A JWT is a string made of three components, a header which says how it is signed, a base64 chunk of JSON data and a
signature verifying the data. You can always read the data inside a JWT, but you need to know the public key used to
sign the token to verify that it's not been tampered with or created from another source.

This brings us to my first problem when building out multi-account Peril: User accounts. For Peril the root element
of the domain model is a GitHub Installation. A first-glance perspective on building a web service like this would
have me creating a user model which can keep track of permission to installations and unique user settings. With
[GDPR so freshly baked][gdpr] I really didn't see any actual value in keeping this kind of data. Instead I added
enough metadata to a JWT to replace a user model completely.

I opted to rely on GitHub's Oauth API to verify what orgs a user has access to. This means GitHub hosts both the
user model, and the permission relationships. This is always set up outside of Peril, and so there's no need for
duplication of the objects and connections inside this service.

#### Here's an example JWT

<script src="https://gist.github.com/orta/0265c143e2c4f473d4dff5cc6980d1a4.js"></script>

You could throw it into [jwt.io][jwtio] to look at what's inside it, but I'll do that for you:

#### When decrypted

```json
{
  "iat": 1529198097,
  "iss": ["123", "321"],
  "data": {
    "user": {
      "name": "Orta",
      "avatar_url": "https://avatars2.githubusercontent.com/u/49038?v=4"
    }
  },
  "exp": 1529201697
}
```

So far, I think that's enough information for the dashboard. You can let people know what account they're logged
into, and a show an avatar in a UI. The JWT is generated when you log in to Peril via GitHub OAuth, and Peril looks
up what installations you have access to via the GitHub API. The connected installations IDs are stamped into the
JWT in the `iss` section. This JWT is stored in the user's browser via cookies, and the server never stores it.

In every API call from the front-end, the server validates that the JWT was signed by Peril, and has not expired. If
it's OK - the server trusts the data inside the JWT and you have access to administrate the installations. No stored
sessions, no stored users.

There's downsides to using a JWT like this. For example, what happens if the user is removed from the org? Until
that JWT has expired (1 month), the user will continue have access to the installation. This is a trade-off which
I'm OK to take right now. I think [this post][jwt_tradeoff] covers a lot of the downsides of this stateless JWT
technique well. In the future, as Peril has access to org members being added or removed, I can build a way to
expire the token at runtime.

## Temporary Tokens

The user/authentication JWT is not the only JWT in play in Peril.

I needed the ability for the JavaScript Runtime to send messages back to the Peril server. Peril re-uses JWTs for
creating a short-lived (2 min) token. This token only has access to a single installation and is given a
list of mutations it has whitelisted access to in the GraphQL API. This token is a part of the data injected in at
the start of the process. The Peril JavaScript DSL uses this token under the hood when you run particular functions.
This approach, the above post argues, is a perfect use-case for JWTs.

## Temporary Webhooks

With an admin user interface set up, you can now get a good overview of what your installation looks like in
Peril.

<img src="/images/peril-state/admin.png">

This is a good start, but it's a static representation of a live system. In order to do any development of your
Dangerfiles in Peril, you would need to keep triggering the same event inside the GitHub and seeing how Peril
evaluates your code. Even with the rich type definitions, you're unlikely to get it right first time.

And here's where I made a compromise or two, in favour of a good abstraction. Ash recommended that perhaps storing
webhooks from GitHub and making it feasible to re-send them in Peril would make a great development environment. I
couldn't think of a way to do that statelessly, so I opted to time-box them. Now you can trigger a 5 minute window
on an installation where any event sent to Peril will be stored in mongo for a week. After that they're gone.

This is a great trade-off on data storage vs value of a feature. It's been the best idea so far on how to handle
building a development mode into Peril, so I wouldn't want to compromise the feature in favour of something that
won't store any data.

## Real-time logging

On the flip side, I spent a long time thinking about how I can get logs from a Peril run to a user without having to
store those.

I came up with what feels like such an obvious answer in retrospect. When you open up the admin dashboard, it
connects to Peril via a websocket. This websocket is used to send real-time updates about when an event is
triggering a Dangerfile evaluation and its changing status. When the evaluation is finished, then the logs are
collected and sent through the websocket to any users connected to the associated installation. The feature is
particularly elegant because storing the logs for every Dangerfile run on something like S3 will not scale with my
wallet. Plus, I don't want to have access to your logs ideally.

<img src="/images/peril-state/websocket.png">

Again, an interesting trade-off. You can only get logs when you're looking for them, as opposed to when a problem
may actually have occurred. There's things I can do to work around this if and when it becomes a pressing need, for
example keeping an installation's logs around for a day in Peril. Alternatives to this could be that Peril allows
installations to define a webhook to receive the logs, or for Peril to pass them directly to a installation's
[Papertrail][] (or other hosted log services).

A lot of the obsession comes from a reasonable enough desire to ship something that people can trust, that could
start off small and hard enough that it doesn't consume all my spare time with support and fixing fires. With a lot
of these ideas in tow, I've been able to feel pretty confident in letting others access staging environments and use
my hosted version of Peril. Which means I can move on to the next items in my TODO list, making the dashboard make
sense and to start thinking about what the public facing product pages look like for Peril.

[nosqliscool]: https://www.infoworld.com/article/2990184/database/nosql-simply-isnt-hip-anymore.html
[probots]: https://probot.github.io
[rfc]: https://github.com/artsy/peril-settings/blob/6ec744e552df0828b3de2c5bc72e97accc6f562f/danger/new-rfc.ts
[danger-js]: http://danger.systems/js/
[ext]: http://danger.systems/js/reference.html#PerilDSL
[vm2]: https://github.com/patriksimek/vm2
[lambda]: https://github.com/danger/peril/issues/159
[birds]: https://celebrateurbanbirds.org/learn/gardening/providing-water-for-birds/
[lambda-reuse]: https://aws.amazon.com/blogs/compute/container-reuse-in-lambda/
[ecs]: https://aws.amazon.com/ecs/
[hyper]: https://hyper.sh
[jwts]: https://artsy.github.io/blog/2016/10/26/jwt-artsy-journey/
[gdpr]: https://www.wired.co.uk/article/what-is-gdpr-uk-eu-legislation-compliance-summary-fines-2018
[jwt_tradeoff]: http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/
[jwtio]: https://jwt.io
[peril_at_artsy]: /blog/2017/09/04/Introducing-Peril/
[json_dsl]: https://github.com/danger/peril/blob/93439da3a088e9a7824192e24d33295ced017239/docs/settings_repo_info.md
[papertrail]: https://papertrailapp.com
