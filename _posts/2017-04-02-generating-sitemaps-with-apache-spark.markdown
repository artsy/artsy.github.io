---
layout: post
title: "Generating Sitemaps with Apache Spark"
date: 2017-04-02
comments: true
author: db
categories: [Big Data, Apache Spark]
---
While Artsy is the largest database of Contemporary Art online, it's not exactly "big data". To date, we have published over 500,000 artworks by more than 50,000 artists from over 4,000 galleries, 700 museums and institutions across over 40,000 shows. Our team has written thousands of articles, hosted hundreds of art fairs and a few dozen auctions. We have over 1,000 genes from the Art Genome project, too.

There're just over a million web pages generated from this data on [artsy.net](https://www.artsy.net). Generating sitemaps to submit to Google and other search engines for a million pages never seemed like a big deal. In this post I'll describe 3 generations of code, including our most recent iteration that uses Apache Spark to generates static sitemap files in S3.

<!-- more -->

### What's in a Sitemap?

If you're not familiar with sitemaps, they are an easy way for us to inform search engines about pages on artsy.net available for crawling. A Sitemap is an XML file that lists URLs along with some additional metadata. All Artsy sitemaps are listed in our [robots.txt](https://www.artsy.net/robots.txt).

```
User-agent: *
Sitemap: https://www.artsy.net/sitemap-artists.xml
Sitemap: https://www.artsy.net/sitemap-shows.xml
...
```

