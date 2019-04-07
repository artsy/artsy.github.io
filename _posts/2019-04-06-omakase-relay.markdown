---
layout: epic
title: "Why does Artsy use Relay?"
date: "2019-04-06"
author: [orta]
categories: [community, omakase, relay]
css: relay
comment_id: 557
---

When the mobile team at Artsy considered moving to React Native back in 2016, one of the most compelling cases for
making that jump was Relay. This, it seems, is a dependency that is rarely used in the JS community and we often
find ourselves defending this decision to new engineers during onboarding and to the public at large.

Which makes this a perfect blog post topic, so let's have a deep dive into what makes Relay compelling for Artsy's
engineering team.

<!-- more -->

# What problem does Relay solve?

Relay is an API client for GraphQL, it comes in two parts: a compiler and a set of front-end components. Relay aims
to provide a really tight binding between your GraphQL API and your view hierarchy. When you build data-driven
apps, Relay removes a whole suite of non-business logic from your application.

Relay handles:

- Data binding (API -> props)
- Cache management (invalidation, updates etc)
- Consistent bi-directional pagination abstractions
- Multiple query consolidation (e.g. consolidate all API requests to one request)
- Declarative data mutation (describe how data should change, instead of doing it)
- UI best practices baked in (optimistic response rendering, cheap rollbacks)
- AOT query generation (allowing you to persist queries)

By taking the responsibilities of the grunt work for most complex apps and moving it into Relay you get
Facebook-scale best-practices and can build on top of that.

# How does it work?

You write a set of Relay components, you always start with a [`QueryRenderer`][query] then use a tree of either
[`FragmentContainer`][frag], [`RefetchContainer`][re] or [`PaginationController`][pag]s. You mostly use
`FragmentContainer`s so I'll focus on that here.

A `FragmentContainer` is based on a [GraphQL fragment][gql-frag]. If you've never used a fragment, they are an
abstraction that lets you declare shared fields on a specific GraphQL type to reduce duplication up your queries.
For example:

```
query GetPopularArtistsAndMyFavs {
  me {
    artists {
      id
      name
      bio
    }
  }
  popularArtists {
    id
    name
    bio
  }
}
```

To move this query to use fragments:

```
query GetPopularArtistsAndMyFavs {
  me {
    artists {
      ...ArtistMetadata
    }
  }
  popularArtists {
    ...ArtistMetadata
  }
}

fragment ArtistMetadata on Artist {
  id
  name
  bio
}
```

It's tiny a bit longer, but you have a guarantee that the data is consistent across both sets of artists. Now that
you have a rough idea of what a GraphQL fragment is, let's look at what a `FragmentContainer` looks like. Here's a
simplified [profile page] from the Artsy iOS app:

```ts
import React from "react"
import { createFragmentContainer, graphql } from "react-relay"
import { MyProfile_me } from "__generated__/MyProfile_me.graphql"

interface Props extends ViewProperties {
  me: MyProfile_me
}

export class MyProfile extends React.Component<Props> {
  render() {
    return (
      <View>
        <Header>
          <ProfilePhoto initials={props.me.initials} image={props.me.image} />
          <Subheading>{props.me.name}</Subheading>
        </Header>
        <ButtonSection>
          <ProfileButton
            section="Selling"
            description="Sell works from your collection"
            onPress={startSubmission}
          />
          <ProfileButton
            section="Account Details"
            description="Email, password reset, profile"
            onPress={goToUserSettings}
          />
        </ButtonSection>
      </View>
    )
  }
}

export default createFragmentContainer(
  MyProfile,
  graphql`
    fragment MyProfile_me on Me {
      name
      image
      initials
    }
  `
)
```

There are three moving parts:

- The TypeScript interface `MyProfile_me` which ensures we have a correct interface to our props
- The `MyProfile` component, which is a vanilla React component
- The exported `createFragmentContainer` which wraps the `MyProfile` and ties it to a fragment on a `Me` type in
  GraphQL.

## Isolation

The React component `MyProfile` will be passed in props that directly tie to the fragment that was requested. In
Relay terms, this is called data-masking and it is one of the first hurdles for someone new to Relay to [grok][].
In REST clients, and GraphQL API clients like Apollo Client, you make a request and that request is passed through
the React tree. E.g.

{% include epic_img.html url="/images/omakase-relay/tree.png" title="REST inspired props" style="width:100%;" %}

