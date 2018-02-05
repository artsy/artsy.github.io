---
layout: post
title: "In the 'Whelp!' of the Great Wave"
date: 2018-01-24
comments: true
author: ash
categories: [kubernetes, hokusai, open-source, danger]
series: Apogee
---

This past week has found me working on a brand new Rails project. Now, if I was building this project for my personal needs, I would without a doubt deploy it to [Heroku][] – for both the ease of use and the high level of abstraction that [Dynos][] afford. But I'm not building this for myself, I'm building it for my team.

<!-- more -->

While Heroku is easy to get started with, costs scale up quickly. And, as described in our [2017 tech stack post][stack], our team is moving more and more towards [Kubernetes][]. I had almost no experience with Kubernetes before last week, and I was intimidated by the Kubernetes web UI. With some help from my colleague Isac, who wrote the [Hokusai][] tool, I was able to get a staging environment up and running in under a day.

But let's step back first.

My background is in iOS software development, so spinning up new servers isn't something I do often. When I _do_, I usually use Heroku. After deploying to it, it feels like Kubernetes is a kind of hosted Heroku: it handles scaling up instances, managing worker/db/other instances, load-balancers, environment variables, promoting from staging to production – all that stuff. But Kubernetes' sophistication comes with a sophisticated user interface. 

So basically, Hokusai is to Kubernetes what the Heroku command-line tool is to the Heroku platform.

Hokusai provides [a bunch of commands][commands] for interacting with the Kubernetes cluster. Deploying my new Rails app to Kubernetes involved a few steps, but most of the work was handled automatically by Hokusai.

First, I installed and setup Hokusai locally (with required environment variables for AWS access). I then ran the following command to scaffold out everything.

```sh
hokusai setup --aws-account-id ARTSY_ACCOUNT_ID --project-type ruby-rails
```

In addition to staging- and production-specific config files, this command creates a `Dockerfile`. See, where Heroku uses Dynos as a high level of abstraction, Kubernetes uses [Docker][] images (as a slightly less high a level of abstraction). Docker is a technology I'm familiar with, and I managed to configure the generated `Dockerfile` and `hokusai/*.yml` config files pretty quickly. At this point, I could run `hokusai dev start` to start a development Docker container, or `hokusai test` to run RSpec tests. Nothing fancy yet, but that verifies that everything is working so far.

Next up was to use Hokusai in our CI environment. [Circle CI 2.0][circle] is very Docker-oriented, so we set up everything using their [Workflows][]. This is a much higher level of abstraction for CI configuration than I'm used to, but I got the hang of it quickly. I created a job to run RSpec tests through Hokusai, a job to run [Danger][], a job to build and push a Docker image to our S3 bucket, and a job to deploy that image to the Kubernetes cluster. Finally, I added the workflows to build and deploy automatically after successful builds on the `master` branch.

Here's a slightly redacted copy of our Circle config:

```yaml
version: 2
jobs:
  test:
    docker:
      - image: artsy/hokusai:0.4.0
    working_directory: ~/REPO_NAME
    steps:
      - add_ssh_keys
      - checkout
      - setup_remote_docker
      - run:
          name: Test
          command: hokusai test
  danger:
    docker:
      - image: circleci/ruby:2.5.0
    working_directory: ~/apogee
    steps:
      - checkout
      - restore_cache:
          keys:
          - v1-dependencies-{{ checksum "Gemfile.lock" }}
          - v1-dependencies-
      - run:
          name: Install Dependencies
          command: bundle install --with=ci --without development test --path vendor/bundle
      - save_cache:
          paths:
            - ./vendor/bundle
          key: v1-dependencies-{{ checksum "Gemfile.lock" }}
      - run:
          name: Danger
          command: bundle exec danger
  push:
    docker:
      - image: artsy/hokusai:0.4.0
    steps:
      - add_ssh_keys
      - checkout
      - setup_remote_docker
      - run:
          name: Push
          command: hokusai registry push --tag $CIRCLE_SHA1 --force --overwrite
  deploy:
    docker:
      - image: artsy/hokusai:0.4.0
    steps:
      - add_ssh_keys
      - checkout
      - run:
          name: Configure
          command: hokusai configure --kubectl-version 1.6.3 --s3-bucket BUCKET_NAME --s3-key k8s/config --platform linux
      - run:
          name: Deploy
          command: hokusai staging deploy $CIRCLE_SHA1
workflows:
  version: 2
  default:
    jobs:
      - test
      - danger:
          filters:
            branches:
              ignore: master
      - push:
          filters:
            branches:
              only: master
          requires:
            - test
      - deploy:
          filters:
            branches:
              only: master
          requires:
            - push
```

The initial build on `master` built and pushed the server image, but the deploy failed. This is an [issue][] that's being tracked in Hokusai – I'm sure it'll get addressed on the road to a 1.0. To explain, it's a Catch-22: we can't deploy until we have an image, but we only want to build images on CI, so the first deploy on CI is expected to fail.

Once the initial image was pushed, I ran `hokusai staging env create` locally to create the staging environment. I was able to set staging environment variables using `hokusai staging env set NAME=VALUE`, but unlike Heroku, I had to manually restart the server using `hokusai staging refresh` after adding the environment variables. 

At this point, my server was working behind a load balancer, but I still had to add a CNAME record for the `really-long-url.elb.amazonaws.com` domain name. After some DNS propagation, everything worked fine!

So that's it! I was apprehensive about moving to a totally new (to me) deploy infrastructure. But, it's a direction our engineering team has decided to go in, and there's no better time to migrate to a new deploy infrastructure than before your first deploy. With some encouragement and help from my team, I was able to get the entire thing working in under a day (next time will be a lot faster).

I'm very encouraged by Kubernetes. It offers really slick, enterprise-level scaling features in an open source tool. And I've heard really great things about its community practices. Kubernetes is, however, a very specialized tool and its web interface doesn't make any sense to me. With Hokusai, I got a very programmer-friendly interface for a very DevOps-focused tool.

[Heroku]: https://www.heroku.com
[Dynos]: https://www.heroku.com/dynos
[stack]: http://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017/
[Kubernetes]: https://kubernetes.io
[Hokusai]: https://github.com/artsy/hokusai
[commands]: https://github.com/artsy/hokusai/blob/master/docs/Command_Reference.md
[circle]: https://circleci.com/docs/2.0/
[Danger]: http://danger.systems
[Docker]: https://www.docker.com
[Workflows]: https://circleci.com/docs/2.0/workflows/
[issue]: https://github.com/artsy/hokusai/issues/50
