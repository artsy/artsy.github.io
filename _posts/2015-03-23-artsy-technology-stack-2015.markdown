---
layout: post
title: Artsy's Technology Stack, 2015
date: 2015-03-23
comments: true
categories: [Technology, force]
author: db
series: Artsy Tech Stack
---
Artsy has now grown past 100 team members and our Engineering organization is now 20 strong. For a brief overview of what the company has accomplished in the last two years, check out our [2013](http://2013.artsy.net) and [2014](http://2014.artsy.net) reviews.

This is a good opportunity to describe our updated technology stack. Last time [we did this](/blog/2012/10/10/artsy-technology-stack) was when Artsy launched publicly in 2012.

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/stats.png'></center>

Three years ago Artsy was a classic [Ruby-on-Rails](http://rubyonrails.org) monolith with a handful of adjacent processes and tools. We've since broken it up into many independent services, and continue to heavily be a Ruby and JavaScript shop, using Rails where appropriate, with native code on mobile devices and some JVM-based experiments in micro-services.

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/languages.png'></center>

<!-- more -->

What you see today when you go to [www.artsy.net](https://www.artsy.net) is a website built with [Ezel.js](https://github.com/artsy/ezel), which is a boilerplate for [Backbone](http://backbonejs.org) projects running on [Node](https://nodejs.org) and using [Express](http://expressjs.com) and [Browserify](http://browserify.org). The [CoffeeScript code](https://github.com/artsy/force) is open-source. The mobile version of www.artsy.net is [m.artsy.net](https://m.artsy.net) and is built on the same technology. Both run on [Heroku](http://heroku.com) and use [Redis](http://redis.io) for caching. Assets, including artwork images, are served from [Amazon S3](http://aws.amazon.com/s3/) via the [CloudFront CDN](http://aws.amazon.com/cloudfront).

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/artsy.png'></center>

These web applications talk to a private Ruby API built with [Grape](https://github.com/intridea/grape), that serves JSON. We also have a more modern and better designed [public HAL+JSON API](https://developers.artsy.net). For historical reasons, both are hosted side-by-side on top of a big Rails app that used to be our original monolith. The API service runs on [AWS OpsWorks](http://aws.amazon.com/opsworks) and retrieves data from several [MongoDB](http://www.mongodb.com) databases hosted with [Compose](https://www.compose.io). It also uses [Apache Solr](http://lucene.apache.org/solr), [Elastic Search](https://www.elastic.co) and [Google Custom Search](https://www.google.com/cse). The API service also heavily relies on [Memcached](http://memcached.org).

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/developers.png'></center>

Our partners upload artworks, artists and other metadata via a home-grown content-management system built entirely from scratch in 2014 on Ruby-on-Rails. This was a deliberate ["boring"](http://chris.eidhof.nl/posts/boring-choice.html) choice that continues to serve us very well. We have adopted a common model for admin-type apps with a shared component library and a reusable UI, all implemented as Rails engines. Using these components we are able to quickly and easily compose beautiful and useful applications - we have built dedicated systems to manage fairs and auctions. We standardized on related services as well - for example, our customers interact with us via [Intercom](https://www.intercom.io). We're also experimenting with some new technologies in our internal apps, notably [React](http://facebook.github.io/react).

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/cms.png'></center>

Our family of mobile applications includes [Artsy for iOS](http://iphone.artsy.net), which is a hybrid app written in Objective-C, and a [bidding kiosk](https://github.com/artsy/eidolon), written in Swift. Both are open-source [here](https://github.com/artsy/eigen) and [here](https://github.com/artsy/eidolon).

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/folio.jpg'></center>

A lot of data, including the artwork similarity graph that powers The Art Genome Project, is processed offline by a generic job engine, written in Ruby or by [Amazon Elastic MapReduce](http://aws.amazon.com/elasticmapreduce). We take data snapshots from MongoDB, run jobs on the data and export data back to the database. Other recently rewritten services include image processing, which creates thumbnails, image tiles for deep zoom and watermarks high quality JPEGs. Several new applications use [PostgreSQL](http://www.postgresql.org).

Various front-ends pipe data to [Snowplow](https://github.com/snowplow/snowplow) and [Segment](https://segment.com), which forwards events to [Keen](https://keen.io), [Google Analytics](http://www.google.com/analytics), [MixPanel](https://mixpanel.com) and [ChartBeat](https://chartbeat.com). Some data is warehoused in [AWS Redshift](http://aws.amazon.com/redshift) and [PostgreSQL](http://www.postgresql.org) and may be analyzed offline using [R](http://www.r-project.org) or [iPython Notebooks](http://ipython.org/notebook.html). We also have a [Statsd](https://github.com/etsy/statsd) and [Graphite](http://graphite.wikidot.com) system for tracking high volume, low-level counters. Finally, it's also fairly common to find a non-Engineer at Artsy in a read-only Rails console or in Redshift directly querying data.

We send millions of e-mails via [SendGrid](http://sendgrid.com/) and [Mandrill](https://mandrill.com) and use [MailChimp](http://mailchimp.com) for manual campaigns.

Smaller systems usually start on [Heroku](https://dashboard.heroku.com) and larger processes that perform heavier workloads usually end up on [AWS OpsWorks](http://aws.amazon.com/opsworks). Our systems are monitored by a combination of [New Relic](http://newrelic.com/) and [Pingdom](https://www.pingdom.com). All of this is built, tested and continuously deployed with [Jenkins](http://jenkins-ci.org), [Semaphore](https://semaphoreci.com), and [Travis-CI](https://travis-ci.org).

<center><img src='/images/2015-03-23-artsy-technology-stack-2015/gravity.png'></center>

In terms of Engineering workflow we live in [Github](https://github.com) and [Trello](https://trello.com). We tend to have a workflow similar to open-source projects with individuals owning components and services and the entire team contributing to them.

In 2015 we intend to complete our transformation into small independent services built with 10x growth in mind. We can then focus on maturing the Artsy platform both vertically and horizontally and enabling many new directions for our thriving businesses.

We hope you find this useful and will be happy to describe any detailed aspect of our system on this blog. We're always hiring, please e-mail <a href='mailto:jobs@artsy.net'>jobs@artsy.net</a> if you want to work with us. Finally, we welcome any questions here and look forward to answering them below!
