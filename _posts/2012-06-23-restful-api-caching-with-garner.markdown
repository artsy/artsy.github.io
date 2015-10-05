---
layout: post
title: RESTful API Caching with Garner
date: 2012-05-30 21:21
comments: true
categories: [API, REST, Caching, Performance]
author: db
---
Implementing server-side RESTful API caching is hard. In a straightforward API all the expiry decisions can be made automatically based on the URL, but most real world APIs that add requirements around object relationships or user authorization make caching particularly challenging.

At [GoRuCo](http://goruco.com/) we open-sourced [Garner](http://github.com/artsy/garner), a cache implementation of the concepts described in this post. To "garner" means to gather data from various sources and to make it readily available in one place, kind-of like a cache! Garner works today with the [Grape API framework](http://github.com/intridea/grape) and the [Mongoid ODM](http://github.com/mongoid/mongoid). We encourage you to fork the project, extend our library to other systems and contribute your code back, if you find it useful.

Garner implements the Artsy API caching cookbook that has been tried by fire in production.

<!-- more -->

### Enabling Caching of Static Data

Caching static data is fairly easy: set `Cache-Control` and `Expires` headers in the HTTP response.

``` ruby
expire_in = 60 * 60 * 24 * 365
header "Cache-Control", "private, max-age=#{expire_in}"
header "Expires", CGI.rfc1123_date(Time.now.utc + expire_in)
```

This example indicates to a cache in front of your service (CDN, proxy or user's browser) that the data expires in a year and that it's private for this user. When caching truly static data, such as images, use `public`. Your CDN or proxy, such as [Varnish](https://www.varnish-cache.org/) that sits in front of Artsy on [Heroku](http://www.heroku.com/), will cache the data and subsequent requests won't even need to hit your server, even though it could potentially serve different content every time.

### Disabling Caching of Dynamic Data

Caching dynamic data is slightly more involved. Let's begin with a simple Ruby API that returns a counter.

``` ruby
class API < Grape::API
  def count
    { count : 0 }
  end
end
```

This kind of dynamic data cannot have a well-defined expiration time. The counter may be incremented at any time via another API call or process, so we must tell the client not to cache it. This is accomplished by setting the value of `Cache-Control` to `private, max-age=0, must-revalidate`. The `private` option instructs the client that it's allowed to store data in a private cache (unnecessary, but is known to work around overzealous cache implementations), `max-age` that it must check with the server every time it needs this data and `must-revalidate` prevents gateways from returning a response if your API server is unreachable. An additional `Expires` header set to a past date (usually January 1st 1990), will make double-sure the entire request expires immediately with old browsers.

Garner provides [Garner::Middleware::Cache::Bust](https://github.com/dblock/garner/blob/master/lib/garner/middleware/cache/bust.rb) a Rack middleware that accomplishes just that.

### If-Modified-Since, ETags and If-None-Match

Given our API example, a client may want to retrieve the value of the counter and, for example, run a job every time the value changes. As it stands, the current API requires an effort on the client's part to remember the previous value and compare it every time it makes an API call. This can be avoided by asking the server for a new counter if the value has changed since last time it was retrieved.

One option for the client is to include an `If-Modified-Since` header with a timestamp. The server could then choose to respond with `304 Not Modified` if the counter hasn't changed since the timestamp in `If-Modified-Since`. While this may be acceptable for certain data, timestamps have a granularity of seconds. A counter may be modified multiple times during the same second, therefore preventing it from retrieving the result of the second modification.

A more robust solution is to generate a unique signature, called ETag, for this data and to use it to find out whether the counter has changed. There exists a generic [Rack::ETag](https://github.com/rack/rack/blob/master/lib/rack/etag.rb) middleware that sets ETags on all text bodies. Adding the middleware would produce an ETag for every response from the API. You can now combine `Rack::ETag` and `Rack::Cache` - a client makes a request with an `If-None-Match: Etag` header and the server returns a `304 Not Modified` if the data hasn't changed, without sending the data.

### Memcached via Dalli and Rails.Cache

There's an obvious problem with `Rack::Cache`. In order for it to serve a `304 Not Modified` response it must compare the ETag from the request with the ETag generated from the body of the current response. So it saves bandwidth, but doesn't save execution time on the server. We'd also like the server to cache the entire response and therefore avoid any heavy processing, such as querying a database.

A typical Ruby cache supports a block syntax. The following example returns a cached copy when available or executes the supplied block and stores the result in the cache. In this context `cache` could be `Rails.cache` or an instance of `ActiveSupport::Cache::FileStore`. We use `Rails.cache` with [Memcached](http://memcached.org/) via the [dalli gem](https://github.com/mperham/dalli) in production.

``` ruby
cache("count") do
  { count : 0 }
end
```

The parameter of the `cache` call is the cache key that uniquely identifies the cache entry. Hard-coding cache keys is tedious, so we can generate a key from the API version, route and request parameters.

``` ruby
def cache_key
  options = { }
  options[:version] = version
  options[:path] = request.path
  options[:params] = request.GET
  Digest::MD5.hexdigest(options.to_json)
end
```

This generic approach to key generation is fine to get one started, but is largely insufficient for real-world applications.

### Production-Grade Cache Keys and Model Binding

Most large scale web properties operate on data with the following requirements.

* Partition cache in sync with object ownership and permissions. For example, a `Widget` may have different representations depending on whether `current_user` owns it or not or may choose to return a `401 Access Denied` in some of the cases.
* Retrieve objects from cache no matter where the calling code appears. The above strategy would generate identical keys from two different locations within the same function.
* Invalidate entire cached collections when one of the objects in a collection has changed. For example, invalidate all cached instances of `Widget` when a new `WidgetCategory` is created and forces a reorganization of those widgets.

Garner will help you introduce such aspects of your domain model into the cache and solve all these.

A cache is a collection of flat name/value pairs. We'll specify object relationships within each key by chaining model names, field values and by using wildcards where appropriate. For example, `User/id=12,Widget/id=45,Gadget/*` binds the cache value to changes in `User` with id=12, `Widget` with id=45 and any instance of `Gadget`.

``` ruby
cache(bind: [[User, { id: current_user.id }], [Widget, { id: params[:widget_id] }], [Gadget] ])
  Widget.where({ id: params[:widget_id], user_id: current_user.id }).first.as_json
end
```

Binding to multiple objects or classes can also be reasoned about as a way to partition the cache. Adding structure into the fields lets us reason about the relationships between various instances of data in the cache.

### Role-Based Caching

Role-Based caching is a subset of the generic problem of binding data to groups of other objects. For example, a `Widget` may have a different representation for an `admin` vs. a `user`. In Garner you can inject something called a "key strategy" into the current key generation pipeline. A strategy is a plain module that must implement two methods: `field` and `apply`. The former should define a unique key name and the latter applies the strategy within a context.

The following example introduces the role of the current user into the cache key.

``` ruby
module MyApp
  module Garner
    module RoleStrategy
      class << self
        def field
          :role
        end
        def apply(key, context = {})
          key.merge { :role => current_user.role }
        end
      end
    end
  end
end
```

Garner key strategies can be currently set at application startup time.

``` ruby
Garner::Cache::ObjectIdentity::KEY_STRATEGIES = [
  Garner::Strategies::Keys::Caller, # support multiple calls from the same function
  MyApp::Garner::RoleStrategy, # custom strategy for role-based access
  Garner::Strategies::Keys::RequestPath # injects the HTTP request's URL
]
```

### Multiple Calls from the Same Function

Binding to the same set of objects within the same function call will produce the same key. To solve this in a generic way we can examine the call stack, find the caller that's not within the helper module and inject it in the key options.

``` ruby
api_caller = caller.detect { |line| !(line =~ /\/#{File.basename(__FILE__)}/) }
api_caller_line = api_caller.match(/(.*\.rb:[0-9]*):/) if api_caller
options[:caller] = api_caller_line[1] if api_caller_line
```

Garner implements this as [Garner::Strategies::Keys::Caller](https://github.com/dblock/garner/blob/master/lib/garner/strategies/keys/caller_strategy.rb).

### Cache Invalidation

Invalidating a cache entry bound to multiple objects requires keeping an additional index along with the actual cache data. In the example above we've bound the resulting Widget to a specific `User`, the `Widget` instance itself and all instances of `Gadget`. Every time a Gadget changes, we'll want to invalidate this cache entry. Garner will handle this either automatically via a mixin (we've provided [Garner::Mixins::Mongoid::Document](https://github.com/dblock/garner/blob/master/lib/garner/mixins/mongoid_document.rb) for the Mongoid ODM) or via an explicit `invalidate(Gadget)` call.

Since we're not able to scan the entire cache during invalidation, we keep a key index in the cache as well. The key for each index entry is derived from the individual elements in the binding.

### Using with Grape

Garner currently ships with [Garner::Mixins::Grape::Cache](https://github.com/dblock/garner/blob/master/lib/garner/mixins/grape_cache.rb). There're two ways to use it: `cache` and `cache_or_304`.

The `cache` implementation will generate a key from the binding by applying all registered cache key strategies within the current context, look up the entry by that key and either cache hit or miss. In summary, it's an extension to a standard cache, introducing a much more fully featured binding system.

``` ruby
# caches, but always returns the widget
get "widget/:id" do
  cache(bind: [Widget, params[:id]]) do
    Widget.find(params[:id])
  end
end
```

The `cache_or_304({ bind: [ ] })` will generate a meta key from the binding by applying all registered cache key strategies within the current context and search the cache index by the meta key. If a value is found, it will be compared to the ETag or the timestamp supplied in the request's `If-None-Match` or `If-Modified-Since` and issue a `304 Not Modified` where appropriate.

``` ruby
# caches, returns the widget and supports If-Modified-Since or If-None-Match
get "widget/:id" do
  cache_or_304(bind: [Widget, params[:id]]) do
    Widget.find(params[:id])
  end
end
```

### Conclusion

An effective cache implementation for a web service combines server-side caching with client-side expiration. The latter broadly includes proxies, CDNs and browsers, all active actors in the process of exchanging information. The web is, in a way, an eventually consistent data storage and distribution system.

### Links

* [Garner](https://github.com/artsy/garner)
