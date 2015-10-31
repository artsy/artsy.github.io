---
layout: post
title: 10x Rack and Rails Output Compression with Rack::Deflater
date: 2012-02-24 16:05
comments: true
categories: [Rack, Rails, Performance, API]
author: db
---
You can quickly reduce the amount of data transferred from your Rack or Rails application with [Rack::Deflater](https://github.com/rack/rack/blob/master/lib/rack/deflater.rb). Anecdotal evidence shows a reduction from a 50Kb JSON response into about 6Kb. It may be a huge deal for your mobile clients.

For a Rails application, modify config/application.rb or config/environment.rb.

``` ruby config/application.rb
Acme::Application.configure do
  config.middleware.use Rack::Deflater
end
```

For a Rack application, add the middleware in config.ru.

``` ruby config.ru
use Rack::Deflater
run Acme::Instance
```

<!-- more -->

Note that the order of the middleware is very important. For example, we also use Rack::JSONP that adds automatic JSONP support to our API. It must be invoked before Rack::Deflater or it will attempt to wrap compressed content. Rack middleware is executed in reverse order [[source](http://verboselogging.com/2010/01/20/proper-rack-middleware-ordering)].

``` ruby config/application.rb
  config.middleware.use Rack::Deflater
  config.middleware.use Rack::JSONP
```

A couple of handy RSpec tests to add to your application. You will need to modify this code with a valid API path and expected response.

``` ruby spec/api/rack_deflater_spec.rb
require 'spec_helper'

describe Rack::Deflater do
  it "produces an identical eTag whether content is deflated or not" do
    get "/api/acme"
    response.headers["Content-Encoding"].should be_nil
    etag = response.headers["Etag"]
    content_length = response.headers["Content-Length"].to_i
    get "/api/acme", {}, { "HTTP_ACCEPT_ENCODING" => "gzip" }
    response.headers["Etag"].should == etag
    response.headers["Content-Length"].to_i.should_not == content_length
    response.headers["Content-Encoding"].should == "gzip"
  end
  it "deflates JSONP content" do
    get "/api/acme?callback=parseResponse", {}, { "HTTP_ACCEPT_ENCODING" => "deflate" }
    response.headers["Content-Encoding"].should == "deflate"
    inflated_response_body = Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(response.body.to_s)
    inflated_response_body.should == "parseResponse(...)"
  end
end
```
