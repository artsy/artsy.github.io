---
layout: epic
title: Is GraphQL The Future?
date: 2018-05-08
author: [alan]
categories: [programming, api, graphql, rest]
css: graphql
comment_id: 443
---

I have seen the future, and it looks a lot like GraphQL. Mark my words: in 5
years, newly minted full-stack app developers won’t be debating _RESTfulness_
anymore, because REST API design will be obsolete. By the end of this post, I
hope you'll see what I see in the promise of GraphQL as a new approach to
client-server interaction.

<!-- more -->

GraphQL is taking the full-stack world by storm. In case you’re not familiar,
GraphQL is a language-independent specification for client-server communication.
It lets you model the resources and processes provided by a server as a
[domain-specific language (DSL)](https://en.wikipedia.org/wiki/Domain-specific_language).
Clients can use it to send scripts written in your DSL to the server to process
and respond to as a batch.

That’s...different from how GraphQL’s own page describes it. GraphQL is better
known as a query language designed for clients to fetch exactly the data they
need. While this is sort of true, I would argue that GraphQL actually fails this
test in reality. It’s neither a query language, nor particularly graph-oriented.
I argue that it's _not_ a query language because it comes with no native
concepts of operators and expressions that build up to queries. _You_ build
whatever facilities for specifying and fulfilling queries on your own. Likewise,
if your data is a graph, it’s on you to expose that structure. But your requests
are, if anything, trees.

I’m not trying to be pedantic. I believe GraphQL succeeds at something subtler
and more important than literally being a graph query language. I’m writing this
piece because I kept running into difficulties approaching GraphQL from the
standpoints of REST, graph theory, or typical query languages. As I read blog
posts, StackOverflow Q&As, issues on the GraphQL repo and the GraphQL spec
itself, I developed a much more nuanced understanding, which I outline below.

For brevity, the following assumes a intermediate familiarity with GraphQL,
including its type system, syntax, and server-side implementation. If you don’t
have this level of familiarity, I recommend going through any tutorial that
requires you to set up a GraphQL server, not just play with the query language
(which is how I ended up with a lot of misconceptions).
[The docs for the official JavaScript server library](https://graphql.org/graphql-js/)
are a good option. I’m going to start with the basics, but only so I can put my
own spin on those concepts, not to really illustrate them with examples.

# A tree of fetches

Most applications are designed in the form of discrete pages, which are seeded
with some tiny chunk of data—say, a key or slug for some domain object—and then
perform a cascade of contingent fetches to get the data needed to populate the
templates rendered to a user. This is the basis of designing applications driven
by URL-based routing and it has been a mainstay of the MVC approach to web
application architecture for the past decade.

> **Example:** At Artsy, the seed of data for rendering an artwork page could be
> the slug identifying some artwork. From this slug, we need a whole bunch more
> data: the metadata of the artwork, information about the artist(s), sales data
> if it’s available for purchase, information about the Artsy partner that owns
> it, and so on. In classic REST, this data is aggregated by a cascade of dozens
> of HTTP fetches to our backend API.

I wasn’t in the room when GraphQL was invented, but it seems to me that the team
that built it made a particularly crucial insight:

> In most cases, all of this contingent fetching forms a tree, which is more or
> less _fixed_ for a given page.

Data from early responses contain the keys for subsequent requests, but the
linkages between these requests are usually straightforward. So if it were
possible to factor all this disparate fetching into one spot and encode it into
one big “fetching tree” data structure ahead of time, this tree could be sent to
the the server, and the server could fulfill all of the data requirements in one
shot. This cuts out a tremendous amount of wasteful chatter between client and
server. Even in today's broadband world, bandwidth and latency matter,
especially for mobile users.

# GraphQL anatomy

> **Editorial note** I'm going to use the term "operation" pretty liberally
> here, but I mean it in the conceptual sense, not in the sense of the GraphQL
> spec, where it defines the semantics of an entire GraphQL request.

A GraphQL request always starts with at least _one root API operation_ and some
finite number of follow-ups. Idiomatically, these follow-ups are queries,
meaning that they just retrieve data, without changing the server state in
observable ways. GraphQL models API operations as **fields**. How a field works
in GraphQL depends on its **type**, which falls into one of two basic
categories:

* **Scalar** types (`Int`, `Float`, `String`, `Boolean`, and `ID`, as well as
  application-defined `enum` and `scalar` types) represent the individual pieces
  of _data actually sent to the client_. Contrary how I think of the term scalar
  in other contexts, the data can be arbitrarily complex. As far as the GraphQL
  spec is concerned, scalars are just opaque blobs of data with validation and
  serialization rules. As an operation, a scalar field is terminal data fetch,
  with no follow-ups. They are the leaves of the request tree.
* **Object** types (`type`, `union` and `interface`) are collections of fields.
  As an operation, an object-typed field is an intermediate operation that
  serves as the junction point for follow-up operations. But, it doesn’t
  directly return any data. They are the branches of the request tree.

The entire model for a given API is known as its **schema**. Every schema has a
root query type, whose fields serve as the API’s entry points.

```
# The root query object type
type Query {
  artwork(id: ID): Artwork
  artist(name: String)
  # … a whole bunch more root fields
}

type Artwork {
  title: String
  artist: Artist
}

type Artist {
  name: String
}
```

A GraphQL query request begins by mentioning at least one of the fields of the
root query object. This represents an initial query. And if that field is an
object, _its_ fields are used to specify any number of follow-up queries.
Critically, _any_ field in the request tree can take arguments, allowing a
request to be parameterized at all depths.

Take this query, for example:

```
{
  artwork(id: "andy-warhol-campbells-soup-i-black-bean") {
    title
    artist {
      name
    }
  }
}
```

Here, we tell the server to look up an `Artwork` by its slug, and tell us the
title. So far, this is just like REST. But we _also_ tell it to find us the
`Artist` for us. Importantly, object fields _must_ be followed up with further
queries, and scalar fields _cannot_ be. With that in mind, it’s easy to see that
`artwork` and `artist` are object fields, while `title` and `name` are scalar
fields.

Also note that the fact that there’s also an `artist` root query field actually
has nothing to do with its presence under `Artwork`. There can be multiple paths
to reach the same GraphQL type. This is defined explicitly by the schema.

Usefully, the server’s response to a GraphQL request will directly mirror the
shape of the request itself. The result of the request above looks like:

```
{
  "data": {
    "artwork": {
      "title": "Campbell's Soup I: Black Bean",
      "artist": {
        "name": "Andy Warhol"
      }
    }
  }
}
```

# GraphQL as a (meta-)scripting language

Let’s dig a little deeper into the scripting language interpretation of GraphQL,
because this is the crux of how I think people should think of GraphQL. If I
were to guess, I think Facebook…

* …knows this is true. After all, much of the spec is devoted to
  [the execution model of GraphQL](http://facebook.github.io/graphql/October2016/#sec-Execution).
* …might have backed into this design. It’s well known that they think of their
  data as a graph, so I suspect GraphQL might have begun literally as a "graph
  query language", analogous to [SQL](https://en.wikipedia.org/wiki/SQL) for
  relational databases.
* …thinks that this too difficult to explain, and thus, settled on the query
  language paradigm.

There are a couple reasons GraphQL might not look like a scripting language to
you. It didn’t to me, at first! After all, you don't write your request as list
of statements. It doesn’t have a concept of variables, other than parameters to
the whole document. There are no looping constructs or recursion. But I think a
closer look might shift your perspective.

## Control flow

It’s true that a GraphQL request doesn’t follow the same vertical sequence of
steps model familiar to most programming languages. But sequencing _does_ exist.
It’s just represented by calling nested fields of object types, terminating in a
scalar field. See this request:

```
{
  step1(arg: “something”) {
    step2 {
      step3(arg: "something else”) {
        outputScalar
      }
    }
  }
```

In a more traditional language, this would look more like:

```
step1(“something”)
step2()
return step3(“something else”)
```

So, sequencing got a bit more verbose, but it _is_ there.

Interestingly, GraphQL reserves vertical stacking for something that’s an
afterthought in most languages: _concurrency_. (Granted, there’s no way to
[synchronize](<https://en.wikipedia.org/wiki/Synchronization_(computer_science)>)
concurrent paths of execution.) I’m not going to quote
[the spec](https://facebook.github.io/graphql/October2016/), but search it
yourself, and you can find the word “parallel” in there several times. This
design is intentional.

## Variables

One of the core aspects of programming is the ability to pass intermediate data
around. The most basic way languages accomplish this is with named variables.
Many languages allow variables to be reassigned; some don't. GraphQL doesn’t
have them at all! But that doesn’t mean data can’t be propagated.

GraphQL supports one kind of propagation, which is the propagation of context
down the sequence of resolvers. It happens implicitly and invisibly. Exactly
what data is propagated and what that means is up to you.

How does this work? Well, if you have worked on GraphQL server code, you know
that every field has a **resolver**.

* For scalar fields, the resolver is responsible for returning the actual data
  that the client sees.
* For object fields, the resolver instead returns a hidden chunk of data that is
  forwarded along to the resolvers of the fields contained in the object. So
  these resolvers get their parent object’s hidden data, the global context, and
  any arguments, and they can use all of these values to produce their value.

Often, we just resolve an object field to a domain object. Its scalar fields
might correspond to properties of that domain object and its object fields might
correspond to related objects. But the architecture is more powerful than this!
A deeply nested field can potentially be the result of the resolved values of
all its parents. It all depends on how you design your resolvers to work
together.

This pattern reminds me a bit of when [jQuery](https://api.jquery.com/) first
clicked for me. A lot of details are propagated invisibly within your `jquery`
object as you chain method calls to refine your DOM selections.

## Looping and recursion

GraphQL doesn’t have them, plain and simple. Consequently, the GraphQL DSLs you
design are not
[Turing-complete](https://en.wikipedia.org/wiki/Turing_completeness)--they will
always halt in a finite amount of steps. This is really important, because it
prevents clients from being able to send servers on errands that will never end.
Of course, the _implementations_ of field resolvers on the server are free to do
whatever they want in full Turing-complete glory.

## Putting it together

My point here is that the execution model of GraphQL is in many ways just like a
scripting language interpreter. The limitations of its model are strategic, to
keep the technology focused on client-server interaction. What's interesting is
that you as a developer provide nearly all of the definition of what operations
exist, what they mean, and how they compose. For this reason, I consider GraphQL
to be a _meta-scripting language_, or, in other words, a toolkit for building
scripting languages.

# The post-REST world

Subtly, this paradigm is a sharp step away from a whole body of knowledge that
models APIs as resources with fixed verbs, which we know as REST. It’s more
appropriate to think of GraphQL requests as a script of remote procedure calls
(RPC). From this perspective, the design of the schema is a lot less about data
modeling than it is a question of how you want your entire API to be traversed.
This encourages a verb-oriented mindset.

## Verb orientation

Speaking of verbs, you can think of "fetch" as being the default verb in
GraphQL. You model other verbs as **mutations**. I delayed learning about
mutations, because I thought they must be way more complex than queries. Quite
the opposite! They all sit in one big, flat bucket at the root of your schema,
as the fields of the root `mutation` type. These fields have a type too, and if
it is an object type, then you can issue effectively any number of follow-up
queries after your mutation completes. Learning about mutations was when it
really dawned on me that _fields are just function calls_.

Mutations are a major break with REST. In GraphQL, your mutations are defined
under root mutation object that is separate from your root query object.
Therefore, you are immediately asked to accept that they don't represent verbs
on a resource, but verbs _on your entire service_. This eliminates one of REST’s
key weak points, namely that complex operations that touch multiple parts of an
application’s data model are difficult to model as a PUT, DELETE, POST, or PATCH
on a single resource. In my experience, this "impedance mismatch” between API
modeling and domain modeling has led to the worst aspects of my HTTP API
designs.

## REST is dead. Long live REST!

It is borderline heresy in some circles to suggest that REST API design is dead.
But I’m saying it. Don’t get me wrong, REST is still a great paradigm for
serving static assets. It’s the _API_ part I have an issue with.

Ironically, I think there’s a strong argument that a GraphQL request document
maps very nicely to the concept of a resource:

* It doesn’t change that often, and you could PUT it to store it, perhaps using
  a hash of the request document to form the URL.
* GraphQL queries map elegantly to GET operations on a stored query request
  document’s URL.
* GraphQL mutations map decently to POST operations to a stored mutation request
  document’s URL.
* The arguments of a GraphQL request map elegantly to HTTP query parameters.

In other words, GraphQL is simply another formalization layer of HTTP-based API
design. Think of it as being akin to the way JSON representation changed the way
we think about client-server communication in full-stack apps. It’s not so much
that REST will cease to exist, but that it will fade to the background, as an
implementation detail of GraphQL application frameworks.

# GraphQL is not your data model

Another realization I’ve had in learning to apply GraphQL is that the schema is
_not_ the actual data model, and therefore raw GraphQL responses cannot be
directly used by the client. You _could_ choose to think of it this way, but
you’re likely to run into some conundrums:

* [There is no free-form map data structure](https://github.com/facebook/graphql/issues/101).
  There are only objects with fixed fields, scalars, and lists.
* It is difficult to design abstractions over types.
* The object tree you get in return from a query request is neither normalized
  nor is it an object graph (multiple copies of the same object may be
  returned).
* Commonly used protocol patterns, like
  [the connection pattern](https://facebook.github.io/relay/docs/graphql-connections.html),
  require explicit modeling within your schema.
* The limitations of GraphQL's type system make certain modeling techniques
  difficult to directly model, such as
  [singletons within unions](https://stackoverflow.com/questions/47933512/representing-enum-object-variant-type-in-graphql).
* Recursive data types can’t be queried to undefined depth in their nested form.
  Think of your comment board with nested replies.

The upshot of this is that there likely needs to be some process of conversion
from your native data model on your server to your GraphQL API, and then again
from your client’s API consumption code to its internal data model.
[Relay](https://facebook.github.io/relay/) and
[Apollo](https://www.apollographql.com/client) serve this purpose. Their utility
wasn’t immediately clear to me when I naively imagined GraphQL to literally be a
system for reproducing a slice of server-side object graph. (Hmm, where might I
have gotten that impression from?)

A lot of discussion in the GraphQL space centers on data modeling—the nouns.
There’s a lot of debate and worthwhile work to be done on that front, but one of
my primary reasons for writing this piece is to think about the verbs. What
happens when you think of GraphQL requests as not just verbs, but _chains_ of
verbs? My inkling is that you start to be able to represent services in a much
more fluid way. Complex processes no longer have to be orchestrated by API
clients or hidden behind unwieldy black-box POST endpoints. Instead, clients can
compose processes from the easily inspectable building blocks that the server
provides via its GraphQL schema. That’s a whole different approach to API
design.

# So, where to now?

I began by asserting that the future looks a lot _like_ GraphQL. But I did not
say that GraphQL _is the future_. I hedge because there are a lot of unanswered
questions and some pain points within today’s GraphQL, even as it paints a
compelling picture of the future. I may write a follow-up piece bringing up some
of these gripes. At the moment, Facebook still largely controls the development
of the technology and it has been slow to evolve. Arguably, this is a good
thing, as the full-stack community continues to digest the basic concepts. But
I’m sure impatient folks will attempt forks or create parallel technologies. How
it all balances out is anybody’s guess.

Nonetheless, today’s GraphQL is already a tremendous leap forward from REST API
design. It much more directly models the sort of data traversals a client needs
to perform in order to do its job. I expect significant refinement within this
space over the next couple years. And after a couple more, the days before
GraphQL will be just another source of lore for grizzled vets like us.
