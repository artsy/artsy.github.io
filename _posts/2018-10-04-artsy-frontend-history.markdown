---
layout: epic
title: "A History of Artsy's Web Frontend"
date: 2018-10-04
author: ash
css: frontend-tech
categories: [react, ezel, javascript, force, architecture, best practices]
series: Omakase
---

As Artsy Engineering grows in 2018, we have so many newcomers looking for context: they want to understand the
systems they'll be working in day-to-day. Awesome! But it's not enough to understand the systems themselves, it's
often helpful to understand the _history_ of how we ended up where we are.

Frontend web development has changed a _lot_ during Artsy's existence, and it continues to advance at a blistering
pace. It's easy to get caught up in the churn of frameworks and languages and tools, so I want to use this post as
an opportunity to contextualize each transition that Artsy's web presence has made over the past seven years. We've
changed technologies, but we've tried to do so with care and attention. Documenting these decisions is important
(and is ideally done [contemporaneously][]), but even with the best documentation, [sometimes our own documentation
is unclear to us][github_convo].

In an effort to help contextualize our web frontend (which is [open source][force]), this blog post will document
the major transitions that Artsy's web presence has made over the past seven years. Let's begin!

<!-- more -->

## Backbone + CoffeeScript

Artsy as you know it today began as a standard Rails application. We ran `git init` in January 2011, which coupled
our backend API to our web frontend, but since our frontend was just a fancy user interface for our API, this
worked for over two years. The web app itself was a kind of simplified MVC – controller logic lived inside the
views and models dealt with backend communication and notifying the view of state changes. For CSS, we used the
SASS CSS preprocessor. The Rails backend served initial pages that were then populated with follow-up API calls
made on the client-side. At a _very_ high level, this isn't _that_ different from what we do today with React.

Our site was built with a framework called [Backbone][], which was really well-suited for our needs at the time.
From their documentation:

> Philosophically, Backbone is an attempt to discover the minimal set of data-structuring (models and collections)
> and user interface (views and URLs) primitives that are generally useful when building web applications with
> JavaScript. In an ecosystem where overarching, decides-everything-for-you frameworks are commonplace, and many
> libraries require your site to be reorganized to suit their look, feel, and default behavior — Backbone should
> continue to be a tool that gives you the _freedom_ to design the full experience of your web application.

As an outsider to the web at that time, I can't comment too heavily on Backbone. It seems like the freedom
(emphasis theirs) that they describe is a freedom from tangled jQuery code everywhere. I think our definition of
freedom on the web frontend has evolved since then, but that's just my feeling.

The other key component to our web frontend was [CoffeeScript][]. According to its documentation, "CoffeeScript is
a little language that compiles into JavaScript", which was pretty important at the time. JavaScript in 2011 was
very different from JavaScript today. The CoffeeScript docs also state that "JavaScript has always had a gorgeous
heart", which I'm not sure I'd agree with to be honest, but the CoffeeScript project really shows how a handful of
engineers working to improve something they care about can change an entire industry. While I don't think
contemporary JavaScript would have gotten as good as it has without CoffeeScript, it's a bit anachronistic to see
it used today.

Our goal as a (very small!) engineering team at the time was to keep our moving parts to a minimum.
Rails+SASS+CoffeeScript+Backbone helped us achieve that goal, and we couldn't have gotten this far without the help
of those projects.

## Ezel & Friends

In November 2013, we split our web frontend from the API backend. You can read
[all the details in this blog post](2013_review), but the story is summarized nicely as "moving from a single
monolithic application to modular Backbone apps that run in Node and the browser and consume our external API."
This move from monolith to modular systems continues to influence day-to-day work on the Artsy Engineering team.

We had already started moving away from a typical Rails app by moving our API to [Grape][] in order to support an
iOS application. The monolith also had some clear drawbacks including severe page load times, maintaining
duplicated backend and frontend UI templates, slow test suites, and poor developer productivity. We took the
project of building our mobile web frontend, m.artsy.net (still known as "martsy" internally) as an opportunity to
address these problems.

