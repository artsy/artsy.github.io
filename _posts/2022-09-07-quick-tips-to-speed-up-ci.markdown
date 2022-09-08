---
layout: epic
title: "Parallelizing Jest and Cypress.io Tests on CircleCI"
subtitle: A few simple tips on how to speed up your CI
date: 2022-09-07
categories: [CircleCI, CI, Tests, Jest, Cypress]
author: [chris]
---

At Artsy, exploring ways to improve the developer experience is part of our
makeup. Whether it's implementing [hot-swapping][hot-swap] for Express.js or
integrating the Rust-based [SWC compiler][swc] into our front-end build
pipeline, we're always trying to reduce the amount of time it takes for a code
cycle to take place. CI is no exception. When a developer opens a PR, we want to
ensure they get timely feedback. Do their unit tests pass? Does the app build
correctly? And how about smoke tests? Each of these jobs are complex processes
that take time, and the more one can parallelize said tasks the less devs will
need to wait. Scaled out to a whole engineering org, minor improvements to CI
can be radical.

In this regard, two things came across our radar recently that we'd like to
share: sharding via Jest, and a (free) way to parallelize Cypress.io integration
tests via CircleCI's `split` command.

<!-- more -->

## Sharding in Jest

"What is sharding?" Good question! In short, it means "a small part of a whole".
The database community has employed sharding techniques for decades, where a
large database is split up into smaller, more manageable chunks, usually to
improve performance at scale. The same idea can be applied to any process or
task involving a lot of data, including tests.

Think about it like this. Imagine an app that has thousands of tests. One can
open up their terminal and run `yarn test` and execute all of the tests at once
in a single process, or one can open two terminal tabs and run
`yarn test src/utils` and `yarn test src/routes`, and have both processes
allocate a pool of memory to complete each (smaller) subset of tasks. Because
each process has its own memory pool the performance characteristics are
generally better, and thus the overall time required to run our tests is reduced
/ decreased. Running each of these commands scoped to a particular folder is
easy enough, but in a CI environment this is somewhat cumbersome; we'd need to
define two new jobs and then the conditions in which they run, increasing the
scope and complexity of our configuration file.

This is where [Jest's new sharding feature][sharding] comes into play, which
taps nicely into most modern CI runners. Using a hypothetical app containing 100
tests, here's a quick example of how it works:

```bash
$ yarn jest --shard 1/5
```

What this says is: take the total number of tests (100), divide them into five
buckets (containing 20 tests each), and execute the test runner against the
first bucket (the first 20 tests). Continuing:

```bash
$ yarn jest --shard 2/5
```

Now take the second bucket and execute the next 20 tests -- and so on. Simple
enough.

Taking this further, we could turn this into a bash loop, including an `&`
symbol to run things in parallel and automating some of the redundancy away:

```bash
BUCKETS=5

for i in {1..${BUCKETS}}
do
   yarn jest --shard $i/$BUCKETS &
done
```

For many the above snippet should be sufficient to speed up your test suite, but
who wants to write bash loops? Thankfully, most modern CI task runners contain
the ability to split jobs into separate processes programatically and so this
kind of logic is unnecessary.

Here's how to do this in Circle CI:

```yaml
test:
  parallelism: 5
  steps:
    - run: yarn test --shard=$(expr $CIRCLE_NODE_INDEX + 1)/$CIRCLE_NODE_TOTAL
```

Set a `parallelism` value, and drop the `jest` command into a cool one-liner.
The variable `CIRCLE_NODE_INDEX` refers to which container index the job is
running on, and `CIRCLE_NODE_TOTAL` points to the value of `parallelism`.

On Artsy.net, we've been able to reduce the average time it takes to run our
unit tests from around ~10 minutes per PR to just above 2m. A 4-5x performance
improvement.

## Parallelizing Cypress.io Integration Tests (For Free)

For those who want robust integration test coverage, [Cypress.io][cypress] has
been a game-changer due to its reliability and ease of use. Here at Artsy we use
it in a number of apps, most notably
[Integrity](https://github.com/artsy/integrity). One complaint, however, is just
how _slow_ it is. This is reasonable; Cypress is simulating a user browsing your
website and sometimes a user needs to do `x` and `y` (such as logging in) before
they can do `z`. At scale this can really slow things down and lead to
bottlenecks, especially if deploys are dependent on all of your integration
tests passing.

The Cypress.io team has recognized this bottleneck and released the
[Cypress Dashboard](https://docs.cypress.io/guides/dashboard/introduction), a
paid product which includes the ability to unlock parallelized tests on your CI.
For those willing to pay for another SAAS product this will get the job done
well, but for those with leaner budgets there's another way to accomplish this
for free, and on CircleCI it's very easy to setup via the
[CircleCI CLI command `split`](https://circleci.com/docs/parallelism-faster-jobs#using-the-circleci-cli-to-split-tests).

You can check out the
[full example here](https://github.com/artsy/force/blob/main/.circleci/config.yml#L219-L235),
but in short:

```yaml
integration:
  parallelism: 5
  run: |
    TESTS=$(circleci tests glob "cypress/integration" | circleci tests split | paste -sd ',')
    cypress run --spec $TESTS
```

We use the `circleci tests glob` command to gather all of our tests, and then
pipe that into the `circleci tests split` which will divide our tests into
buckets, similar to how Jest's `--shard` command works up above. We then assign
that to a `$TESTS` variable and pass it into `cypress run --spec $TESTS`.
CircleCI sees the `parallelism` prop in the config and automatically divides our
tests into 5 separate containers, each running a small subset of our integration
tests in parallel.

On Artsy.net, our smoke tests times have gone from around ~7m on average down to
~3m. A huge reduction for only a few lines of config!

[sharding]: https://jestjs.io/blog/2022/04/25/jest-28#sharding-of-test-run
[hot-swap]: https://github.com/artsy/express-reloadable
[swc]: https://github.com/artsy/force/pull/10598
[cypress]: https://www.cypress.io
