---
layout: epic
title: "Two years of Next.js at Artsy: A Retrospective"
subtitle: "(On Love and Second Thoughts)"
date: 2024-03-07
categories: [Next.js, React]
author: [chris]
---

Where to begin! Where to begin...

Lets start with a good measure of success, one that I think most engineers could
agree on: a from-scratch rebuild of a complex, internal tools app. Success with
rebuilds is often fleeting, as many can attest. There's risk involved. Extending
the challenge further, lets assign (most) of the task to a team of platform
engineers who aren't too familiar with modern front-end technology -- and then
say that we succeeded.

Is Artsy crazy? Or is Next.js (along with our team 🙂) just that good? Well,
it's a little of both. And it's a little bittersweet, in a way. Here's our tale.

<!-- more -->

### Beginnings

Our first formal use of Next came from a project spun up during Hackathon, two
years ago. Hackathon's are great opportunities to push technology forward, and
Artsy has had a lot of success with them. We'd been talking about Next.js for a
while, and experimenting here and there, but we were never able to find the
proper intersection of product and purpose to take things further. With this in
mind, one of our Engineers (Roop 👋) spun up a Next.js POC that allowed us to
deduplicate artist records. On the surface, the effort was non-trivial. It
involved authentication, DB communication, and more. Yet when presented during
Hackathon, all of this was done and it also looked _beautiful_.

How could so much product work get completed in such a short period of time? A
large part of that is due to Next.js's framework design, and how it simply gets
out of the way and allows one to start building product features. The defaults
made sense; to create a new route, simply create a new folder or file in the
`pages` directory, and Next takes care of the rest. And what about compilation,
TypeScript, linting, and all of the other extraordinarily confusing JavaScript
toolchain details that folks typically struggle over? (Most) of the setup was
taken care of at the framework level, and the API side of things was light and
easy to understand, thanks to great documentation.

There are omitted details of course, and there were things we needed to figure
out (such as auth, via `next-auth`, and passing runtime ENV secrets to our
Dockerized container), but in any case this gave us a lot of confidence to start
discussing what it might take to seriously consider rebuilding our internal
tools app. A few meetings later it was decided, and our platform team agreed to
take it (with loose backup support from a couple other engineers). And a few
short month's later much of the core functionality was complete, executed by a
team working amidst unfamiliar terrain.

That's the definition of success, and the measure. With our internal tools app
complete it was natural to start looking around for other opportunities -- but
first, a quick detour.

### Enter: Next 13 (aka, The `app` Router)

Many of the limitations of Next 12 are well known, with the most notable ones
being the inability to (naturally) do page layouts along with quirks around
`getServerSideProps` and `_app` and `_document` request fetching not being as
flexible as one would like. These issues, however, were not _deal-breakers_; and
in fact, we hardly even noticed them. Our page layouts simply rendered a shared
`<Layout>` component that accepted `children`; and per-route data fetching
requested data per-route, with globally shared data going in `_app`. It got the
job done.