These are actually sitemap indexes, such as [the shows sitemap index](https://www.artsy.net/sitemap-shows.xml). Each index contains links to the actual sitemaps.

```xml
<sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
 <sitemap>
  <loc>https://www.artsy.net/sitemap-shows-2016.xml</loc>
 </sitemap>
 ...
</sitemapindex>
```

Each sitemap contains links to web pages on [www.artsy.net](https://www.artsy.net), such as the [sitemap containing links to shows in 2016](https://www.artsy.net/sitemap-shows-2016.xml).

```xml
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
 <url>
  <loc>https://www.artsy.net/show/guy-hepner-kate-moss-exhibiton</loc>
 </url>
 ...
</urlset>
```

### The Monolith's Rake Task

When Artsy was a Ruby on Rails monolith we generated and wrote static sitemap files to S3 in a Rake task. We iterated over all our data nightly, created a set of URLs and wrote an XML file. We got fairly clever with a `Sitemappable` module that was included in anything that yielded a sitemap.

```ruby
module Sitemappable
  extend ActiveSupport::Concern

  module ClassMethods
    def sitemappable_priority
      0.5
    end
  end
end
```

We even used HAML, the same templating system we used to render web pages, to render sitemaps.

```haml
!!! XML
%urlset{ xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" }
  - documents.each do |document|
      - type.sitemappable_urls(document, self).each do |url|
        %url
          %loc=h url
```

Of course, there were many more implementation details, but adding a sitemap was easy as we made Mongoid models use `Sitemappable`.

Generating sitemaps took a couple of hours and ran nightly.

### The Dynamic Front-End

By 2015 our front-end was fully decoupled from the monolith that now served as the core API service. The sitemap code still lived there and needed to know about an increasing number of URLs, which seemed totally backwards. We wanted an easier way to maintain and update sitemaps and concluded that by generating sitemaps on the fly we would also see better reflect our live data and prevent 404s in stale sitemaps during crawling. Furthermore, sitemaps increasingly needed information from other places, as we tore the monolith apart into micro-services.

Our solution for dynamic sitemaps queried the API for the number of total items in every collection, then generated a sitemap index with an entry for each page of results. A subsequent query from Google for a given page would query the API for the actual data that was needed to produce the requested sitemap. You can see the entire code [in our open-source artsy.net project](https://github.com/artsy/force/tree/2059f8f5e7faa8213221480c1c9cd3c62e9d5ffb/desktop/apps/sitemaps).

This worked for a while, but introduced new challenges. The first was that we needed individual sitemaps to contain thousands of items or have tens of thousands of sitemaps. That meant tens of megabytes of data returned from either multiple API calls or from a very slow single API query. That problem was even more serious for models that required joining data, and was solved by our first attempt at an orchestration layer that would crawl our own API on a schedule. Today we use GraphQL for that purpose, but we never deprecated the system we put in place during this phase of the sitemap rewrite. That system was barely maintained and riddled with its own issues, starting by the fact that the data crawl began timing out as the amount of data increased sharply. This system quickly became unsustainable as our data grew.

### The Big(gish) Data Solution

In 2016 we started using Apache Spark for calculating similarity graphs and artwork recommendations. We previously loaded a vast majority of our data from many sources into HDFS and wrote Spark jobs in Scala. Having all the data from our multiple databases readily available made our Spark cluster a perfect candidate for a simple need like sitemaps.

#### A Spark Job

A spark job is a Scala class with an entry point that receives some configuration. A typical sitemap fetches data, partitions it, and generates XML sitemap files. This is automatically parallelized and distributed across worker nodes that already have their subset of data locally, making the whole thing blazingly fast.

```scala
def main(args: Array[String]): Unit = {
  val conf = new SparkConf().setAppName(this.getClass.getName)
  val sc = new SparkContext(conf)
  val hc = new HiveContext(sc)
  val data = getData(hc)
  val sitemaps = generateSitemaps(mapData(data))
  writeSitemaps(sitemaps)
  writeSitemapsIndex(sitemaps)
  purgeSitemaps(sitemaps)
}
```

#### Getting Data

We use Hive to define schemas for all data stored in HDFS. The following example fetches a show ID and its start date/time.

```scala
def getData(hc: HiveContext): RDD[Row] = {
  hc.sql("SELECT id, start_at FROM shows")
}
```

#### Mapping Data

We partition sitemaps by date (mostly by year). This helps keep track of how many URLs Google has indexed and makes problems easier to diagnose.

We start by bucketing data for simple objects into tuples of `(date, Iterable[String])`. In the following example all shows in 2016 will be grouped together.

```scala
def mapData(rows: RDD[Row]): RDD[(String, Iterable[String])] = {
  rows.map { row =>
    val id = row.getString(0)
    val start_at = new DateTime(row.getLong(1))
    val year = DateTimeFormat.forPattern("yyyy").print(start_at)
    (year, slug)
  }.groupByKey()
}
```

#### Generating Sitemaps

For each bucket we generate a sitemap. Each sitemap entry is a URL with a `loc`.

```xml
def getSitemapEntry(id: String): Elem = {
  val loc = s"https://www.artsy.net/show/${id}"
  <url><loc>{ loc }</loc></url>
}
```

Sitemaps cannot contain more than 50,000 items according to the [sitemap spec](https://www.sitemaps.org/protocol.html), so we generate files such as `sitemap-shows-2016-1.xml` and `sitemap-shows-2016-2.xml` when necessary.

```scala
def getSitemaps(data: RDD[(String, Iterable[String])]): RDD[(String, Elem)] = {
  data.map {
    case (date: String, all: Iterable[String]) =>
      val groups = all.iterator.grouped(50000).zipWithIndex
      groups.map {
        case (ids: Seq[String], index: Int) =>
          val indexLabel = if (index != 0 || groups.hasNext) s"-${index + 1}" else ""
          val dateLabel = s"-${date}"
          val sitemapKey = s"sitemap-shows${dateLabel}${indexLabel}"
          val sitemapXml = <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{
            ids.map(getSitemapEntry)
          }</urlset>
          (sitemapKey, sitemapXml)
      }.toArray
  }.flatMap(x => x)
}
```

#### Writing Sitemap Files

We write a file for each sitemap. The production output goes to S3.

```scala
def writeSitemaps(sitemapsXml: RDD[(String, Elem)]) = {
  sitemapsXml.foreach {
    case (key: String, xml: Elem) =>
      writeFile(xml, s"${key}.xml")
  }
}
```

#### Writing Sitemap Index

An index is a list of all the sitemaps, also written to S3.

```scala
def getSitemapsIndex(sitemapsXml: RDD[(String, Elem)]): Elem = {
  <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{
    sitemapsXml.collect().map {
      case (key: String, _) =>
        <sitemap><loc>{ s"https://www.artsy.net/${key}.xml" }</loc></sitemap>
    }
  }</sitemapindex>
}

def writeSitemapsIndex(sitemapsXml: RDD[(String, Elem)]) = {
  val sitemapsIndexXml = getSitemapsIndex(sitemapsXml)
  writeFile(sitemapsIndexXml, s"sitemap-shows.xml")
}
```

You also need to do a bit more work to purge files that are no longer generated as data changes. For the shows example above we fetch a list of sitemap files such prefixed by `sitemap-shows-` and delete the set difference.

```scala
def purgeSitemaps(sitemapsXml: RDD[(String, Elem)]) = {
  val sitemapKeys = sitemapsXml.keys.map(k => s"${k}.xml")
  val existingFiles = ... // fetch files prefixed by sitemap-shows-
  val filesToDelete = existingFiles &~ sitemapKeys.collect().toSet
  keysToDelete.foreach(file => deleteFile(file))
}
```

#### Serving Sitemaps

We serve sitemaps through a Node.js proxy [in our front-end](https://github.com/artsy/force/blob/9eedf063d024ea94e6c32b01497c3fcb7f596d68/desktop/apps/sitemaps/routes.coffee#L42).

```js
SITEMAP_BASE_URL = 'http://artsy-sitemaps.s3-website-us-east-1.amazonaws.com'
httpProxy = require 'http-proxy'
{ parse } = require 'url'
sitemapProxy = httpProxy.createProxyServer(target: SITEMAP_BASE_URL)

@sitemaps = (req, res, next) ->
  req.headers['host'] = parse(SITEMAP_BASE_URL).host
  sitemapProxy.web req, res
```

### Results

We schedule a workflow for each sitemap in Spark with Oozie. Each sitemap job completes in under 5 minutes, which is pretty remarkable given where we started. It will also easily scale to many multiples of our current size as our data continues to grow.
