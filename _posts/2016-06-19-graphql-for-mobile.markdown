---
layout: post
title: "GraphQL for iOS Developers"
date: 2016-06-19 12:09
author: orta
categories: [mobile, graphql, eigen]
---

GraphQL is something you may have heard in passing, usually from the web team. It's a Facebook API technology, that describes itself as a _A Data Query Language and Runtime_. As mobile engineers, we can consider it an API, where the front-end team have as much control as the backend.

This blog post covers our usage of GraphQL, and what I've learned in the last 3 months of using it in [Eigen](https://github.com/artsy/eigen/).

<!-- more -->

### So what is GraphQL

So, you can get the full explaination on [their website](http://graphql.org). Though I found running through [Learn GraphQL](https://learngraphql.com) to really hammer down how it works as an API consumer. Reading the [introduction blog post](https://facebook.github.io/react/blog/2015/05/01/graphql-introduction.html) can be useful too, I'll be doing a quick TLDR though.

GraphQL is an API middle-layer. It acts as an intermediate layer between multiple front-end clents and multiple back-end APIs. This means it can easily coalesce multiple API calls into a single request, this can be a _massive_ user experience improvement when you have a screen that requires information from multiple sources before you can present anything to a user.

<img src="/images/2016-06-19-graphql-for-iOS-devs/graphQL.svg" width=100%>

As a client, you send a "JSON-SQL"-like query structure, which is heirarchical and easy to read:

```json
{
  artwork(id: "kimber-berry-as-close-to-magic-as-you-can-get") {
    id
    additional_information

    is_acquireable
    is_sold
  }
}

```

> This will search for a [specific artwork](https://www.artsy.net/artwork/kimber-berry-as-close-to-magic-as-you-can-get), sending back the Artwork's `id`, `additional_information`, `is_acquireable` and `is_sold`.

It's important to note here, the data being sent _back_ is only what you ask for. This is not defined on the server as a _short_ or _embedded_ version of a model, but the specific data the client requested. When bandwidth and speed is crucial, this is another way in which GraphQL improves the end-user experience.

So, that's the two killer features:

1. Coelesce Multiple Network Requests
2. Only Send The Data You Want

This is in stark contrast to existing API concepts, like [HAL](http://stateless.co/hal_specification.html) and [JSON-API](http://jsonapi.org) - both of which are optimised for caching, and rely on "one model, one request" types of API access. E.g. a list of Artworks would actually contain a list of hrefs instead of the model data, and you have to fetch each model as a separate request.

### How We Use GraphQL

### How GraphQL Changed How We Write View Controllers
