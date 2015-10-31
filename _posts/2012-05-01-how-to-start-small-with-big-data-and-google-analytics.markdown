---
layout: post
title: How to Start Small with Big Data and Google Analytics
date: 2012-05-01 20:52
comments: true
categories: [Analytics, Data]
author: db
---
Why do so many companies write a homegrown pageviews tracking system? Between Google Analytics, Kissmetrics and many others, isn't that a completely solved problem?

These popular solutions lack domain knowledge. They are easily capable of segmenting users by region or browser, but they fail to recognize rules core to your business. Tracking pageviews with a homegrown system becomes your next sprint's goal.

Implementing a hit counter service is quite tricky. This is a write-heavy, asynchronous problem that must minimize impact on page rendering time, while dealing with rapidly growing amounts of data. Is there a middle ground between using Google Analytics and rolling out our own homegrown implementation? How can we use Google Analytics for data collection and inject domain knowledge into gathered data, incrementally, without writing our own service?

<!--more-->

Let's write a Rake task that pulls data from Google Analytics. We can run it daily. Start with a Ruby gem called [Garb](https://github.com/vigetlabs/garb).

``` ruby
gem "garb", "0.9.1"
```

Garb requires Google Analytics credentials. Those can go into a YAML configuration file, which will use environment settings in production (it's an ERB template, too). We can hardcode the test account values.

``` yaml config/google_analytics.yml
defaults: &defaults

development, test:
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

Establish a Google Analytics session and fetch the profile corresponding to the Google user account with Garb.

``` ruby
config = YAML.load(ERB.new(File.new(Rails.root.join("config/google_analytics.yml")).read).result)[Rails.env].symbolize_keys
Garb::Session.login(config[:email], config[:password])
profile = Garb::Management::Profile.all.detect { |p| p.web_property_id == config[:ua] }
raise "missing profile #{config[:ua]} in #{Garb::Management::Profile.all.map(&:web_property_id)}" unless profile
```

Garbs needs a data model to collect pageviews. It extends `Garb::Model` and defines a set of "metrics" and "dimensions".

``` ruby app/models/google_analytics_pageviews.rb
class GoogleAnalyticsPageviews
  extend Garb::Model
  metrics :pageviews
  dimensions :page_path
end
```

You can play with the [Google Analytics Query Explorer](http://ga-dev-tools.appspot.com/explorer/) to see the many possible metrics (such as pageviews) and dimensions (such as requested page path).

By default, Google Analytics lets clients retrieve 1000 records in a single request. To get all records we can add an iterator, called `all`, that will keep making requests until the server runs out of data. The code for *config/initializers/garb_model.rb* is [in this gist](https://gist.github.com/2265877) and I made a [pull request](https://github.com/vigetlabs/garb/pull/116) into Garb if you'd rather merge that onto your fork.

The majority of our pages are in the form of "/model/id", for example "/artwork/leonardo-mona-lisa". We're interested in all pageviews for a given artwork and in pageviews for a given artist, at a given date. We'll store selected Google Analytics data in a `GoogleAnalyticsPageviewsRecord` model described further.

``` ruby
t = Date.today - 1
GoogleAnalyticsPageviews.all(profile, { :start_date => t, :end_date => t }) do |row|
  model = /^\/#\!\/(?<type>[a-z-]+)\/(?<id>[a-z-]+)$/.match(row.page_path)
  next unless (model[:type] == "artwork" || model[:type] == "artist")
  GoogleAnalyticsPageviewsRecord.create!({
    :model_type => model[:type],
    :model_id => model[:id],
    :pageviews => row.pageviews,
    :dt => t.strftime("%Y-%m-%d")
  })
end
```

Each `GoogleAnalyticsPageviewsRecord` contains the total pageviews for a given model ID at a given date. We now have a record for each artwork and artist. We can rollup existing data into a set of collections, incrementally. For example, `google_analytics_artworks_monthly` will contain the monthly hits for each artwork.

``` ruby
class GoogleAnalyticsPageviewsRecord
  include Mongoid::Document

  field :model_type, type: String
  field :model_id, type: String
  field :pageviews, type: Integer
  field :dt, type: Date

  index [
    [:model_type, Mongo::ASCENDING],
    [:model_id, Mongo::ASCENDING],
    [:dt, Mongo::DESCENDING]
  ], :unique => true

  after_create :rollup

  def rollup
    Mongoid.master.collection("google_analytics_#{self.model_type}s_total").update(
      { :model_id => self.model_id },
      { "$inc" => { "count" => self.pageviews }}, { :upsert => true })
    {
      :daily => self.dt.strftime("%Y-%m-%d"),
      :weekly => self.dt.beginning_of_week.strftime("%Y-%W"),
      :monthly => self.dt.beginning_of_month.strftime("%Y-%m"),
      :yearly => self.dt.beginning_of_year.strftime("%Y")
    }.each_pair do |t, dt|
      Mongoid.master.collection("google_analytics_#{self.model_type}s_#{t}").update(
        { :model_id => self.model_id, :dt => dt },
        { "$inc" => { "count" => self.pageviews }}, { :upsert => true })
    end
  end

end
```

The rollup lets us query these tables directly. For example, the following query returns a record with the pageviews for the Leonardo's "Mona Lisa" in January 2012.

``` ruby
Mongoid.master.collection("google_analytics_artworks_monthly").find_one({
  :model_type => "artwork", :model_id => "leonardo-mona-lisa", :dt => "2012/01"
})
```

One of the obvious advantages of pulling Google Analytics data is the low volume of requests and offline processing. We're letting Google Analytics do the hard work of collecting data for us in real time and are consuming its API without the performance or time pressures.