This means most components know more about the request than it probably needs, as it may be needed to pass on to
the component's children. This can lead to data-duplication, or even worse, not knowing if you can delete or
refactor a component.

Data masking solves this by hiding data that the component didn't request. I've still yet to find the right visual
abstraction, but I feel this just about pays for itself.

{% include epic_img.html url="/images/omakase-relay/isolation.png" title="Relay isolation tree" style="width:100%;" %}

You let Relay be responsible for consolidating all your fragments into a query, request it, and (mostly) passing it
through your component hierarchy. This means Relay powered component can be safely changed and drastically reduces
the chance for unintended consequences elsewhere.

This isolation gives Artsy engineers the safety to work on projects with tens of contributors over long time
periods without accruing technical debt. The components we create are nearly all focused only on the data-driven
aspects of rendering a GraphQL response into views.

## Co-location

Relay helped us move to one file representing everything a component needed. Effectively a single file now handles
the styles, the actual view content hierarchy and the exact parts of the API it needs to render itself.

<img src="/images/omakase-relay/co-location.png">

In roughly that proportion too, though our most modern code uses the Artsy design system [Palette][palette] which
drastically reduces the need for style in a Relay component.

Co-location's biggest selling point is simplicity, having everything you need in one place makes it easier to
understand how a component works. This makes code review simpler, and lowers the barrier to understanding the
entire systems at scale.

## Community

When we adopted Relay, there was no competition - we'd have just used the fetch API. Over time, Apollo came up and
really put a considerable amount of effort into lowering the barriers to entry, and making it feasible to build
complex apps easily.

We did an audit last year of what it would take to re-create a lot of the infrastructure we use in Relay atop of
the (much more popular) Apollo GraphQL eco-system and saw it was feasible but would require a considerable amount
of work across many different plugins and tools. With Relay that's all packaged into one tool, works consistently
and obviously doesn't have a scaling problem as Facebook have tens of thousands of Relay components.

It's worth highlighting the core difference in community management for Apollo vs Relay. Engineers working on
Apollo have great incentives to do user support, and improve the tools for the community - that's their businesses
value. Relay on the other hand is used in many places at Facebook, and the engineers on the team support internal
issues first. IMO, this is reasonable, Relay is an opinionated batteries-included framework for building user
interfaces, and ensuring it works with the baffling amount of JavaScript at Facebook is more or less all the team
has time for.

That leaves space for the OSS community to own their own problems.

## Scale Safety

Relay puts a lot of emphasis on ahead of time safety. The Relay compiler validates your queries against your
GraphQL schema, we extended the compiler to create TypeScript types for the composed API fragments and there are
strict naming systems enforced by the compiler. All of these guides engineers to build scalable codebases.

How this works in practice is that whenever you need to change the data a component requires, you edit the
fragment, the Relay compiler verifies your query, if successful then your TypeScript types are updated and you can
use the new property in your React component above. See below for a [quick video][vid] showing the Relay compiler
in action:

{% include epic_video.html url="/images/omakase-relay/relay-process-720.mov" title="Relay isolation tree" style="width:100%; display:block;" %}

## Cultural Fit

Relay fit well into our team because:

- We had engineers who were interested in contributing back and making it work for our cases, this is much less of
  an issue now that Relay has matured and is better documented.
- We had engineers used to using ahead-of-time error validation tools like compilers
- We saw a lot of value in a tightly coupling our view structure to our user interface

It's not without its flaws, but Relay has definitely paid for it's initial and occasional complexity for the
tightness of our codebases many years down the line.

<!-- prettier-ignore-start -->
[profile page]: https://github.com/artsy/emission/blob/892af2621eef455388e074701cca747330de3b3f/src/lib/Scenes/Settings/MyProfile.tsx#L95
<!-- prettier-ignore-end -->

[grok]: https://en.wikipedia.org/wiki/Grok
[palette]: https://github.com/artsy/palette
[vid]: /images/omakase-relay/relay-process-720.mov
[gql-frag]: https://graphql.org/learn/queries/#fragments
[frag]: https://facebook.github.io/relay/docs/en/fragment-container.html
[re]: https://facebook.github.io/relay/docs/en/refetch-container.html
[pag]: https://facebook.github.io/relay/docs/en/pagination-container.html
[query]: https://facebook.github.io/relay/docs/en/query-renderer.html
