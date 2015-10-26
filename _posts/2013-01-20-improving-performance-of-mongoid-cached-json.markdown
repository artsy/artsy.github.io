---
layout: post
title: Improving Performance of Mongoid-Cached-Json
date: 2013-01-20 21:21
comments: true
categories: [Mongoid, Caching, API]
author: db
---

Last year, we have open-sourced and made extensive use of two Ruby libraries in our API: [mongoid-cached-json](https://github.com/dblock/mongoid-cached-json) and [garner](https://github.com/artsy/garner). Both transform the procedural nightmare of caching and JSON generation into a declarative and easily manageable DSL. It was worth the investment, since our service spends half of its time generating JSON and reading from and writing to Memcached.

Today we've released mongoid-cached-json 1.4 with two interesting performance improvements.

<!-- more -->

Bulk Reference Resolving with a Local Cache
-------------------------------------------

Consider an array of database model instances, each with numerous references to other objects. It's typical to see such instances reference the same object: for example we have an `Artwork` that references an `Artist`. It's common to see multiple artworks reference the same artist in a collection. Retrieving the artist from cache every time it is referenced is clearly inefficient.

`Mongoid::CachedJson` will now collect all JSON references, then resolve them after suppressing duplicates, in-place within the JSON tree. This significantly reduces the number of cache queries.

Note, that while this optimization reduces load on the Memcached servers, there's a cost of doing additional work after collecting the entire JSON in Ruby.

Fetching Cache Data in Bulk
---------------------------

Various cache stores, including Memcached, support bulk read operations. The [Dalli](https://github.com/mperham/dalli) gem, which we use in production, exposes this via the `read_multi` method. With the bulk reference optimization above we now have the entire list of keys to query from cache, at once. `Mongoid::CachedJson` will always invoke `read_multi` where available, which significantly reduces the number of network roundtrips to the cache servers.

This is a good example of where declarative models and DSLs have tremendous advantages in enabling massive improvements across the board. Imagine making the `read_multi` optimization in hundreds of API endpoints!

Benchmarks
----------

With the above optimizations the library does more work in order to make less roundtrips to Memcached over the network. Since the network is often the slowest part in any large scale system, the overall production performance should be better as long as we can obtain similar throughput in ideal network conditions on localhost. We've added some common case benchmarks in [spec/benchmark_spec.rb](https://github.com/dblock/mongoid-cached-json/blob/master/spec/benchmark_spec.rb) and ran them against 1.2.3 and 1.4.0 to obtain [these results](https://gist.github.com/4583039). The overall performance gain averaged 14.6%, which is quite significant. With real world data in a production environment we're seeing 15-50% less time spent in Memcached, depending on the API.

Links
-----

The concepts behind these improvements should be attributed to [@aaw](https://github.com/aaw) and [@macreery](https://github.com/macreery). If you want to learn more about the above-mentioned libraries, check out the following links:

* [From Zero to API-Cache w/ Grape and MongoDB](http://confreaks.com/videos/986-goruco2012-from-zero-to-api-cache-w-grape-mongodb-in-10-minutes), video recorded at GoRuCo
* [Caching Model JSON with Mongoid-Cached-Json](/blog/2012/02/20/caching-model-json-with-mongoid-cached-json/)
* [Simplifying Model Level Versioning with Mongoid-Cched-Json](/blog/2012/03/23/simplifying-model-level-json-versioning-with-mongoid-cached-json/)
* [RESTful API Caching with Garner](/blog/2012/05/30/restful-api-caching-with-garner/)
