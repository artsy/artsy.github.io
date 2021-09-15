---
layout: epic
title: "Server-Rendering Responsively"
date: "2019-05-24"
author: [steve-hicks, eloy, chris, justin]
categories: [react, html, web]
comment_id: 577
---

We use server-side rendering (SSR) to deliver every page you hit on [artsy.net](https://artsy.net). We decided on
using SSR for many reasons, amongst them performance.
[We wrote about this all the way back in 2013](https://artsy.github.io/blog/2013/11/30/rendering-on-the-server-and-client-in-node-dot-js/)!

We've also built our site using responsive design, so you get a browsing experience optimized for your device.

Combining SSR and responsive design is a non-trivial problem. There are many concerns to manage, and they are
sometimes in conflict with each other. We server render for performance reasons, but we also want to be sure our
app is performant when your browser takes over, all while optimizing for accessibility and SEO.

This article describes the tools we use on [artsy.net](https://artsy.net) to combine SSR and responsive design.

<!-- more -->

## Tool 1: [`styled-system`](https://styled-system.com)

We handle the majority of responsive styling differences with
[`styled-system`](https://styled-system.com/responsive-styles). This has been a really great addition to our
toolbox. Here's a component that would render a `div` (`Box`) with a width of 50% for small screens, 75% for
medium-sized screens, and 100% for anything larger:

```xml
<Box width={["50%", "75%", "100%"]}>
  ...
</Box>
```

Another example:

```xml
<Flex flexDirection={["column", "row"]}>
  <Box px={40} background="black10">
    ...
  </Box>
</Box>
```

While only one property in this example is specifying an array of values to be used at different breakpoints, all
of those properties _can_ take an array for different breakpoints. As developers, we love this experience. We can
apply subtle differences to components across breakpoints with very little code and effort.

We use [`styled-system`](https://styled-system.com) extensively within
[our design system](https://palette.artsy.net/). You can
[poke around our source](https://github.com/artsy/reaction/blob/32de03fe526355258655ded510d23335a456b9ce/src/Components/NavBar/Menus/MoreNavMenu.tsx#L23-L28)
to see how much we've embraced [`styled-system`](https://styled-system.com)'s responsive styles.

There's one type of challenge with building a responsive app that [`styled-system`](https://styled-system.com)
can't solve: when we need to emit different layouts across different breakpoints. In this case, we need something
that can render very different component sub-trees. We couldn't find an approach that satisfied our needs, so we
wrote our own.

## Tool 2: [`@artsy/fresnel`](https://github.com/artsy/fresnel)

First off, an announcement: we've just released [`@artsy/fresnel`](https://github.com/artsy/fresnel) version 1.0!

[`@artsy/fresnel`](https://github.com/artsy/fresnel) allows you to define a set of breakpoint widths, then
declaratively render component sub-trees when those breakpoints are met. It looks something like this:

```xml
<>
  <Media at="xs">
    <MobileLayout />
  </Media>
  <Media greaterThan="xs">
    <NonMobileLayout />
  </Media>
</>
```

In this example, we're emitting the `MobileLayout` component for devices at or below our `xs` breakpoint, and the
`NonMobileLayout` for devices greater than our `xs` breakpoint. You can imagine that the `MobileLayout` and
`NonMobileLayout` components contain complicated sub-trees, with more significant differences than
[`styled-system`](https://styled-system.com) could handle.

### How it works

The first important thing to note is that when server-rendering with
[`@artsy/fresnel`](https://github.com/artsy/fresnel), **all** breakpoints get rendered by the server. Each `Media`
component is wrapped by plain CSS that will only show that breakpoint if it matches the user's current browser
size. This means that the client can accurately start rendering the HTML/CSS _while_ it receives it, which is long
before the React application has booted. This improves perceived performance for end-users.

Why not just the breakpoint that the current device needs? Because we can't _accurately_ identify which breakpoint
your device needs on the server. We could use a library to sniff the browser `user-agent`, but those aren't always
accurate, and they wouldn't give us all the information we need to know when we are server-rendering.

If you're interested, you can
[read the issue that originally inspired us to build `@artsy/fresnel`](https://github.com/artsy/reaction/issues/1367).
One of the neat things about Artsy being [open-source by default](/series/open-source-by-default/) is that you can
see decisions being made and libraries being built _as they happen_; not just after they're complete.

## Tool 3: [`@artsy/detect-responsive-traits`](https://github.com/artsy/detect-responsive-traits)

I mentioned above that it's difficult to accurately detect devices by user agent to identify which breakpoint to
render. We didn't want this to be our primary strategy for combining SSR with responsive design.

But with [`@artsy/fresnel`](https://github.com/artsy/fresnel) as our primary approach, we felt that we could make
some further optimizations with user agent detection. In the event that we don't know your device by its user
agent, we'll still render all breakpoints on the server. But if we are certain you are on a device that only ever
needs a subset of the breakpoints, we only render those on the server. This saves a bit of rendering time; more
importantly it reduces the number of bytes sent over the wire.

We really wanted to not maintain our own list of user agents. Alas, we found that none of the existing user agent
detection libraries surfaced all the information we needed in a single resource. We needed to know the minimum
width for a browser on a given device, and if it was resizable, and to what dimensions it was resizable. If any
existing libraries _did_ have this data, they didn't provide it to us easily.

So we did some experimentation, given the browsers and devices we knew we needed to support. And yeah...we
(reluctantly) created our own user-agent detection library,
[@artsy/detect-responsive-traits](https://github.com/artsy/detect-responsive-traits). We're using this to determine
if your browser is likely going to use only the mobile breakpoint of our app, in which case we don't have to also
render the desktop version. The library is currently targeting only the browsers and devices we support on
[artsy.net](artsy.net), but
[we're always open to contributions](https://github.com/artsy/detect-responsive-traits)!

We aren't doing any detection of desktop browsers. They are more resizable than mobile browsers, and we are more
concerned with mobile users getting less content sent over their 3G connection.

## Why didn't you \_\_\_?

Those are our primary tools for combining SSR with responsive design! They work well for us. We considered many
many other options along the way. Here are a couple:

### [`react-media`](https://github.com/ReactTraining/react-media) or [`react-responsive`](https://github.com/contra/react-responsive)

We investigated both [`react-media`](https://github.com/ReactTraining/react-media) and
[`react-responsive`](https://github.com/contra/react-responsive), but found that they didn't approach the SSR side
of the problem as deeply as we needed.

We also weren't fans of the imperative API in [`react-media`](https://github.com/ReactTraining/react-media). We
started with a similar API when building [`@artsy/fresnel`](https://github.com/artsy/fresnel), but found ourselves
inhibited by the restriction that only one branch can be rendered. This contradicted our strategy of emitting all
breakpoints from the server.

With [`react-responsive`](https://github.com/contra/react-responsive), we didn't like that it relied on user agent
detection as its primary method of handling SSR.

### Rely solely on CSS

As mentioned before, we render all breakpoints from the server and hide the non-matching branches with CSS. The
issue with this approach, when combined with React, is that after
[hydration](https://reactjs.org/docs/react-dom.html#hydrate) you have many components that are mounted and rendered
unnecessarily. There's a performance hit you take for rendering components your user isn't seeing, but even worse
is the potential for duplicate side-effects.

Imagine a component that, when rendered, emits a call to an analytics service. If this component exists in both a
mobile and desktop branch, you're now double-stuffing your analytics. Hopefully your analytics service is smart
enough to count only one call, but it's still a bad idea to duplicate components that have side-effects.

[`@artsy/fresnel`](https://github.com/artsy/fresnel) will only client-render the breakpoint that matches your
browser dimensions, so you don't have to worry about duplicate side-effects.

## What's left to solve?

Our SSR and responsive design toolbox does a lot of things well. We get great performance from both the server and
client. Our site looks great on any device.

We do have some SEO concerns, though. Since we're server-rendering multiple breakpoints, it's likely that search
engine bots are seeing double the content on our pages. We _think_ this is okay.
[Google WebMasters](https://youtu.be/WsgrSxCmMbM) says it's okay. We haven't noticed any awful side-effects from
this yet, but SEO is a bit of a dark art, yeah?

## Our advice

Responsive design is hard, especially when layouts change significantly between desktop and mobile. Server-side
rendering in React is hard to get right, period. Combining SSR with responsive design compounds the challenges.

At the end of the day, you should do everything you can to limit layout differences between mobile and desktop. Use
responsive props from [`styled-system`](https://styled-system.com). Play around with `flexbox` and
`flex-direction`, start learning about CSS `grid`, and use CSS `@media` queries when you can. If you absolutely
must render different views on different breakpoints, render all the UI and hide what's not needed for that
breakpoint. You want your users to see the right content as quickly as possible. Send them HTML and CSS from your
server that their client can use.
