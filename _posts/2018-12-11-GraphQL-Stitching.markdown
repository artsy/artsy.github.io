---
layout: epic
title: GraphQL Stitching 101
date: 2018-12-11
author: [orta]
categories: [graphql, stitching, metaphysics]
css: graphql-stitch
comment_id: 450
series: Omakase
---

Micro-Services make sense for an engineering team of our size. You can scope a domain of your business to
particular small unit of abstraction like an API. Doing so makes it easy to work in isolation, experiment with new
ideas and evolve in many directions.

We've been [carefully pushing][monolith] for years to move away from our single monolithic API, to a collection of
smaller, more focused projects. Our [highlights docs][high] showcase this well. The movement to smaller composable
services works great from an isolated platform/systems perspective but can be a bit tricky to handle with front-end
clients. Until 2018, the way that we've addressed the growing complexity in our service later has been to migrate
the complexity inside our main GraphQL API, [metaphysics][mp]. Metaphysics is our GraphQL API gateway that
consolidates many API sources into a single service, then extending and interleaving and their data to make clients
easier to write.

However, as more services have been created, and grown - so has metaphysics. This creates a worrying trend, as the
growth of code in metaphysics isn't quite linear.

Our main line-of-thought on how to address this is via GraphQL schema stitching. We've been [running
experiments][ex] in stitching for over a year, and have have been running with stitching enabled in production for
a few months.

<!-- more -->

## What is Schema Stitching?

The core idea behind schema stitching is that because GraphQL talks in type systems, you should be able to merge
type systems from many GraphQL APIs into a single source of truth. Schema stitching came out at the [end of
2017][stitching_out] via the [`graphql-tools`][tools] and became production-[ready in April
2018][stitching_announcement].

We started experimenting on staging last year and would occasionally run into edge-case issues. This meant the
state of the project would ebb & flow between being blocked, or no-one having the bandwidth to work on it. This was
fine, because our aim was [incremental evolutions over bold revolution][rev].

Before we dive into implementation details, here's a quick glossary of terms before we start:

- **GraphQL [Type][type]** - the shape of an object exposed from your GraphQL API
- **GraphQL Schema** - a representation of your GraphQL's type system, containing all types and fields on them
- **GraphQL Resolver** - every field accessed in a query resolves to a corresponding value, the function doing that
  is a resolver
- **Schema Merging** - taking two GraphQL schemas, and merging all the types and resolvers into one schema
- **Schema Stitching** - extending a GraphQL Schema programmatically, with the ability to delegate to merged
  schemas

Stitching is one of the end-goals, but merging may be enough for a lot of cases. Both of the two launch posts above
give a much more in-depth explanation of how everything comes together, but these should be enough for this post.

## How Do We Do It?

We have 5 GraphQL APIs inside the Artsy ecosystem, our aim is to cautiously include these APIs inside metaphysics.
We don't need the entire contents of those APIs, and as you'll learn - we couldn't do that even if we wanted.

The technique we settled on was:

1.  Download the schema of each external API into metaphysics' source code
1.  Have each schema trimmed to just the essentials that we need today
1.  Merge in each schema incrementally
1.  Stitch in any desired schema changes

Let's dig, with some code into how we do each of these steps.

#### Downloading Schemas

We created a [pretty minimal script][dl-schema] which can be run periodically from a developer's computer.

```js
const destination = "src/data"

const httpConvectionLink = createHttpLink({
  fetch,
  uri: urljoin("https://convection-staging.artsy.net/api", "graphql")
})

introspectSchema(httpConvectionLink).then(schema => {
  fs.writeFileSync(
    path.join(destination, "convection.graphql"),
    printSchema(schema, { commentDescriptions: true })
  )
})
```

The script uses an [apollo-http-link][] to grab our schema, and store it in our repo, see
[`src/data/convection.graphql`][c-gql]. This means that when someone wants to update to a new version of the
schema, it will go through code review and a normal testing-flow. The trade-off being that it will always be out of
date a little bit, but you can make guarantees about the current schema. This is a reasonable trade-off, as GraphQL
schemas [should always][] be forward compatible for queries, and when someone wants to use a new field from another
service they can move the schema definition from [the git repo][rfc31].

This file is the [GraphQL SDL][sdl] representations of the entire type system for that schema. This means we have a
local copy of the schemas, so we can use it for tests for the next few steps.

#### Schema Manipulation

Each API writes for their own domain. This can be problematic when you use a `User` in one API, which isn't generic
enough to be a `User` in a global API of all services combined. When thinking about this problem, we created a
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

This one is interesting, we _don't_ want the version of `Artist` and `Artwork` from Gravity's GraphQL
implementation - because the hand-rolled `Artwork` and `Artist` types which lives in the source code of Metaphysics
right now is a combination of many sources, and front-end-client specific code.

