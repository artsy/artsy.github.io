---
layout: epic
title: "At Last: An Artsy Log Out Button"
date: "2020-01-10"
author: [ash]
categories: [ios, tech debt, hackathon]
---

In 2013, Artsy shipped the first version of our iOS app. Typical for an early-day startup, the app was a "minimum
viable product", with a big emphasis on "minimum" here. One of the features that didn't make the cut was something
you expect to see from most apps: a log out button.

When I joined the company a year later, there was still no log out button. And there would be no log out button for
another six years, until today.

I want to talk about this quirk of our app, from both a product and technical perspective. I also want to talk
about how we finally managed to prioritize this kinda weird feature request (spoilers: it was our company-wide
hackathon). Let's go!

<!-- more -->

When I say that our app doesn't have a log out button, that's a bit of a fib: it does have one, in the admin-only
debug menu. The reason why this isn't a user-facing feature is that the final step of this admin-only log out
feature is a call to `exit(0)`, effectively crashing the app. That's one way to make sure that user-specific state
doesn't pollute your app's runtime, but of course it would be ridiculous for a user-facing log out button to crash
the app.

So Artsy staff could log out of the app, but our normal users couldn't. This quirk was acceptable in the early days
of our app, but as the years wore on, it became less of a quirk and more of a product limitation. While our
recently-formed Mobile Experience team is dedicated to creating a slick and polished app, in three months we still
hadn't prioritized the feature.

Why? Well, to be honest, we had (and still have) a lot of work to do to improve the app, and the log out button
never made the cut. Why is that? Well, it's actually quite complicated. And why is it complicated? Well for that,
we need to step back and think about software development and requirements gathering.

Experienced software developers will tell you that it's far, far easier to build a piece of software with a feature
in mind from the start than it is to take an existing piece of software and add something to it that it was never
intended to do. For our app, logging out was something it was never intended to do. So adding it was hard. Why?

Well, because of state. When you log in to our app, the state of the app changes: we get a user ID and access token
from our API, and our code assumed that these values would never change. This is further complicated by the fact
that our app is split into two pieces: the native code (written in Objective-C and Swift) and the React Native code
(written in TypeScript). You can effectively think of these as _two_ apps that interoperate with each other. The
state now has to be managed across _two_ pieces of software, further complexifying the work to add a log out
button.

So what we had was a difficult technilcal problem that wasn't _that_ high of priority and didn't have an obvious
solution. I mean, our app didn't even have a settings screen, so where would a log out button even go? Our product
team wasn't feeling the pain, but our colleagues who interface more directly with our users _were_ feeling it.

Enter the 2020 Artsy-wide Hackathon. We run these events roughly ever year, and they provide a great opportunity
for
