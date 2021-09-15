---
layout: epic
title: "Accessing the Relay Store Without a Mutation"
date: 2021-04-15
categories: [relay, graphql, react, redis, tooling]
comment_id: 685
author: anna
---

I recently encountered a problem where client-side data (returned from a Relay query) became out of sync after a
user interaction. How can we make sure our data is consistent while maintaining a single source of truth? This post
explores why a developer might want to update client-side data locally, the basics of Relay and its store, and how
to delete records in the store when you're not using a mutation.

## Relay x Artsy x Me

[Relay][relay-docs] is a GraphQL client library maintained by Facebook engineers and enables rapid client-side data
fetching in React applications. [Artsy's adoption of Relay][why-does-artsy-use-relay] coincided with our move
toward using React Native for our mobile work around 2016. I joined Artsy as an engineer in November of 2020 (after
[transitioning to engineering from a non-technical role at the
company][how-losing-my-way-helped-me-find-my-way-back].) When I joined, I was about a year into React development
and completely new to Relay.

<!-- more -->

I work on the Partner Experience (PX) team at Artsy. We build and maintain software used by our gallery and auction
house partners to sell artwork on Artsy. Although Relay is not new to Artsy, it’s relatively new to our team’s main
repository, Volt. (Volt is Artsy’s CMS used by gallery partners to manage their presences on the platform.) A topic
for another blog post, but Volt’s structure is worth noting here: Volt is a collection of mini React apps injected
into HAML views—our way of incrementally converting the codebase to our new stack.

Relay’s biggest advantage in my eyes is how it tightly couples the client view and API call (in our case, to the
GraphQL layer of our stack, which we call Metaphysics.) In addition to performance and other benefits, colocating a
component with its data requirements creates a pretty seamless developer experience.

## Building an Artwork Checklist

On the PX team, we recently launched a checklist feature aimed at empowering our gallery partners to be more
self-sufficient and find the greatest success possible on Artsy. The checklist prompts galleries to add specific
metadata to artworks that we know (because of our awesome data team) will make the work more likely to sell. The
new feature gathers a list of five high-priority artworks (meaning they are published, for-sale, and by a
top-selling artist) that are missing key pieces of metadata. The checklist prompts users to add the missing
metadata. Users also have the ability to click a button to “snooze” works, which removes them from the list for the
day.

<figure class="illustration">
    <img src="https://user-images.githubusercontent.com/9466631/114630150-28886200-9c77-11eb-9f04-461101496ee0.png">
</figure>

The feature makes use of [Redis][about-redis], a key-value store used for in-memory cache, to store two lists:

1. `includeIDs` to store the five artworks in the list, so users see a consistent list of artworks whenever they
   log in and load the page
2. `excludeIDs` or “snoozed” IDs which Redis will store for 24 hours and ensure the user does not see

When a user presses the “snooze” button, the ID for the artwork is added to the snoozed list in Redis. The list of
`includeIDs` and the list of `excludeIDs` are passed down from Rails controllers to our HAML views and then passed
as props into our React `HomePageChecklist` app. In our Checklist component, we use both the `includeIDs` and the
`excludeIDs` as arguments passed to our Relay query to determine what is returned from Metaphysics (Artsy's GraphQL
layer).

```js
fragment ArtworksMissingMetadata_partner on Partner
  @argumentDefinitions(
    first: { type: "Int", defaultValue: 5 }
    after: { type: "String" }
    includeIDs: { type: "[String!]" }
    excludeIDs: { type: "[String!]" }
  ) {
    id
    artworksConnection(
      first: $first
      after: $after
      includeIDs: $includeIDs
      excludeIDs: $excludeIDs
    ) @connection(key: "ArtworksMissingMetadata_partner_artworksConnection", filters: []) {
      edges {
        node {
          ...ArtworksMissingMetadataItem_artwork
        }
      }
    }
  }
```

## Problem: How to Change the Data Displayed When a User Interacts with the Page

The problem we were running into occurs when the user presses “snooze” on an item. We successfully update Redis
with the new snoozed item, but the UI still renders the item on the page. (This is because the response from Relay
becomes stale.) If the user refreshes the page, the list is correct: The up-to-date Redis `excludeIDS` list will be
passed into our component and used in the Relay query. But without refreshing the page, we need to make sure that
the list in the UI updates when the user snoozes an item.

The initial fix was to use a local state variable to keep track of which items were snoozed. We defined the following variable in the parent
React component that renders the list:

```js
const [localSnoozedItems, setLocalSnoozedItems] = useState([])
```

We passed `localSnoozedItems ` and `setLocalSnoozedItems` down to each of the children items. When the “snooze”
button was pressed on an item, the `localSnoozedItems` in the parent was updated with the complete list of snoozed
items. The parent then controls which items get rendered. We used the `localSnoozedItems` list to filter the connection
returned from our Relay query (which remember, is already filtered based on our Redis `excludeIDs` from Redis.)

This worked, but it definitely did not feel great to have two sources of truth for snoozing: The Redis key and the
local state variable.

## Solution: Deleting a Record From the Relay Store

Cue the [RelayModernStore][relay-documentation-relay-modern-store]! I learned that Relay keeps track of the GraphQL
data returned by each query in a store on the client. Each record in the store has a unique ID, and the store can be
changed, added to, and deleted from. There are a couple of helpful blog posts (like
[this][deep-dive-into-the-relay-store] and
[this][wrangling-the-client-store-with-the-relay-modern-updater-function]) that explain the store and how to
interact with it.

In most of the Relay documentation, blog posts, and Artsy’s uses cases, the store is accessed through an `updater`
function via [mutations][relay-documentation-mutations]. [Updater functions][relay-documentation-updater-functions]
that return the store in the first argument can optionally be added to Relay mutations. Inside that function, you can access
the store to modify the records you need.

Here's an example:

```js
commitMutation(defaultEnvironment, {
  mutation: graphql`
    mutation SomeMutation {
      ...
    }
  `,
  updater: (store) => {
    // Do something with the store
  },
})
```

In my use case, I was not using a Relay mutation because I did not need to modify anything on the server. Since
Redis is keeping track of our `excludeIDs` for us, any round trip to the server will be up-to-date. We just need to
modify our local data store.

Relay provides a [separate API method to make local updates][relay-documentation-local-data-updates] to the Relay
store: `commitLocalUpdate`. `commitLocalUpdate` takes two arguments: the first is the Relay environment, which you
can easily access from the parent Relay fragment or refetch container. The second is an `updater` callback function
that returns the store in the first argument. We now have access to the store!

## Deleting a Connection Node with ConnectionHandler

My main hurdle during this journey was finding an appropriate way to hook into the store for our specific use case—when we do
not require an update to server data.

But to close us out: Let's finish the job and delete the item from the connection in the store.

When an item is snoozed, we call `commitLocalUpdate`, pass in the Relay environment, and then pass in the `updater`
function. Once we have access to the store, our goal is to delete this particular item from the
`artworksConnection`, which is the GraphQL object returned by our original Relay query.

Because we are dealing with connections, we want to use the [ConnectionHandler
API][relay-documentation-connection-handler] provided by Relay. `ConnectionHandler.getConnection` takes in the
connection's parent record (which we can find using the GraphQL ID added as a field on our query for the
connection) as the first argument and the connection key which can be provided through [Relay’s @connection
directive][relay-modern-connection-derivative].

