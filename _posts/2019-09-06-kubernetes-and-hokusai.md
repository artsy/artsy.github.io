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

Kubernetes is a tool designed to _orchestrate containers_ at scale.

Let's break that down a bit. First, some helpful vocab:

**Container**: Effectively code + all necessary dependencies for an application. A
["standardized unit of software"](https://www.docker.com/resources/what-container).

**Cluster**: Multiple containers being managed by Kubernetes.

**Nodes**: Physical or virtual machines that run pods.

**Pods**: A single instance of an application or process. Consists of one or more containers.

**Container orchestration**: A systemized approach to managing containers. Allows for things like auto-scaling,
easy rollouts and rollbacks, and automation of container downtime (i.e. something goes wrong with a machine and
causes your app to crash; a new container gets spun up immediately so that your app doesn't go down).

Sources: [Kubernetes docs](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/),
[Infoworld](https://www.infoworld.com/article/3268073/what-is-kubernetes-your-next-application-platform.html),
[Docker](https://www.docker.com/resources/what-container)

So, in effect, Kubernetes allows you to configure the containers in which your application will run. If everything
goes as expected, this makes it easy to scale applications up or down as needed to deal with traffic patters,
maintain a zero-downtime deployment, and more. Very cool.

# What is Hokusai?

General overview

# How can I set up Hokusai with my project?

Could I set up a whole new k8s cluster and Hokusai with it? Would be super cool, but I feel like it might cost
money

Or migrating an existing Artsy app to k8s? Joey just mentioned Gemini

# What's next for Hokusai?

# Appendix A: Useful Hokusai commands

List out a bunch of commands that we use on a regular basis and break down what's happening in them

`hokusai production env get` `hokusai production env set`
