---
layout: post
title: "GraphQL for iOS Developers"
date: 2016-06-19 12:09
author: orta
categories: [mobile, graphql, eigen]
---

GraphQL is something you may have heard in passing, usually from the web team. It's a Facebook API technology, that describes itself as a _A Data Query Language and Runtime_. As mobile engineers, we can consider it an API, where the front-end team have as much control as the backend.

This blog post covers our usage of GraphQL, and what I've learned in the last 3 months of using it in [Eigen](https://github.com/artsy/eigen/).

<!-- more -->

### So what is GraphQL

So, you can get the full explaination on [their website](http://graphql.org). Though I found running through [Learn GraphQL](https://learngraphql.com) to really hammer down how it works as an API consumer. Reading the [introduction blog post](https://facebook.github.io/react/blog/2015/05/01/graphql-introduction.html) can be useful too, I'll be doing a quick TLDR though.

GraphQL is an API middle-layer. It acts as an intermediate layer between multiple front-end clents and multiple back-end APIs. This means it can easily coalesce multiple API calls into a single request, this can be a _massive_ user experience improvement when you have a screen that requires information from multiple sources before you can present anything to a user.

<img src="/images/2016-06-19-graphql-for-iOS-devs/graphQL.svg" width=100%>

As a client, you [send](https://github.com/artsy/eigen/blob/dac7c80b66b600f9a45aaae6095544fe420f0bbc/Artsy/Networking/ARRouter.m#L1011) a "JSON-SQL"-like query structure, which is heirarchical and easy to read:

```json
{
  artwork(id: "kimber-berry-as-close-to-magic-as-you-can-get") {
    id
    additional_information

    is_price_hidden
    is_inquireable
  }
}

```

> This will search for a [specific artwork](https://www.artsy.net/artwork/kimber-berry-as-close-to-magic-as-you-can-get), sending back the Artwork's `id`, `additional_information`, `is_price_hidden` and `is_inquireable`.

It's important to note here, the data being sent _back_ is only what you ask for. This is not defined on the server as a _short_ or _embedded_ version of a model, but the specific data the client requested. When bandwidth and speed is crucial, this is the other way in which GraphQL improves the end-user experience.

So, that's the two killer features:

1. Coelesce Multiple Network Requests.
2. Only Send The Data You Want.

This is in stark contrast to existing API concepts, like [HAL](http://stateless.co/hal_specification.html) and [JSON-API](http://jsonapi.org) - both of which are optimised for caching, and rely on "one model, one request" types of API access. E.g. a list of Artworks would actually contain a list of hrefs instead of the model data, and you have to fetch each model as a separate request.

### Using GraphQL

Artsy's GraphQL server is (unsurprisingly) open-source, it's at [artsy/metaphysics](https://github.com/artsy/metaphysics). However, it's not publicly accessible, ([yet?](https://github.com/artsy/metaphysics/issues/279)). One of the coolest things about developing against a GraphQL server is that it has a built-in IDE. I can't show you ours, but I can send you to [Clay Allsop's](http://clayallsopp.com) [GraphQLHub](https://www.graphqlhub.com):

[Here][hub] ( I strongly recommend pausing to open that link in a new window. Press cmd + enter to see the results )

GraphQL comes with a playground for the API! It's amazing! Clay called it the ["Killer App" of GraphQL](https://medium.com/the-graphqlhub/graphiql-graphql-s-killer-app-9896242b2125#.6ht6374bq) - I'm inclined to concur. I've never had API docs this useful.

{% expanded_img /images/2016-06-19-graphql-for-iOS-devs/graphiql.png Selection diagram %} 

### How GraphQL Changed How We Write Native Code

#### View Models

Our GraphQL server is owned by the [web-practice](http://artsy.github.io/blog/2016/03/28/artsy-engineering-organization-stack/) and the mobile practice also help out occasionally. This ownership distinction is important, an API like this would normally be handled by our platform team. 

Because of Metaphysics' ownership as a "front-end" product, it can contain additional information that is specific to our needs. For example, in our first example of a request to our GraphQL server we requested `id`, `additional_information`, `is_price_hidden` and `is_inquireable` - only two of these datums come from the database. The `is_` denotes a derived state in our implmentation.

This is _awesome_, because previously a [lot of this logic](https://github.com/artsy/eigen/blob/dac7c80b66b600f9a45aaae6095544fe420f0bbc/Artsy/Views/Artwork/ARArtworkActionsView.m#L310-L362) existed in a [Google Doc](https://github.com/artsy/eigen/blob/dac7c80b66b600f9a45aaae6095544fe420f0bbc/Artsy/Views/Artwork/ARArtworkActionsView.m#L108-L109) which needed to be re-implmented in 3-4 clients. On the native side we would regularly find out we were out-of-date mid-release cycle and had to rush to catch up.

So, what does this mean for view models? It lessens the need for them. If you can move a lot of your derived data to the server, it is presenting the logic that should be in a view model. We've not stopped writing view models, but now discussions on them includes "should this move to Metaphysics?".

#### React Native

We've already [shipped one full view controller](https://twitter.com/orta/status/734880605322776576) in [React Native](https://facebook.github.io/react-native/) for our flagship app, [Eigen](https://github.com/artsy/eigen/). The advantages that came from from GraphQL were a big part of the discussion around using Reacy Native.

There will be longer articles on the "why" and "how" we choose to work this way. However the TLDR: the key thing that we're excited about React Native is Relay. Using Relay, our [views](https://github.com/artsy/emission/tree/2ac6e9fc0f85ca81483bcbd6c841841104f07833/lib/components/artist) can declare a fragment of the GraphQL query that [view needs](https://github.com/artsy/emission/blob/2ac6e9fc0f85ca81483bcbd6c841841104f07833/lib/components/artist/biography.js#L60-L69).

So, in our Artist View Controller, the Biography "View" ([component](https://facebook.github.io/react-native/docs/native-components-ios.html)) declares "when I am in the view heirarchy, you need to grab a `bio`, and `blurb`"

``` js
export default Relay.createContainer(Biography, {
  fragments: {
    artist: () => Relay.QL`
      fragment on Artist {
        bio
        blurb
      }
    `,
  }
});
```

Once your views are declaring what data they need, and are acting on that data - you see less of a need to use models.

---

GraphQL is having a massive impact in the way that we write our apps. It means we can make much faster apps, as the network is our critical path. Faster apps means happier users, happier users means happier developers. I want to be happy. So I'm thankful that the [Web practice](https://github.com/artsy/metaphysics/graphs/contributors) gave GraphQL a try, and [welcome'd](https://github.com/artsy/metaphysics/pull/243) [us](https://github.com/artsy/metaphysics/pull/313) [to](https://github.com/artsy/metaphysics/pull/226) [the](https://github.com/artsy/metaphysics/pull/302) [party](https://github.com/artsy/metaphysics/issues/2).


[hub]: https://www.graphqlhub.com/playground?query=%23%20Hit%20the%20Play%20button%20above!%0A%23%20Hit%20%22Docs%22%20on%20the%20right%20to%20explore%20the%20API%0A%0A%7B%0A%20%20graphQLHub%0A%20%09reddit%20%7B%0A%20%20%20%20user(username%3A%20%22orta%22)%20%7B%0A%20%20%20%20%20%20username%0A%20%20%20%20%20%20commentKarma%0A%20%20%20%20%20%20createdISO%0A%20%20%20%20%7D%0A%20%20%20%20%0A%20%20%20%20subreddit(name%3A%20%22swift%22)%7B%0A%20%20%20%20%20%20newListings(limit%3A%202)%20%7B%0A%20%20%20%20%20%20%20%20title%0A%20%20%20%20%20%20%20%20comments%20%7B%0A%20%20%20%20%20%20%20%20%20%20body%0A%20%20%20%20%20%20%20%20%20%20author%20%7B%20%0A%20%20%20%20%20%20%20%20%20%20%20%20username%0A%20%20%20%20%20%20%20%20%20%20%09commentKarma%0A%20%20%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%20%20%7D%0A%20%20%20%20%20%20%7D%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D