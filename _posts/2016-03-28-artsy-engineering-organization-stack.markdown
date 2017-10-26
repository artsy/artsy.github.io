---
layout: post
title: Artsy's Engineering Organization Stack, 2016
date: 2016-03-28
comments: true
categories: [People]
author: db
series: Artsy Tech Stack
---
<div style="max-width: 50%; text-align: center; float: right; padding: 0 0 10px 10px; line-height: 1;"><img src="/images/2016-03-28-artsy-engineering-organization-stack/stack.jpg"><br><font size="2px"><em>The Artsy Engineering Organization "Stack" in 2012<br>from <a target="_blank" href="http://code.dblock.org/2011/07/12/sitting-is-killing-you-move-to-new-york.html">"Sitting is Killing You? Move to New York"</a></em></font></div>

Artsy has now grown past 140 team members and our Engineering organization is a nimble 25. We've recently performed a large organizational change (I highly recommend reading ["The Secret(s) to Company Re-Orgs"](https://www.artsy.net/article/robert-lenne-the-secret-s-to-company-re-orgs)), so this is a good time to describe our updated Engineering organization, starting from the top - Artsy as a company and business.

<!-- more -->

## The Company

Artsy’s mission is to make all the world’s art accessible to anyone with an Internet connection. We are a resource for art collecting and education. Artsy features the world’s leading galleries, museum collections, foundations, artist estates, art fairs, and benefit auctions, all in one place. Our growing database of 350,000 images of art, architecture, and design by 50,000 artists spans historical, modern, and contemporary works, and includes the largest online database of contemporary art. Artsy is used by art lovers, museum-goers, patrons, collectors, students, and educators to discover, learn about, and collect art.

## The Artsy Businesses

Artsy has 3 businesses: _Listings_, _Marketplace_ and _Content_.

**Listings**: Artsy [gallery partners](https://www.artsy.net/galleries) pay a flat monthly subscription fee to list an unlimited number of artworks for sale, plus a host of other benefits. They do not pay a commission fee on sales made through Artsy.

**Marketplace**: In 2015 Artsy expanded into hosting commercial auctions on our platform. Much like our Listings business, we work with top auction houses. The latter pay commissions from sales. Check out [current auctions on Artsy](https://www.artsy.net/auctions).

**Content**: We are also working on making Artsy a go-to platform for brands to co-create and distribute content that engages a global arts and culture audience. In 2015 we debuted our first sponsored content feature on Artsy, a [series of 11 educational short films about the Venice Biennale in partnership with UBS](https://www.artsy.net/venice-biennale-2015) (if anything, [watch this amazing video](https://www.artsy.net/article/artsy-editorial-behind-the-venice-biennale-2015-a-short-history-of-the-world-s-most-important-art-exhibition)).

## A Product Engineering Organization

We think of _Engineering_ as a service of the _Product_ organization. Products serve customers and product teams serve businesses. Each product team may contribute to one or several businesses. To make our goals crystal clear, we developed Key Performance Indicators (KPIs) for each business. For example, _churn_ is a KPI for the Listings business - a low churn shows how well we're serving our existing subscribers. Furthermore, we designed each product team to own all necessary resources to accomplish their goals. In some ways, our product teams operate like small start-ups.

Each product team consists of one or more _Business People_, a _Product Owner_ (often a _Product Manager_), a _Designer_, an _Engineering Lead_ and several _Engineers_.

Our product teams map directly into our businesses and inherit the same KPIs.

**Partner Success**: The Partner Success team focuses on products that serve the Listings business. These include our Content Management system and [Artsy Folio](http://folio.artsy.net), an iPad app used by our partners.

**Auctions**: The Auctions product team builds all auction systems across web and mobile.

**Collector GMV**: GMV stands for _Gross Merchandising Volume_, a measure of artworks traded on the platform. We have two collector product teams, web and mobile, focused on various customer experiences across all our web and mobile properties.

**Publishing**: The publishing team works on the platform used to produce and distribute all our online editorial content.

## Practices

While there're many advantages of product teams operating independently, it's also very easy to create vertical inefficiencies. Multiple teams could choose to achieve similar outcomes in many different ways, creating a lot of redundant work and making it impossible for team members to move between organizations.

To address this problem we've created a separate _Platform Engineering Team_ and _Practices_.

The Platform Engineering Team is responsible for systems and shared infrastructure that help product teams work smarter, scale our operations, and much more. Our _Design_ team is similar in nature to Platform Engineering, creating a consistent visual language and user experience across all products.

Our _Practices_, specifically _Web_ and _Mobile_, are run by a handful of experienced Engineers working independently and floating between product teams to build features, while evangelizing best practices of making software or our [commitment to open-source](http://artsy.github.io/open-source) at the same time. Engineers on product teams may also belong to a practice - mobile engineers on the Auctions team are members of the Mobile practice, but don't report to the Director of Mobile.

## Reporting Structure

We believe that in order to help our team members grow professionally, their manager must understand their work. Engineers report to Engineering Leads in product teams. Engineering and Engineering Practice Leads report to the Head of Engineering. Product Managers report to the Head of Product. Designers report to the Design Lead, who reports to the Head of Product. It's important to note that, while preserving top-down authority and responsibility, we try to practice bottom-up leadership - the job of team leads is to help individual contributors do their best work.

## Conclusion

We have a very complex business, and we think our structure works well for a company that does many things at once. Your mileage may vary, so don't try to apply the same structure in your company just because this works for us! And always remember that evolving an organization is a disruptive process. It may yield better focus and can be transformational to a group. It may also produce the opposite effect, since moving individuals between teams is much more involved than drag-and-dropping a headcount in an organizational chart.
