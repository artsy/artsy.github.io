---
layout: post
title: "Taking a Snapshot with Second Curtain"
date: 2014-08-07 11:46
comments: true
categories: [iOS, Continuous Integration, Travis, Testing]
author: ash
---

At Artsy, we try hard to [test](https://speakerdeck.com/orta/getting-eigen-out?slide=35)
our iOS applications to ensure that we avoid regressions and have a clearly
defined spec of how our apps should look and behave. One of the core pieces of
our testing setup is [FBSnapshotTestCase](https://github.com/facebook/ios-snapshot-test-case),
a library written by Facebook to compare views at runtime with images of those
views that are known to be correct. If the images differ, the test fails. We
also use [Travis](https://travis-ci.org) for continuous integration.

Lately, we've been noticing a friction between the developers on the iOS team
and the tools we're using to test our apps: while Travis allows us to easily
access the logs of test runs, it can only indicate that a snapshot test failed,
not why it failed. That's because the images that are compared are locked on
Travis' machine – we cannot access those images, so we can't see the
differences. This is *really* promblematic when the tests pass locally but fail
only on Travis.

<!-- more -->

A few weeks ago, [Orta](http://twitter.com/orta) and I were discussing this
problem and we came up with a potential solution. Since the images were stored
on disk on Travis' machine, why not just upload them somewhere we *can* see
them? Like an S3 bucket. We could even generate a basic HTML page showing you
the different test failures.

Time passed and, later on, I had tests passing locally but failing on Travis.
I saw an opportunity to build something new. I'm not a proficient Ruby developer,
but I enjoy learning new things, so I decided to create a Ruby gem that could
fit within our existing testing pipeline. A lot of the structure for the code
came from an existing gem we already use with Travis, [xcpretty](https://github.com/supermarin/xcpretty).
With an example of how gems that support iOS testing are written, I was on my
way to creating my own.

At first, things were very difficult. While I had contributed small patches to
existing Ruby projects before, I had never created a brand new one from scratch.
The existing [guides](http://guides.rubygems.org/make-your-own-gem/) were very
helpful, and I found help from the CocoaPods developers when I had questions
about things like the arcane semantics of Ruby's `require` syntax.

Eventually, I had a working proof-of-concept. Everything seemed ready to go, and
I prepared to incorporate my new tool, which I called [Second Curtain](https://github.com/AshFurrow/second_curtain),
into my pull request on the Artsy repo. But there was a problem.

Second Curtain relies on environment variables to get access to the S3 bucket
where it stores the images. I planned on using Travis' system to [encrypt](http://docs.travis-ci.com/user/encryption-keys/)
those credentials. It turns out, for very good reasons, encrypted environment
variables are not available on pull requests created on forks of repositories.
This is a problem because of the way that [Artsy uses GitHub](http://artsy.github.io/blog/2012/01/29/how-art-dot-sy-uses-github-to-build-art-dot-sy/).
While it's not a problem for a closed-source repository to have (restrictive)
access to an S3 bucket, it would be irresponsible to expose S3 credentials for
an open-source project. I'm [working](https://github.com/AshFurrow/second_curtain/issues/5)
on a solution.

Orta helped with the design aspect of the tool; while uploading the images was
sufficient, we could make the process of seeing the differences between the two
images even easier. He created a [HTML page](https://eigen-ci.s3.amazonaws.com/snapshots/2014-08-04--15-47/index.html)
that would allow developers to see the before-and-after versions by moving their
mouse cursor over the different images.

![Image Diff](http://static.ashfurrow.com/github/second_curtain.png)

In the end, I got Second Curtain to work with Artsy's iOS repository and I
discovered the discrepency between the two images: due to a timezone difference
between my computer and Travis', a date was being formatted differently. Not a
difficult thing to fix, but not something I would have ever been able to
discover had I not been able to see the images side-by-side.

So after all that, one line of Objective-C was changed and the tests passed – my
pull request was merged. I learnt a lot about how Ruby developers structure
their code and what tools they use to write software. While I'm happy to return
to iOS apps for a while, it was a great experience and I'm hoping to bring some
of the ideas I discovered writing Ruby back to Objective-C.