We built our new site with [Node.js][node] since it allowed us to share and consolidate our server/client rendering
code. We split out areas of concern into separate "apps", with their own bundled CSS/JS to help page load times. We
server-side rendered above-the-fold content and used client-side JS to load the rest, which helped SEO and user
experience. We took a [BEM][]-like approach to our CSS, which helped developer productivity. Our technical
decisions were driven primarily by our desire to create great user experiences.

And because we are an open source by default organization, we collected these approaches into an open source
project called [Ezel][]. While our main app used this Ezel approach, other new web apps – CMS systems for our
partners, auction-management systems for our admins, etc – were built on new internal tools to share assets and
code across the apps. We experimented a lot; we got pretty good at sharing resources across codebases. Most of our
web projects started on Heroku before moving to heavier-duty deployments as needed. Our frontend mindset at the
time (2015) was focused on getting to a stable, predictable stack. However... we started experimenting with React
around the same time.

CoffeeScript and Backbone were still working for us, and we still use them in production in many systems. However,
the state of the art in web development moved on. When I joined the auctions team and helped maintain one of our
CoffeeScript+Backbone apps, I was _very_ confused about how data flowed from one part of the app to another, across
languages, with a lot of magic happening. I think that's typical in these kinds of apps – "convention over
configuration" is a good mantra _if_ you can expect that incoming engineers are familiar with the conventions.
That's just not the case anymore.

By 2016, we had [experimented with React][helix] and followed up with [another app built with the
technology][auctions]. React (and Redux) were very well-suited for our realtime auction bidding UI, and would later
prove helpful in our [editorial CMS][positron]. These experiences helped prove the technology was ready for
production use _and_ convinced us that React was great at reducing the complexities of building user interfaces
(the realtime nature of our auctions product was particularly well-suited for Redux's state management; it was our
first from-scratch React app).

When the Artsy business require us to make changes to how we build software, like splitting up our monolith, we try
to take full advantage of those changes to improve how we work, which means evaluating new tools. Adopting Node.js
and Ezel wouldn't make sense today, but at the time, they helped us scale up Artsy's business without the same
scaling up of our engineering resources. Ezel helped us do more with less, which is still an important criteria we
use for evaluating new tools.

## React

By 2017, the divisions between our mobile frontend and web frontend teams had been totally dissolved (as they
should – the division between mobile and web developers is a false dichotomy). Our [2017 tech stack
post][2017_review] discusses this in depth, but our goal was really to unify the paradigm that frontend engineers
at Artsy use to build user interfaces, whether that's on mobile or web. React and React Native were our answer to
that challenge.

On the web side of things, however, Artsy had another challenge. Sure, React is great, and sure, it's how we want
to build user interfaces, but how do we get there? We're not fans of large rewriting projects, so we opted for what
we call an "incremental revolution" approach. We built a library called [Stitch][] that would let us mount React
components inside our existing app. Using this approach, we could migrate to React component-by-component. We've
been using Stitch in production for over a year and have been very happy with its approach; you can read more
details of integrating it into our main frontend app [in this blog post][force_modern].

Today, principal React work takes place in [a shared components repo][reaction]. We share these components across
several of our web apps using Stitch. We have been pretty pleased with the results! But our dive into React is only
just beginning. The community is moving quickly to figure out what best practices make sense in the React paradigm,
and we're a part of that. We are evaluating technologies like [styled-components][] and [styled-system][] to create
a universal design system within Artsy. The area is under very active development, so I'll save details for a
future blog post.

I can't go too much further without talking about GraphQL. v1 of our API (REST) is still in use around much of
Artsy and, despite the best efforts of some of our engineers, v2 of our API ([HAL][]) hasn't gained significant
internal use yet. Instead, we found ourselves building a [GraphQL][] server to orchestrate API calls to our
existing APIs. This confers many benefits, which I describe from a mobile perspective in some detail [here][moya].
The key thing to understand about our GraphQL server, [which is open source][metaphysics], is that it is under the
stewardship of our frontend engineers, not our platform engineers. That's not to say that our platform team isn't
involved with its development – in fact, they've been key to scaling it up – but Artsy frontend engineers created
the server to help us build better UIs, and while the technology is still very new, we continue to see it pay
dividends.

