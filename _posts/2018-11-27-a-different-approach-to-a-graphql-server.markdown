---
layout: epic
title: A different approach to building a GraphQL server
date: 2018-11-27
author: luc
categories: [best practices, dependencies, javascript, node, roads and bridges]
---

Here at Artsy, we're big fans of [GraphQL][]. It is now being used X different projects both for server to server
and client to server communication. We also ♥ [Typescript][typescript]. Knowing about some of the introspection
features in Typescript, I asked myself: How can we reduce the amount of Type definition boilerplate? I'll breakdown
how in this post.

We've written a lot about GraphQL and our uses of it in the past, from "GraphQL Stitching", to (insert other blog
posts about GraphQL). Our main GraphQL server [Metaphysics](metaphysics) has been around for X years. The landscape
of best practices in the GraphQL community has changed drastically since then. For instance, we've adopted
Typescript as our primary language for new development about a year ago. One of the core features of Typescript, is
adding types to Javascript of course. As we know types are very useful for complex systems comprised of many
modular APIs. GraphQL also has it's own type system.

()

Example of GraphQL SDL

```graphql
type Conversation {
  id: ID!
  message: [String]!
}
```

And here is the corresponding Typescript model representing this type.

```typescript
class Conversation {
  id: string
  messages: string[]
}
```

So my question was, how can we share type definitions between GraphQL + Typescript? I knew there must be a way to
access metadata about our class in Typescript, this is usually called reflection in other languages, and after
doing some research, sure enough there's a NPM package called [type-reflection](type-reflection) to just that in
Typescript. Essentially type reflection allows to access metadata about the Typescript code we write such as class
and variable names, but also type definitions. This is very useful for generating code based (...). In our case, we
use it to inspect our Typescript model and generate GraphQL types without writing these twice. (...) After
researching potential options. I stumbled upon [Type-GraphQL][type-graphql]. TypeGraphQL works by using a language
feature called [type reflection](link to reflection).

```typescript
import { type, field } from "type-graphql"
import { Message } from "./Message"

@type()
class Conversation {
  @field()
  id: string

  @field(type => Message)
  message: Message[]
}
```

`field` and `type` are decorator functions that use reflection to generate a GraphQL type based on the typescript
definition. We're now able to generate GraphQL types based on a javascript classes. But how do write resolvers in
this paradigm? I'm glad you asked, let's write a resolver.

```typescript
import { resolver } from "type-graphql"
import { Conversation } from "./Conversation"

@resolver(of => Conversation)
class ConversationResolver {
  data: []

  conversations(): Conversation[] {
    return this.repository.find()
  }
}
```

Here's the GraphQL SDL that gets generated from this.

```graphql
type Query {
  conversations: [Conversation]
}
```

Looks a bit magic at first but ()

(Explain a bit about `typeorm`). Now we have the ability to generate both GraphQL types and a Database schema by
writing types only once.

For comparison sake, here's what this would look like if written in standard JS. (Insert code example with standard
graphql library)

```

```

As you can see, the code we wrote is closer to something like `rails` which we all know is great at reducing
boilerplate code.

To conclude, this approach requires a bit of knowledge about GraphQL, Typescript, TypeGraphQL and TypeORM to truly
understand what is going on. But once the basics are clear, it

Here's the full example running in a [sandbox][codesandbox]

[graphql]: https://graphql.org
[typescript]: http://www.typescriptlang.org
[typeorm]: http://typeorm.io/
