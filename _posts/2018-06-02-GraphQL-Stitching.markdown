---
layout: epic
title: GraphQL Stitching 101
date: 2018-06-02
author: [orta]
categories: [graphql, stitching, metaphysics]
css: graphql
# comment_id: 443
---

Micro-Services make sense. You can scope a domain of your business to particular small unit of abstraction like an
API. Doing so makes it easy to work in isolation, experiment with new ideas and evolve in many directions.

We've been [carefully pushing][monolith] for years to move away from our single monolithic API, to a collection of
smaller, more focused projects. This is great from a platform/systems perspective but is a bit tricky to handle from
major front-end clients. The main way that we've addressed this has been to store a lot of that complexity inside
our main GraphQL API, [metaphyics][mp].

As more services have been created, and grown - so has metaphysics. This creates a worrying trend. Our main
line-of-thought on how to address this is via GraphQL Stitching. This post goes into some of the implementation
details, and ideas.

<!-- more -->

## What is Schema Stitching?

Schema Stitching came out at the [end of 2017][stitching_out] and became very production-[ready in April
2018][stitching_announcement].

We started experimenting last year and, we have all the code [in metaphysics][stitch_mp], but it's still behind a
feature flag. Every so often an engineer picks the project back up and we get a little bit closer to having it
running in production. Safe, incremental evolutions over bold revolution.

Here are the principals:

* **GraphQL Schema** - a representation of your GraphQL's type system, containing all Types and fields on them
* **GraphQL Resolver** - every field accessed in a query has a corresponding resolver
* **Schema Merging** - taking two GraphQL schemas, and merging all the Types and resolvers
* **Schema Stitching** - extending a GraphQL Schema by using Types from another schema

Stitching is one of the end-goals, but merging may be enough for a lot of cases. Both of the two launch posts above
give a much more in-depth explanation of how everything comes together, but that should be enough for this post.

## How Do We Do It?

We have 4 GraphQL APIs inside the Artsy ecosystem, our aim is to cautiously include these APIs inside metaphysics.
We don't need the entire contents of those APIs, and as you'll learn - we couldn't do that even if we wanted.

The technique we settled on was:

1.  Download the schema of each external API into metaphysics' source code
1.  Have each schema trimmed to just the essentials that we need today
1.  Merge in each schema incrementally
1.  Stitch in any desired schema changes

Let's dig, with some code into how we do each of these steps.

#### Downloading Schemas

We created a [pretty minimal script][dl-schema] which can be run from a developer's computer.

```js
const destination = "src/data"

const httpConvectionLink = createHttpLink({
  fetch,
  uri: urljoin("https://convection-staging.artsy.net/api", "graphql")
})

introspectSchema(httpConvectionLink).then(schema => {
  fs.writeFileSync(path.join(destination, "convection.graphql"), printSchema(schema, { commentDescriptions: true }))
})
```

This uses a [apollo-http-link][] to grab our schema, and store it in our repo, see
[`src/data/convection.graphql`][c-gql]. This means that when someone wants to update to a new version of the schema,
it will go through code review and a normal testing-flow. This is useful because you don't know how the schema will
grow in the future.

Plus, if you have a local copy of the schemas, it's much easier to write tests for the next few steps.

#### Schema Manipulation

Each API writes for their own domain. This can be problematic when you use a `LineItem` in one API, which isn't
generic enough to be a `LineItem` in a global API of all services. When thinking about this problem, we created a
[guide for ourselves][guides-schema] on how to think about schema design at local and global level.

We use a few of [the transform APIs][transform] available in graphql-tools to make the merges work. The first
approach is to force a namespace by prefixing the merged Types with their domain.

```js
export const executableConvectionSchema = async () => {
  const convectionLink = createConvectionLink()
  const convectionTypeDefs = readFileSync("src/data/convection.graphql", "utf8")

  // Setup the default Schema
  const schema = await makeRemoteExecutableSchema({
    schema: convectionTypeDefs,
    link: convectionLink
  })

  // Remap the names of certain types from Convection to fit in the larger
  // metaphysics ecosystem.
  const remap = {
    Submission: "ConsignmentSubmission",
    Category: "ConsignmentSubmissionCategoryAggregation",
    Asset: "ConsignmentSubmissionCategoryAsset",
    State: "ConsignmentSubmissionStateAggregation",
    SubmissionConnection: "ConsignmentSubmissionConnection"
  }

  // Return the new modified schema
  return transformSchema(schema, [
    new RenameTypes(name => {
      const newName = remap[name] || name
      return newName
    })
  ])
}
```