If we allowed the `Artist` or `Artwork` to overwrite the existing implementations it would be a massively breaking
change. For example, compare the Artwork type from [Gravity's GraphQL][grav-artwork] (5 fields) vs [Metaphysics'
GraphQL][mp-artwork] (~90 fields) accidentally switching the types would cripple our front-ends.

#### Merging Schemas

There are two classes of schemas involved in our stitching. Local Schemas, which is our existing schema (e.g. the
resolver live inside the current source code), and Remote Schemas (e.g. where you make an API request to run those
resolvers). [Merging a schema][merging] has a pretty small API surface and doesn't mind which type of schemas you
merge together.

```js
import { mergeSchemas as _mergeSchemas } from "graphql-tools"
import { executableGravitySchema } from "lib/stitching/gravity/schema"
import { executableConvectionSchema } from "lib/stitching/convection/schema"
import { executableLewittSchema } from "lib/stitching/lewitt/schema"

import localSchema from "../../schema"

export const mergeSchemas = async () => {
  const convectionSchema = await executableConvectionSchema()
  const gravitySchema = await executableGravitySchema()

  const mergedSchema = _mergeSchemas({
    schemas: [gravitySchema, localSchema, convectionSchema]
  })

  return mergedSchema
}
```

It's a pretty simple composition model, makes it real easy to do some verification tests using the same techniques
as above.

#### Stitching Schemas

The next step from merging is stitching. Stitching is about taking the merged schemas and taking data from one and
re-applying it via another API. For example, we have a consignments API (for when you want to sell a work at
auction) and a consignment references the artwork's artist. These live inside an API called convection.

In this case, the consignment has an `artist_id` which represents an `Artist` type which lives in metaphysics. We
would like to stitch an Artist in from the local schema, into a `ConsignmentSubmission` which has come in from a
remote schema.

The API works by using [Type Extensions][t-e] which are a way of opening up an existing Type and adding new fields
on it. We want to be working with the highest level abstraction, which in this case is directly writing [GraphQL
SDL][sdl] (basically writing the interface) and then hooking that up to its resolvers.

Here's what that looks like in our app:

```js
export const consignmentStitchingEnvironment = (
  localSchema: GraphQLSchema,
  convectionSchema: GraphQLSchema
) => ({
  // The SDL used to declare how to stitch an object
  extensionSchema: `
    extend type ConsignmentSubmission {
      artist: Artist
    }
  `,

  // Resolvers which correspond to the above type extension
  resolvers: {
    ConsignmentSubmission: {
      artist: {
        // The required query to get access to the object, e.g. we have to
        // request `artist_id` on a ConsignmentSubmission in order to access the artist
        // at all
        fragment: `fragment SubmissionArtist on ConsignmentSubmission { artist_id }`,
        // The function to handle getting the Artist data correctly, we
        // use the root query `artist(id: id)` to grab the data from the local
        // metaphysics schema
        resolve: (parent, _args, context, info) => {
          const id = parent.artist_id
          return info.mergeInfo.delegateToSchema({
            schema: localSchema,
            operation: "query",
            fieldName: "artist",
            args: {
              id,
            },
            context,
            info,
            transforms: (convectionSchema as any).transforms,
          })
        },
      },
    },
  },
})
```

This file consolidates the two steps of merging and then stitching:

```diff
export const mergeSchemas = async () => {
  const convectionSchema = await executableConvectionSchema()
+ const convectionStitching = consignmentStitchingEnvironment(localSchema, convectionSchema)

  const gravitySchema = await executableGravitySchema()

  // The order should only matter in that extension schemas come after the
  // objects that they are expected to build upon
  const mergedSchema = _mergeSchemas({
    schemas: [
      gravitySchema,
      localSchema,
      convectionSchema,
+      convectionStitching.extensionSchema,
+    ],
+    resolvers: {
+      ...convectionStitching.resolvers,
+    },
  })

  return mergedSchema
}
```

We extend the merge schema function to also include the SDL for our stitching, and de-structure in the extension
resolvers. We're still exploring how to write _useful_ tests for this part.

## Validating your changes

We had some useful tools which were used to make the switch to using schema-stitching in production.

1. **Stored Queries**

   In order to validate that the runtime behavior of our queries wasn't changing, we used the [persistent
   queries][ps] generated by our iOS app Emission to create JSON dumps of the results of many API calls in both
   stitched and un-stitched environments in a script and compared the results.

1. **SDL dump comparison**

   We can use the GraphQL type system to validate our changes don't break clients. We used a schema dump script to
   validate the type system was the same across stitched and un-stitched environments.

