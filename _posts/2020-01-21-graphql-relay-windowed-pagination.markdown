---
layout: epic
title: Effortless Pagination with GraphQL and Relay? Really!
date: 2020-01-21
categories: [GraphQL, Relay, Pagination]
author: matt
comment_id: 606
---

It's the year 2020. You use a modern front-end stack of [Relay](https://relay.dev/),
[GraphQL](https://graphql.org/), [React](https://reactjs.org/) and [TypeScript](https://www.typescriptlang.org/).
You can build an infinite scroll 'feed' type UI totally out of the box with these tools, by mostly putting together
boilerplate (proper [connections](https://facebook.github.io/relay/graphql/connections.htm#sec-Connection-Types),
along with a [pagination container](https://relay.dev/docs/en/pagination-container)). You have a design system, and
are rapidly building up a component library. Things are great!

Then you take a look at the latest design comps for a 'browse' type page, and you see that the
[controversial](https://medium.com/simple-human/7-reasons-why-infinite-scrolling-is-probably-a-bad-idea-a0139e13c96b)
infinite scroll has been replaced by a more traditional pagination bar.

You know the one. Like the following, from [Amazon](https://www.amazon.com):

<img src="/images/2020-01-21-graphql-relay-windowed-pagination/amazon.png">

You start to realize that the cursor-based setup of a connection, along with a Relay pagination container, does not
lend itself to this more traditional UI. For one thing, a user can arbitrarily 'jump' to any page by including a
`?page=X` query param (typically). For another, the user can only actually see the current page of content, versus
a feed. As you go to sleep and dream of REST, Rails controllers, [kaminari](https://github.com/kaminari/kaminari),
[will_paginate](https://github.com/mislav/will_paginate), and a simpler time, you start to have a vision...

<!-- more -->

To get a good primer of what a GraphQL connection is and why they're so useful, read this
[excellent Apollo blogpost](https://blog.apollographql.com/explaining-graphql-connections-c48b7c3d6976). Seriously.
It's one of the best writeups on this subject out there. I'll assume basic familiarity with connection types from
this point forward.

We prefer to use connections in place of lists almost always. Not only do they provide a preferred cursor-based
pagination API for clients, but their type specification (a map vs a list) is naturally forward-looking. Even if
you do no pagination, a pure list type can't accomodate returning other metadata (such as a `totalCount`) alongside
the list. Additionally, if your data is very relational and better represented as nodes connected by edges (which
would contain data about the 'join' of the two nodes), the connection type gives one more flexibility than a simple
list. This (and more) is all covered in the aforementioned blog post.

So, let's start by taking a look at our desired pagination UI, and think about what kind of schema/components make
sense.

<img src="/images/2020-01-21-graphql-relay-windowed-pagination/pagination.png">

There looks to be several types of appearances we want to show, based on the total size of our list and fixed page
size chosen, as well as the current page. There's also some edge cases of empty lists, or lists that are short
enough to just display all their page numbers. Users can click on any displayed page number to jump to it. There's
a prev/next navigation, which brings the user forward and back one page at a time. Whenever the current page
changes, the URL should update accordingly. For a responsive implementation, we want to hide the page numbers, and
only show the prev/next toggles on small screens.

Wow! Ok, we have our work cut out for us. But wait til you see how easy this is! There'll be links to our actual
production components involved (all open-source) at the end.

## Pagination Schema

Let's tackle the first part of this, which is: how do we adapt the
[GraphQL connection spec](https://facebook.github.io/relay/graphql/connections.htm) in order to hold necessary
information that a UI might need? Generally we want the UI's to be as simple as possible, and so if the server
could construct a suitable pagination schema, that would be preferable. The simpler our UI, and the more business
logic and good abstractions made in our GraphQL server, the more portable and reusable this all becomes.

What kind of data does the UI need, in order to render a particular page of contents? Well, for a particular page
we'd need to render the actual number it corresponds to. We'll need to know if this is the current page or not (so
we can distinguish it in the UI from neighboring pages). And, we'll need to know the actual cursor (think:
[opaque string](https://relay.dev/graphql/connections.htm)) that corresponds to this page number. It seems likely
we'll need some sort of way to construct cursors from page numbers, on the server.

So, check this out:

```js
// SDL
type PageCursor {
  cursor: String!
  pageNumber: Int!
  isCurrent: Boolean!
}

type PageCursors {
  first: PageCursor
  around: [PageCursor!]!
  last: PageCursor
  previous: PageCursor
}
```

This is our pagination schema. Including a field of type `pageCursors` as a connection-level field, onto a
connection, is sufficient for a UI to incredibly simply 'just render' a correct pagination bar always, and be able
to hook up proper interactions. We can fully construct a simple UI (using Relay, shown in the next section) that
can present and allow for the interactions desired, for windowed pagination.

But, of course we're glossing over the implementation for such a `pageCursors` type, so let's check that out before
looking at how a client might consume this.

Our backing API's largely still paginate via offsets, and not cursors. That is, they accept page/size or
size/offset style arguments. We use [graphql-relay-js](https://github.com/graphql/graphql-relay-js), which includes
helpers to make sure types and resolvers are compatible with some Relay expectations. So, we use this library to
generate our cursors, and can convert the cursor to an offset. A page of 4 with a size of 10, returns the elements
numbered 30 - 39 in that list. So a page of 4 (and size of 10), is equivalent to an offset of 29 (and size of 10).
We have:

```js
const pageToCursor = (page, size) => {
  return String((page - 1) * size - 1)
}
```

This gives us the offset of the last value of the previous page. While our upstream services are all still
paginating using this size/offset method, the [GraphQL cursor spec](https://relay.dev/graphql/connections.htm)
prefers opaque cursors to be used on the client. This allows the actual implementation of pagination to change
upstream while clients remain unaffected. Thus if we ever update our upstream pagination arguments/logic/setup, we
could update this schema implementation accordingly, and clients would continue to be functional.

For inspiration in constructing our `first`, `last`, and `around` groups, we turn to
[Fingertips](https://www.fngtps.com/) and their
[pagination library](https://github.com/Fingertips/peiji-san/blob/6bd1bc7c152961dcde376a8bcb2ca393b5b45829/lib/peiji_san/view_helper.rb#L87).
That code goes through the various cases possible (a short list, a long list where the current page is near the
front, middle or end, various degenerate cases, etc.), and returns a proper structure that represents this data. It
can handle all combinations of list sizes, and current position relative to the total size.

In pseudo-code, it looks like:

```js
if emptyList
  around = [1]
else if listIsShort
  around = [1...totalPages]
else if nearBeginning
  around = [1...3]
  last = [totalPages]
else if nearMiddle
  first = [1]
  middle = [currentPage-1, currentPage, currentPage+1]
  last = [totalPages]
else if nearEnd
  first = [1]
  around = [last-1, last, last+1]
```

Our full implementation of that method can be found
[here](https://github.com/artsy/metaphysics/blob/205592be7f59970cf80313972ceb95bb1579c31f/src/schema/v2/fields/pagination.ts#L96).

For a real-life example, check out
[this link, corresponding to a page number of 4](<https://metaphysics-staging.artsy.net/v2?query=%7B%0AartworksConnection(first%3A5%2C%20after%3A%20%22YXJyYXljb25uZWN0aW9uOjE0%22)%20%7B%0A%20%20pageInfo%20%7B%0A%20%20%20%20hasNextPage%0A%20%20%20%20endCursor%0A%20%20%7D%0A%20%20pageCursors%7B%0A%20%20%20%20first%20%7B%0A%20%20%20%20%20%20cursor%0A%20%20%20%20%20%20page%0A%20%20%20%20%20%20isCurrent%0A%20%20%20%20%7D%0A%20%20%20%20last%20%7B%0A%20%20%20%20%20%20cursor%0A%20%20%20%20%20%20page%0A%20%20%20%20%20%20isCurrent%0A%20%20%20%20%7D%0A%20%20%20%20around%20%7B%0A%20%20%20%20%20%20cursor%0A%20%20%20%20%20%20page%0A%20%20%20%20%20%20isCurrent%0A%20%20%20%20%7D%0A%20%20%20%20previous%20%7B%0A%20%20%20%20%20%20page%0A%20%20%20%20%20%20cursor%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D%7D>).
You can adjust the arguments to see how the output changes based on where you are in the list. Try putting
different cursor values in! It looks like:

<img src="/images/2020-01-21-graphql-relay-windowed-pagination/graphiql.png">

Let's look at a couple of other pieces of data requested here. One of these is a `previous` page cursor. This is to
support that action (the prev/next toggles) in the UI. However, we don't need a custom `next` item to support that
behavior. That's because we tend to use
[forward-style pagination arguments](https://facebook.github.io/relay/graphql/connections.htm#sec-Forward-pagination-arguments)
with connections, which means the connection will already return the data needed for that action (remember, you can
implement a scrolling infinite scroll feed that always takes you to the next page right out of the box).
Specifically, the `hasNextPage` and `endCursor` are those fields from the
[GraphQL `pageInfo` object](https://facebook.github.io/relay/graphql/connections.htm#sec-undefined.PageInfo.Fields)
which give you that information.

## Companion UI Component

Ok, now that we have a connection and corresponding fields that provide the needed data, let's take a look at a
simple React component that can render this:

```js
const Page = ({pageCursor: { page, cursor }}) => {
  return (
    <Button onClick={() => onClick(cursor)}>
      {page}
    </Button>
  )
}

// Show page 1 if `first` is present, and append with dots
// Show everything in `around`
// Show last page if present, and prepend with dots
//
// Show previous toggle, active if present
// Show next toggle, active if next page exists
return (
  <>
    {<Button disabled={!previous} onClick={() => onClick(previous.cursor)}>Previous</Button>}
    {first && (<><Page pageCursor={first} />...</>)}
    {around.map(page => <Page pageCursor={page}>)}
    {last && (<>...<Page pageCursor={last} /></>)}
    {<Button disabled={!hasNextPage} onClick={() => onNext()}>Next</Button>}
  </>
)
```

That's basically it, visually speaking! The data provided by our GraphQL server is sufficient to render what's
needed. You can see such a UI component in our design system
[here](https://github.com/artsy/palette/blob/f882d32c3fdc6e7f81915c2922e3824bd26791e7/packages/palette/src/elements/Pagination/Pagination.tsx).
It looks very similar to the above code. Of note, is since this is a simple UI component, it is vanilla React. It
is not a Relay component. It requires an `onClick` and `onNext` to be passed as props.

## Relay Integration Step I

Now, let's take a look at how we can build a Relay container that will use the above UI component. First, let's
build a Relay-wrapped component of the above UI component. This is a fragment container, and lists all the fields
needed:

```js
fragment Pagination_pageCursors on PageCursors {
  around {
    cursor
    page
    isCurrent
  }
  first {
    cursor
    page
    isCurrent
  }
  last {
    cursor
    page
    isCurrent
  }
  previous {
    cursor
    page
  }
}
```

As a fragment container, this doesn't have the ability to fetch anything by itself. We want to pass in an `onClick`
and `onNext` prop from a parent, as well as the `hasNextPage` and `endCursor` data. Check out
[this component](https://github.com/artsy/reaction/blob/c6d630f8c3213f47c5124f63eda13fbb9d8f497b/src/Components/v2/Pagination.tsx)
in our library to see how we take that vanilla React component mentioned above, and use the above fragment to make
a Relay fragment container out of it.

Now, we need to decide what kind of parent container is appropriate, and how this fragment container will be used.

## Relay Integration Step II

This is going to be confusing, but for this step, we use a
[refetch container](https://relay.dev/docs/en/refetch-container) in order to present our paginated collection view,
rather than the aptly-named [Relay pagination container](https://relay.dev/docs/en/pagination-container). The
latter is more suited for an infinite scroll feed view (presenting all content already fetched, only adjacent pages
in a particular direction are able to be scrolled to, etc.) vs. the windowed pagination we are trying to
accomplish. The refetch container is a much more natural fit for our use case, despite the naming.

That fragment looks like:

```js
fragment ConnectionResults_query on Query {
  someConnection(first: $first, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    pageCursors {
      ...Pagination_pageCursors
    }
    ...OtherStuffForYourView
  }
}
```

We include our `pageCursors` fragment, as well as the `hasNextPage` and `endCursor` from the `pageInfo` object. We
need to provide the `onClick` and `onNext` callbacks as well. Since this component will have access to a
[`relay` prop](https://relay.dev/docs/en/refetch-container#refetch) since it is a refetch container, those look
like:

```js
handleNext = () => {
  if (hasNextPage) this.handleClick(endCursor)
}

handleClick = (cursor: string) => {
  this.props.relay.refetch(
    {
      first: PAGE_SIZE,
      after: cursor
    },
    null,
    error => {
      /* Update URL, set state, etc. */
    }
  )
}
```

The refetch query defined for the container will look like:

```js
query SomeConnectionQuery($first: Int, $after: String) {
  ...ConnectionResults_query @arguments(first: $first, after: $after)
}
```

We're pretty much done, this is all just Relay boilerplate at this point.

Putting it all together, our refetch container winds up rendering a fully functional pagination component in one
line:

```js
<Pagination onClick={handleClick} onNext={handleNext} pageCursors={props.pageCursors} />
```

That's it! Any connection can have this pagination functionality added to it very simply. You include the page
cursor schema on the server for that type (we have a
[factory method](https://github.com/artsy/metaphysics/blob/205592be7f59970cf80313972ceb95bb1579c31f/src/schema/v2/fields/pagination.ts#L160)
to help us do that automatically for any connection type). Then, following the above steps, you can quickly build a
Relay refetch container that displays and seamlessly paginates any list.

You can see an example of this in numerous places on the [Artsy](https://www.artsy.net) website. Head on over to
our [Artworks browse experience](https://www.artsy.net/collect) and have fun filtering and searching/browsing
through all accessible works! The pagination controls and functionality on this page, and others, are built using
the technique described in this post.

## Examples

Since our [GraphQL orchestration layer](https://github.com/artsy/metaphysics), our
[design system](https://github.com/artsy/palette) and
[UI component and app library](https://github.com/artsy/reaction) are all open source, here's links to our actual
production implementation of the above:

- [Pagination schema in GraphQL](https://github.com/artsy/metaphysics/blob/205592be7f59970cf80313972ceb95bb1579c31f/src/schema/v2/fields/pagination.ts)
- [React UI component](https://github.com/artsy/palette/blob/f882d32c3fdc6e7f81915c2922e3824bd26791e7/packages/palette/src/elements/Pagination/Pagination.tsx)
- [Relay FragmentContainer wrapping of the above](https://github.com/artsy/reaction/blob/c6d630f8c3213f47c5124f63eda13fbb9d8f497b/src/Components/v2/Pagination.tsx)
- [Relay RefetchContainer full example](https://github.com/artsy/reaction/blob/c6d630f8c3213f47c5124f63eda13fbb9d8f497b/src/Apps/Search/Routes/Artists/SearchResultsArtists.tsx)