Once we have the connection, we will use `ConnectionHandler.deleteNode` which takes the connection as the first
argument and the id to be deleted, which we can also easily access using the GraphQL ID added as a field to the
query for the item.

Bonus: Because `commitLocalUpdate` works anywhere in Relay land, we got to perform this deletion exactly where the
"snooze" action is happening: in the child item component. (In our previous solution, we had to manage the state of
the children from their parent component, which wasn't as intuitive.)

```js
import { commitLocalUpdate } from "relay-runtime"

commitLocalUpdate(relay.environment, (store) => {
  const parentRecord = store.get(parentID)

  if (parentRecord) {
    const artworksConnection = ConnectionHandler.getConnection(
      parentRecord,
      "ArtworksMissingMetadata_partner_artworksConnection"
    )
    if (artworksConnection) {
      ConnectionHandler.deleteNode(artworksConnection, id)
    }
  }
})
```

## Key Takeaways

1. Relay is great because it colocates a component with its data requirements.
2. The Relay store allows us to access and modify data that we are using on the client.
3. `commitLocalUpdate` provides us access to the store if we just need to modify local data and aren’t using a
   mutation to update server-side data.

[relay-docs]: https://relay.dev/
[why-does-artsy-use-relay]: https://artsy.github.io/blog/2019/04/10/omakase-relay/
[how-losing-my-way-helped-me-find-my-way-back]: https://medium.com/swlh/how-losing-my-job-helped-me-find-my-way-back-8c8f86552acc
[about-redis]: https://redis.io/
[relay-documentation-relay-modern-store]: https://relay.dev/docs/api-reference/store/
[deep-dive-into-the-relay-store]: https://yashmahalwal.medium.com/a-deep-dive-into-the-relay-store-9388affd2c2b
[wrangling-the-client-store-with-the-relay-modern-updater-function]: https://medium.com/entria/wrangling-the-client-store-with-the-relay-modern-updater-function-5c32149a71ac
[relay-documentation-mutations]: https://relay.dev/docs/guided-tour/updating-data/graphql-mutations/
[relay-documentation-updater-functions]: https://relay.dev/docs/guided-tour/updating-data/graphql-mutations/#updater-functions
[relay-documentation-local-data-updates]: https://relay.dev/docs/guided-tour/updating-data/local-data-updates/
[relay-documentation-connection-handler]: https://relay.dev/docs/api-reference/store/#connectionhandler
[relay-modern-connection-derivative]: https://www.prisma.io/blog/relay-moderns-connection-directive-1ecd8322f5c8
