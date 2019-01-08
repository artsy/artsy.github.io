---
layout: epic
title: Automation Encourages More Automation
date: 2019-01-08
author: [ash]
categories: [automation, peril, roads and bridges]
---

Last year, [I wrote about the process of fully automating our weekly engineering-wide standup][automate]. One of
the benefits of automating what _was_ a meeting run by a single person to a meeting run by everyone is that we
removed a [single point of failure][spof]. However, I may have fibbed just slightly when I called our standups
_fully_ automated.

This blog post is going to cover how (and more importantly, _why_) I finally automated the last 5% of our weekly
standups. Let's go!

<!-- more -->

---

Our weekly standup process is a finely tuned machine. The meeting is run every Monday morning by a different pair
of engineers, based on our [on-call rotation][support]. The process is [documented][docs] in the open, and we
improve it over time. I'm really proud of it! But there's just one problem... someone needs to make sure that the
people responsible for the meeting _know_ about that responsibility.

So for the past 8 months, I've begun every week by sending Slack DMs to the responsible engineers to remind them to
run the standup, including a link to the docs. This made me a single point of failure: when I was out of the
office, I always made sure to ask someone else to remind them about the meeting. What if I had forgot? Or I was
sick that day? What would happen to our finely-tuned machine?!

Okay, so what would probably happen is that people would remember anyway or someone would post to Slack "hey who is
running standup today?" Automating this reminder was a pretty small priority, but it was a gap in our process, and
I wanted to patch it.

When I discussed all of this with my colleagues, it wasn't long before someone brought up [the xkcd comic on
automation][xkcd]. Oh, you know the one.

[<center><img src="https://imgs.xkcd.com/comics/automation.png" srcset="//imgs.xkcd.com/comics/automation_2x.png 2x" alt="xkcd comic about automation" title="I wonder if people would read the hover text of an xkcd comic linked to from a different site, just out of habit? I probably would." /></center>][xkcd]

The comic observes that, often, the work necessary to automate a task often exceeds the amount of work necessary to
just do the task manually. Pretty funny! You could be forgiven for taking the logical leap to say that automating
tasks isn't worth it, generally, based on this observation. But that analysis would be incomplete because it
focuses entirely on saving _time_. In my experience, automating a task often yields far more value than it costs in
time.

Let's take the task of sending the on-call engineers their Monday morning standup reminder. How would we even
automate that?

Well, first I think about how _I_ do this task. First I look at the on-call schedule, shared in Google Calendar.
Then I open a DM in Slack with the engineers. I copy the pre-composed message from my recurring OmniFocus task and
send it in the DM.

Okay so how would I automate that? [Artsy uses Peril already][peril] to automate reminders about open RFCs, so I
piggy-backed on that existing automation. This is key: I'm not starting from scratch, I'm building upon the
existing automation infrastructure that we've already built.

Next, I find out how to access the Google Calendar API using a [Google Services Account][gsa]. It has an
authentication method purpose-built for server-to-server communication, which is perfect for our needs. I write
some code to pick the correct calendar events based on the current time, extract the email addresses of those
events' attendees, and handle an edge case. Then I look up the [Slack API][slack] for Peril's platform, learn how
to authenticate with it properly from a server, and lookup Slack user IDs based on those email addresses. Finally,
compose the message and use some previously written code to post it to our #dev channel.

Boom. [Open a PR][pr]. Add some unit tests. Done.

<img alt="screenshot of the peril task working in Slack" src="/images/2019-01-08-automation-encourages-more-automation/success.png"  />

I spent about four hours automating this and by my calculations, I'll recoup that time by... July 2020. But like I
said, there's more value to this than the time I saved.

In the process of automating this, I learned how to use _two_ new APIs _and_ I created infrastructure in our [Peril
installation][peril_installation] to access them. Not only did I build _upon_ the existing automation framework,
but I _contributed_ to it so it's easier for the next person. I even [fixed a Peril bug][peril_pr] in the process.

Automation encourages automation. Every time you automate a task, it gets easier to automate the next one. With
sufficient infrastructure, a sort of exponential takeoff happens: all of a sudden you're not just automating
_existing_ tasks, you're using that infrastructure for _new_ tasks. Tasks that add value to your team, like
[merge-on-green][merge] or [notifying engineers of recent API changes][schema].

As a consequence of the nature of engineering, we often consider ideas in only terms of constraints. We define
what's possible by what we can already accomplish. Automation is a way to hack around that habit; it encourages
engineers to think outside the box by giving us a larger box. Simple, but effective!

---

So. Four hours of work. Was it worth it?

Well, let's evaluate this in terms of _impact_. Those four hours could have kept our standups running until next
July, or they could have automated that task _and_ further enhanced our automation infrastructure. And, personally,
it was very satisfying.

I would say that's _definitely_ worth it.

[automate]: http://artsy.github.io/blog/2018/05/07/fully-automated-standups/
[spof]: https://en.wikipedia.org/wiki/Single_point_of_failure
[support]: http://artsy.github.io/blog/2018/05/25/support-process/
[docs]: https://github.com/artsy/README/blob/eb2f23c835983223877a6031475153db93e98e8c/events/open-standup.md
[xkcd]: https://xkcd.com/1319/
[pr]: https://github.com/artsy/peril-settings/pull/87
[peril]: http://artsy.github.io/blog/2017/09/04/Introducing-Peril/
[gsa]: https://cloud.google.com/iam/docs/understanding-service-accounts
[slack]: https://github.com/slackapi/node-slack-sdk#features
[peril_installation]: https://github.com/artsy/peril-settings
[peril_pr]: https://github.com/danger/peril/pull/407
[merge]: https://github.com/artsy/peril-settings/blob/master/org/mergeOnGreen.ts
[schema]: https://github.com/artsy/peril-settings/blob/master/tasks/compareSchemas.ts
