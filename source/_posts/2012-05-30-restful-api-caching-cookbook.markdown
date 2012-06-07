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
Implementing solid server-side RESTful API caching is hard. It requires good understanding of both your data domain and of HTTP. This post is the Art.sy API caching cookbook that has been tried by fire in production. 

Examples below will use [Grape](http://github.com/intridea/grape), but these concepts apply as well to any Sinatra-style framework based on Rack or Rails.

Caching static data is fairly easy. Set `Cache-Control` and `Expires` headers.

``` ruby
  expire_in = 60 * 60 * 24 * 365
  header "Cache-Control", "private, max-age=#{expire_in}"
  header "Expires", CGI.rfc1123_date(Time.now.utc + expire_in)
```

Caching dynamic data is more involved. Let's begin with a simple Ruby API that returns a counter.

``` ruby
class API < Grape::API
  def count
    { count : 0 }
  end
end
```

This kind of dynamic data cannot have a well-defined expiration time. The counter may be incremented at any time via another API call or process. therefore, we must tell the client not to cache it. This is accomplished using the following Rack Middleware, executed after any API call.

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

A typical Ruby cache supports a block syntax. The following example returns a cached copy when available or executes the supplied block and stores the result in the cache. In this context `cache` could be `Rails.cache` or an instance of `ActiveSupport::Cache::FileStore`. The parameter is the cache key that uniquely identifies the cache entry.

``` ruby
cache("count") do
  { count : 0 }
end
```

Hard-coding cache keys can be tedious. We chose to generate a key from the API version, route and request parameters.

``` ruby
def cache_key
  options = { }
  options[:version] = version
  options[:path] = request.path
  options[:params] = request.GET
  Digest::MD5.hexdigest(options.to_json)
end
```


