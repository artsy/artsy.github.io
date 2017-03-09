---
layout: post
title: Artsy's Technology Stack, 2017
date: 2017-03-05
categories: [Technology, eigen, force, gravity]
author: orta
series: Artsy Tech Stack
---

Artsy was launched in 2012 as the Art Genome Project. By 2014 we had 230,000 works of art from 600 museums and institutions and launched our first business, a subscription service for commercial galleries, bringing over 80,000 works for sale and partnerships with 37 art fairs and a handful of benefit auctions. That year collectors from 82 countries inquired on over $5.5B of art. By 2015 we doubled our "for sale" inventory and aggregated 4,000 of the world's leading galleries and 60 art fairs. We also launched two new businesses: commercial auctions and online media. 

Finally, last year, in 2016 we doubled our paid gallery network size to become the largest gallery network in the world and grew to become the most-read online art publication in the world as our highly engaging editorial traffic ballooned 320% and as we launched a live auction and a consignments service with the major auction houses.

With all this business growth, Artsy has grown past 160 team members and our Engineering organization is now 29 engineers, including 4 leads, 3 directors and a CTO. In this post, I'd like to comprehensively cover what, and how we make the technical and human sides of Artsy businesses work.

<!-- more -->

# Organizational Structures

In 2016, we updated [the Engineering organization](/blog/2016/03/28/artsy-engineering-organization-stack/) to be oriented around product verticals. Since then, web and mobile "practices" have largely been subsumed into these separate product teams. Mobile's increasing reliance on React Native has aligned nicely with web tooling. It no longer made sense to keep the teams separate, so where product teams used to have 2 separate sub-teams of engineers, they've now merged into 1.

The Platform "practice" has remained as a way to coordinate and share work among product teams, as well as monitor and upgrade Artsy's platform over time. Most platform engineers operate from within product teams, while a few focusing on data and infrastructure form a core, dedicated Platform team.

# Artsy Tech Infrastructure

## Partner Subscriptions

### User Facing

Partner's subscribe to Artsy because we bring a very large audience of Art lovers to their virtual doors. A lot of the focus within this business on being able to present interfaces with a quality worthy of art.

