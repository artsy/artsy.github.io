---
layout: post
title: Caching Model JSON with Mongoid-Cached-Json
date: 2012-02-20 13:06
comments: true
categories: [Mongoid, Caching, API]
author: db
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
