---
layout: post
title: Beat Heroku's 60 Seconds Application Boot Timeout with a Proxy
date: 2012-12-13 21:21
comments: true
categories: [Heroku,ruby,em-proxy]
author: db
---

<img src="/images/2012-12-13-beat-heroku-60-seconds-application-boot-timeout-with-a-proxy/heroku-logo-light-234x60.png">

Heroku will log an [R10 - Boot Timeout](https://devcenter.heroku.com/articles/error-codes#r10-boot-timeout) error when a web process takes longer than 60 seconds to bind to its assigned port. This error is often caused by a process being unable to reach an external resource, such as a database or because you have a lot of gems in your `Gemfile` which take a long time to load.

```
Dec 12 12:12:12 prod heroku/web.1:
  Error R10 (Boot timeout)
  Web process failed to bind to $PORT within 60 seconds of launch
```

There's currently no way to increase this boot timeout, but we can beat it with a proxy implemented by our new [heroku-forward](https://github.com/dblock/heroku-forward) gem.

<!-- more -->

The concepts for `heroku-forward` come from [this article](http://noverloop.be/beating-herokus-60s-boot-times-with-the-cedar-stack-and-a-reverse-proxy/) by Nicolas Overloop. The basic idea is to have a proxy bind to the port immediately and then buffer requests until the backend came up. The proxy implementation is Ilya Grigorik's [em-proxy](https://github.com/igrigorik/em-proxy). Communication between the proxy and the backend happens over a unix domain socket (a file), which needed a bit of work (see [#31](https://github.com/igrigorik/em-proxy/pull/31)), inspired by an excellent article, [Fighting the Unicorns: Becoming a Thin Wizard on Heroku](http://jgwmaxwell.com/fighting-the-unicorns-becoming-a-thin-wizard-on-heroku) by JGW Maxwell. The `heroku-forward` gem connects all the dots.

Check out the gem's [README](https://github.com/dblock/heroku-forward/blob/master/README.md) for how to set it up.

Here's the log output from an application that uses this gem. Notice that Heroku reports the state of `web.1` up after just 4 seconds, while the application takes 67 seconds to boot.

```
2012-12-11T23:33:42+00:00 heroku[web.1]: Starting process with command `bundle exec ruby config.ru`
2012-12-11T23:33:46+00:00 app[web.1]:  INFO -- : Launching Backend ...
2012-12-11T23:33:46+00:00 app[web.1]:  INFO -- : Launching Proxy Server at 0.0.0.0:42017 ...
2012-12-11T23:33:46+00:00 app[web.1]: DEBUG -- : Attempting to connect to /tmp/thin20121211-2-1bfazzx.
2012-12-11T23:33:46+00:00 app[web.1]:  WARN -- : no connection, 10 retries left.
2012-12-11T23:33:46+00:00 heroku[web.1]: State changed from starting to up
2012-12-11T23:34:32+00:00 app[web.1]: >> Thin web server (v1.5.0 codename Knife)
2012-12-11T23:34:32+00:00 app[web.1]: >> Maximum connections set to 1024
2012-12-11T23:34:32+00:00 app[web.1]: >> Listening on /tmp/thin20121211-2-1bfazzx, CTRL+C to stop
2012-12-11T23:34:53+00:00 app[web.1]: DEBUG -- : Attempting to connect to /tmp/thin20121211-2-1bfazzx.
2012-12-11T23:34:53+00:00 app[web.1]: DEBUG -- : Proxy Server ready at 0.0.0.0:42017 (67s).
```

You can read more about how we use Heroku at [http://success.heroku.com/artsy](http://success.heroku.com/artsy).
