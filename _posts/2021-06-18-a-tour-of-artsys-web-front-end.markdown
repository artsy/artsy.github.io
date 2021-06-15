---
layout: epic
title: "A Tour Of Artsy's Web Front-end in 2021"
date: 2021-06-18
categories: [architecture]
author: steve-hicks
comment_id: 690
---

It's been a few years since we comprehensively described our tech stack for artsy.net. A few years ago we wrote [a
flurry][2017-02-article] of [articles][2017-04-article] about [our tech stack][2018-10-article]. Since then we've
written the occasional article about modifications to the stack.

And it's not that our stack has stabilized. We're constantly iterating on it, always seeking that ideal balance of
performance and developer experience. We've just not given you a comprehensive summary of the full stack in a
while.

To answer the question "what _is_ Artsy's current web tech stack," let's follow the bits as they flow from your
computer to our server and back. What happens when you make a request to artsy.net/some-url?

## Express Server

The first stop: an [Express][express]
[server](https://github.com/artsy/force/blob/89ce00df9816e892f456e6885fab17c9ab539235/src/v2/server.ts#L52) built
with [Typescript](https://artsy.github.io/blog/2019/04/05/omakase-typescript/). Many (most?) of Artsy's services
are built with Rails, but [Force](https://github.com/artsy/force), our web app, is one of the few built on NodeJS.

Force uses the [`found`](https://github.com/4Catalyzer/found) router to render a React app from the server. We have
[many child apps](https://github.com/artsy/force/tree/a52a4998ff59daeaae1619a0388314cd9a8376df/src/v2/Apps) within
Force. Each app defines its own routes, and
[they're all aggregated together](https://github.com/artsy/force/blob/0c1b86322a7056ee952703abc08d9d399a05fb32/src/v2/routes.tsx)
to route your request to the corresponding app.

---

- history

  - 2019-04-10-omakase-relay

- we have articles that cover individual libraries/tools we use in our web front-end
  - but we don't have a single place that lists them all
  - this article is that.

What happens when you make a request to artsy.net/some-url?

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

- headers per system/technology
  - palette
  - react
  - relay
  - express
  - fresnel

[2017-02-article]: http://artsy.github.io/blog/2017/02/05/Front-end-JavaScript-at-Artsy-2017
[2017-04-article]: http://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017
[2018-10-article]: http://artsy.github.io/blog/2018/10/04/artsy-frontend-history
[express]: https://expressjs.com/
[typescript-article]: https://artsy.github.io/blog/2019/04/05/omakase-typescript/
