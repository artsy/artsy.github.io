---
layout: post
title: RESTful API Caching Cookbook
date: 2012-05-30 21:21
comments: true
categories: [API, REST, Caching, Performance]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---
Implementing solid server-side RESTful API caching is hard. Sample RESTful APIs often demonstrate caching based on routes, but most real-world web applications don't have that luxury: requirements around object relationships or user permissions make caching particularly challenging.

Today we're open-sourcing [Garner](http://github.com/dblock/garner), a cache implementation of the concepts described in this post. Garner works today with the [Grape API](http://github.com/intridea/grape) framework and [Mongoid ODM](http://github.com/mongoid/mongoid). If you find this useful, we encourage you to fork the project, extend our library to other systems and contribute your code back.

Garner's approach to caching is detailed in this post. It's the Art.sy API caching cookbook that has been tried by fire in production.

<!-- more -->

### Enabling Caching of Static Data

Caching static data is fairly easy. Set `Cache-Control` and `Expires` headers.

``` ruby
  expire_in = 60 * 60 * 24 * 365
  header "Cache-Control", "private, max-age=#{expire_in}"
  header "Expires", CGI.rfc1123_date(Time.now.utc + expire_in)
```

When caching static data, also consider a `public` cache. Varnish, for example, will serve the same content to different users even if the server always serves different content. This is a very effective way of leveraging a CDN.

### Disabling Caching of Dynamic Data

Caching dynamic data is more involved. Let's begin with a simple Ruby API that returns a counter.

``` ruby
class API < Grape::API
  def count
    { count : 0 }
  end
end
```

This kind of dynamic data cannot have a well-defined expiration time. The counter may be incremented at any time via another API call or process. therefore, we must tell the client not to cache it. 

TODO: replace with garner - In pure Grape, this is accomplished using the following Rack middleware, executed after any API call.

``` ruby
class ApiCacheBuster < Grape::Middleware::Base
  def after
    @app_response[1]["Cache-Control"] = "private, max-age=0, must-revalidate"
    @app_response[1]["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    @app_response
  end
end
```

The `private` option of the `Cache-Control` header instructs the client that it is allowed to store data in a private cache (unnecessary, but is known to work around overzealous cache implementations), `max-age` that it must check with the server every time it needs this data and `must-revalidate` prevents gateways from returning a response if your API server is unreachable. An additional `Expires` header will make double-sure the entire request expires immediately.

### If-Modified-Since, ETags and If-None-Match

A client may want to retrieve the value of the counter and runs a job every time the value changes. As it stands, the current API requires an effort on the client's part to remember the previous value and compare it every time it makes an API call. This can be avoided by asking the server for a new counter if the value has changed. 

One possibility is to include an `If-Modified-Since` header with a timestamp. The server could respond with `304 Not Modified` if the counter hasn't changed since it was last requested. While this may be acceptable for certain data, timestamps have a granularity of seconds. A counter may be modified multiple times during the same second, therefore preventing it from retrieving the result of the second modification.

A more robust solution is to generate a unique signature, called ETag, for this data and to use it to find out whether the counter has changed. There's a generic `Rack::ETag` middleware that sets ETags on all String bodies. Adding the middleware now produces an ETag for every response from the API.

A client makes a request with an `If-None-Match: Etag` header. The server should return a `304 Not Modified` if the data hasn't changed. Here's how a typical ETag is generated.

``` ruby
def etag_for(object)
  serialization = case object
    when String then object
    when Hash then object.to_json
    else Marshal.dump(object)
  end
  %("#{Digest::MD5.hexdigest(serialization)}")
end
```

We support reading and writing `If-Modified-Since` and `If-None-Match` headers via a helper. The complete source code is [in this gist](https://gist.github.com/2856045). Converting the value of the `If-Modified-Since` header as defined in [RFC2827](http://www.ietf.org/rfc/rfc2822.txt) to a Ruby `Time` is the only tricky part.

``` ruby
def if_modified_since
  if since = env["HTTP_IF_MODIFIED_SINCE"]
    Time.rfc2822(since) rescue nil
  end
end
```

### Using Memcached via Dalli and Rails.Cache

A typical Ruby cache supports a block syntax. The following example returns a cached copy when available or executes the supplied block and stores the result in the cache. In this context `cache` could be `Rails.cache` or an instance of `ActiveSupport::Cache::FileStore`. We use `Rails.cache` with MemCached via the [dalli gem](https://github.com/mperham/dalli) in production.

### Constructing Cache Keys

``` ruby
cache("count") do
  { count : 0 }
end
```

The parameter of the `cache` call is the cache key that uniquely identifies the cache entry. Hard-coding cache keys is tedious, so we generate a key from the API version, route and request parameters.

``` ruby
def cache_key
  options = { }
  options[:version] = version
  options[:path] = request.path
  options[:params] = request.GET
  Digest::MD5.hexdigest(options.to_json)
end
```

A more complicated problem with this approach is that two cache_key calls within the same API produce identical keys. To solve that we examine the call stack, find the caller that's not within the helper module and inject it in the key options.

``` ruby
api_caller = caller.detect { |line| !(line =~ /\/#{File.basename(__FILE__)}/) }
md = api_caller.match(/(.*\.rb:[0-9]*):/) if api_caller
options[:caller] = md[1] if md
```

### Production-Grade Cache Keys

A generic approach to key generation is good enough to get one started. Larger applications frequently choose a more involved scheme that binds cache data with the domain model in order to solve the following issues:

* Partition cache in sync with object ownership and permissions. For example, a Widget may have different representations depending on whether `current_user` owns it or not.
* Retrieve objects from cache nomatter where the calling code appears.
* Invalidate entire cached collections when one of the objects in a collection has changed.

A cache is a collection of flat name/value pairs. Object relationships can be specified within each key by chaining model names, field values and by using wildcards where appropriate. For example, `User/id=12,Widget/id=45,Gadget/*` binds the cache value to changes in `User` with id=12, `Widget` with id=45 and any instance of `Gadget`.

``` ruby
cache(bind: [[User, { id: current_user.id }], [Widget, { id: params[:widget_id] }], [Gadget] ])
  Widget.where({ id: params[:widget_id], user_id: current_user.id }).as_json
end
```

Another way of thinking about binding to multiple objects or classes as a way to partition the cache. The implementation of key generation can be found in [this gist](https://gist.github.com/2954175).

### Cache Invalidation

Since we're not going to be able to scan the entire cache during invalidation, we'll have to keep a key index in the cache as well. The key for each index entry is derived from the individual elements in the binding. 

``` ruby
def self.index_string_for(klass, object = nil)
  "INDEX:" +
  if object && object[:id]
    "#{klass}/id=#{object[:id]}"
  else
    "#{klass}/*"
  end
end
```


