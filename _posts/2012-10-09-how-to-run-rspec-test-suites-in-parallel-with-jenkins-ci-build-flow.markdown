---
layout: post
title: How to Run RSpec Test Suites in Parallel with JenkinsCI Build Flow
date: 2012-10-09 21:21
comments: true
categories: [Continuous Integration, Testing, RSpec]
author: db
---
We now have over 4700 RSpec examples in one of our projects. They are stable, using the techniques described in an [earlier post](/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/) and organized in [suites](/blog/2012/05/15/how-to-organize-over-3000-rspec-specs-and-retry-test-failures/). But they now take almost 3 hours to run, which is clearly unacceptable.

To solve this, we have parallelized parts of the process with existing tools, and can turn a build around in just under an hour. This post will dive into our [Jenkins](http://jenkins-ci.org/) build flow setup.

To keep things simple, we're going to only build the `master` branch. When a change is committed on `master` we're going to push `master` to a `master-ci` branch and trigger a distributed build on `master-ci`. Once all the parts have finished, we'll complete the build by pushing `master-ci` to `master-succeeded` and notify the dev team of success or failure.

Here's a diagram of what's going on.

<img src="/images/2012-10-09-how-to-run-rspec-test-suites-in-parallel-with-jenkins-ci-build-flow/master-ci.png">

<!-- more -->

Plugins
-------

Install the [Build Flow](https://wiki.jenkins-ci.org/display/JENKINS/Build+Flow+Plugin) and the [Parameterized Trigger](https://wiki.jenkins-ci.org/display/JENKINS/Parameterized+Trigger+Plugin) plugin. Grant `Anonymous` job read permissions in Jenkins system configuration (see [JENKINS-14027](https://issues.jenkins-ci.org/browse/JENKINS-14027)).

Create the following Jenkins jobs.

master-prequel
--------------

A free-style job that connects to the SCM, in our case Git.

* Set SCM repository URL to your Git repo, eg. `git@github.com:spline/reticulator.git`
* Change the default branch specifier from `**` to `master`. We'll be pushing a `master-ci` branch, which could, in turn, cause more builds if you don't do this.
* Add a post-build action to build another project. Trigger the `master` project if the build succeeds.

master
------

This is a build-flow job. We'll describe the individual tasks that the flow invokes further. The flow DSL looks as follows.

``` ruby
build("master-ci-init")
parallel (
 { build("master-ci-task", tasks: "spec:suite:models:ci") },
 { build("master-ci-task", tasks: "spec:suite:api:ci") },
 { build("master-ci-task", tasks: "spec:suite:integration:ci") }
)
build("master-ci-succeeded")
```

This is a good place to add an e-mail notification post-build action for every unstable build.

master-ci-init
--------------

A free-style job that creates the `master-ci` branch from master. It needs to be connected to your SCM and executes the following shell script.

``` bash
#!/bin/bash
git checkout $GIT_BRANCH
git push origin -f $GIT_BRANCH:$GIT_BRANCH\-ci
```

Note that we cannot combine this task with `master-prequel`, because we have to make sure the branch creation runs once under the entire flow, while `master-prequel` can be run multiple times, once per check-in. Otherwise the `master-ci` branch could get updated before a `master-ci-task` runs from a previous flow execution.

master-ci-task
--------------

A parameterized build that accepts a `tasks` parameter that the flow will pass in.

Change the default branch specifier to `master-ci` and execute the following shell script.

``` bash
#!/bin/bash
bundle install
bundle exec rake $tasks
```

This example runs `rake $tasks`, which we define to be various test suites in our flow DSL. Our test suite setup is described in [this post](/blog/2012/05/15/how-to-organize-over-3000-rspec-specs-and-retry-test-failures/). Your mileage may vary.

master-ci-succeeded
-------------------

This is an optional step. We use this free-style job to tag `master-ci` as `master-succeeded` with the following shell script.

``` bash
#!/bin/bash
git checkout $GIT_BRANCH
git push origin -f $GIT_BRANCH:${GIT_BRANCH/%-ci/}-succeeded
```

Our deployment to production will pickup the `master-succeeded` branch when it's time.

Improvements?
-------------

I see a few possible improvements here that might require a bit of work.

* The ability to split an RSpec suite up across an arbitrary number N sub-jobs and M executors would create an optimal parallel split based on the resources available.
* Passing the value of `GIT_BRANCH` and `GIT_COMMIT` across these jobs would enable building any branch and eliminate the need for `master-ci-init`.
* Build flow could support SCM polling the same way as free-style jobs, avoiding the need for `master-prequel`. We weren't able to get a stable notification of changes from Github with the Jenkins Github plugin.

Please suggest further improvements in the comments below!

(Update: See [Splitting up a large test suite](/blog/2015/09/24/splitting-up-a-large-test-suite/) for a modified approach that splits work approximately evenly among an arbitrary number of sub-jobs.)
