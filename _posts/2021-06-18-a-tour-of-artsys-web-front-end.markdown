---
layout: epic
title: "A Tour Of Artsy's Web Front-end in 2021"
date: 2021-06-18
categories: [architecture]
author: steve-hicks
comment_id: 690
---

- history

  - 2018-10-04-artsy-frontend-history
  - 2017-04-14-artsy-technology-stack-2017
  - 2017-02-05-Front-end-JavaScript-at-Artsy-2017

- we have articles that cover individual libraries/tools we use in our web front-end
  - but we don't have a single place that lists them all
  - this article is that.

What happens when you make a request to artsy.net/some-url?

- [express server](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/server.ts#L52)
  - Built with [TypeScript])(https://artsy.github.io/blog/2019/04/05/omakase-typescript/)
  - uses the [found](https://github.com/4Catalyzer/found) router
    - why do we use found???
    - each app defines
      [its own routes & they're aggregated](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/routes.tsx#L35)
- renders a react app server-side
  - https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/Artsy/Router/buildServerApp.tsx#L164
  - [`Boot` is our React wrapper](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/Artsy/Router/Boot.tsx#L39)
    - includes some providers we
      [get from fresnel](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/Utils/Responsive/index.tsx#L16)
      - link to fresnel, explain it
  - once server-rendered content is rendered in the browser,
    [the client app is hydrated](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/client.tsx#L40)
    - [a lot of the same things that happened on the server happen here](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/Artsy/Router/buildClientApp.tsx#L38)
      - including hooking up our `Boot` React wrapper, and our aggregated found routes
- data is queried from metaphysics with relay
  - server-side for most data, but also client-side for some things like lazy-loaded data that appears on scroll.
  - a Relay environment is
    [created in `buildServerApp` and `buildClientApp`](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/Artsy/Router/buildClientApp.tsx#L50)
    and
    [passed into `Boot`](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/Artsy/Router/buildClientApp.tsx#L114)
  - link to article on relay
  - explain what it is
  - noteworthy - we aren't using latest version of relay (the one with hooks)
    - why?
- content is styled with palette
  - our design system; currently v3
  - based on styled-system, based on styled-components
- integration tested with cypress, via integrity

- anything to say about legacy code?
- anything to say about emission/reaction getting absorbed into eigen/force?
- ***

reference: https://artsyproduct.atlassian.net/browse/WP-10
