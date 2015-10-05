---
layout: post
title: An Easter Egg for Curl
date: 2013-04-01 12:21
comments: true
categories: [Fun,Easter Eggs]
author: db
---

Let's implement an Easter egg that requires [curl](http://curl.haxx.se/) and is HTTP-compliant.

We accept access tokens on our API endpoints. These can come from an `access_token` query string parameter.

```
curl https://api.artsy.net/api/v1/system/up?access_token=invalid -v

< HTTP/1.1 401 Unauthorized
< Content-Type: application/json
< Content-Length: 24

{ "error" : "Unauthorized" }
```

So far, so good. Now try this:

```
curl https://api.artsy.net/api/v1/system/up?access_token=10013 -v

< HTTP/1.1 401 Broadway
< Content-Type: application/json
< Content-Length: 76

{ "error" : "Inspiration from the Engineering team at http://artsy.github.com" }
```

What?! **401 Broadway**? See, our office address is *401 Broadway, 10013, New York, NY*. We just tried to add a more developer-friendly way to find us in the New York grid. And here's the view from our 25th floor office - that's SOHO right below us and the Empire State Building a bit North.

<img src="/images/2013-04-01-an-easter-egg-for-curl/artsy-office-view.jpg" />

Photo by [@zamiang](https://github.com/zamiang).

Easter egg implementation follows.

<!-- more -->

Implementing a custom HTTP response is surprisingly hard with most web servers. Changing the text that follows error codes is not something most people need. Our API will have to return a custom error code and some monkey-patching will translate the status message. We use [grape](https://github.com/intridea/grape), which is Rack-based and supports inserting middleware, where we do authentication. We randomly chose the number 2600 for an internal status code.

``` ruby api/api_action_dispatch_request.rb
class ApiActionDispatchRequest < ActionDispatch::Request

  def initialize(env)
    super(env)
  end

  def [](key)
    params[key] || headers["X_#{key.to_s.upcase}"]
  end

end
```

``` ruby api/api_auth_middleware.rb
class ApiAuthMiddleware < Grape::Middleware::Base

  def before
    if access_token == "10013"
      throw :error,
        message: 'Inspiration from the Engineering team at http://artsy.github.com',
        status: 2600
    else
      ...
    end
  end

  private

    def access_token
      @access_token ||= request[:access_token]
    end

    def request
      @request ||= ApiActionDispatchRequest.new(env)
    end

end
```

### WEBrick

``` ruby config/initializers/broadway/webrick.rb
module WEBrick
  class HTTPResponse
    def status=(status)
      if status == 2600
        @status = 401
        @reason_phrase = "Broadway"
      else
        @status = status
        @reason_phrase = HTTPStatus::reason_phrase(status)
      end
    end
  end
end
```

### Thin

``` ruby config/initializers/broadway/thin.rb
module Thin
  class Response
    def head
      if @status == 2600
        "HTTP/1.1 401 Broadway\r\n#{headers_output}\r\n"
      else
        "HTTP/1.1 #{@status} #{HTTP_STATUS_CODES[@status.to_i]}\r\n#{headers_output}\r\n"
      end
    end
  end
end
```

### Unicorn

``` ruby config/initializers/broadway/unicorn.rb
require 'unicorn/http_response'
module Unicorn::HttpResponse
  CODES[2600] = '401 Broadway'
end
```

### More Eggs?

Check out [artsy.net/humans.txt](https://api.artsy.net/humans.txt) for more Easter eggs and please feel free to email me at **db[at]artsy[dot]net** if you want to come visit or [work here](https://artsy.net/jobs).