## Alternatives

Our stitching implementation used metaphysics as a local schema - e.g. the merging and the stitching occurred
inside the same source code as our main GraphQL API. This wasn't the only way we cold achieve a single source of
truth, I explored an alternative which is to treat all schemas as remote schemas. Basically having an API gateway
in-front of our API gateway. I called it [incorporeal][inc], it's actually a tiny amount of code - a testament to
modern GraphQL techniques in JavaScript.

The advantage here is that we take reduce the acceleration of growing complexity in Metaphysics completely, because
the merging and stitching occurs outside of it. Metaphysics is merged and stitched in, just as all our other APIs
are.

The downside is that it's another hop to get what you want, and changes could require being updated in more places.
We'd be able to use the above ideas for validating that the API is working as expected.

## In Production

Today we stitch all new APIs by default, see [Kaws' integration][kaws] PR. We're _slowly_ trying to retro-actively
migrate existing APIs into stitching and then deleting the existing code, but that's real tricky when those APIs
are being used or use advanced features of GraphQL.

We've been using GraphQL [since mid-2015][init] and we've also used it with Relay for the past two years, this has
meant we have quite a few interesting edge cases in our use of the GraphQL. We got in touch with [Mikhail
Novikov][mn] and he contracted to help us with most of these issues and I'd strongly recommend doing the same (with
any OSS dependency, but that's, like, just my opinion man.)

GraphQL Stitching solves the problem of API consolidation in a really well thought out abstraction, and I consider
it one of the most interesting avenues of exploration into what GraphQL will be in the future (see [Is GraphQL The
Future?][igtf] for a more philosophical take also.)

<!-- prettier-ignore-start -->

[stitching_announcement]: https://dev-blog.apollodata.com/the-next-generation-of-schema-stitching-2716b3b259c0
[stitching_out]: https://dev-blog.apollodata.com/graphql-tools-2-0-with-schema-stitching-8944064904a5
[monolith]: http://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017/#Artsy.Technology.Infrastructure.2017.-.Splitting.the.Monolith
[mp]: https://github.com/artsy/metaphysics/
[stitch_mp]: https://github.com/artsy/metaphysics/tree/1423ee39f8e348805710080a4857e6575d3ddade/src/lib/stitching
[apollo-http-link]: https://www.apollographql.com/docs/link/links/http.html
[dl-schema]: https://github.com/artsy/metaphysics/blob/1423ee39f8e348805710080a4857e6575d3ddade/scripts/dump-remote-schema.js#L15-L25
[c-gql]: https://github.com/artsy/metaphysics/blob/master/src/data/convection.graphql
[guides-schema]: https://github.com/artsy/README/blob/master/playbooks/graphql-schema-design.md#notes
[transform]: https://www.apollographql.com/docs/graphql-tools/schema-transforms.html
[type-q]: https://github.com/artsy/metaphysics/blob/1423ee39f8e348805710080a4857e6575d3ddade/src/lib/stitching/lib/getTypesFromSchema.ts
[merging]: https://github.com/artsy/metaphysics/blob/1423ee39f8e348805710080a4857e6575d3ddade/src/lib/stitching/mergeSchemas.ts#L9-L39
[t-e]: https://github.com/graphql/graphql-js/pull/1117
[sdl]: https://blog.graph.cool/graphql-sdl-schema-definition-language-6755bcb9ce51
[init]: https://github.com/artsy/metaphysics/commit/50b23f1738b9fa9757ff83c2d1e0d265c70e4e90
[mn]: https://www.freiksenet.com
[igtf]: http://artsy.github.io/blog/2018/05/08/is-graphql-the-future/
[high]: https://github.com/artsy/README/blob/master/culture/highlights.md#highlights
[ex]: https://github.com/artsy/metaphysics/pull/809
[rev]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#incremental-revolution
[tools]: https://github.com/apollographql/graphql-tools/
[rfc31]: https://github.com/artsy/README/issues/31
[kaws]: https://github.com/artsy/metaphysics/pull/1327
[ps]: https://github.com/artsy/emission/pull/999
[inc]: https://github.com/orta/incorporeal
[type]: https://graphql.org/learn/schema/#type-system
[grav-artwork]: https://github.com/artsy/metaphysics/blob/51939d1f8eb0d5a60e6e888bf701e082a9ee3731/src/data/gravity.graphql#L14-L29
[mp-artwork]: https://github.com/artsy/metaphysics/blob/51939d1f8eb0d5a60e6e888bf701e082a9ee3731/_schema.graphql#L723-L889
[should always]: https://graphql.org/learn/best-practices/#versioninghttps://graphql.org/learn/best-practices/#versioning
<!-- prettier-ignore-end -->
