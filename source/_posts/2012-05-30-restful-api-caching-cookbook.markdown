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

Let's begin with small JSON data returned from a Ruby API. It returns a single counter. We'll use [Grape](http://github.com/intridea/grape), but these concepts apply as well to any Sinatra-style framework based on Rack or Rails.

``` ruby
class API < Grape::API
  def count
    { count : 0 }
  end
end
```

This kind of dynamic data cannot have a well-defined expiration time. The counter can be incremented at any time via another API call or process. Since it's a counter, it's important to tell the client not to cache it. This is accomplished using the following Rack Middleware.

``` ruby
class ApiCacheBuster < Grape::Middleware::Base
  def after
    @app_response[1]["Cache-Control"] = "private, max-age=0, must-revalidate"
    @app_response[1]["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    @app_response
  end
end
```

The `private` option of the `Cache-Control` header instructs the client that it is allowed to store data in a private cache, `max-age` that it must check with the server every time it needs this data and `must-revalidate` prevents gateways from returning a response if your API server is unreachable. An additional `Expires` header will make double-sure the entire request expires immediately.

A client may want to retrieve the value of the counter and runs a job every time the value changes. As it stands, the current API requires an effort on the client's part to remember the previous value and compare it every time it makes an API call. This can be avoided by asking the server for a new counter if the value has changed. 

One possibility is to include an `If-Modified-Since` header with a timestamp. The server could respond with `304 Not Modified` if the counter hasn't changed since it was last requested. While this may be acceptable for certain data, timestamps have a granularity of seconds. A counter may be modified multiple times during the same second, therefore preventing it from retrieving the result of the second modification.

A more robust solution is to generate a unique signature, called ETag, for this data and to use it to find out whether the counter has changed. There's a generic `Rack::ETag` middleware that sets ETags on all String bodies, so you will need to roll out your own implementation for other types. We try to serialize in a way such that the ETag matches the one which would be returned by `Rack::ETag` at response time, with fallback to `Marshal.dump`.

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

A client makes a request with an `If-None-Match: Etag` header. The server should return a `304 Not Modified` if the data hasn't changed.

We support both `If-Modified-Since` and `If-None-Match` via a helper.



