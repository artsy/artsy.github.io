---
layout: post
title: Simplifying Model-Level JSON Versioning with Mongoid-Cached-Json
date: 2012-03-23 09:14
comments: true
categories: [Mongoid, Caching, API, Versioning]
author: db
---
Did you know that Netflix has hundreds of API versions, one for each device? Daniel Jacobson's [Techniques for Scaling the Netflix API](http://www.slideshare.net/danieljacobson/techniques-for-scaling-the-netflix-api-qcon-sf) at QConSF 2011 explained why they chose this model. And while we don't all build distributed services that supply custom-tailored data to thousands of heterogeneous TVs and set-top boxes, we do have to pay close attention to API versioning from day one.

Versioning is hard. Your data models evolve, but you must maintain backward-compatibility for your public interfaces. While many strategies exist to deal with this problem, we'd like to propose one that requires very little programming effort and that is more declarative in nature.

At Artsy we use [Grape](http://github.com/intridea/grape) and implement the "path" versioning strategy from the [frontier](http://github.com/intridea/grape/tree/frontier) branch. Our initial v1 API is consumed by our own website and services and lives at [https://artsyapi.com/api/v1](https://artsyapi.com/api/v1). We've also prototyped v2 and by the time v1 is frozen, it should already be in production.

Grape takes care of version-based routing and has a system that lets you split version-based presentation of a model from the model implementation. I find that separation forcefully induced by unnecessary implementation complexity around wanting to return different JSON depending on the API version requested. What if implementing versioning in `as_json` were super simple?

Consider a Person model returned from a v1 API.

``` ruby
class API < Grape::API
  prefix :api
  version :v1
  namespace :person
    get ":id"
      Person.find(params[:id]).as_json
    end
  end
end
```

``` ruby
class Person
  include Mongoid::Document

  field :name

  def as_json
    {
      name: name
    }
  end

end
```

In v2 the model split `:name` into a `:first` and `:last` name and in v3 `:name` has finally been deprecated. A version v3 Person model would look as follows.

``` ruby
class Person
  include Mongoid::Document

  field :first
  field :last

  def as_json
    {
      first: first,
      last: last
    }
  end

end
```

How can we combine these two implementations and write `Person.find(params[:id]).as_json({ :version => ? })`?

In [mongoid-cached-json](http://github.com/dblock/mongoid-cached-json) we've introduced a declarative way of versioning JSON. Here's the code for Person v3.

``` ruby
class Person
  include Mongoid::Document
  include Mongoid::CachedJson

  field :first
  field :last

  def name
    [ first, last ].join(" ")
  end

  json_fields \
    name: { :versions => [ :v1, :v2 ] },
    first: { :versions => [ :v2, :v3 ] },
    last: { :versions => [ :v2, :v3 ] }

end
```

With the [mongoid-cached-json](http://github.com/dblock/mongoid-cached-json) gem you also get caching that respects JSON versioning, for free. Read about it [here](http://artsy.github.com/blog/2012/02/20/caching-model-json-with-mongoid-cached-json/).
