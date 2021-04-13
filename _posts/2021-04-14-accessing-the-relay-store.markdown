---
layout: epic
title: "A Cool Way to Access the Relay Store"
date: 2021-04-14
categories: [relay, graphql, react, redis, tooling]
author: anna
---

Need to access the Relay store without using a mutation? Relay's `commitLocalUpdate` allows you to modify the relay
store from inside any relay component. The solution is particularly well suited to situations that just require
client-side updates and do not involved changes to server-side data.

<!-- more -->

```js
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

## Quick Intro to Artsy x Relay x Me

Relay is a GraphQL client library maintained by Facebook engineers and enables rapid client-side data fetching in
React applications. [Artsy's adoption of Relay][why-does-artsy-use-relay] coincided with our move toward using
React Native for our mobile work around 2016. I joined Artsy as an engineer in November of 2020 (after
[transitioning to engineering from a non-technical role at the
company][how-losing-my-way-helped-me-find-my-way-back].) When I joined, I was about a year into React development
and completely new to Relay.

I work on the Partner Experience (PX) team at Artsy. We build and maintain software used by our gallery and auction
house partners to sell artwork on Artsy. Although Relay is not particularly new to Artsy, it’s relatively new to
our team’s main repository, Volt. (Volt is Artsy’s CMS used by gallery partners to manage their presences on the
platform.) A topic for another blog post, but Volt’s structure is worth noting here. Volt is a collection of mini
React apps injected into HAML views——our way of incrementally converting the codebase to our new stack.

Relay is one of the many new pieces of technology I've learned on the job here at Artsy. Relay’s biggest advantage
in my eyes is how it tightly couples the client view and API call (in our case, to the GraphQL layer of our stack,
which we call Metaphysics.) In addition to performance and other benefits, having the data fetch right on top of
the React component creates a pretty seamless developer experience.

## Building an Artwork Checklist

On PX, we recently launched a checklist feature aimed at empowering our gallery partners to be more self-sufficient
and find the greatest success possible on Artsy. The checklist prompts galleries to add specific metadata to
artworks that we know (because of our awesome data team) will make the work more likely to sell. The new feature
gathers a list of five high-priority artworks (meaning they are published, for-sale, and by a top-selling artist)
that are missing key pieces of metadata. Users are prompted to add the pieces of meatdata and also have the ability
to click a button to “snooze” works, which removes them from the list for the day.

<figure class="illustration">
    <img src="https://user-images.githubusercontent.com/9466631/114630150-28886200-9c77-11eb-9f04-461101496ee0.png">
</figure>

The feature makes use of [Redis][about-redis], a key-value store used for in-memory cache, to store two lists:

1. `includeIDs` to store the five artworks in the list, so users see a consistent list of artworks whenever they
   log in and load the page
2. `excludeIDs` or “snoozed” IDs which Redis will store for 24 hours and ensure the user does not see

When a user presses the “snooze” button, the ID for the artwork is added to the snoozed list in Redis. The list
`includeIDs` and the list of `excludeIDs` are passed down from Rails controllers to our HAML views and then passed
as props into our React `HomePageChecklist` app. In our Checklist component, we use both the `includeIDs` and the
`excludeIDs` as arguments passed to our Relay query to determine what is returned from Metaphysics (Artsy's GraphQL
layer).

```js
fragment ArtworksMissingMetadata_partner on Partner
@argumentDefinitions(
  first: { type: "Int", defaultValue: 5 }
  after: { type: "String" }
  checklistArtworkIDs: { type: "[String!]" }
  checklistExcludedArtworkIDs: { type: "[String!]" }
  missingPriorityMetadata: { type: "Boolean", defaultValue: true }
  publishedWithin: { type: "Int", defaultValue: 7776000 }
  shallow: { type: "Boolean", defaultValue: false }
) {
  id
  artworksConnection(
    first: $first
    after: $after
    artworkIDs: $checklistArtworkIDs
    exclude: $checklistExcludedArtworkIDs
    missingPriorityMetadata: $missingPriorityMetadata
    publishedWithin: $publishedWithin
    shallow: $shallow
  ) @connection(key: "ArtworksMissingMetadata_partner_artworksConnection", filters: []) {
    totalCount
    edges {
      node {
        internalID
        ...ArtworksMissingMetadataItem_artwork
      }
    }
  }
}
```

## The Damn User

The problem we were running into is that when the user presses “snooze” on an item, Redis is updated but the list
that we’re using in our Relay query becomes stale. When the user reloads the page, the response from our Relay
query is correct because it's using the fresh Redis list, but we needed to make sure that the list in the UI is
also correct and does not include that snoozed item.

Without reloading, our initial solution was to use a local state variable in our React component to keep track of
which items were snoozed. This looked like:

```js
const [localSnoozedItems, setLocalSnoozedItems] = useState([])
```

`localSnoozedItems ` and `setLocalSnoozedItems` were passed down to each of the children items so when the “snooze”
button was pressed on that item, not only was the new key stored in Redis (for future reloads of the page) but the
`localSnoozedItems` state variable was also updated. The connection returned from our Relay query (which remember,
is already filtered based on our Redis `excludeIDs` from Redis) passes through an additional check to make sure
that none of those items were snoozed locally and checked again the `localSnoozedItemsList`.

This worked, but it definitely did not feel great to have two sources of truth for snoozing: The Redis key and the
local state variable.

## Head to the Relay Store

Cue the [RelayModernStore][relay-documentation-relay-modern-store]! I learned that Relay keeps track of the GraphQL
data returned by each query in a store on the client. Each record in the store has a unique ID and the store can be
changed, added to, and deleted from. There are a couple of helpful blog posts (like
[this][deep-dive-into-the-relay-store] and
[this][wrangling-the-client-store-with-the-relay-modern-updater-function]) that explain the store and how to
interact with it.

In most of the Relay documentation, blog posts, and Artsy’s uses cases, the store is accessed through an updater
function via [mutations][relay-documentation-mutations]. [Updater functions][relay-documentation-updater-functions]
that take the store as an argument can optionally be added to Relay mutations. Inside that function, you can use
the store to access and modify the records you need.

Here's an example from our app:

```js
commitMutation <
  MyCollectionArtworkModelDeleteArtworkMutation >
  (defaultEnvironment,
  {
    mutation: graphql`
      mutation MyCollectionArtworkModelDeleteArtworkMutation($input: MyCollectionDeleteArtworkInput!) {
        myCollectionDeleteArtwork(input: $input) {
          artworkOrError {
            ... on MyCollectionArtworkMutationDeleteSuccess {
              success
            }
            # TODO: Handle error
            ... on MyCollectionArtworkMutationFailure {
              mutationError {
                message
              }
            }
          }
        }
      }
    `,
    variables: {
      input: {
        artworkId: input.artworkId,
      },
    },

    updater: (store) => {
      const parentID = store.get(me.id)

      if (parentID) {
        const connection = ConnectionHandler.getConnection(
          parentID,
          "MyCollectionArtworkList_myCollectionConnection"
        )
        if (connection) {
          ConnectionHandler.deleteNode(connection, input.artworkGlobalId)
        }
      }
    },
    onCompleted: () => actions.deleteArtworkComplete(),
    onError: actions.deleteArtworkError,
  })
```

In my use case, I was not using a Relay mutation because I did not need to modify anything on the server. Since
Redis is keeping track of our `excludeIDs` for us, any round trip to the server will be up-to-date. We just need to
modify our local data store.

Relay provides a [separate API method to make local updates][relay-documentation-local-data-updates] to the Relay
store: `commitLocalUpdate`. `commitLocalUpdate` takes two arguments: the first is the relay environment, which you
can easily access from the parent relay fragment or refetch container. The second is an updater that takes in the
store as the first argument. We now have access to the store!

## Finishing the Checklist Task with ConnectionHandler

The main hurdle here was finding an appropriate way to hook into the store for our specific use case——when we do
not require an update to server data.

But to close us out: Let's delete the item from the connection in the store.

When an item is snoozed, we call `commitLocalUpdate`, pass in the relay environment, and then pass in the updater
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

1. Relay is great because it couples our data fetch with our React component.
2. The Relay store allows us to access and modify data that we are using on the client.
3. `commitLocalUpdate` provides us access to the store if we just need to modify local data and aren’t using a
   mutation to update server-side data.

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
