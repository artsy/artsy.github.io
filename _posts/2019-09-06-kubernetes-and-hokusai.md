---
layout: epic
title: "Kubernetes and Hokusai"
date: "2019-09-06"
author: [matt-dole]
categories: [artsy, beginners, engineering, hokusai, kubernetes, k8s]
---

When I joined Artsy Engineering a few months ago, I had roughly 0 knowledge of Kubernetes. I'd heard the term
thrown around a few times, but had no idea how it worked or what it was good for.

Kubernetes is still a bit of a mystery to me, but I'm able to do a lot of Kubernetes operations quickly and easily
thanks to an open-source tool developed at Artsy: [Hokusai](https://github.com/artsy/hokusai).

In this post, I'll give some background on Kubernetes, a brief history of Hokusai and a description of its
functionality, and some pointers for how to get started using it.

<!-- more -->

# What is Kubernetes?

On a high level, Kubernetes is a tool designed to _orchestrate containers at scale._

Let's break that down a bit. First, some helpful vocab:

**Container**: Effectively code + all necessary dependencies for an application. A
["standardized unit of software"](https://www.docker.com/resources/what-container).

**Pods**: Single instance of an application or process. Consists of one or more containers, though one container
per pod is the most common use case.

**Replicas**: Multiple instances of the same application, each running on its own pod.

**Node**: A physical or virtual machine that runs a pod or pods.

**Cluster**: A node or nodes managed by a "master" machine (which could be a physical computer or a virtual
machine - it's one node within the cluster).

**Container orchestration**: A systemized approach to managing containers. Allows for things like auto-scaling,
easy rollouts and rollbacks, and automation of container downtime (i.e. something goes wrong with a machine and
causes your app to crash; a new container gets spun up immediately so that your app doesn't go down).

Sources: [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/),
[Infoworld](https://www.infoworld.com/article/3268073/what-is-kubernetes-your-next-application-platform.html),
[Docker](https://www.docker.com/resources/what-container)

To sum up the general structure: a Kubernetes cluster contains nodes which contain pods which contain containers.
Not at all confusing, right?

Kubernetes, in a general sense, allows you to configure the containers in which your application will run. With a
properly configured Kubernetes cluster, this makes it easy to scale applications up or down as needed to deal with
traffic patters, maintain a zero-downtime deployment, and more. Very cool.

# What is Hokusai?

When Artsy's Engineering team was contemplating a move to Kubernetes from Heroku, we had beef with a few things.

For one, we wanted to be able to do a few core things simply and easily using the command line. While Kubernetes
has robust CLI tooling using [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), it's also very
complex. We wanted to be able to quickly and easily do the things we were used to doing with Heroku; we preferred
`heroku logs` to `kubectl logs [POD]` (where we would have to either look up or know the specific pod name we
wanted, even though pods are being spun up and taken down all the time).

[Helm](https://helm.sh), the de-facto package manager for Kubernetes, also didn't quite fit our needs. Helm is
great for big, complex implementations with Kubernetes, and it's very useful for managing releases. Artsy
Engineering wanted something that didn't involve quite as many complex charts, and we're not as concerned as some
orgs with versioned releases since our focus is mostly on web apps.

Basically, we wanted our commands to be application-level instead of pod- or node-level. We wanted a little more
abstraction than was offered by `kubectl`, and a little less than Helm.

And there was the issue of review apps. Review apps are basically standalone versions of an application that fall
completely outside a normal production pipeline. They allow you to test big or scary changes in functionality
without even putting them on a staging instance (which could affect other developers' work or be deployed
accidentally).

Kubernetes doesn't support review apps out of the box. There are some add-ons that offer them, but at the time
Artsy was looking to switch, I don't think they existed or were widespread.

Thus was born Hokusai: a tool that makes interacting with applications deployed on Kubernetes from the command line
simple. Need logs? `hokusai production logs`. Or a review app? There are a
[few steps involved](https://github.com/artsy/hokusai/blob/master/docs/Review_Apps.md), but you can have a
fully-featured copy of your app up and running in a few minutes.

The end of this post has a larger cheatsheet for handy Hokusai commands, but for now, let's talk about how you can
use it yourself.

# How can I set up Hokusai with my project?

I should begin by noting that Hokusai is currently only meant to work with AWS - if your application is running on
a different provider, you might have to hold off on Hokusai for now :( (or
[open a PR in Hokusai](https://github.com/artsy/hokusai) yourself!)

Installing hokusai is super easy! You can see full instructions in the README on
[GitHub](https://github.com/artsy/hokusai), but if you're already set up with Python, pip, Docker, Docker Compose,
and Git, you can do a quick install with Homebrew:

```
$ brew tap artsy/formulas
$ brew install hokusai
```

There's more robust directions
[in the Hokusai repo](https://github.com/artsy/hokusai/blob/master/docs/Getting_Started.md), but the very short
version is that `hokusai setup` to handle most of the basics (creation of a Dockerfile, a config folder, and a few
other bits and bobs). From there, you can customize according to the needs of your project.

You should also check out Ash's [great post](https://artsy.github.io/blog/2018/01/24/kubernetes-and-hokusai/) on
setting up a new Hokusai project - he runs through the process of setting up a new Rails application with Hokusai
in an easy-to-follow way that also details small hitches he ran into along the way.

# What's next for Hokusai?

As Hokusai has grown and changed over the years (the GH repo was created in November 2016!), a few things have
changed.

For one, it's been increasingly used in coordination with CircleCI. Hokusai has made it really easy to standardize
a lot of application configuration across Artsy's applications. We have
[CircleCI orbs](https://github.com/artsy/orbs/blob/master/src/hokusai) set up for Hokusai specifically, which allow
us to maintain one copy of our Hokusai config across multiple applications utilizing CircleCI. Given how helpful
it's been to have a single source of CircleCI config for many of our apps, we're pondering the idea of a central
source for Kubernetes Hokusai config. In other words, we'd like to have a "baseline" for things like deployments -
something that could be overriden as necessary in specific projects but would make spinning up new projects easy.
And it would hopefully make it easy to update deployment strategies for many apps at the same time...we'll see
where we land.

Interested in contributing? Hokusai is
[open source](https://artsy.github.io/blog/2019/04/29/how-did-artsy-become-oss-by-default/) and we'd love to hear
from you!

# Appendix A: Useful Hokusai commands

These are the commands I find myself using on a regular basis. If you're playing around with Hokusai, you can also
run most commands with `--help` to get more information on their usage.

- `hokusai [production|staging] env get`: Print all of the environment variables from your application's pod
- `hokusai [production|staging] env set "ENV=value"`: Set an environment variable on your application's pod
- `hokusai [production|staging] run 'bundle exec rails c' --tty`: Open a Rails console for your app (I have this
  one aliased to `hokusai-[production|staging]-console`)
- `hokusai [production|staging] refresh`: Refresh the application's deployment by recreating its containers
- `hokusai build`: Build your application's Docker image as defined in a `hokusai/build.yml` file
- `hokusai test`: Boot a test environment and run a test suite as defined in `hokusai/test.yml`
- `hokusai pipeline gitcompare --org-name [org]`: Spits out a URL for a git comparison between production and
  staging images
- `hokusai pipeline gitlog`: Print a git log for commits between the image deployed on production and the image on
  staging. Handy if you need to get the SHA of a staged commit quickly, e.g. for rollback purposes (?)
