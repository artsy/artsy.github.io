---
layout: epic
title: "Kubernetes and Hokusai"
date: "2019-09-06"
author: [matt-dole]
categories: [artsy, beginners, engineering, hokusai, kubernetes, k8s]
---

When I joined Artsy Engineering a few months ago, I had roughly 0 knowledge of Kubernetes. I'd heard the term
thrown around a few times, but had no idea how it worked or what it was good for.

Artsy also has a super cool wrapper that we use to emulate a lot of Heroku CLI functionality for Kubernetes (and to
do some other awesome stuff, read on for deets). It's fully open-source, and you should think about adopting it if
you or your company uses Kubernetes.

Read on for the full scoop.

<!-- more -->

# What is Kubernetes?

If you already have a good idea of what Kubernetes is and how it works, feel free to skip this section. Since I
still find Kubernetes pretty confusing, I thought I'd start by breaking down the basics.

Kubernetes is a tool designed to _orchestrate containers at scale._

Let's break that down a bit. First, some helpful vocab:

**Container**: Effectively code + all necessary dependencies for an application. A
["standardized unit of software"](https://www.docker.com/resources/what-container).

**Pods**: Single instance of an application or process. Consists of one or more containers, though one container
per pod is the most common use case.

**Replicas**: Multiple instances of the same application, each running on its own pod.

**Node**: A physical or virtual machine that runs a pod or pods.

**Cluster**: A node or nodes managed by a "master" machine.

**Container orchestration**: A systemized approach to managing containers. Allows for things like auto-scaling,
easy rollouts and rollbacks, and automation of container downtime (i.e. something goes wrong with a machine and
causes your app to crash; a new container gets spun up immediately so that your app doesn't go down).

Sources: [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/),
[Infoworld](https://www.infoworld.com/article/3268073/what-is-kubernetes-your-next-application-platform.html),
[Docker](https://www.docker.com/resources/what-container)

To sum up the general structure: a Kubernetes cluster contains nodes which contain pods which contain containers.
Not at all confusing, right?

Kubernetes, in a general sense, allows you to configure the containers in which your application will run. If
everything goes as expected, this makes it easy to scale applications up or down as needed to deal with traffic
patters, maintain a zero-downtime deployment, and more. Very cool.

# What is Hokusai?

When Artsy's Engineering team was contemplating a move to Kubernetes from Heroku, they had beef with a few things
(I'll refer to the team as "they" when discussing the past since I wasn't actually part of the team yet).

For one, they wanted to be able to do a few core things simply and easily using the command line. While Kubernetes
has robust CLI tooling using [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/), it's also very
complex. They wanted to be able to quickly and easily do the things they were used to doing with Heroku; they
preferred `heroku logs` to `kubectl logs [POD]` (where they would have to either look up or know the specific pod
name they wanted, even though pods are being spun up and taken down all the time).

Basically, they wanted their commands to be application-level instead of pod- or node-level. They wanted a little
more abstraction.

And there was the issue of review apps. Review apps are basically standalone versions of an application that fall
completely outside a normal production pipeline. They allow you to test big or scary changes in functionality
without even putting them on a staging instance (which could affect other developers' work or be deployed
accidentally).

Kubernetes doesn't support review apps out of the box. There are some add-ons that offer them, but at the time
Artsy was looking to switch, I don't think they existed or were widespread.

Thus was born Hokusai: a tool that makes interacting with applications deployed on Kubernetes from the command line
simple.

# How can I set up Hokusai with my project?

Could I set up a whole new k8s cluster and Hokusai with it? Would be super cool, but I feel like it might cost
money

Or migrating an existing Artsy app to k8s? Joey just mentioned Gemini

# What's next for Hokusai?

# Appendix A: Useful Hokusai commands

List out a bunch of commands that we use on a regular basis and break down what's happening in them

`hokusai production env get` `hokusai production env set`