With these things in mind (and a few things more), many of us were extremely
excited when Next released its
[Layouts RFC](https://nextjs.org/blog/layouts-rfc), outlining the _next_ version
of Next.js, which would be built on top of another long-anticipated React.js
feature,
[React Server Components](https://legacy.reactjs.org/blog/2020/12/21/data-fetching-with-react-server-components.html).

In short, the Layouts RFC outlined what looked to be a beautifully obvious, yet
performant architecture. Using Next's preference for file-system based
configuration, a typical "page" could soon look like this:

```
- app/
---- layout.tsx
---- page.tsx
- app/artist
---- layout.tsx
---- page.tsx
---- middleware.tsx
```

And so on. "Global" SSR data could be fetched right there in `layout` or `page`
and shared with its subtree; and likewise, for sub-sub-tree's we could do the
same in each individual app `layout` or `page` component.

Additionally, with React Server Components, we would no longer need to use many
Next.js-specific APIs. To fetch data on the server, you simply `await` a promise
and pass it right to your component as props. Next's already minimal API
footprint would diminish even further, and it became possible to glean a vision
of "just vanilla JS" all the way down, and within that vision the possibility of
true simplicity.

Little did we know, it wouldn't take much to turn this beautiful vision into
something of a dilemma, but that part of the story comes a bit later.

### Expanding Next.js at Artsy

Coming off of our success with the internal tools app rebuild, we wanted more.
And we didn't need to look far: right around the corner was a ~10 year old
external CMS app that our partners use to manage their inventory.

We decided the path forward was Next, and like our internal tools app rebuild,
for the most part it has been a success. We again went with the `pages` router
(as the new `app` router wasn't yet released) and so far there's been minimal
confusion from the team. And buisness-wise, its been refreshing to defer
framework design decisions, lib upgrades and more to Next, versus having to
maintain [all of these things in-house](https://github.com/artsy/force).

It's also worth mentioning that there _have_ been a few significant challenges
involved (such as setting up performant SSR patterns for using Relay, our
GraphQL client -- thats another blog post), but on the whole Next has served our
needs well. Team performance was unlocked, and we've been able to quickly get to
building and rebuilding CMS pages in this new application. And our engineers
have loved working in it.

### Back to Next 13

In the meantime, Next 13 was released. Imagine our excitement! Just as this new
app is spinning up we receive a little gift from the stars. Carlos and I are the
first ones to bite; lets see what migrating our work over to the new framework
might look like, what kind of effort.

From the start, it was immediately obvious that the Next.js team released an
alpha-quality (or less) product, marked as `stable`. Not a `beta`, not an `RC`
to peruse and experiment with, but rather an

```bash
npm install next
```

package that comes with an application scaffold generator that suggests using
the `app` router over `pages` -- marked as _"Recommended"_. In other words,
highly polished. And what's the first thing one experiences?
[Hot Reloading is broken](https://www.google.com/search?q=next+13+hot+reloading+broken+site:github.com&sca_esv=b6c25dbec4ffd71b&sa=X&ved=2ahUKEwjlmtTR_eKEAxW4CjQIHTqPAJYQrQIoBHoECBgQBQ&biw=1512&bih=829&dpr=2#ip=1).

And what's the next thing? Styles are broken. It turns out that RSC (React
Server Components) doesn't fully support pre-existing CSS-in-JS patterns. Or
rather,
[they do, kind of](https://nextjs.org/docs/app/building-your-application/styling/css-in-js#styled-components),
but they can only be used inside `use client` components (which, in Next.js,
actually means a server-side rendered component environment that's _separate
from_ a RSC rendered "server-only" environment -- aka the old pages router
model). And we certainly weren't about to throw out our Design System component
library [Palette](https://github.com/artsy/palette), which has been nothing but
a runaway success (and a
[highly portable one](https://github.com/artsy/palette-mobile) at that).

With this limitation, our ability to use React Server Components had been
severely hampered. Excluding the root-most level of our component tree, we were
now required to prepend `use client` on the top of every component, lest we
receive ambiguous errors about rendering a client component (which used to be
server-side render safe) on the "RSC server".

Things can be taught, however. So lets proceed from the assumption that through
some kind of tooling / linting layer, `use client` is added to every new
component. It _should_ behave at that point just like the old Next and now we
get the best of both worlds. Nope: turns out that even with the CSS-in-JS setup
instructions described in the the next docs above, we still run into issues.
There are bugs.

(These are the two main red flags, but there are many others as well.)

At this point, we wisely back out. It's only `next@13.0.0`, and what they're
doing here is to a certain extent revolutionary. It's a new way of thinking
about React, yet an old way of thinking about page rendering. It's like... PHP,
or so they say. RSC is _interesting_, there's something to it. Lets give them
the benefit of the doubt and return to things in a few months, after a few
`minor` version bumps; there are, after all, countless eyes on the project.

### Many Months Later

We run `npx create-next-app@latest` (this is around the time they release
`13.4`) and then add these two components inside the newly-created vanilla
project:

```tsx
// app/HelloClient.tsx
'use client'

export const HelloClient = () => {
  return <div>Does this hot reload</div>
}

// app/layout.tsx
import { HelloClient } from './HelloClient'

export default Layout() {
  return <HelloClient />
}
```

Everything renders. And then

```tsx
export const HelloClient = () => {
  return <div>Does this hot reload... nope :(</div>
}
```

In the most basic project setup, the most obvious Next.js selling point --
Developer Experience -- failed to deliver. Vercel is really forcing us to
question things. But we're flexible, and we like to investigate at Artsy, so
even though this definitely-required feature doesn't quite work, maybe it will
once we're done with our migration spike, and maybe we can still take advantage
of everything else that RSC has to offer.

So again, we start refactoring the project. Stuff from the `pages` directory
starts getting copied over to `app`. We update configuration. We setup styling
(it seems to work better). Things are _almost_ there. But then the obscure
framework errors start to arrive, and CSS still doesn't quite work: it turns out
that refactoring across RSC-`use client` boundaries is harder than one thought.
I.e., if any piece of "client" (remember, 'use client' actually means SSR-safe)
code _anywhere in the dependency tree_ happens to intersect an RSC boundary, the
whole thing will fail. And this includes any use of React's `createContext` --
because React Contexts aren't supported. Given an app of any reasonable size,
you're likely to rely on a context somewhere, as contexts are so critical within
the react hooks model of behavior. Said contexts might come from within your
app, and if not there they'll certainly come from a 3rd party library.

One would expect the errors to be helpful in tracking this down -- Next.js is
all about DX -- but no. Confusion reigns.

We're experts though, and we eventually _do_ find the source of the violation,
and we make sure to create a "safety wrapper" around the offender so that it
doesn't happen again. But it does happens again -- and again, any time any piece
of any complexity is added in the new RSC-intersected route. It's rather
unavoidable. And each time solvable, but at a great cost to the developer.
Thankfully we know what we're doing!

Another trivial yet annoying issue (thankfully fixed with some custom eslint
config) is accidentally importing the `useRouter` hook from the `app` router
location, or `redirect`, or any number of other new `app` router features,
because all of these things don't work in `pages`, and will error out. The
errors here are slightly less opaque, but what if you're a backend dev who knows
nothing about any of this? Googling "useRouter next" now yields two sets of
docs. Figure it out.

<div style="text-align: center;">
  <img src="https://miro.medium.com/v2/resize:fit:1400/0*Sce5egkhwWpCeqF0.jpg" width="600" />
</div>

At this point, we make a judgement call: this simply isn't going to work at
Artsy. We're here to empower folks and unlock productivity. Remember the team of
DevOps engineers on Platform who rebuilt a CMS in record time? In the new Next
13 model, that would be unfathomable, impossible even. Paper cuts would kill
motivation, and dishearten the already skeptical. And the front end already has
a bad rap, for good reason: historically, everything that seems like it should
be easy is hard and confusing for those who aren't experts. And everything is
always changing. And the tooling is always breaking. And everybody always has a
bright new idea, one that will finally end this madness for good.

A certain amount of sadness is appropriate here, because Next's `pages` router
was very, very close to being the silver bullet for web applications that we've
all been looking for. Even though the `pages` router has its flaws, it showed us
that it's possible to get something out the door very quickly with little prior
knowledge of Front End development. This is no small thing. Next 13's fatal
error is that its destiny, being coupled to RSC, now requires experts. And by
'expert' I mean: those with many years of experience dealing with JavaScript's
whims, its complex eco-system, its changeover, as well as its problems. In
short, folks who have become numb to it all. This is no way to work.
[Thankfully the community is finally responding](https://www.reddit.com/r/nextjs/comments/1abd6wm/hitler_tried_rsc_and_next_14/).

### A Quick Note on Performance

It's worth remembering that Next 12 was industry-leading in terms of performance
and pioneered many innovative solutions. Let me say it again: Next's pages
router IS fast. Next 13 combined with RSC _is_ faster, but at what point does an
obsession with performance start negating other crucial factors? What's good for
the 90%? And what's required for the other 10%? Most companies just need
something that's fast enough -- and easy enough -- to _move_ fast. And not much
more.

### Back At Artsy...

With all of this in mind, and with the uncertainty around long-term support for
Next.js `pages` (amongst other things), we recently decided to hit pause on
future development in our new external CMS app rebuild. Weighing a few different
factors (many entirely unrelated to Next), including a team reorg that allowed
us to look more closely (and fix) the DX in our old external CMS app, we took a
step back and recognized that our needs are actually quite minimal:

- Instant hot reloading
- Fast, SPA-like UX performance
- Simple, convention-based file organization

With these things covered, the "web framework" layer looks something like the
following, minus a few underlying router lib details:

```tsx

const Router = createRouter({
  history: 'browser',
  routes: [
    {
      path: '/foo',
      getComponent: React.lazy(() => import('./Foo'));
    },
    {
      path: '/bar',
      getComponent: React.lazy(() => import('./Bar'));
    }
  ]
})
```

We're now required to manage our compiler config, but
[that layer](https://github.com/shakacode/shakapacker) isn't too complicated
once its setup, and it works great. (If you're using something like `Vite`, it
could be even simpler.)

### Final Thoughts

Next 13 and React Server Components are very intriguing; it's a new model of
thinking that folks are still trying to work out. Like other revolutionary
technologies released by Meta, sometimes it takes a few years to catch on, and
maybe RSC is firmly in that bucket. Vercel, however, would do well to remember
Next's original fundamental insight -- that all good things follow from
developer experience. Improvements there tend to improve things everywhere.

In addition to fixing some of the obvious rough edges in the new `app` router,
it would be helpful if Next could provide an official response to
[the question of long-term Pages support](https://github.com/vercel/next.js/discussions/56655).
There's been quite a backlash in the community against Next 13, and that should
give all developers pause. It'd also be great to get word on whether there will
be any further development on the pages router -- perhaps some of the features
from the new `app` router can be migrated to `pages` as well? -- or if the pages
router is officially deprecated and locked. All of this is currently ambiguous.

Another area where Next could improve is their willingness to ship buggy
features, and to rely on patched versions of React in order to achieve certain
ends. Even though Vercel employs many members of the React Core team, by
releasing Next versions that rely on patched and augmented `canary` builds of
React, Vercel is effectively compromising some of React's integrity, and forcing
their hand. Once a neo-React feature is added to Next, it makes it hard to say
no; Next has captured too much of the market-share.

All of this calls for sobriety and hesitation on the part of developers working
with -- and building companies on top of -- Vercel's products. Next is Open
Source, yes, but it's also a wildcard. Artsy has had some real success with
Next, but sometimes that's just not enough to avoid hitting pause, and looking
at the bigger picture. Inclusivity should always win.
