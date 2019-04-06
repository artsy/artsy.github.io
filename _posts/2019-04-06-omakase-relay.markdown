---
layout: epic
title: "Why does Artsy use Relay?"
date: "2019-04-06"
author: [orta]
categories: [community, omakase, relay]
---

When the mobile team at Artsy considered moving to React Native back in 2014, one of the most compelling cases for
making that jump was Relay. This, it seems, is a dependency that is rarely used in the JS community and we often
find ourselves defending this decision to new engineers during onboarding. It's great to [..]

Let's have a deep dive into what makes Relay compelling for Artsy Engineering.

<!-- more -->

# What problem does Relay solve?

Relay is an API client for GraphQL, it comes in two parts: a compiler and a set of front-end components. Relay aims
to provide a really tight binding between your GraphQL API and your view hierarchy. When you build data-driven
apps, Relay removes a whole suite of non-business logic from your application.

Relay handles:

- Data binding (API -> props)
- Data transformations (response shaping)
- Cache management (invalidation, updates etc)
- Consistent bi-directional pagination abstractions
- Multiple query consolidation (e.g. consolidate all API requests to one request)
- Declarative data mutation (describe how data should change, instead of doing it)
- UI best practices baked in (optimistic response rendering, cheap rollbacks)
- AOT query generation (allowing you to persist queries)

By taking the responsibilities of the grunt work for most complex apps and moving it into Relay you get
Facebook-scale best-practices and can build on top of that.

# How does it work?

You write a set of Relay components, you always start with a `QueryRenderer` then use a tree of either
`FragmentContainer`, `RefetchContainer` or `PaginationController`s. You mostly use `FragmentContainer`s.

The `FragmentContainer` is based on a GraphQL fragment. If you've never used a fragment, they are an abstraction
that lets you declare shared fields on a specific GraphQL type to reduce duplication up your queries. For example:

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
you have a rough glimpse at what a GraphQL fragment is, let's look at what a `FragmentContainer` looks like. Here's
a simplified [profile page][] from the Artsy iOS app:

```ts
import React from "react"
import { createFragmentContainer, graphql } from "react-relay"
import { MyProfile_me } from "__generated__/MyProfile_me.graphql"

// [...]

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

- The `MyProfile` component, which is a vanilla React component
- The exported `createFragmentContainer` which wraps the `MyProfile` and ties it to a fragment on a `Me` type in
  GraphQL.
- The TypeScript interface `MyProfile_me` which ensures we have a correct interface to our props

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
periods without too much technical debt. The components we create are nearly all focused only on the data-driven
aspects of rendering a GraphQL response into views.

## Co-location

Relay helped us move to one file representing everything a component needed. Effectively a single file now handles
the styles, the actual view content hierarchy and the exact parts of the API it needs to render itself.

<img src="/images/omakase-relay/co-location.png">

In roughly that proportion too, though our most modern code uses the Artsy design system [Palette][palette] which
drastically reduces the need for styling.

## Community

When we adopted Relay, there was no competition - we'd have just used the fetch API. Over time, Apollo came up and
really put a considerable amount of effort into lowering the barriers to entry, and making it feasible to build
complex apps easily.

We did an audit last year of what it would take to re-create a lot of the infrastructure we use in Relay atop of
the (much more popular) Apollo GraphQL eco-system and saw it was feasible but would require a considerable amount
of work across many different plugins and tools. With Relay that's all packaged into one tool, works consistently
and obviously doesn't have a scaling problem as Facebook have tens of thousands of Relay components.

## Scale Safety

Relay puts a lot of emphasis on ahead of time safety. The Relay compiler validates your queries against your
GraphQL schema, we extended the compiler to create TypeScript types for the composed API fragments and there are
strict naming systems enforced by the compiler. All of these guides engineers to build scalable codebases.

<!-- prettier-ignore-start -->
[profile_page]: https://github.com/artsy/emission/blob/892af2621eef455388e074701cca747330de3b3f/src/lib/Scenes/Settings/MyProfile.tsx#L95
<!-- prettier-ignore-end -->

[grok]: https://en.wikipedia.org/wiki/Grok
[palette]: https://github.com/artsy/palette
