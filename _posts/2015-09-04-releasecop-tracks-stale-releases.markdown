---
layout: post
title: "Releasecop Tracks Stale Releases"
date: 2015-09-01 17:30
comments: true
author: joey
categories: [Ruby, open source, OSS, testing, Continuous Integration, Continuous Deployment, devops, tools]
---

Artsy practices a sort of [continuous delivery](http://en.wikipedia.org/wiki/Continuous_delivery). We keep release cycles short and the process of reviewing, testing, and deploying our software as reliable, fast, and automated as possible. (This blog has touched on these practices [multiple](http://artsy.github.io/blog/categories/testing/) [times](http://artsy.github.io/blog/categories/continuous-integration).)

Usually, commits that have been reviewed and merged are immediately built and tested. Successfully built versions of the codebase are often automatically deployed to a staging environment. On an automated or frequent-but-manual basis, that version is deployed to a production environment. Thus, commits form a pipeline:

* From developers' working branches
* To the master branch
* Through a hopefully-successful build
* To a staging environment
* To production

The number of apps and services we deploy has grown to _dozens_ per team, so sometimes things fall through the cracks. We've been using [Releasecop](https://github.com/joeyAghion/releasecop) for the last few months to get gentle email reminders when an environment could use a deploy.

<!-- more -->

    gem install releasecop
    releasecop edit

This opens a _manifest_ file where you can describe the sequence of git remotes and branches that make up your own release pipeline. For example:

    {
      "projects": {
        "charge": [
          { "name": "master", "git": "git@github.com:artsy/charge.git" },
          { "name": "staging", "git": "git@heroku.com:charge-staging.git" },
          { "name": "production", "git": "git@heroku.com:charge-production.git" }
        ],
        "gravity": [
          { "name": "master", "git": "git@github.com:artsy/gravity.git" },
          { "name": "master-succeeded", "git": "git@github.com:artsy/gravity.git", "branch": "master-succeeded" },
          { "name": "staging", "git": "git@github.com:artsy/gravity.git", "branch": "staging" },
          { "name": "production", "git": "git@github.com:artsy/gravity.git", "branch": "production" }
        ]
      }
    }

The `charge` app is a typical deployment to Heroku. Work progresses from the `master` branch to a `charge-staging` app to a `charge-production` app. The `gravity` app is a more complicated, non-Heroku deployment. It updates git branches to reflect what has been merged (`master`), tested (`master-succeeded`), deployed to staging, and deployed to production.

Run the `releasecop check [app]` command to report the status of your apps' releases:

    $ releasecop check --all
    charge...
      staging is up-to-date with master
      production is up-to-date with staging
    gravity...
      master-succeeded is up-to-date with master
      staging is up-to-date with master-succeeded
      production is behind staging by:
        06ca969 2015-09-04 [config] Replace Apple Push Notification certificates that expire today. (Eloy Durán)
        171121f 2015-09-03 Admin-only API for cancelling a bid (Matthew Zikherman)
        4c5feea 2015-09-02 install mongodb client in Docker so that import rake tasks can run (Barry Hoggard)
        95347d1 2015-08-31 Update to delayed_job cookbook that works with Chef 11.10 (Joey Aghion)
    2 project(s) checked. 1 environment(s) out-of-date.

A nightly [Jenkins](https://jenkins-ci.org/) job emails us the results, but a cron job could work equally well.

[Releasecop](https://github.com/joeyAghion/releasecop) reminds us to deploy ready commits and close the loop on in-progress work. We hope you find it useful. (Pull requests are welcome!)
