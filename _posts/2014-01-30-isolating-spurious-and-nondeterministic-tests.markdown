---
layout: post
title: "Isolating Spurious and Nondeterministic Tests"
date: 2014-01-30 14:42
comments: true
categories: [RSpec, Testing, Travis]
author: [joey, frank]
---

Testing is a critical part of our workflow at [Artsy](https://artsy.net). It gives us confidence to make regular, aggressive enhancements. But anyone who has worked with a large, complex test suite has struggled with occasional failures that are difficult to reproduce or fix.

These failures might be due to slight timing differences or lack of proper isolation between tests. Integration tests are particularly thorny, since problems can originate not only in application code, but in the browser, testing tools (e.g., [Selenium](http://docs.seleniumhq.org/)), database, network, or external APIs and dependencies.

## The Quarantine

We've been [automatically retrying failed tests](http://artsy.github.io/blog/2012/05/15/how-to-organize-over-3000-rspec-specs-and-retry-test-failures/), with some success. However, these problems tend to get worse. (If you have 10 tests that each have a 1% chance of failing, roughly 1 in 10 builds will fail. If you have 50, 4 in 10 builds will fail.)

Martin Fowler offers the most compelling thoughts on this topic in [Eradicating Non-Determinism in Tests](http://martinfowler.com/articles/nonDeterminism.html). (Read it, really.) He suggests quarantining problematic tests in a separate suite, so they don't block the build pipeline.

<!-- more -->

## Setting it up

This turned out to be pretty easy to set up, using our preferred tools of [RSpec](https://relishapp.com/rspec) and [Travis](http://travis-ci.com/). First, tag a problem test with `spurious`:

    it 'performs tricky browser interaction', spurious: true do
      ...
    end

Your continuous integration script can exclude the tagged tests as follows:

    bundle exec rspec --tag ~spurious

We'd like to be aware of spurious failures, but not allow them to fail the build. In our app's `.travis.yml` file, this is as simple as adding a script entry that always exits with `0` status:

    language: ruby
    rvm:
      - 1.9.3
    script:
      - "bundle exec rspec --tag ~spurious"
      - "bundle exec rspec --tag spurious || true"

We'll see any spurious failures in the build's output, but our pipeline won't be affected.

## Bonus: Limiting quarantined tests

So, what prevents the quarantine from getting larger and larger, while the test suite gets weaker and weaker? Fowler [recommends](http://martinfowler.com/articles/nonDeterminism.html#Quarantine) enforcing a limit on the number of quarantined tests (e.g., 8).

We can even trigger a build failure if the limit is exceeded. This `.travis.yml` writes the spurious suite's abbreviated output to a file, then asserts that the summary mentions no more than "8 examples":

    language: ruby
    rvm:
      - 1.9.3
    script:
      - "bundle exec rspec --tag ~spurious"
      - "bundle exec rspec --tag spurious --format documentation --format progress --out spurious.out || true"
      - "[[ $(grep -oE '^\d+' spurious.out) -le 8 ]]"

## Conclusion

The quarantine is no excuse to create tests that fail under realistic conditions. It's simply a framework for recognizing and, eventually, fixing or eliminating the problematic tests that inevitably crop up in a complex environment.

Hopefully, our experiment is useful to other teams struggling with unreliable builds. Share any feedback in the comments!
