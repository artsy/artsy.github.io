---
layout: post
title: Starting Small with Big Data and Google Analytics
date: 2012-03-30 20:52
comments: true
categories: [Analytics, Data]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---
Why do so many companies write a homegrown pageviews tracking system? Between Google Analytics, Kissmetrics and many others, isn't that a completely solved problem?

These popular solutions lack domain knowledge. They are easily capable of segmenting users by region or browser, but they fail to recognize rules core to your business. Tracking pageviews with a homegrown implementation quickly becomes your next sprint goal.

Implementing a hit counter service is quite tricky. This is a write-heavy, asynchronous problem that must minimize impact on page rendering time, while dealing with rapidly growing amounts of data. Is there a middle ground between using Google Analytics and rolling out our own homegrown implementation? How can we use Google Analytics for data collection and inject domain knowledge into gathered data, incrementally, without writing our own service?

<!--more-->

Lets write a Rake task that pulls data from Google Analytics, daily. We'll start with a Ruby gem called [Garb](https://github.com/vigetlabs/garb).

``` ruby
gem "garb", "0.9.1"
```

Garb requires Google Analytics credentials. Lets put these into a YAML configuration file.

``` yaml config/google_analytics.yml
defaults: &defaults

development:
  <<: *defaults
  email: "ga@example.com"
  password: "password"
  ua: "UA-12345678-1"

production:
  <<: *defaults
  email: <%= ENV['GOOGLE_ANALYTICS_EMAIL'] %>
  password: <%= ENV['GOOGLE_ANALYTICS_PASSWORD'] %>
  ua: <%= ENV['GOOGLE_ANALYICS_UA'] %>
```

We establish a Google Analytics session and fetch the profile corresponding to the user account.

``` ruby
config = YAML.load(File.read("#{Rails.root}/config/google_analytics.yml"))[Rails.env].symbolize_keys
Garb::Session.login(config[:email], config[:password])
profile = Garb::Management::Profile.all.detect { |p| p.web_property_id == config[:ua] }
raise "missing profile #{config[:ua]} in #{Garb::Management::Profile.all.map(&:web_property_id)}" unless profile
```

Garbs needs a data model to collect pageviews. You can play with the Google Analytics data explorer to see the many possible metrics (eg. pageviews) and dimensions (eg. requested page path).

``` ruby app/models/google_analytics_pageviews.rb
class GoogleAnalyticsPageviews
  extend Garb::Model
  metrics :pageviews
  dimensions :page_path
end
```

By default, Google Analytics lets clients retrieve 1000 records at-a-time. To get all records we can add an iterator that will keep making requests until the server runs out of data. The code for config/initializers/garb_model.rb is [in this gist](https://gist.github.com/2265877).