What you see today when you go to [artsy.net](https://artsy.net) is a website built with [Ezel.js](http://ezeljs.com), which is a boilerplate for [Backbone](http://backbonejs.org) projects running on [Node](https://nodejs.org) and using [Express](http://expressjs.com) and [Browserify](http://browserify.org). We used to have separate projects for mobile and desktop web, but now they [are merged][force_merge_pr]. It is hosted on [Heroku](http://heroku.com) and uses [Redis](http://redis.io) for caching. Assets, including artwork images, are served from [Amazon S3](http://aws.amazon.com/s3/) via the [CloudFront CDN](http://aws.amazon.com/cloudfront).

What you see today when you open the Artsy iOS app is a mix of Objective-C, Swift and React Native. Objective-C and Swift continue to provide a lot of over-arching cross-View Controller code. While individual representations of Artsy resources tend to be built in React Native. All of our React Native code uses Relay to handle API integration.

Our core API serves the public facets of our product, many of our own internal applications, and even [some of your own projects](https://developers.artsy.net/). It's built with [Ruby](https://www.ruby-lang.org/en/), [Rack](http://rack.github.io/), [Rails](http://rubyonrails.org/), and [Grape](https://github.com/intridea/grape) serving primarily JSON. The API is hosted on [AWS OpsWorks](http://aws.amazon.com/opsworks) and retrieves data from several [MongoDB](http://www.mongodb.com) databases hosted with [Compose](https://www.compose.io). It also uses [Memcached](http://memcached.org) for caching and [Redis](https://redis.io/) for background queues. We used to employ [Apache Solr](http://lucene.apache.org/solr) and even [Google Custom Search](https://www.google.com/cse) for the many search functions, but have since consolidated on [Elasticsearch](https://www.elastic.co).

Most modern code for both the website, and the iOS app use an orchestration layer which is powered by [GraphQL][graphQL]. Our GraphQL server is an [Express](http://expressjs.com) app, using [express-graphql][express-graphql] to provide a single API end-point. The GraphQL API does not access our data directly, but forwards requests to the core API or other services. We have been migrating shared display logic into the GraphQL server, to make it easier to build consistent clients.

We continue to have a [public HAL+JSON API](https://developers.artsy.net) for external developers. This API is in active use for a few production services inside Artsy.

### Partner Facing

There is more to this than just the consumer facing side though, we have a home-grown Content Management System (CMS) for gallery and institution partners. This CMS allows our partners to upload Show, Fair, Artist and Artwork metadata to our API. 

This CMS use stable, mature technologies like [Rails][rails], [Bootstrap][bootstrap], [Turbolinks][turbolinks], [CoffeeScript][coffee] and 

We have an in-house image processing project (rails, sidekiq, redis, rmagick, imagemagick)

Partners are billed via 
https://github.com/artsy/induction/

and handled via
https://github.com/artsy/vibrations/

Fairs? https://github.com/artsy/waves

### Communications

Art collectors inquire on an artworks though our internal messaging system. This can be either thought an API call, or through emails. For 

https://github.com/artsy/radiation


[CMS: One for Partners to upload Show, Fair, Artist and Artwork metadata.]
[Genoming: One for in-house Genomers to handle connecting artworks together.]
https://github.com/artsy/helix/

## Auctions

[Auctions setup/set down infra]
https://github.com/artsy/ohm/
[Live]

## Editorial

[Writer]
[One offs, UBS]
[]


# Analytics

We have consolidated a lot of our analytics tooling into RedShift

[confirm with Will]

# Platform Services

As Artsy's business has grown more complex, so has the data and concepts handled by its core API. We've begun supporting certain product areas with separate, dedicated API services, and even extracting existing API domains into separate services when practical. These services tend to expose simple [REST](https://en.wikipedia.org/wiki/Representational_state_transfer)-ful HTTP APIs, maintain separate data sources, and even do their own [authentication](/blog/2016/10/26/jwt-artsy-journey/). This has certain advantages:

* Each system can be deployed and scaled independently.
* Each chooses the best-suited languages and technologies for its purpose.
* Code bases remain more focused and developers' cognitive overhead is minimized.

Balancing these out are some very real disadvantages:

* Development must sometimes touch multiple systems.
* Some data is copied between services. These can become out-of-sync, though we always try to have a single _authoritative_ source in such cases.
* Deploys must be coordinated.

At our size and complexity, a single code base is simply impractical. So, we've tried to be consistent in the coding, deployment, monitoring, and logging practices of these services. The more repeatable and disciplined our process, the less overhead is introduced by additional systems.

We've also explored alternate communication patterns, so systems aren't as dependent on each other's APIs. Recently we've begun publishing a stream of interesting data events from our core systems. Other systems can simply subscribe to the notifications they care about, so the source system doesn't need to be concerned about integrating with one more destination. After experimenting with [Kafka](https://kafka.apache.org/) but finding it hard to manage, we switched to [RabbitMQ](https://www.rabbitmq.com/) for this purpose.

## Hosting

[deployment via Kubernetes]
[talk with anil]

## One-offs

[Messaging: Facebook, Alexa, Google Home]
[Slackbots: PR assignees]
[Team Nav]

## Culture

[Remote workers vs office]
[Slack]
[Diverse?]

# Trends

By the end of 2016, almost every major front-end aspect of Artsy was [Open Source by Default][oss-default]. This means the entire working process is done in the open, from developer PRs to QA. In order to work in the open but still keep details private, we create a private GitHu  b repo for each front-end team that represents cross-project issues and team milestones. This is done using [ZenHub][zenhub], and is managed by Engineering leads and Product Managers.

Consistently over the [last 2 years][trying-react], our front-end code has moved towards using React across all platforms. As well as a trend towards stricter JavaScript languages like TypeScript over CoffeeScript in order to provide better tooling.

These transitions haven't come in the form of big re-writes, but as incremental improvements into mature systems after building out smaller example projects to prove a concept.



[tech2015]: /blog/2015/03/23/artsy-technology-stack-2015/
[db]: /author/db
[force_merge_pr]: LINK
[graphQL]: LINK
[express-graphql]: LINK
[oss-default]: LINK
[zenhub]: LINK
[trying-react]: /blog/2015/04/08/creating-a-dynamic-single-page-app-for-our-genome-team-using-react/
[aws]: /blog/2013/08/27/introduction-to-aws-opsworks/
