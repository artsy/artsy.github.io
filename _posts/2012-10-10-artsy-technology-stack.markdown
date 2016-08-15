---
layout: post
title: Artsy's Technology Stack
date: 2012-10-10 21:21
comments: true
categories: [Technology]
author: db
series: Artsy Tech Stack
---
The public launch of Artsy via the [New York Times](http://www.nytimes.com/2012/10/09/arts/design/artsy-is-mapping-the-world-of-art-on-the-web.html) is a good opportunity to describe our current technology stack.

What you see when you go to [Artsy](http://artsy.net) is a website built with [Backbone.js](http://backbonejs.org/) and written in [CoffeeScript](http://coffeescript.org/). It renders JSON data from [Ruby on Rails](http://rubyonrails.org/), [Ruby Grape](https://github.com/intridea/grape) and [Node.js](http://nodejs.org/) services. Text search is powered by [Apache Solr](http://lucene.apache.org/solr/). We also have an [iOS](https://developer.apple.com/devcenter/ios/index.action) application that talks to the same back-end Ruby API. We run all our web processes on [Heroku](http://www.heroku.com/) and all job queues on [Amazon EC2](http://aws.amazon.com/). Our data store is [MongoDB](http://www.mongodb.org/), operated by [MongoHQ](https://mongohq.com/) and we have some [Redis](http://redis.io/) instances. Our assets, including images, are served from [Amazon S3](http://aws.amazon.com/s3/) via the [CloudFront CDN](http://aws.amazon.com/cloudfront/). We heavily rely on [Memcached](http://memcached.org/) Heroku addon and we use [SendGrid](http://sendgrid.com/) and [MailChimp](http://mailchimp.com/) to send e-mail. Systems are monitored by a combination of [New Relic](http://newrelic.com/) and [Pingdom](https://www.pingdom.com/). All of this is built, tested and deployed with [Jenkins](http://jenkins-ci.org/).

<img src="/images/2012-10-10-artsy-technology-stack/artsy-infrastructure.png">

In this post I'll go in depth in our current system architecture and tell you the story about how these parts all came together.

<!-- more -->

Early Prototypes
----------------

Artsy early prototypes in 2010 consisted of a combination of PHP and Java web services running on JBoss and backed by a MySQL database. The system had more similarities with a large transactional banking application than a consumer website.

In early 2011 we rebooted the project on Ruby on Rails. RDBMS storage was replaced with NoSQL MongoDB. A [video](http://www.10gen.com/presentations/MongoNYC-2012/Using-MongoDB-to-Build-Artsy) was recorded at MongoNYC 2012 that goes in depth into this specific choice.

Artsy Architecture Today
-------------------------

Having only a handful of engineers, our goal has always been to keep the number of moving parts to an absolute minimum. With a few new engineers we were able to expand things a bit.

Artsy Website Front-End
------------------------

The Artsy website is a responsive [Backbone.js](http://backbonejs.org/) application written in [CoffeeScript](http://coffeescript.org/) and [SASS](http://sass-lang.com/) and served from a Rails back-end. The generated JavaScript and CSS files are packaged and compressed with [Jammit](http://documentcloud.github.com/jammit/) and deployed to Amazon S3. The Rails app itself is a traditional MVC system that bootstraps application data and mostly serves SEO needs, such as meta tags, escaped fragments and page titles. Once the basic data has been rendered though, Backbone routing takes over and you're now navigating a client-side browser app with pushState support as available, swapping frames and rendering views using JST templates and JSON data returned from the API.

Core API
--------

The website talks to the nervous system of Artsy, a RESTful API built in Ruby and [Grape](https://github.com/intridea/grape).

In the early days we did a ton of domain-driven design and spent a lot of time modeling concepts such as *artist* or *artwork*. The API has read and write behavior for all our domain concepts. Probably 70% of it is pure CRUD doing [Mongoid](http://mongoid.org/) queries with a layer of access control in [CanCan](https://github.com/ryanb/cancan) and cache partitioning and binding using [Garner](http://confreaks.com/videos/986-goruco2012-from-zero-to-api-cache-w-grape-mongodb-in-10-minutes).

Search Autocomplete
-------------------

The first iteration of the website's text search was powered by [mongoid_fulltext](https://github.com/artsy/mongoid_fulltext). Today we run an [Apache Solr](http://lucene.apache.org/solr/) master-slave environment hosted on EC2.

Offline Indexes
---------------

The indexes that serve complex queries like related artists/artworks and filtered searches of artworks are all built offline. Our index-building system runs continuously, repeatedly pulling data from our production system to build the most out-of-date index. All of the most current indexes are imported back into production by a daily batch process and we swap the old indexes out atomically using [mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot).

One of such indexes a *similarity graph* that we query to produce most similar results on the website, other indexes serve filtering needs, etc. We run these processes nightly.

Admin Back-End and Partner CMS
------------------------------

The Artsy CMS and the Admin system are two newer projects and serve the needs of our partners and our internal back-end needs, respectively. These are built on a thin [Node.js](http://nodejs.org) server that proxies requests to our API using [node-http-proxy](https://github.com/nodejitsu/node-http-proxy). They consist of a client-side Backbone.js application with assets packaged with [nap](https://github.com/craigspaeth/nap). This is a lot like our website, but completely decoupled from the main Rails application and sharing the same technology for both client and server with CoffeeScript and [Jade](http://jade-lang.com/).


Folio Partner App
-----------------

Artsy makes a free iOS application, called [Folio](http://artsy.github.com/blog/categories/ios/), which lets our partners display their inventory at art fairs.

Folio is a native iOS implementation. The interface is heavily skinned UIKit with CoreData for storage. Our network code was originally a thin layer on top of NSURLConnection, but for our forthcoming update, we’ve rewritten it to use [AFNetworking](https://github.com/AFNetworking/AFNetworking/). We manage external dependencies with [CocoaPods](https://github.com/CocoaPods/CocoaPods).

Want More Specifics? Have Questions?
------------------------------------

We hope you find this useful and are happy to describe any aspect of our system on this blog. Please ask questions below, we’ll be happy to answer them.
