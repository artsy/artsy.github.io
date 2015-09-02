---
layout: post
title: 'Cocoa Architecture: Dropped Design Patterns'
date: 2015-09-01T00:00:00.000Z
comments: false
categories:
  - ios
  - mobile
  - architecture
  - eigen
  - energy
author: Orta Therox
github-url: 'https://www.github.com/orta'
twitter-url: 'http://twitter.com/orta'
blog-url: 'http://orta.io'
---

As a part of going through the design patterns we've found in the creation of the Artsy iOS apps, I'd like to talk a bit about some of the patterns that we've had and migrated away from. This is not 100% comprehensive, as there has been a lot of time, and a lot of people involved. Instead I'm going to try and give a birds eye view, and zoom in on some things that feel more important overall.

<!-- more -->
--------------------------------------------------------------------------------

### NSNotifications as a decoupling method

A lot of the initial codebase for eigen relied on using NSNotifications as a way of passing messages throughout the application. There were notifications for user settings changes, download status updates, anything related to authentication and the corrosponding different error states and a few app features. These relied on sending global notifications with very little attempts at scoping the relationship between objects.

NSNotificationCenter notifications are an implementation of the [Observer Pattern](https://en.wikipedia.org/wiki/Observer_pattern) in Cocoa. They are a beginner to intermediate programmers design paradigm dream. It offers a way to have objects send messages to each other without having to go through any real coupling. As someone just starting on iOS ( I had mostly been a OS X programmer before starting at Artsy ) it was an easy choice to adapt. 

One of the biggest downsides of using NSNotifications are that they make it easy to be lazy as a programmer. It allows you to not think carefully about the realtionships between your objects and instead to pretend that they are loosely coupled, when instead they are coupled but via stringly typed notifications.

Loose-coupling can have it's place but without being careful there is no scope on what could be listening to any notification. Also de-registering for interest can be a tricky thing [to learn](http://stackoverflow.com/questions/tagged/nsnotification) and the default memory-management behavior is about to change ( [for the better](https://developer.apple.com/library/prerelease/mac/releasenotes/Foundation/RN-Foundation/index.html#//apple_ref/doc/uid/TP30000742).)

We still have a [lot of notifications](https://github.com/artsy/energy/blob/702036664a087db218d3aece8ddddb2441f931c8/Classes/Constants/ARNotifications.h) in Energy, however in Eigen and Eidolon there are next to none. We don't even have a specific file for the constants.

### 