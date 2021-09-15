---
layout: epic
title: "GraphQL: Union vs. Interface"
date: "2019-01-14"
author: [ashkan]
categories: [graphql, ruby]
comment_id: 522
---

At Artsy we’ve been moving towards GraphQL for all of our new services. Acknowledging GraphQL is a relatively new
technology, we faced some challenging questions as we were developing one of our most recent services.

Naively as my first attempt to define GraphQL types and schemas, I naturally tried to map our database models to
GraphQL types. While this may work for lot of cases, we may not be utilizing some of the useful features that come
with GraphQL that can make the consuming of our data a lot easier.

## GraphQL: Interface or Union?

Think of the case where we are trying to expose search functionality and the result of our search can be either a
`Book` , `Movie` or `Album`. One way to think about this is to have our search query return something like:

<!-- more -->

```js
search(term: "something") {
  books {
    id
    title
    author
  }
  movies {
    id
    title
    director
  }
  albums {
    id
    name
  }
}
```

While ☝️ works, we can’t rank the result based on relevance in one result set. Ideally, we would return one result
set that can have different types in it. A naive approach for this could be to only return one type in the results:

```js
search(term: "something") {
  results {
    id
    name
    author   // when a book
    director // when a movie
    title    // when a movie/book
  }
}

```

We could have a single object that has all these values as optional properties:

```js
type Result {
  id: ID!
  name: String!

  // All of the optional data, available as nullable types
  author: String
  director: String
  title: String
}
```

But returning these Result objects would be very messy on the server and for clients, plus it would undermine using
GraphQL's type system.

There are two main solutions in the GraphQL toolkit for this problem:
[Unions](https://graphql.org/learn/schema/#union-types) and
[Interfaces](https://graphql.org/learn/schema/#interfaces).

### Union

GraphQL interfaces are useful to solve problems like above where we want to have the returned type possibly from
different types.

For this to work, we can define a `Union` type that can resolve to either one of `Book`, `Movie` or `Album` and
then each type can have its own set of fields.

In `graphql-ruby` you can define Unions with:

```ruby
class Types::Movie < Types::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
  field :director, String, null: false
end

class Types::Book < Types::BaseObject
  field :id, ID, null: false
  field :title, String, null: false
end

class Types::Album < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
end

class SearchResultUnionType < Types::BaseUnion
  description 'Represents either a Movie, Book or Album'
  possible_types Book, Movie, Album
  def self.resolve_type(object, _context)
    case object
    when Movie then Types::Movie
    when Book then Types::Book
    when Album then Types::Album
    else
      raise "Unknown search result type"
    end
  end
end
```

With the above change you can now query for search results and use specific fragments for different result types:

```js
query {
  search(term: "something") {
    ... on Movie {
      __typename
      id
      title
    }
    ... on Book {
      __typename
      id
      title
    }
    ... on Album {
      __typename
      id
      name
    }
  }
}
```

```json
{
  "data": [
    {
      "__typename": "Movie",
      "id": 1,
      "title": "Close-Up"
    },
    {
      "__typename": "Album",
      "id": 2,
      "name": "Dark Side Of The Moon"
    }
  ]
}
```

### Interface

Unions are useful when we are trying to group different types together in one field. Now let’s think of the case
where we are trying to expose models of the same Type that can have different fields populated.

For example a music `Instrument` can have strings or not. If it has strings we want to mention how many strings it
has in `numberOfStrings` field. For any non-string instrument this field would be `null` in the database.

One way to do this is to have the `Instrument` Type always have `numberOfStrings` and in the case of non-string
instruments return `nil`. Sample result for this would be:

```json
{
  "data": [
    {
      "id": 1,
      "name": "Guitar",
      "numberOfStrings": 6
    },
    {
      "id": 2,
      "name": "Drums",
      "numberOfStrings": null
    }
  ]
}
```

The above solution would work, but it will add extra work on the clients to decide if `numberOfStrings` is even
applicable to this current instrument or not.

The more GraphQL approach for this would be to use an `Interface`. We can define a generic `Instrument` interface and
have all the common fields between all instruments defined there. Then we can have each specific category of
instruments define its own special fields and then access those specific fields using fragments.

In `graphql-ruby` you can define an Interface with:

```ruby
module Types::InstrumentInterface
  include Types::BaseInterface

  description 'A Musical Instrument'
  graphql_name 'Musical Instrument'

  field :id, ID, null: false
  field :name, String, null: false
  field :category, String, null: false

  definition_methods do
    def resolve_type(object, _context)
      case object.category
      when "string" then Types::StringInstrument
      when "drums" then Types::DrumInstrument
      else
        raise 'Unknown instrument type'
      end
    end
  end
end
```

Then we can have our specific types implementing this interface.

```ruby
class Types::StringInstrument < Types::BaseObject
  implements Types:: InstrumentInterface

  field :number_of_strings, Integer, null: false
end
```

For types that don’t have any extra field, they can just reuse everything from interface.

```ruby
class Types::DrumInstrument < Types::BaseObject
  implements Types:: InstrumentInterface
end
```

This way the query for getting instruments can look like

```ruby
query {
  instruments {
    id
    name
    category
    ... on StringInstrument {
       numberOfStrings
    }
  }
}
```

Sample response can look like

```json
{
  "data": [
    {
      "id": 1,
      "name": "Guitar",
      "category": "StringInstrument",
      "numberOfStrings": 6
    },
    {
      "id": 2,
      "name": "Drums",
      "category": "StringInstrument"
    }
  ]
}
```

One issue we found after doing the above was, since this way we don’t reference `StringInstrument` and `DrumInstrument`
types anywhere in our schema, they actually don’t end up showing in the generated schema. For them to show up we
have to add them as `orphan_types` in the interface. So the interface definition will look like:

```ruby
module Types::InstrumentInterface
  include Types::BaseInterface

  description 'A Music Album'
  graphql_name 'Album'

  field :id, ID, null: false
  field :name, String, null: false
  field :category, String, null: false

  ## Changes
  orphan_types Types::StringInstrument, Types::DrumInstrument

  definition_methods do
    def resolve_type(object, _context)
      case object.category
      when "string" then Types::StringInstrument
      when "drums" then Types::DrumInstrument
      else
        raise 'Unknown instrument type'
      end
    end
  end
end
```

## Conclusion

The biggest learning experience for us was realizing that with GraphQL we have the option to decouple our database
modeling with how the data is exposed to consumers. This way when designing our persistence layer, we can focus on
the needs of that layer and then separately think about what's the best way to expose the data to the outside world.
