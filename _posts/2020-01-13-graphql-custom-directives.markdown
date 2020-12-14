---
layout: epic
title: Better GraphQL Error Handling I - Using Custom Directives
date: 2020-01-13
categories: [GraphQL, Error Handling]
author: matt
comment_id: 603
---

This will be the first in a series of posts about how we used advanced GraphQL tooling and functionality to better
handle errors occurring during query resolution, and better equip clients to reason about such errors.

The goal is to describe our current approach, but also do a deep dive into specific ways we've extended our
[GraphQL server](https://github.com/artsy/metaphysics) to help us accomplish that. If you are an interested GraphQL
user, you may find this useful, even if some of the larger context specifically around how we are using it to help
standardize error handling doesn't apply.

<!-- more -->

## Introduction and Initial Context

At Artsy, we use GraphQL as our API language of choice. In particular,
[as](https://artsy.github.io/blog/2018/05/08/is-graphql-the-future/)
[we've described](https://artsy.github.io/blog/2016/06/19/graphql-for-mobile/)
[before](https://artsy.github.io/blog/2016/11/02/improving-page-speed-with-graphql/), we have an orchestration
layer speaking GraphQL, which is what our front-end clients talk to. The GraphQL orchestration layer wraps up
access to several backend services, which are made accessible via a combination of data loaders and
[schema stitching](https://www.apollographql.com/docs/apollo-server/features/schema-stitching/).
[Apollo Federation](https://www.apollographql.com/docs/apollo-server/federation/introduction/) is another tool
people are using to bring together disparate backends when using GraphQL in an orchestration layer.

Now, consider the following query, which is a realistic one you might see when accessing a 'product' page.

```javascript
{
  artwork(id: "andy-warhol-skull") {
    mainContentStuff
    biographicalData
    userReviews {
        ...
    }  # Accesses a back-end reviews service
    ...
  }
}
```

Part of the [GraphQL spec](https://graphql.github.io/graphql-spec/) advises that one should return a 2XX status
code, even if there are exceptions raised when resolving your query. A non-2XX status code from a GraphQL server
would indicate an error with the server itself. Errors that occur during query resolution can be consolidated and
placed in the `errors` key of the response. This is all
[advised by the spec](https://graphql.github.io/graphql-spec/draft/#sec-Errors), and so is found in most GraphQL
implementations.

Given that this query likely backs a product page, some questions about possible error handling behavior that
immediately arise:

- If there are multiple fields erroring, which error (if any) is reported to the user?
- How does the UI decide whether an error is recoverable? That is, if the `mainContentStuff` field for a view has
  errored, that's probably not recoverable, and appropriate feedback should be displayed. But, if user reviews are
  unavailable at this time, it's likely you might still want to render the main view, but with that section
  appropriately handled. Is there a generic way to handle this?

## Using a Directive to Eliminate Ambiguity

We decided to allow our UI components to declare, using a GraphQL directive, one and only one field in a query to
optionally be the 'principal field'. That is, this is the field that, if there are any errors resolving it, should
result in an entire view rendering an appropriate error state. For web, this means a non-2XX status code and
resulting error page. Any errors occurring in field resolution of non-principal fields should still result in a 2XX
to the user, and the UI should be able to gracefully recover from the missing data. Since we use
React/Relay/GraphQL, and GraphQL queries are colocated with UI components, a GraphQL directive is particularly
useful.

Rewriting the above query, we might do something like:

```javascript
{
  artwork(id: "andy-warhol-skull") {
    mainContentStuff @principalField
    biographicalData
    userReviews {
        ...
    }  # Accesses a back-end reviews service
    ...
  }
}
```

This would mean that any errors occuring in resolving `mainContentStuff` would result in either a 500 status code
and error page to the user, or possibly a more specific error and status code. However, any errors occurring in
resolving user reviews or other fields, would not cause a 500 and error page. Instead, there would be a 200 and the
UI would render. This means that our UI components should generally be defensive about their incoming props being
`null` (which is likely what you'd see when the corresponding field errors during query resolution). Using
TypeScript and
[strict null checking](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-0.html) can help
make your UI bulletproof to these sorts of issues.

With this context, let's look at how we implement a custom `@principalField` GraphQL directive. Future posts in
this series talking about custom GraphQL functionality will likely skip this intro section.

## Implementing a Custom GraphQL Directive

First, we have a new directive that we'd like to add to our schema. That is, we'd like a client to be able to
specify `@principalField` alongside any field, and have that query be validated correctly by the server. You can
[see for yourself](<https://metaphysics-staging.artsy.net/?query=%7B%0Aartwork(id%3A%22andy-warhol-skull%22)%20%40nonExistentDirective%7B%0A%20%20id%0A%7D%7D>)
how [graphql-js](https://github.com/graphql/graphql-js) and
[express-graphql](https://github.com/graphql/express-graphql) respond when an unknown directive is specified. Your
GraphQL server implementation may look slightly different.

Turns out, that's pretty easy to do in `graphql-js`. We declare a variable of type `GraphQLDirective`, which
operates on a `DirectiveLocation.FIELD` location:

```javascript
const PrincipalFieldDirective = new GraphQLDirective({
  name: "principalField",
  locations: [DirectiveLocation.FIELD]
})
```

and then when we create our schema, we pass this in as `directives`. Since this will overwrite the
[default directives](https://www.apollographql.com/docs/apollo-server/schema/directives/), we need to append ours.

Something like:

```javascript
import { specifiedDirectives } from "graphql"

new GraphQLSchema({
  directives: [...specifiedDirectives, PrincipalFieldDirective],
  query: ...
  ...
})
```

In terms of the SDL for your schema, this is equivalent to the following line:

```
directive @principalField on FIELD
```

That's it! You've successfully added a new directive to your schema. At this point, your GraphQL server will
properly validate and allow a `@principalField` directive specified by a client alongside any field. Now, we do
want to ensure that if this directive is used, it only appears once in your query. We can accomplish this with a
custom GraphQL validation, which we'll cover in the next post.

So now, how should we implement the functionality of this directive? We decided that we want to use the
[extensions](https://github.com/graphql/graphql-spec/blob/master/spec/Section%207%20--%20Response.md#response-format)
part of our GraphQL response to carry this data, a free-form map of data up to the implementor, which is a perfect
fit for this type of optional additional information. If an error occurs in a field tagged with the directive, we
want the response to look something like:

```json
{
  "data": {
    ...
  },
  "extensions": {
    "principalField": {
      "error": ...
    }
  }
}
```

In `express-graphql`, we'll need a method appropriate for the
[extensions](https://github.com/graphql/express-graphql#options) option. That looks like:

```javascript
const principalFieldDirectiveExtension = ({ documentAST, result }) => {
  const path = getPrincipalFieldDirectivePath(documentAST)
  if (path.length) {
    const error = result.errors.find(e => isEqual(e.path, path))
    if (error) return { principalField: error }
  }
}
```

If there is a field designated with the principal field directive, and there is an error at that same path, we'll
return that information, otherwise do nothing.

That's it! We have one additional helper we need to write, `getPrincipalFieldDirectivePath`. This builds an array
of all the fields encountered to get to one tagged with our directive. It matches the way the
[path of an error](https://graphql.github.io/graphql-spec/June2018/#sec-Errors) is constructed by the server, which
enables us to determine if a particular error was associated with a field tagged with the directive.

That looks like:

```javascript
import { visit, BREAK, DocumentNode } from "graphql"

export const getPrincipalFieldDirectivePath = (documentNode: DocumentNode): string[] => {
  const path: string[] = []
  visit(documentNode, {
    Field: {
      enter(node) {
        const name = (node.alias || node.name).value
        path.push(name)
      },
      leave() {
        path.pop()
      }
    },
    Directive(node) {
      if (node.name.value === "principalField") {
        return BREAK
      }
    }
  })

  return path
}
```

This uses a [GraphQL visitor](https://graphql.org/graphql-js/language/#visit) to traverse our query, and build up
an array of field names. We can exit early with that path if we encounter our directive.

## Example Query

Let's take a look at how you can use this in practice, in order to help standardize when and with what status a UI
can inform the user of an error.

Something like:

```
{
  artwork(id: "andy-warhol-skull") @principalField {
    userReviews {
      notes
    }
    contents
    ...
  }
}
```

results in:

```json
{
  "data": {
    "artwork": null
  },
  "extensions": {
    "principalFieldError": {
      "httpStatusCode": 404
    }
  }
}
```

and the UI can immediately return an appropriate message to the user, if the artwork is not found. If fetching the
artwork is successful, but there's an issue with the reviews, the response will look like:

```json
{
  "data": {
    "artwork": {
      "userReviews": null,
      "contents": ...
    }
  }
}
```

We can make sure that our UI components (likely Relay containers) corresponding to `userReviews` are defensive
about that incoming prop being `null`. Most likely a zero state ("No Reviews Found"), or just skipping the section
entirely, is appropriate.

## Conclusion

In this way, we can standardize on and remove ambiguity about how a UI handles one or more errors in query
resolution and exactly when such an error should be propagated and made user-facing. We can help ensure that our
UI's are resilient to errors occurring in a leaf.

In the next post, we'll look at how we can write a GraphQL validation rule to ensure that a client specifies at
most one field with the `@principalField` directive. After that, we'll take a look at how you can successfully
parse and support GraphQL query resolution errors occurring in a variety of contexts such as during stitching.
Putting this altogether, we hope you will come away with a better understanding of how to extend your GraphQL
server with your own custom behaviors, and in particular how we've used these to better log/propagate/present the
potential errors occurring during a query.