Another example is to outright remove almost everything in the schema, and to only allow Types and fields which we
know to be useful.

```js
export const executableGravitySchema = async () => {
  const gravityTypeDefs = readFileSync("src/data/gravity.graphql", "utf8")

  const gravityLink = createGravityLink()
  const schema = await makeRemoteExecutableSchema({
    schema: gravityTypeDefs,
    link: gravityLink,
  })

  // Types which come from Gravity which MP already has copies of.
  // In the future, these could get merged into the MP types.
  const blacklistedTypes = ["Artist", "Artwork"]

  // Gravity's GraphQL contains a bunch of objects and root fields that will conflict
  // with what we have in MP already, this lets us bring them in one by one
  const whitelistedRootFields = ["Query", "recordArtworkView"]

  // Return the new modified schema
  return transformSchema(schema, [
    new FilterRootFields((_type, name) => {
      return !whitelistedRootFields.includes(name)
    }),
    new FilterTypes(type => {
      return !blacklistedTypes.includes(type.name)
    }),
    // snip
  ])
})
```

We can write tests for this by running [a query which returns all of the types][type-q] in a schema, and validating
what exists:

```js
import { executableGravitySchema } from "../schema"
import { getTypesFromSchema } from "lib/stitching/lib/getTypesFromSchema"

it("Does not include blacklisted types", async () => {
  const gravitySchema = await executableGravitySchema()
  const gravityTypes = await getTypesFromSchema(gravitySchema)

  expect(gravityTypes).not.toContain("Artist")
  expect(gravityTypes).not.toContain("Artwork")
})
```

#### Merging Schemas

[Merging a schema][merging] has a pretty small API surface,

```js
import { mergeSchemas as _mergeSchemas } from "graphql-tools"
import { executableGravitySchema } from "lib/stitching/gravity/schema"
import { executableConvectionSchema } from "lib/stitching/convection/schema"
import { executableLewittSchema } from "lib/stitching/lewitt/schema"

import localSchema from "../../schema"

export const mergeSchemas = async () => {
  const convectionSchema = await executableConvectionSchema()
  const convectionStitching = consignmentStitchingEnvironment(localSchema, convectionSchema)

  const gravitySchema = await executableGravitySchema()
  const lewittSchema = await executableLewittSchema()

  // The order should only matter in that extension schemas come after the
  // objects that they are expected to build upon
  const mergedSchema = _mergeSchemas({
    schemas: [gravitySchema, localSchema, convectionSchema, lewittSchema]
  })

  return mergedSchema
}
```

[stitching_announcement]: https://dev-blog.apollodata.com/the-next-generation-of-schema-stitching-2716b3b259c0
[stitching_out]: https://dev-blog.apollodata.com/graphql-tools-2-0-with-schema-stitching-8944064904a5
[monolith]: http://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017/#Artsy.Technology.Infrastructure.2017.-.Splitting.the.Monolith
[mp]: https://github.com/artsy/metaphysics/
[stitch_mp]: https://github.com/artsy/metaphysics/tree/1423ee39f8e348805710080a4857e6575d3ddade/src/lib/stitching
[apollo-http-link]: https://www.apollographql.com/docs/link/links/http.html
[dl-schema]: https://github.com/artsy/metaphysics/blob/1423ee39f8e348805710080a4857e6575d3ddade/scripts/dump-remote-schema.js#L15-L25
[c-gql]: https://github.com/artsy/metaphysics/blob/master/src/data/convection.graphql
[guides-schema]: https://github.com/artsy/guides/blob/master/guides/GraphQL-Schema-Design.md
[transform]: https://www.apollographql.com/docs/graphql-tools/schema-transforms.html
[type-q]: https://github.com/artsy/metaphysics/blob/1423ee39f8e348805710080a4857e6575d3ddade/src/lib/stitching/lib/getTypesFromSchema.ts
[merging]: https://github.com/artsy/metaphysics/blob/1423ee39f8e348805710080a4857e6575d3ddade/src/lib/stitching/mergeSchemas.ts#L9-L39
