---
layout: epic
title: "Server-Rendering A Responsive Artsy.Net"
date: "2019-04-22"
author: [steve-hicks, eloy]
categories: [react, html, web]
---

At Artsy, we use server-side rendering (SSR) to deliver every page you hit on [artsy.net](https://artsy.net). We
decided on using SSR for many reasons, amongst them performance. (TODO: Maybe more about why we chose SSR, but I
don't know much about that history.)

(TODO: Maybe a bit more about SSR & `hydrate`, or just link to those docs.)

One challenge we've run into with SSR is rendering markup and styles from the server that the browser doesn't have
to throw away. When your browser finishes loading our JavaScript & hydrates our React app, our app suddenly has
more information about your browser dimensions than we had in the server request. React will go through the
reconciliation process with this new information, to determine which DOM elements need to be updated. If there are
significant differences between the markup our server gave you and the component tree our React app is now
rendering, there's noticeable churn in the DOM.

We'd like our app to churn as little as possible during hydration. We've taken several steps (and mis-steps) toward
accomplishing this goal: how can we emit _usable_ responsive markup from the server, so that the browser doesn't
have to throw everything away when the browser dimensions become known?

To help us solve this problem, we've released
[@artsy/react-responsive-media](https://github.com/artsy/react-responsive-media). This is the story of how
@artsy/react-responsive-media came about.

<!-- more -->

## Iteration 1: Render props and a disposable component tree

Our initial attempt to emit responsive content from the server is what prompted us to dig deeper into this problem.
We started with a `<Responsive>` component that used
[a "render props"/"function as a child" pattern](https://reactjs.org/docs/render-props.html#using-props-other-than-render),
and allowed you to return different JSX based on the current breakpoint. In practice, it looked something like
this:

```
<Responsive>
  {({ xs }) => {
    if (xs) {
      return <Box width={1} />
    } else {
      return <Box width={2} />
    }
  }}
</Responsive>
```

The argument to the child function contained a flag for each of the breakpoints our app supports. In the example
above, we're rendering a `<Box>` with a width of `1` if the screen matches our `xs` breakpoint; otherwise, we're
rendering a `<Box>` with a width of `2`.

Our biggest problem with this API was that on the server, we don't know which breakpoint you're at. We had to
default to something, so we assumed that if we didn't know which breakpoint you wanted, we would give you the
`xs`/"extra small" one. But if you were browsing with a desktop, the first client-side render will completely throw
away what the server gave you. In the example above, that's probably not that big a deal, but our `<Responsive>`
elements tended to contain large sub-trees of components. This is a big deal, and this is the DOM churn we really
want to avoid.

In addition, this API was imperative. Sprinkling our app with lots of `if/else/else` statements degraded
readability, and it just generally felt against the spirit of building a declarative React app. We also avoid the
render props pattern when possible because we find it less readable.

## Iteration 2: A declarative API that renders all branches

Our biggest concern from attempt 1 was the fact that we were potentially literally throwing away the entire
sub-tree on hydration.
[We started our next iteration from scratch](https://github.com/artsy/reaction/issues/1367#issuecomment-428954599]),
and came to an API that looked this:

```
<>
  <Media at="xs">
    <Box width={1} />
  </Media>
  <Media greaterThan="xs">
    <Box width={2} />
  </Media>
</>
```

We're using a `<Media>` component to wrap each sub-tree, and specifying the breakpoint at which each applies.

The first thing to point out about this API is that it's declarative in nature. Right off the bat it felt more
readable.

We were also able to do things differently behind the scenes. We could emit _all_ of the rendered breakpoint
sub-trees from the server. We couldn't do that in iteration 1, because the imperative branches required only one
sub-tree to be returned. The advantage of emitting all breakpoints from the server is that we could use
plain-old-CSS (via JS :) ) to show and hide component sub-trees based on `@media` queries. React wouldn't have to
throw away any sub-trees when the app hydrates - the unused ones are still there in the DOM; just hidden with CSS.

This meant less DOM-churn on hydration, 🎉!

But there was no celebration 😢. Rendering all sub-trees, even the ones that were hidden by CSS,
[raised some red flags](https://github.com/artsy/reaction/issues/1367#issuecomment-428743160).

These types of components lend themselves to large sub-trees. They're usually used to lay out a mobile page
slightly differently than a desktop page. If we were rendering all breakpoints, we could be rendering a lot of
nearly-identical-but-slightly-different sub-trees. This is definitely less than ideal from a performance
perspective. It's _especially_ a problem for duplicated components that perform side-effects when mounting. If two
versions of a component are in the DOM, and both perform the same side-effect when mounting, that can be a problem.
For example, if we have a component that emits a page-view event to our analytics service, and it gets rendered in
both the mobile and desktop sub-trees, we're suddenly double-stuffing our page-views.

## Iteration 3: Emit all breakpoints from the server, but only the matching breakpoint after rehydration

Our API didn't change in this iteration, but we wanted to be smarter about how we rendered unnecessary breakpoints.
Once the app is hydrated in your browser, we know your browser dimensions. At this stage, we can opt to not render
any breakpoints that aren't needed. So while we were still rendering all breakpoints from the server, your browser
was rendering only the subtree that made sense for your viewport. Performance gains!

## Iteration 4: Sniff your user-agent, and only render the matching breakpoint for your device....when possible

While we initially wanted to avoid sniffing browser user-agents, and we definitely didn't want to maintain our own
list of user-agents, we couldn't pass up the opportunity for more performance optimization. We have analytics about
our users, and we know the browsers & devices we need to support. If we recognize your device, why not skip the
non-mobile breakpoint when rendering from the server?

We investigated existing user-agent detection libraries, but the ones we found didn't have the right data for us.
We needed to know the minimum width for a browser on a given device, and if it was resizable, and to what
dimensions it was resizable. If they _did_ have this data, they didn't provide it to us easily.

So we did some experimentation, given the browsers & devices we knew we needed to support. And yeah...we
(reluctantly) created our own user-agent detection library,
[@artsy/detect-responsive-traits](https://github.com/artsy/detect-responsive-traits). This data is very specific to
the browsers & devices we support on [artsy.net](artsy.net), but it's the data we need to optimize our responsive
rendering. We're using it to determine if your browser is likely going to use only the mobile breakpoint of our
app, in which case we don't have to also server-render the desktop version.

TODO: is this sniffing part of react-responsive-media, or is it separate? I should find this out and make it clear.

## The current state of @artsy/react-responsive-media

With this, we now have:

- TODO: list the features out.

We're pretty happy with this, and we have generally good feelings about where it's at. We're proud of the fact that
our approach works well for SSR, even in cases where you're doing _only_ SSR.

## `styled-system`

One other major factor in our approach to a responsive [artsy.net](artsy.net) is the
[`styled-system`](https://styled-system.com/) project. We started using it around the same time we started building
@artsy/react-responsive-media, and it has been incredibly helpful. While @artsy/react-responsive-media is great for
rendering large sub-trees based on a matching breakpoint, `styled-system` is really great for styling individual
components based on a matching breakpoint. For example, here's a component that would render a `div` (`Box`) with a
width of 50% at our mobile breakpoint, and 100% for anything larger:

```
<Box width={["50%", "100%"]}>...</Box>
```

It's pretty amazing. `styled-system` allows us to use the same components at different breakpoints, but style them
differently at each breakpoint. Without it, we were seeing _a lot_ of duplicated components via
@artsy/react-responsive-media. With `styled-system`, we're finding that we use @artsy/react-responsive-media to
occasionally handle significant layout differences across breakpoints, but `styled-system` more frequently for
subtle styling differences across breakpoints.

TODO: Have we already blogged about styled-system? I feel like we might have, and I should find out & link to that
article.

## Things we haven't solved

As you might expect, there are still some problems we're trying to solve. Software is always a work-in-progress,
amiright?

### SEO

TODO: clean up these notes

- duplicate headings are likely fine (link to webmaster video)

- But also, we're truncating data for the "mobile" breakpoints, and this might be affecting what gets crawled by
  Google

- [https://artsyproduct.atlassian.net/browse/PURCHASE-973](https://artsyproduct.atlassian.net/browse/PURCHASE-973)

- But then, who really knows, because SEO is magic.

### Accessibility

TODO: clean up these notes

- Modern screenreaders are also parsing semantics (html5/sections), but older screenreaders are not.

- We are still making progress here, including adding the ability to specify element for typography in our design
  system, to increase the semantic meaning of our markup.

- Media emits a div, so we have to consider in sizing our components inside of a Media element

## Conclusion

TODO: Figure out some really smart thing to say here, or ask someone really smart to think of something really
smart to say.
