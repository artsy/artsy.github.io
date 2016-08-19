---
layout: post
title: Designing the Public Artsy API
date: 2014-09-12 12:21
comments: true
categories: [API, Open-Source]
author: db
---

Today we are happy to announce that we're making a new public API generally available, along with over 26,000 artworks from many of our institutional partners.

The Artsy API currently provides access to images of historic artwork and related information on [artsy.net](https://artsy.net) for educational and other non-commercial purposes. You can try it for playing, testing, and learning, but not yet for production. The scope of the API will expand in the future as it gains some traction.

<a href="https://developers.artsy.net"><img src="/images/2014-09-12-designing-the-public-artsy-api/the-art-world-in-your-app.png" border="0"></a>

If you just want to use the API, you can stop reading here and head to the [developers.artsy.net](https://developers.artsy.net/) website. (The developers website itself is a classic Rails + Bootstrap example and is also [open-source](https://github.com/artsy/doppler).)

In this post we will step back and describe some of the technical decisions made during the development of the new API.

<!-- more -->

## First, Make All The Mistakes

Artsy has been developing a homegrown API over the last four years, consisting of almost 400 endpoints and exposing over 100 domain models. It's probably one of the largest [Ruby Grape](https://github.com/intridea/grape) implementations and it has been battlefield-tested by the dozens of services that we have built around it, starting with our [recently open-sourced artsy.net website](https://github.com/artsy/force). The core API project itself is unfortunately not public.

As with all legacy code with many client dependencies, our API has accumulated a staggering number of architectural faults, which have become impossible to work ourselves out of without a major rewrite. When thinking about a public API we went back to the drawing board with a more pragmatic approach.

## Use Hypermedia

One of the common problems of being an API client is figuring out which routes an API provides or what data is available. For example, what can I do with this specific artwork? Documentation helps, but it often lacks such context. Furthermore, URLs are long and cumbersome to reference, parse and use. How can we make the API more developer-friendly and discoverable? Our answer was to settle on a well-known Hypermedia format. We chose [HAL+JSON](http://stateless.co/hal_specification.html) because it is disciplined and very complete. Let me illustrate by example.

The [API root](https://api.artsy.net/api) lists all the API routes within "_links", such as "artists".

``` json
{
  _links: {
    artists: {
      href: "https://api.artsy.net/api/artists"
    },
    ...
  }
}
```

If you fetch artists from the above URL, they will be returned in the same JSON+HAL format. Each artist will include a number of links, notably to the artist's artworks. This is a perfect example of "context".

``` json
{
  _embedded: {
    artists: [
      {
        id: 123,
        _links: {
          artworks: {
            href: "https://api.artsy.net/api/artworks?artist_id=123"
          }
        }
      }
    ]
  }
}
```

This is very powerful and makes it possible to write a generic API client that consumes any HAL+JSON API with just a bit of meta-programming. For Ruby, we provide examples using [hyperclient](https://github.com/codegram/hyperclient). Here's a more complete example that retrieves a well-known artist, [Gustav Klimt](https://artsy.net/artist/gustav-klimt), and a few of his works.

``` ruby
require 'hyperclient'

api = Hyperclient.new('https://api.artsy.net/api').tap do |api|
  api.headers.update('Accept' => 'application/vnd.artsy-v2+json')
  api.headers.update('X-Xapp-Token' => ...)
end

artist = api.links.artist.expand(id: '4d8b92b64eb68a1b2c000414') # Gustav Klimt
puts "#{artist.attributes.name} was born in #{artist.attributes.birthday} in #{artist.attributes.hometown}"

artist.links.artworks.embedded.artworks.each do |artwork|
  puts artwork.attributes.title
end
```

## Provide Canonical URLs for Resources

In the past we returned different JSON payloads for a resource when it appeared within a collection vs. when it was retrieved individually. We have also developed solutions such as [mongoid-cached-json](https://github.com/dblock/mongoid-cached-json) to deal with this in a declarative way. However, clients were burdened to merge data. For example, our iOS application had to deal with the fact that different data existed in the local store for the same artwork depending on how a user navigated to it in the app.

With the new API each resource has a canonical, uniquely identifying, "self" link which is used to reference it from other resources. When a client encounters such a link and has already downloaded the resource, it can just swap the data without making an HTTP request. This is only possible because every single URL maps 1:1 with a specific JSON response - there're no two data responses possible for the same URL. The retrieval of such data can be solved by a generic crawler - get a resource, fetch dependent resource links, iterate until you run out of links. Storage is even simpler and doesn't have to know anything about our domain model since it just maps URLs to JSON bodies.

## Partition Data and Perform Access Controls at API Level

Because we decided not to return two different types of responses for a given model, we needed to partition data at the model level. For example, we introduced publicly available [Users](https://developers.artsy.net/docs/users) and private [User Details](https://developers.artsy.net/docs/user_details). Access controls are now done exclusively at the API level.

The API developer must simply answer the question of whether a client is authorized to retrieve a resource or not. The API will return a 403 or 404 otherwise and it's not necessary to customize the response for different types of access.

## Be Disciplined About Data Access and NxM Queries

The performance of APIs that return collections of objects has been a constant struggle. The initial API design attempted to help clients make the least amount of HTTP requests possible, often requiring many NxM server-side queries. This actually had a profoundly negative impact on overall performance and user experience than we have ever anticipated. Servers had to allocate a lot more memory to parse, render and cache very large JSON payloads, also causing larger garbage collection cycles. Web applications seemed slower because a lot of data had to be retrieved to render anything on initial page load. Mobile clients spend a lot more time parsing huge JSON payloads, requiring a lot of CPU and yielding rarely. This created a very sluggish user experience and much longer delays waiting for background processing to finish. To mitigate this and keep our API response times low on the server we had to leverage complicated caching schemes with [garner](https://github.com/artsy/garner) and had to fine-tune Mongoid's eager-loading endpoint by endpoint.

For the new API we decided to never return relational data for a given model and refactor relations at the API model level when necessary. For example, we do not return artist information with a given artwork, but we do return a collection of artist links (an artwork can be created by a group of artists).

``` json
_embedded: {
    artist_links: [
      {
        id: "4fe8862daa12fb00010017b9",
        _links: {
          artist: {
            href: "https://api.artsy.net/api/artists/4fe8862daa12fb00010017b9"
          }
        }
      }
    ],
  }
}
```

We can still leverage the fact that we do have embedded objects in MongoDB and the fact that HAL supports embedded data. For example, we always return editions embedded within an artwork. Being disciplined about this allows the server to make one database query for one API request.

Furthermore, creating such rigid rules forces us to never optimize for a specific client's scenario. That said, we still want to make life easy for developers that need bulk loading of various resources. We plan to implement a [Netflix API](http://techblog.netflix.com/2012/07/embracing-differences-inside-netflix.html)-style middleware, where you can supply a set of URLs and get back a single, full JSON response with many different embedded resources. HAL+JSON's disciplined structure makes mixing data very easy.

## Use Media Types and Accept Headers for Versioning

Our initial API lives under a versioned URL which includes "v1". For the new API we decided to adopt a different model and use an "Accept" header which currently takes an optional "application/vnd.artsy-v2+json" media type.

```
$ curl 'http://api.artsy.net/api' -H 'Accept:application/vnd.artsy-v2+json'
```

Accept headers in the API context can be used to indicate that the request is specifically limited to an API version. Our API will serve a backward compatible format by default. However, when we decide change the format of a resource we will increment the API version and require a newer value in the header to retrieve it. The new version can become the default only after the old version has been fully deprecated.

## Create a Flat API Structure and Leverage 302 Redirects

Our old API served all artworks from "/artworks" and artworks belonging to a partner from "/partner/:id/artworks". This was convenient, but made obsolete by a Hypermedia API. API URL structure no longer matters, because you no longer have to build URLs yourself, but follow links instead.

We decided to expose all models at the root and to use query string parameters for filtering. The API uses a plural for all routes, so you can query both "/artworks" and "/artworks/:artwork_id". At the Hypermedia API root level those differences are expressed in a declarative way in the shape of link templates with a singular (an artwork) or a plural (artworks) key, and all possible parameters.

``` json
{
  _links: {
    artworks: {
      href: "https://api.artsy.net/api/artworks{?public,artist_id}",
      templated: true
    },
    artwork: {
      href: "https://api.artsy.net/api/artworks/{id}",
      templated: true
    }
  }
}
```

We leverage 302 redirects extensively. For example, querying "/current_user" redirects to "/users/:user_id" with a 302 status code (we cannot serve different content per user at the root of the API, as explained in a section above). Another good example is that the current API only provides access to public domain artworks, so if you navigate to "/artworks", you will currently be redirected to "/artworks?public=true", making this scheme future-proof.

## Do Not Paginate with Pages and Offsets

Our original API accepted "page" or "offset" parameters. This was rather problematic for changing collections. Consider what happens when you are on page 5 and an item is inserted on page 4. Your next set of results for page 6 will include a duplicate that has just moved from page 5 onto page 6. Similarly, if an item was removed from page 4, a request to page 6 will skip an item that now appears on page 5.

Our new API returns subsets of collections with "next" links and optional counts. To fetch a subsequent page, follow the "next" link, which accepts an opaque "cursor" (internally we use the [mongoid-scroll](https://github.com/dblock/mongoid-scroll) Ruby gem). The cursor retains position in a collection, including when an item has been deleted.

``` json
{
  total_count: 26074,
  _links: {
    self: {
      href: "https://api.artsy.net/api/artworks?public=true"
    },
    next: {
      href: "https://api.artsy.net/api/artworks?cursor=...&public=true"
    }
  }
}
```

We also wanted to solve the problem of querying different page sizes as we often wanted to retrieve just a couple of items quickly on an initial page load, then make larger requests for subsequent pages as the user scrolled, or vice-versa. You can now supply "size" to all collection APIs and a cursored approach makes it possible to vary the number on every request.

To get the "total_count", we decided to require clients to append "?total_count=true" to the query string. It's not necessary to do all that counting work on the server side if you're not going to use the data.

## Standardize Error Format

We use HTTP error codes, however we also use JSON data that comes with those errors for additional, often humanly readable descriptions. We settled on a standard error format that includes a "type" and a "message". For example, a 401 Unauthorized response will also carry the following payload.

``` json
{
  type: "auth_error",
  message: "The access token is invalid or has expired."
}
```

## Conclusion

We tried to stay pragmatic with our approach and still have time and room for improvements. We would love to hear from you on our [API developers mailing list](http://groups.google.com/group/artsy-api-developers/subscribe) and hope you'll give our new API a try at [developers.artsy.net](https://developers.artsy.net/).
