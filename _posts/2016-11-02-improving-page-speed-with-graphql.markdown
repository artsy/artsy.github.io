---
layout: post
title: "Improving Page Speed with GraphQL"
date: 2016-11-02 14:21
author: kana
categories: [graphql, javascript, positron]
---

This past year, our team started using a GraphQL orchestration layer that connected various REST APIs, handled caching, and extracted some business logic outside of our client apps. This helped us not only in creating fast views, but it also improved developer happiness and overall consistency of the way we fetch data on our front end apps. This got me thinking more and more about GraphQL and what other problems it could solve.

I work on the Publishing Team at Artsy, and we've recently been focused on page speed as a KPI. With so many ways of measuring speed, it's a daunting task but for this post, I'll focus on the way we handled things on the server-side and the implementation of GraphQL into our API to improve speed.

<!-- more -->

## Speed Issues

In our publishing CMS called [Positron](http://github.com/artsy/positron), we run a separate API, database instance, and front-end from the rest of the Artsy stack.

Since we had an opportunity to experiment, had a tangible metric to test agains, and since our stack was already shifting towards the Facebook technilogies, it made a lot of sense to test out GraphQL on our API next.

** mention metrics used

## Low-hanging fruit

Before we went ahead with adding a GraphQL-based endpoint in Positron, we spent about a week tweaking and refactoring our current code-base. We refactored our router code to make less fetches, made better use of caching (although this turned out to be a pain for our Editors), and moved some below the fold rendering into the client side.

## Enter GraphQL and JoiQL

Our very own [Craig Spaeth](https://twitter.com/craigspaeth) recently started working on a project called [Mural](https://github.com/muraljs/mural). It's a framework for React and GraphQL. One library that came out of this beta project is called [JoiQL](http://github.com/muraljs/joiql). The main purpose of JoiQL is to convert [Joi](http://github.com/hapijs/joi) schemas into GraphQL schemas, and vice versa.

Creating a GraphQL-based endpoint becomes trivial with JoiQL. Note that while JoiQL is currently used in production, it's still a beta project!

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

You can see how simple it becomes to convert apps that already use Joi with JoiQL.

** compare this to traditional way of defining graphql api.

## Results

Data flexibility and reduced payload turned out to be the biggest factors in reducing speed. Just after October 27 we switched over to using GraphQL on our (mobile articles landing page)[http://m.artsy.net/articles].

** payload size mobile especially important for slow network speeds

![download time](/images/2016-11-02-improving-page-speed-with-graphql/download_time.png)

** other benefits of graphql - coalescing requests


## What's next?

Besides making use of this new endpoint on all the things, I think the next big win with GraphQL is to add mutations and see how it fits with our article editing process. We currently use a combination of Backbone Models and React to edit articles, so I think it will be an interesting transition to be able to use both mutations and queries.