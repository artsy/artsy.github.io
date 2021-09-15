---
layout: post
title: Adding API Docs with Grape and Swagger
date: 2013-06-21 12:21
comments: true
categories: [Grape,Mongoid,Swagger]
author: db
---

The Artsy website, Partner CMS, mobile tools, and all our hackathon experiments are built on top of a core API. We've put a lot of effort into documenting it internally. But developers don't want to have to grok through code. With [Grape](https://github.com/intridea/grape) and [Swagger](https://developers.helloreverb.com/swagger), adding an API explorer and exposing the API documentation has never been easier.

<img src="/images/2013-06-21-adding-api-documentation-with-grape-swagger/swagger-ui.png" />

<!-- more -->

### Cross Origin Requests

You don't need to include the API explorer into your application. Instead, enable Cross-Origin Resource Sharing (CORS) with [rack-cors](https://github.com/cyu/rack-cors).

``` ruby Gemfile
gem "rack-cors"
```

``` ruby app.rb
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :get
  end
end
```

Your application will now respond to `OPTIONS` and `GET` requests with CORS headers. It's also important to verify that errors still contain CORS headers, as shown in these RSpec tests.

``` ruby spec/cors_spec.rb
context "CORS" do
  it "supports options" do
    options "/", {}, {
      "HTTP_ORIGIN" => "http://cors.example.com",
      "HTTP_ACCESS_CONTROL_REQUEST_HEADERS" => "Origin, Accept, Content-Type",
      "HTTP_ACCESS_CONTROL_REQUEST_METHOD" => "GET"
    }
    last_response.status.should == 200
    last_response.headers['Access-Control-Allow-Origin'].should == "http://cors.example.com"
    last_response.headers['Access-Control-Expose-Headers'].should == ""
  end
  it "includes Access-Control-Allow-Origin in the response" do
    get "/", {}, "HTTP_ORIGIN" => "http://cors.example.com"
    last_response.status.should == 200
    last_response.headers['Access-Control-Allow-Origin'].should == "http://cors.example.com"
  end
  it "includes Access-Control-Allow-Origin in errors" do
    get "/invalid", {}, "HTTP_ORIGIN" => "http://cors.example.com"
    last_response.status.should == 404
    last_response.headers['Access-Control-Allow-Origin'].should == "http://cors.example.com"
  end
end
```

### Grape-Swagger

There's a gem called [grape-swagger](https://github.com/tim-vandecasteele/grape-swagger) that exposes Swagger-compatible documentation from any Grape API with a one-liner, `add_swagger_documentation`.

``` ruby api.rb
module Acme
  class API < Grape::API
    format :json

    desc "This is the root of our API."
    get "/" do

    end

    add_swagger_documentation api_version: 'v1'
  end
end
```

``` ruby spec/documentation_spec.rb
it "swagger documentation" do
  get "/api/swagger_doc"
  last_response.status.should == 200
  json_response = JSON.parse(last_response.body)
  json_response["apiVersion"].should == "v1"
  json_response["apis"].size.should > 0
end
```

### Swagger UI

Use the [Swagger Petstore](http://petstore.swagger.wordnik.com), start your application, enter *http://localhost:9292/api/swagger_doc* and explore your API!

<img src="/images/2013-06-21-adding-api-documentation-with-grape-swagger/swagger-ping.png" />

### Working Sample

You can find a working sample in [this demo application](https://github.com/dblock/grape-on-rack), added in [this commit](https://github.com/dblock/grape-on-rack/commit/004670804472812322b089fcf6a40b33d68c699c).