Okay so remember earlier when I said that we dissolved our mobile team? Well, I was on that team and it wasn't like
our mobile engineers all learned how Artsy does web – we brought our culture and tools with us and, together with
our web colleagues, have built an integrated engineering team that's greater than the sum of its parts. One thing
that was important to mobile engineers was type safety, so we had to have a conversation about JavaScript.

On its own, JavaScript can't guarantee type safety. We investigated two options: [TypeScript][] and [Flow][]. [This
blog post][fe_js] goes into detail about our decision, but tl;dr we chose TypeScript. We have been building (and
helping to build) tools [relay-compiler-language-typescript][rclt] to take full advantage of interoperability
between TypeScript types and GraphQL types through [Relay][], as well as using Babel 7 to migrate existing projects
to TypeScript incrementally, which you can read about in more detail [here][ts_inc]. It's all very exciting – you
can read more on how Relay and GraphQL interoperate [in this blog post][relay_post].

We started building software in React not because it was trendy, but because it helped our engineering team deliver
more value to the business. It's been a huge success, but not without its costs. We've tried to mitigate those
costs by using tools like Stitch to migrate apps to React incrementally, and through spreading knowledge of how our
stack through internal knowledge-sharing like [JavaScriptures][]. While the transition to React has had its costs,
_not_ moving would also be costly, too.

---

Since I joined Artsy, I've seen us continually investing in tooling that helps us build better software. The
results of this culture-of-continuous-improvement speak for themselves: with fewer than 30 engineers total, we
support a growing company with a suite of software built for many canvasses _and_ we have an outsized impact on the
software industry relative to our size. Our frontend web stack is just one facet of our evolving technology –
there's lots of exciting stuff on the backend, too ([for example...][hokusai]). Through my research for this blog
post, I learned a lot about what drives technological decisions on our team. From humble beginnings as a Rails app,
to CoffeeScript and Bootstrap, to React and GraphQL, Artsy Engineering has evolved our frontend software to achieve
a quality worthy of art – both from the user's perspective and from the developer's. I'm very excited about what's
coming next, and I can't wait to share it with you. Have a great day!

[force]: https://github.com/artsy/force
[contemporaneously]: https://ashfurrow.com/blog/contemporaneous-blogging/
[github_convo]: https://github.com/artsy/artsy.github.io/pull/489#discussion_r221301472
[backbone]: http://backbonejs.org
[coffeescript]: https://coffeescript.org
[grape]: https://github.com/ruby-grape/grape
[node]: https://github.com/ruby-grape/grape
[bem]: http://getbem.com/introduction/
[ezel]: https://github.com/artsy/ezel
[2013_review]: http://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/
[2017_review]: http://artsy.github.io/blog/2017/04/14/artsy-technology-stack-2017/
[auctions]: http://artsy.github.io/blog/2016/08/09/the-tech-behind-live-auction-integration/
[stitch]: https://github.com/artsy/stitch
[force_modern]: http://artsy.github.io/blog/2017/09/05/Modernizing-Force/
[typescript]: http://www.typescriptlang.org
[flow]: https://flow.org
[fe_js]: http://artsy.github.io/blog/2017/02/05/Front-end-JavaScript-at-Artsy-2017/
[rclt]: https://github.com/relay-tools/relay-compiler-language-typescript
[reaction]: https://github.com/artsy/reaction
[styled-components]: https://www.styled-components.com
[styled-system]: https://jxnblk.com/styled-system/
[relay]: https://facebook.github.io/relay/
[hal]: http://stateless.co/hal_specification.html
[graphql]: https://graphql.org
[moya]: https://ashfurrow.com/blog/the-spirit-of-moya/
[metaphysics]: https://github.com/artsy/metaphysics/
[relay_post]: http://artsy.github.io/blog/2018/07/25/Relay-Networking-Deep-Dive/
[hokusai]: https://github.com/artsy/hokusai
[ts_inc]: https://artsy.github.io/blog/2017/11/27/Babel-7-and-TypeScript/
[helix]: http://artsy.github.io/blog/2015/04/08/creating-a-dynamic-single-page-app-for-our-genome-team-using-react/
[positron]: https://github.com/artsy/positron
[javascriptures]: http://artsy.github.io/series/javascriptures/
