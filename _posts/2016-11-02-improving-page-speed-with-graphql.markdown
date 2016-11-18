---
layout: post
title: "Improving Page Speed with GraphQL"
date: 2016-11-02 14:21
author: kana
categories: [graphql, javascript, positron, joi]
---

This past year, our team started using a GraphQL orchestration layer that connects various APIs with many front-end apps including [iOS](http://artsy.github.io/blog/2016/06/19/graphql-for-mobile), handles caching, and extracted some business logic out of our client apps. This helped us not only to be more consistent with the way we fetch data across apps, but also improved developer happiness and even bridged teams by having our web and iOS developers work with the same orchestration API layer. This got me thinking what other problems GraphQL could solve at Artsy.

I work on the Publishing Team at Artsy, and we've recently been focused on page speed as a KPI. With so many ways of measuring speed, it's a daunting task but for this post, I'll focus on the way we handled things on the server-side and how integrating GraphQL on our API improved page speed.

<!-- more -->

## Speed Issues

In our publishing CMS called [Positron](http://github.com/artsy/positron), we run a separate API, database, and front-end from the rest of the Artsy stack. We're also responsible for the delivery and presentation of the content itself. Over the past year we've focused a lot on how the content appears, and now we've opened up time to focus on speed since in the land of content, every second counts.

We split the speed problem in two: `Server Response Time` (server-side) and `Document Interactive Time` (client-side). We currently use Google Analytics to track these [metrics](https://support.google.com/analytics/answer/2383341?hl=en). There are some inaccuracies with GA such as small sampling, geographic noise (countries with different download speeds), and timeouts being counted as zero, but for our initial testing this will suffice for relative measuring.


## Low-hanging fruit

Before we went ahead with adding a GraphQL-based endpoint in Positron, I spent about a week and refactoring our current codebase. We refactored our router code to make less fetches, made better use of caching, and moved some below-the-fold rendering into the client side. These are important steps towards a faster page, but it doesn't push our technology in a direction that lets us reimagine things.

## Enter GraphQL and JoiQL

Our very own [Craig Spaeth](https://twitter.com/craigspaeth) recently started working on a project called [Mural](https://github.com/muraljs/mural). It's a framework for React and GraphQL. One library that came out of this project is called [JoiQL](http://github.com/muraljs/joiql). The main purpose of JoiQL is to convert [Joi](http://github.com/hapijs/joi) schemas into GraphQL schemas, and vice versa.

We already use Joi in Positron so creating a GraphQL-based endpoint was trivial with JoiQL. Note that while JoiQL is currently used in production, it's still a beta project! Below is an example of how the JoiQL setup works.


```javascript
const joiql = require('../')
const { object, string, number, array, date } = require('joi')
const app = require('express')()
const graphqlHTTP = require('express-graphql')

# Given a Joi schema:
const Article = object({
  title: string(),
  body: string(),
  published_at: date()
}).meta({
  args: { id: number().required() }
})

# Define api with JoiQL like this:
const api = joiql({
  query: {
    article: Article
  }
})

# Resolve the request using a Koa 2 style middleware pattern:
api.use((ctx, next) => {
  return new Promise (resolve, reject) ->
    # Method that fetches an article based on the query
    findArticle(ctx.req.query.article.args), (err, results) ->
      ctx.res.article = results.article
      next()
      resolve()
})

# Finally, mount our schema to express:
app.use('/graphql', graphqlHTTP({
  schema: api.schema,
  graphiql: true
}))
app.listen(3000, () => console.log('listening on 3000'))

```

You can see how simple it becomes to convert apps that already use Joi with JoiQL. It's less JSON blobs to handle and we also get a nice Koa 2 style middleware pattern that lets us hook into a downstream/upstream flow. This could be useful later on when if we were to get really granular with measuring speed and decided to track the speed of a request manually. We could do something like this:

```
api.use((ctx, next) => {
  startTIme = Date.now()
  next()
  console.log(Date.now() - startTime)

api.use((ctx, next) => {
  # fetch content here
  next() #we get bumped back up after this
})
```

## Results

Data flexibility and reduced payload turned out to be one of the biggest factors in reducing speed. Just after October 27 we switched over to using GraphQL on our (mobile articles landing page)[http://m.artsy.net/articles].

![download time](/images/2016-11-02-improving-page-speed-with-graphql/download_time.png)

Since we were previously fetching an entire collection of articles (content included), rendering a simple page like a list was increasing the payload size significantly. This is especially important for mobile devices where we encounter slow network speeds.

Other benefits of GraphQL haven't really come into view yet since we've just started the refactoring process. When fetching pages that require multiple requests, being able to coalesce them will be extremely beneficial. Right now, to render an article, there are up to 5 fetches that can occur. If we can aggregate the request and cache the response using a client like [Lokka](http://github.com/lokka/lokka), our future looks bright.


## What's next?

Besides making use of this new endpoint on all the things, I think the next big win with GraphQL is to add mutations and see how it fits with our editing process. We currently use a combination of Backbone and React to edit articles, so I think it will be an interesting transition to be able to use both mutations and queries and ultimately move away from Backbone and towards managing states with Redux where we could cleanly implement things like revision history, which would be a joy for our editors.

In the context of speed, some other topics I look forward to exploring are optimizing expensive database queries and client-side asset compression.
