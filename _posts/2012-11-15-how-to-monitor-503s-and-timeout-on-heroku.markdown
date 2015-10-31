---
layout: post
title: How to Monitor 503s and Timeout Requests on Heroku
date: 2012-11-15 21:21
comments: true
categories: [Heroku,Rack,Grape]
author: db
---
We have recently started hitting an unusually high number of "503: Service Unavailable" errors with one of our applications on Heroku. What are these? How can we monitor their quantity and frequency? What's the fix?

<img src="/images/2012-11-15-how-to-monitor-503s-and-timeout-on-heroku/503-error.png">

<!-- more -->

What does 503 mean?
-------------------

A 503 error means "Service Unavailable". Heroku returns a 503 error when an HTTP request times out between the Heroku routing mesh and your application, including when the application failed to boot. This timeout limit is set to 30 seconds, as [documented by Heroku](https://devcenter.heroku.com/articles/request-timeout), and shows up in the logs as follows.

```
Nov 14 12:10:50 production heroku/router:
 Error H12 (Request timeout) -> GET artsy.net/api/spline
 dyno=web.11 queue= wait= service=30000ms status=503 bytes=0
```

This usually means that the application could not process the request fast enough, and in very rare cases, that there's an infrastructure problem with Heroku itself. A 504 error which means "Gateway Timeout" would have probably been a more appropriate choice. Either way, the root cause could be something as simple as trying to run a very long database query or do too much work that doesn't fit in a 30 seconds window. It could also involve an external service that didn't respond quickly enough. Your mileage may vary.

Monitoring 503s
---------------

503 errors don't happen within your application, they are reported by the routing mesh. They will not appear in internal monitoring systems attached to your app, including [NewRelic](http://newrelic.com/).

We get the frequency of 503s by sending our Heroku logs to [Papertrail](https://papertrailapp.com/) and using their [alerts feature](http://help.papertrailapp.com/kb/how-it-works/alerts) to push the number of 503s to [Geckoboard](http://www.geckoboard.com/). You can send these to [Graphite](http://graphite.wikidot.com/) or any other monitoring system in the same manner.

This is what it looks like:

<img src="/images/2012-11-15-how-to-monitor-503s-and-timeout-on-heroku/503-geckoboard.png">

Aborting Requests
-----------------

When Heroku reports a 503 status code, it just gives up. Your application continues executing the request though, often to completion, which may take forever. In the meantime, Heroku will send a new request to the dyno that's still busy, and get a new 503. This is known as a "stuck" dyno.

To prevent dynos from being stuck you must abort the request within the 30 second period. This can be accomplished with the [rack-timeout](https://github.com/kch/rack-timeout) gem and setting `Rack::Timeout.timeout = 29` in an initializer (or a smaller value within which you want to guarantee a response). The gem automatically inserts itself into a Rails application, but you will need to manually mount it in other Rack apps, such as those using [Grape](https://github.com/intridea/grape).

``` ruby api.rb
class Api < Grape::API
  use Rack::Timeout

  desc "Returns a reticulated spline."
  get "spline/:id"
    Spline.find(params[:id])
  end
end
```

Because your application is now getting a timeout exception, you can also report it in NewRelic. The following works in Grape.

``` ruby
rescue_from Timeout::Error, :backtrace => true do |e|
  NewRelic::Agent.instance.error_collector.notice_error e,
    uri: request.path,
    referer: request.referer,
    request_params: request.params
  rack_response({
    :type => "timeout_error",
    :message => "The request timed out."
  }.to_json, 503)
end
```

Don't forget to write a test!

``` ruby api_spec.rb
require 'spec_helper'

describe Api do
  it "times out after Rack::Timeout.timeout" do
    Rack::Timeout.stub(:timeout).and_return(1)
    Spline.stub(:find) { sleep 3 }
    get "/spline/1"
    response.status.should == 503
    response.body.should == '{"type":"timeout_error","message":"The request timed out."}'
  end
end
```

Fixing Timeouts
---------------

The root causes of timeouts are specific to your application. Our general approach for long running requests is to offload the request processing into a delayed job or background process and "cook" data in a way that makes it readily available to API endpoints. You can read more about this and related aspects of our system architecture in [this earlier blog post](/blog/2012/10/10/artsy-technology-stack/).
