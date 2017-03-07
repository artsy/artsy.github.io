---
layout: post
title: Artsy's Technology Stack, 2017
date: 2017-03-05
categories: [Technology, eigen, force, gravity]
author: orta
series: Artsy Tech Stack
---

Artsy has now grown past 160 team members and our Engineering organization is now 30? strong. [WIP] For a brief overview of what the company has accomplished in the last few years, check out our [2013](http://2013.artsy.net) and [2014](http://2014.artsy.net) reviews.

I'd like to comprehensively cover what, and how we make the technical side of Artsy work.

<!-- more -->

# Organizational Structures

In 2016, we made considerable changes to [the Engineering organizational stack](/blog/2016/03/28/artsy-engineering-organization-stack/). This is still an accurate representation of our team structure.

The only structural changes since then has been the down-playing of the web and mobile practices. The transition in the mobile team to React Native has brought the two so close in terms of execution and ideas that it doesn't make sense to create a strong distinction any more. For example, we used to have two subteams in the product team Collector GMV between iOS and Web, now they are merged.

# Artsy Tech Infrastructure

## Front-End + API

In 2015, [dB][db] published our [2015 technology stack][tech2015], in the core Artsy products, though there are a few interesting changes.

What you see today when you go to [artsy.net](https://artsy.net) is a website built with [Ezel.js](http://ezeljs.com), which is a boilerplate for [Backbone](http://backbonejs.org) projects running on [Node](https://nodejs.org) and using [Express](http://expressjs.com) and [Browserify](http://browserify.org). We used to have separate projects for mobile and desktop web, but now they [are merged][force_merge_pr]. It is hosted on [Heroku](http://heroku.com) and uses [Redis](http://redis.io) for caching. Assets, including artwork images, are served from [Amazon S3](http://aws.amazon.com/s3/) via the [CloudFront CDN](http://aws.amazon.com/cloudfront).

What you see today when you open the Artsy iOS app is a mix of Objective-C, Swift and React Native. Objective-C and Swift continue to provide a lot of over-arching cross-View Controller code. While individual representations of Artsy resources tend to be built in React Native. All of our React Native code uses Relay to handle API integration.

Our core-API is a Rails app using [Grape](https://github.com/intridea/grape) which serves JSON. The API [runs on][aws] [AWS OpsWorks](http://aws.amazon.com/opsworks) and retrieves data from several [MongoDB](http://www.mongodb.com) databases hosted with [Compose](https://www.compose.io). It also uses [Apache Solr](http://lucene.apache.org/solr), [Elastic Search](https://www.elastic.co) and [Google Custom Search](https://www.google.com/cse). The API service also heavily relies on [Memcached](http://memcached.org).

[confirm with joey about ^ - I know there are search changes]

Most modern code for both the website, and the iOS app use an API meta-layer which is powered by [GraphQL][graphQL]. Our GraphQL server is an [Express](http://expressjs.com) app, using [express-graphql][express-graphql] to provide a single API end-point. The GraphQL API does not access our data directly, but forwards requests to the core API, or to micro-services. We have been migrating front-end display logic into the GraphQL server, to make it easier to build consistent clients.

We continue to have a [public HAL+JSON API](https://developers.artsy.net) for external developers, this API is in active use for a few production services inside Artsy.

## CMS + Writer

We have three major CMS projects:

* One for Partners to upload Show, Fair, Artist and Artwork metadata.
* One for Editorial, and Partners for writing articles for our magazine.
* One for in-house Genomers to handle connecting artworks together.

[CMS]
[Writer]
[Genome tool]

## Analytics

We have consolidated a lot of our analytics tooling into RedShift

[confirm with Will]

## Platforms

[jwt] 
/blog/2016/10/26/jwt-artsy-journey/

[messaging]
We have a messenger service using [RabbitMQ][rabbitMQ] so that multiple services could register for notifications of important systemic events. This ...

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

By the end of 2016, almost every major front-end aspect of Artsy was [Open Source by Default][oss-default]. This means the entire working process is done in the open, from developer PRs to QA. In order to work in the open but still keep details private, we create a private GitHub repo for each front-end team that represents cross-project issues and team milestones. This is done using [ZenHub][zenhub], and is managed by Engineering leads and Product Managers.

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
[rabbitMQ]: 
[aws]: /blog/2013/08/27/introduction-to-aws-opsworks/
