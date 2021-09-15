---
layout: epic
title: Artsy's Technology Stack, 2017
date: 2017-04-14
categories: [Technology, eigen, force, gravity]
author: [orta, artsy_engineering]
series: Artsy Tech Stack
---

# History

Artsy was [launched in 2012 as the "Art Genome Project"](http://www.nytimes.com/2012/10/09/arts/design/artsy-is-mapping-the-world-of-art-on-the-web.html) and grew exponentially ever since.

By 2014 we had 230,000 works of art from 600 museums and institutions and launched our first business, a subscription service for commercial galleries, bringing over 80,000 works for sale and partnerships with 37 art fairs and a handful of benefit auctions. That year collectors from 82 countries inquired on over $5.5B of art.

By 2015 we doubled our "for sale" inventory and aggregated 4,000 of the world's leading galleries and 60 art fairs. We also launched two new businesses: commercial auctions and online media.

Finally, in 2016 we, again, doubled our paid gallery network size to become the largest gallery network in the world and grew to become the most-read online art publication as our highly engaging editorial traffic ballooned 320%. We also launched a platform to bid in live auctions and a consignments service with all major auction houses.


# The Artsy Business in 2017

Artsy in 2017 is a very wide platform and it can be challenging to characterize simply. But when you boil it down to its essence, Artsy offers information and a marketplace. Our written content and fair coverage keep people informed about the art world, and the Art Genome powers our tools for exploration. Through our partnerships with the major player in the art market, galleries and auction houses, we offer our users a unified platform for buying and selling art.

Internally we consider Artsy to have three businesses: _Auctions_, _Content_ and _Listings_.

* _Auctions_: Auction houses and charities use Artsy as a sales channel for a commission because collectors want to discover and buy art in a single, central platform that excels at surfacing the art they want from a global market.


* _Content_: Brands pay Artsy to reach the first art audience at scale by enabling evergreen content online and for offline engagement during art world events.


* _Listings_: Galleries, Fairs and Institutions subscribe to Artsy for a fee because we bring a very large audience of art collectors and enthusiasts to their virtual doors.

The Artsy team is now 166 employees across three offices in New York, Berlin and London. The Engineering organization is now 28 engineers, including 4 leads, 3 directors and a CTO. In this post, we'd like to comprehensively cover what, and how we make the technical and human sides of Artsy businesses work.

<!-- more -->

<center>
 <img src="/images/tech-2017/businesses.svg" style="width:100%;">
</center>


# Organizational Structures


In 2016, we [updated the Engineering organization](/blog/2016/03/28/artsy-engineering-organization-stack) to be oriented around product verticals for businesses. We used to focus more on practices to group engineers working with the same technologies across product teams to facilitate knowledge sharing and avoid redundant efforts. 

Since then, web and mobile "practices" have largely been subsumed into the separate product teams. Mobile's increasing reliance on React Native has aligned nicely with web tooling. It no longer made sense to keep the teams separate, so where product teams used to have 2 separate sub-teams of engineers, they've now merged into 1.

The Platform "practice" has remained as a way to coordinate and share work among product teams, as well as monitor and upgrade Artsy's platform over time. Most platform engineers operate from within product teams, while a few focusing on data and infrastructure form a core, dedicated Platform team.

<center>
 <img src="/images/tech-2017/engineering-teams.svg" style="width:100%;">
</center>

# Artsy Technology Infrastructure 2017 - Splitting the Monolith

{% include epic_img.html url="/images/tech-2017/artsy-stack.svg" title="The Artsy Tech Stack 2017" style="width:100%;" %}

## User Facing

A lot of the user-facing focus is on being able to present interfaces with a quality worthy of art.

What you see today when you go to [www.artsy.net](https://artsy.net) is a website built with [Ezel.js](https://github.com/artsy/ezel), which is a boilerplate for [Backbone](http://backbonejs.org) projects running on [Node](https://nodejs.org) and using [Express](http://expressjs.com) and [Browserify](http://browserify.org). We used to have separate projects for mobile and desktop web, but they [are now merged](https://github.com/artsy/force/pull/890). The combined app is hosted on [Heroku](http://heroku.com) and uses [Redis](http://redis.io) for caching. Assets, including artwork images, are served from [Amazon S3](http://aws.amazon.com/s3) via the [CloudFront CDN](http://aws.amazon.com/cloudfront). This [code is open-source](https://github.com/artsy/force).

What you see today when you open the [Artsy iOS app](https://itunes.apple.com/us/app/artsy-collect-and-bid-on-fine-art-design/id703796080?mt=8) is a mix of Objective-C, Swift and React Native. Objective-C and Swift continue to provide a lot of over-arching cross-View Controller code. While individual representations of Artsy resources tend to be built in React Native. All of our React Native code uses Relay to handle API integration. This [code is open-source](https://github.com/artsy/eigen).

You can also find Artsy on [Alexa](http://alexa.artsy.net) and [Google Home](http://assistant.artsy.net), which are both open-source Node.js applications. There is also an open-source [Apple TV](https://github.com/artsy/emergence/) app built in Swift.

Our core API serves the public facets of our product, many of our own internal applications, and even [some of your own projects](https://developers.artsy.net). It's built with [Ruby](https://www.ruby-lang.org/en), [Rack](http://rack.github.io), [Rails](http://rubyonrails.org), and [Grape](https://github.com/intridea/grape) serving primarily JSON. The API is hosted on [AWS OpsWorks](http://aws.amazon.com/opsworks) and retrieves data from several [MongoDB](http://www.mongodb.com) databases hosted with [Compose](https://www.compose.io). It also uses [Memcached](http://memcached.org) for caching and [Redis](https://redis.io) for background queues with [Sidekiq](https://github.com/mperham/sidekiq/). It runs background jobs with [delayed_job](https://github.com/collectiveidea/delayed_job). We used to employ [Apache Solr](http://lucene.apache.org/solr) and even [Google Custom Search](https://www.google.com/cse) for the many search functions, but have since consolidated on [Elasticsearch](https://www.elastic.co).

Most modern code for both the website and the iOS app use an orchestration layer which is powered by [GraphQL](http://graphql.org) to streamline their data fetching and reduce front-end complexity. Our GraphQL server is an [Express](http://expressjs.com) app, using [express-graphql](https://github.com/graphql/express-graphql) to provide a single API end-point. The API does not access our data directly, but forwards requests to the core API or other services. We have been migrating shared display logic into the GraphQL server, to make it easier to build consistent clients. This [code is open-source](https://github.com/artsy/metaphysics).

Consistently, our front-end code [has moved towards](/blog/2017/02/05/Front-end-JavaScript-at-Artsy-2017/) using React across all platforms along with introducing stricter JavaScript languages like TypeScript over CoffeeScript in order to provide better tooling.

We continue to have a [public HAL+JSON API](https://developers.artsy.net) for external developers. This API is in active use for contemporary production services inside Artsy and the [website is open-source](https://github.com/artsy/doppler), too.


<center>
 <img src="/images/tech-2017/languages.svg" style="width:100%;">
</center>

## Partner-Facing

The vast customer-facing business is powered by a Content Management System (CMS) for gallery and institutional partners. This CMS lets them upload and manage gallery shows, fair booths, create artists, and edit artwork metadata. All CMS components talk to our core API. We also have a number of CMS-like internal applications to manage partners, auctions, art genomes, configuring fairs or performing recurrent billing (we use Stripe for storing and charging credit cards and ACH) with invoicing.

CMS applications are based on stable, mature technologies like [Rails](http://rubyonrails.org), [Bootstrap](http://getbootstrap.com), [Turbolinks](https://github.com/turbolinks/turbolinks) and [CoffeeScript](http://coffeescript.org), and gradually adopts modern client-side technologies like [React](https://facebook.github.io/react) and [Browserify](http://browserify.org). They share a lot of common infrastructure.

We have a generic image-processing service in-house, which uses [Rails](http://rubyonrails.org), [Sidekiq](https://github.com/mperham/sidekiq/), [Redis](https://redis.io), and [RMagick](https://github.com/rmagick/rmagick) with [ImageMagick](http://www.imagemagick.org/script/index.php). It receives image processing requests from many Artsy applications and generates thumbnails, tiles and watermarks images on S3.

## Collector-Facing

Collectors inquire on artworks and engage in conversations with partners. For this purpose we have built a generic messaging system that manages communications between different parties. It receives messages via API or e-mail, finds or creates a conversation based on the recipients and forwards them to the proper addresses in that conversation. Its doesn't assume anything about the contents of the messages, which makes it a generic system for any type of conversation. The conversations surface to our partners via CMS.

## Running Auctions

The Auctions business began with doing the occasional benefit auctions for charities. Most of these auctions are online-only, timed sales. The initial version of our auction systems came together before we began our move to microservices, and so it is baked into our core API. Last year, we launched a live auction integration product to allow users to bid on works at commercial sales at the actual auction house sale rooms. The real-time requirements of this system required a rethinking of how we process our bids.

The core API for a commercial auction is a Scala micro-service that uses [Akka](http://akka.io) for distributed computing. It stores information in an append-only storage engine, based on Akka Persistence, with a small library we developed called [atomic-store](https://github.com/artsy/atomic-store). Communication with external clients can either be done via a REST API, or via WebSockets. People visiting a Live Auction on the web are interacting with a [universal](https://medium.com/@mjackson/universal-javascript-4761051b7ae9#.ev1yd3juy) [React](https://facebook.github.io/react)+[Redux](http://redux.js.org) JavaScript app, served from an [Express](http://expressjs.com) server. Bidders visiting a Live Auction on iOS are interacting with a Swift application built with [Interstellar](https://github.com/JensRavens/Interstellar), [Starscream](https://github.com/daltoniam/starscream) and [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON).

A more detailed overview of the Auctions stack can be found in [The Tech Behind Live Auction Integration](/blog/2016/08/09/the-tech-behind-live-auction-integration).

## Publishing

Our in-house editorial team and partners use an [open-source](https://github.com/artsy/positron) platform called "Writer" (which we've built) to publish rich content across the web. Writer is split in two parts: the editorial-focused CMS and a JSON API that stores and distributes content separately from the rest of Artsy's stack.

Writer's frontend is built with [Ezel.js](https://github.com/artsy/ezel), which is a boilerplate for [Backbone](http://backbonejs.org) projects running on [Node](https://nodejs.org) and using [Express](http://expressjs.com) and [Browserify](http://browserify.org). We also heavily use [React](https://facebook.github.io/react) and write in [CoffeeScript](http://coffeescript.org). Writer's backend exposes [REST](https://en.wikipedia.org/wiki/Representational_state_transfer)-based and [GraphQL](http://graphql.org) APIs that are consumed by our applications.

You can see Writer being put to work when you see articles on [www.artsy.net](https://www.artsy.net), Facebook Instant Articles, Google AMP, RSS, Apple News, and email. We handle the distribution and display in all of these channels. We also support brand sponsorship deals and produce front-end heavy projects such as [Year in Art 2016](https://www.artsy.net/2016-year-in-art), and [Year in Art 2015](https://www.artsy.net/article/artsy-editorial-2015-the-year-in-art).

## Data Pipeline

Data generally flows from consumer applications and services into [AWS RedShift](https://aws.amazon.com/redshift). We use a set of [rake](https://github.com/ruby/rake) tasks run on [Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Build+Flow+Plugin) to move data from our several MongoDB and PostgreSQL databases to Redshift via [S3](https://aws.amazon.com/s3). These rake tasks shell out to [psql](https://www.postgresql.org/docs/9.3/static/sql-copy.html) or [mongo-export](https://docs.mongodb.com/manual/reference/program/mongoexport) to generate CSV files for a list of services and upload them to an S3 bucket, then load those CSV files plus others found in that bucket (placed there by other services) into Redshift. If a [Redshift copy](http://docs.aws.amazon.com/redshift/latest/dg/r_COPY.html) fails due to data changes we sample the CSV and generate a working schema from its contents.

We also store application usage data provided by [Segment Warehouses](https://segment.com/warehouses) as well as data from vendors such as [Salesforce](https://www.salesforce.com) and [Sailthru](http://www.sailthru.com).

For production data processing (such as recommendations), large-scale machine learning or even simpler parallel processing such as generating website sitemaps, we have our own Hadoop cluster configured and managed by [Cloudera Manager](https://www.cloudera.com/products/product-components/cloudera-manager.html) and running on EC2. We leverage [Apache Spark](http://spark.apache.org) and [Hadoop](https://www.cloudera.com/products/open-source/apache-hadoop.html) with some [Ooozie](http://oozie.apache.org) workflow scheduling. The same data pipeline that writes data to S3 also pumps data to HDFS with either Ruby code or [Sqoop](http://sqoop.apache.org) and is read by Spark jobs written in Scala using [Hive](https://hive.apache.org). Spark has improved performance and capacity tenfold over our older in-house systems and we will be moving all lengthy processing implemented in Ruby to this system gradually.

## Analytics

For general data access and dashboards we rely on [Looker](https://looker.com). This system empowers all non-engineers to access all of our data. At the time of writing, there are 50 users running 3,500 queries a day against Redshift via Looker. We've found it expedient to pre-compute common denormalized views, and to create our own session rollups from raw pageviews and events for the additional flexibility it gives us in understanding user behavior.

For more in-depth work, we use [Jupyter Notebooks](https://ipython.org/notebook.html) to connect to our Redshift cluster and by default import [pandas](http://pandas.pydata.org), [sci-kit learn](http://scikit-learn.org/stable), and [pyplot](http://matplotlib.org/api/pyplot_api.html) for data analysis.

## Search

We completed our full migration from [Solr](http://lucene.apache.org/solr) to [Elasticsearch](https://www.elastic.co) in the last 18 months, and now use Elasticsearch across all front-ends. This ranges from our artwork filter interfaces through to our real-time artwork similarity features. Elasticsearch gives us high availability clustering features out of the box and easy horizontal scaling on demand.

## Platform Services

As Artsy's business has grown more complex, so has the data and concepts handled by its core API. We've begun supporting certain product areas with separate, dedicated API services, and even extracting existing API domains into separate services when practical. These services tend to expose simple [REST](https://en.wikipedia.org/wiki/Representational_state_transfer)-ful HTTP APIs, maintain separate data sources, and even do their own [authentication](/blog/2016/10/26/jwt-artsy-journey). This has certain advantages:

* Each system can be deployed and scaled independently.
* Each chooses the best-suited languages and technologies for its purpose.
* Code bases remain more focused and developers' cognitive overhead is minimized.

Balancing these out are some very real disadvantages:

* Development must sometimes touch multiple systems.
* Some data is copied between services. These can become out-of-sync, though we always try to have a single _authoritative_ source in such cases.
* Deploys must be coordinated.

At our size and complexity, a single code base is simply impractical. So, we've tried to be consistent in the coding, deployment, monitoring, and logging practices of these services. The more repeatable and disciplined our process, the less overhead is introduced by additional systems.

We've also explored alternate communication patterns, so systems aren't as dependent on each other's APIs. Recently we've begun publishing a stream of data events from our core systems that other systems can consume. Other systems can simply subscribe to the notifications they care about, so the source system doesn't need to be concerned about integrating with one more destination. After experimenting with [Kafka](https://kafka.apache.org) but finding it hard to manage, we switched to [RabbitMQ](https://www.rabbitmq.com) for this purpose. To provide consistency when publishing events we have [our own gem](https://github.com/artsy/artsy-eventservice).

## Operations

All our recent AWS infrastructure is configured in code using [Terraform](https://www.terraform.io). This approach has allowed us to quickly replicate entire deployments along with their dependencies and has increased visibility into the state of our infrastructure across our teams. We started developing an open source [Docker](https://www.docker.com) workflow toolkit named [Hokusai](https://github.com/artsy/hokusai) in order to manage a containerized workflow, CI and deployment to [Kubernetes](https://kubernetes.io). Our Kubernetes clusters are managed using [Kops](https://github.com/kubernetes/kops) and similarly provisioned using Terraform. This new workflow is reducing our dependence on Heroku, giving us more flexibility in our deployments and a more efficient use of server resources.

## Closing Remarks

Like any attempts at mapping something as large as the daily work for a thirty-ish person engineering team, [the map is not the territory](https://en.wikipedia.org/wiki/Map–territory_relation). However, the exploration is worth the time it takes to keep notes for reading again in the next two years.

If you're interested in helping us make this an even longer post in two more years, or _more interestingly_ shorter - we nearly always have a [position open for engineers](https://www.artsy.net/jobs).
