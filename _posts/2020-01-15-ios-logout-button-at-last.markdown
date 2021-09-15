---
layout: epic
title: "At Long Last: A Log Out Button"
date: "2020-01-15"
author: [ash]
categories: [ios, tech debt, hackathon]
---

In 2013, Artsy shipped the first version of our iOS app. Typical for an early-day startup, the app was a "minimum
viable product" (with a big emphasis on "minimum"). One of the features that didn't make the cut was something you
expect to see in most apps: a log out button.

When I joined Artsy a year later, there was still no log out button. And there would be no log out button for
another six years, until today.

I want to talk about this quirk of our app, from both product and technical perspectives. Why wasn't this already
in our app? Why was it so difficult to build? These are interesting questions, and their answers shed light on how
products mature over time. I also want to talk about how we finally managed to prioritize this kinda weird feature
request (spoilers: it was our company-wide hackathon). Let's go!

<!-- more -->

When I say that our app doesn't have a log out button, that's a bit of a fib: it _does_ have a log out button... in
the admin-only debug menu. The reason why this isn't a user-facing feature is that the final step of this
admin-only log out feature is a call to `exit(0)`, effectively crashing the app. That's _one_ way to make sure that
user-specific state doesn't pollute your app's runtime, but of course it would be ridiculous for a user-facing log
out button to crash the app. The only other way to log out was to uninstall the app, which is _not_ something we
want to encourage users to do.

So Artsy staff could log out of the app, but our normal users couldn't. This quirk was acceptable in the early days
of our app, but as the years wore on, it became less of a quirk and more of a product limitation. Even three months
after creating our new Mobile Experience team, we hadn't yet prioritized this feature. Let's
[dive into this question](https://en.wikipedia.org/wiki/Five_whys) a little bit.

The log out button hadn't been prioritized. **Why?** To be honest, we had – and still have – a lot of work to do to
improve the app ([we're hiring, by the way](http://artsy.net/jobs)). Among the high-impact work we've been
shipping, the log out button simply never made the cut. **Why?** It turns out be quite complicated to implement a
log out button in our app. **Why?** To answer that, we need to step back and think about software development and
requirements gathering, generally.

Experienced software developers will tell you that it's far, far easier to build a piece of software with a feature
in mind _from the start_ than it is to take an existing piece of software and add something to it that it was never
intended to do. For our app, logging out was something it was never intended to do, and so adding it was
technically difficult. **Why?**

Because of [state](https://softwareengineering.stackexchange.com/questions/148108/why-is-global-state-so-evil).
When you log in to our app, the state of the app changes: we get a user ID and access token from the Artsy API and
our code assumes that these values never change. This is further complicated by the fact that our app is split into
two pieces: the native code (written in Objective-C and Swift) and the React Native code (written in TypeScript).
You can effectively think of these as _two_ apps that interoperate with each other. The state now has to be managed
across _two_ pieces of software, further complexifying the work to add a log out button.

Returning to the idea of developing features in mind from the start (versus adding them after the fact), our React
Native codebase had always assumed a logged-in user. Adding support for this later on was too difficult (indeed,
our solution was to
[invalidate the entire React Native runtime upon log out](https://github.com/artsy/emission/pull/2027/files#diff-0cc174f9197fd0b06ecbd2eaa0247833R1020)).
This wasn't a limitation of React Native, but rather it was a limitation of how we chose to organize our code. If
we'd added a log out button earlier in the product lifetime, it wouldn't have been so difficult. The longer we
waited, the more and more code we wrote that implicitly relied upon our existing limitations.

In this way, the _absence_ of a feature had gained its own inertia. The missing feature became a present absence,
and I think there's more to think about there – maybe for another blog post.

So what we had was a difficult technical problem that wasn't _that_ high of priority and didn't have an obvious
solution. Our product team wasn't feeling the pain, but our colleagues who interface more directly with our users
_were_ feeling it.

Artsy kicked off 2020 with a company-wide Hackathon. We run these events roughly once a year, and they provide a
great opportunity for engineers and non-engineers to work together to build something over a few days. Maybe it's a
brand-new piece of software to help us do our jobs better. Maybe it's a new zine to collect our favourite artworks
from the site? And maybe, just maybe, it's a long-neglected user feature that never made the cut in prioritization
meetings.

Among all the ideas that Artsy staff submitted for the Hackathon, the Artsy iOS Log Out button received the third
most votes.

![Screenshot of our Hackathon ideas board](/images/2020-01-15-ios-logout-button-at-last/idea.png)

I sat down with another Mobile Experience engineer, Brian, and the people who submitted the Hackathon idea. If we
were going to build this, it was worth doing right, so we asked questions and learned more about why users need a
log out button at all. I'll spare you the details, but it suffices to say that I learned a lot.

Brian and I worked on the feature, digging into the internals of our app and the interop between native and React
Native code. Our solution wasn't necessarily the "best" solution, but it worked within the assumptions that the app
has already made. Here's roughly the plan we set out with.

On the React Native side of the app, build a settings screen with the log out button:

- When the user taps the button, post a notification through `NSNotificationCenter`.
- Also, show the user who they are logged in _as_ on this screen.

On the native side of the app, listen for the notification and take the following steps when it's fired:

1. Tear down the React Native bridge (invalidate it and release it).
2. Tear down the native user interface (set singleton instance to `nil`).
3. Get a fresh unauthenticated API token.
4. Use the token to show the sign in/up flow (set the window's `rootViewController` property).

Invalidating the React Native bridge is quite a dramatic action to take, but it's effective. We chose this solution
because it allows our React Native code to continue assuming that the user ID and access token never change (during
its lifetime, anyway).

We had a few other items to follow-up on, mostly reference cycles that were holding onto invalid singleton
instances in-memory. Here's the log out button in action:

![Screenshot of our new log out button!](/images/2020-01-15-ios-logout-button-at-last/logout.png)

We learned a tonne about the React Native bridge, the existing architecture of our app, and how we'd like to see
that mature going forward.

I said earlier that the longer we waited, the harder it was to build this log out button because more and more of
our existing code relied upon assumptions that the log out button would break. Now that we _do_ have a log out
button, _new code we write needs to take it into account_. The assumptions coders can make about this codebase are
shifting over time – this is an experience that I never appreciated while working on minimum viable products. I'm
trying to lean into these shifts and use them to drive further modernizations in our codebase. For instance, I'm
already thinking ahead to how everything will work once our sign in/up flow is moved from Objective-C to React
Native (since the user ID and access token _will_ need to be mutable state).

In case you're curious, all our iOS code is open source. The work to add a log out button is totally open source in
[these](https://github.com/artsy/emission/pull/2027) [two](https://github.com/artsy/eigen/pull/2977) pull requests.

Any organization structure will lead to features falling through cracks. It just happens, it's the nature of
structured organizations. What we've learned at Artsy is that Hackathons (and cross-team collaboration in general)
are effective "escape hatches" for important-but-not-urgent work to get prioritized. They help our colleagues in
Engineering and other teams get to know each other, get to know our business, and find out what kind of features
our users need – even less-than-glamorous features, like a log out button.
