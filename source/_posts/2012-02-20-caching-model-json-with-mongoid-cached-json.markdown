---
layout: post
title: Caching Model JSON with Mongoid-Cached-Json
date: 2012-02-20 13:06
comments: true
categories: [Mongoid, Caching, API]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---
Consider the following two [Mongoid](http://mongoid.org) domain models, *Widget* and *Gadget*.

``` ruby widget.rb
class Widget
  include Mongoid::Document
  
  field :name
  has_many :gadgets
end
```
``` ruby gadget.rb
class Gadget
  include Mongoid::Document
  
  field :name
  field :extras

  belongs_to :widget
end
```
And an API call that returns a collection of widgets.

``` ruby
get 'widgets' do
  Widget.all.as_json
end
```

Given many widgets, the API makes a subquery to fetch the corresponding gadgets for each widget.

Introducing [mongoid-cached-json](https://github.com/dblock/mongoid-cached-json). This library mitigates several frequent problems with such code.

* Adds a declarative way of specifying a subset of fields to be returned part of *as_json*.
* Avoids a large amount of subqueries by caching document JSONs participating in the parent-child relationship.
* Provides a consistent strategy for restricting child documents' fields from being returned via the parent JSON.

Using *Mongoid::CachedJson* we were able to cut our JSON API average response time by about a factor of 10. Find it [on Github](https://github.com/dblock/mongoid-cached-json).

<!-- more -->

<a href="http://github.com/dblock/mongoid-cached-json"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://a248.e.akamai.net/assets.github.com/img/30f550e0d38ceb6ef5b81500c64d970b7fb0f028/687474703a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6f72616e67655f6666373630302e706e67" alt="Fork me on GitHub"></a>

