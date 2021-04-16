---
layout: epic
title: "Testing React Tracking with Jest and Enzyme"
date: 2021-04-15
categories: [testing, tracking, volt, cms, enzyme, react-tracking]
author: matt-dole
comment_id: 683
---

Recently, I needed to test a button that would make an analytics tracking call using
[react-tracking](https://github.com/NYTimes/react-tracking) and then navigate to a new page in a callback. This
presented some challenges - I wasn't sure how to create a mocked version of react-tracking that would allow a
callback to be passed.

With some help from fellow Artsy engineers [Christopher Pappas](https://github.com/damassi) and
[Pavlos Vinieratos](https://twitter.com/pvinis), I got the tracking and testing to work. Here's how we did it.

<!-- more -->

# A little context

This work took place in Volt, our partner CMS (it's sadly a private repository, but I'll do my best to paste in
relevant code snippets so you're not totally in the dark). Volt has been around for a long time and has had several
different client-side tracking implementations over the years. In this case, I wanted to take the opportunity to
bring Volt up to standard with our other big apps, [Force](https://github.com/artsy/force/) and
[Eigen](https://github.com/artsy/eigen). They both use react-tracking and
[Cohesion](https://github.com/artsy/cohesion/), our centralized analytics schema.

Our use-case was a button that would navigate the user to a new page. The button had been implemented in a previous
PR, and now we wanted to make it execute a tracking call before navigating.

We use Segment for tracking, and their tracking setup relies on a JS snippet being available on your pages. That
snippet sets a `window.analytics` property, which in turn
[has a](https://segment.com/docs/connections/sources/catalog/libraries/website/javascript/#track) `.track()`
method. On a fundamental level, all of our tracking calls boil down to a call to `window.analytics.track()`. We
pass a list of properties to `.track()`, Segment receives the event and properties, and the resulting JSON is
stored in our data warehouse.

# Adding react-tracking

First, there was a bit of setup required to get react-tracking working. The react-tracking package
[assumes you're using Google Tag Manager by default](https://github.com/NYTimes/react-tracking#custom-optionsdispatch-for-tracking-data),
but allows you to override that behavior with a custom `dispatch` function. In our case, we wrap our React apps in
a `<BaseApp>` component, so we added a new `<TrackerContextCohesion>` component with a custom `dispatch` that would
be available to all of our React apps:

```ts
import React from "react"
import { track } from "react-tracking"

// We're following the instructions from react-tracking's README on overriding the dispatch function
const TrackerContextCohesion = track(
  // This is blank because we're not actually tracking a specific event here, just modifying dispatch
  // so that all components in the tree can use it
  {},
  {
    dispatch: ({ data, options, callback }) => {
      trackEvent(window.analytics.track(data.action, data, options, callback))
    },
  }
)((props) => {
  return props.children
})

export const BaseApp = (props) => {
  return <TrackerContextCohesion>{props.children}</TrackerContextCohesion>
}
```

This allows us to make tracking calls in our components, including the passing of custom callback functions:

```ts
import { useTracking } from "react-tracking"
import { Box, Button } from "@artsy/palette"

// Assumes that MyComponent is wrapped in <BaseApp> wherever it's used, giving
// it access to tracking context
const MyComponent = () => {
  const { trackEvent } = useTracking()

  const handleClick = () => {
    trackEvent({
      data: { action: "Click", somePropToTrack: "andy-warhol" },
      options: {}, // Additional Segment options, e.g. integrations: { 'Intercom': false, }
      callback: () => {
        window.location.assign("/artworks")
      },
    })
  }

  return (
    <Box>
      <Button onClick={handleClick}>Track and navigate</Button>
    </Box>
  )
}
```

Being able to pass a callback was especially important in our case. We realized that if we needed to track _and
then navigate_, the callback was necessary. In our testing, we saw that if we simply tried to fire the tracking
call then run `window.location.assign()` synchronously, the tracking call might not get executed before the
navigation started, so we would effectively lose that event. Segment specifically
[allows you to pass a callback](https://segment.com/docs/connections/sources/catalog/libraries/website/javascript/#track)
to their tracking function to their track function for this situation. They describe the optional `callback`
parameter as:

> A function that is executed after a short timeout, giving the browser time to make outbound requests first.

Thus, we pass the tracking data and the callback to the custom `track` call we implemented, and we're good to go.

# The problem with testing

Our use-case is simple enough, but we wanted to make sure that when the button was pressed, we would both execute
the tracking call and then navigate. A test checking that the navigation worked had already been implemented.
However, after moving the `window.location.assign` call into a callback, our test started failing because our
component was trying to execute a tracking call before navigating.

The test that predated the addition of tracking looked like this:

```ts
import React from "react"
import { mount } from "enzyme"
import { MyComponent } from "./MyComponent"
import { TestApp } from "testing/components/TestApp"

window.location.assign = jest.fn()

it("Navigates to artworks page", () => {
  const wrapper = mount(
    <TestApp>
      <MyComponent />
    </TestApp>
  )

  wrapper.find("Button").simulate("click")
  expect(window.location.assign).toBeCalledWith("/artworks")
})
```

So we were rendering our button, clicking on it, and expecting to try to navigate. How could we mock our tracking
call while still executing a passed callback?

# The final solution

Our mock ended up looking like this:

```ts
window.analytics = {
  track: jest.fn(),
}

jest.mock("react-tracking", () => ({
  useTracking: jest.fn(),
  track: () => (children) => children,
}))

const trackEvent = jest.fn((args) => {
  args.callback()
})

useTracking.mockImplementation(() => ({
  trackEvent,
}))
```

Let's break that down section by section. First:

```ts
window.analytics = {
  track: jest.fn(),
}
```

As noted above, all of our tracking calls assume `window.analytics` exists and that it has a `.track()` method. We
started by mocking that setup.

Next:

```ts
jest.mock("react-tracking", () => ({
  useTracking: jest.fn(),
  track: () => (children) => children,
}))
```

Here we mock the `react-tracking` package and two specific methods it exports, `useTracking` and `track`. We made
`useTracking` a Jest function - we'll flesh it out further a few lines farther down in the file.

Then there's the mocking of `track`. To put it in words, our mock is: a function that returns a function that takes
in `children` and returns those `children`. That might sound like gibberish at first blush, but essentially what
we're doing is mocking the function composition we performed earlier when creating `TrackerContextCohesion`. We
needed something that was the same shape as `react-tracking`'s `track()`, but we don't care about overriding
`dispatch` in our mocks.

Last:

```ts
const trackEvent = jest.fn((args) => {
  args.callback()
})
useTracking.mockImplementation(() => ({
  trackEvent,
}))
```

`trackEvent` is a mock function that takes in an `args` object and executes `args.callback()`. We then update our
`useTracking` mock to make it return a function that returns an object with a `trackEvent` property. What a
mouthful! That sounds super confusing, but remember that we're trying to mock something that we actually use like
this:

```ts
const { trackEvent } = useTracking()
```

So basically, our goal was to mock `trackEvent` and we needed to emulate the shape it has when it's exported by
`react-tracking`. Hopefully that makes things a little clearer.

After some tinkering and eventually getting the mocks to work in a single test file, we moved these mocked
functions to a `setup.ts` file that all of our Jest tests load automatically. We chose to make these mocks
available to all tests because then we wouldn't get surprising test failures if we, say, forgot that we were making
a tracking call in a component and didn't explicitly mock the tracking calls in those tests.

At the end of the day, we can use these mocked calls in our test files by doing the following:

```ts
import React from "react"
import { mount } from "enzyme"
import { MyComponent } from "./MyComponent"
import { TestApp } from "testing/components/TestApp"
import { useTracking } from "react-tracking"

// This only works because we mock tracking in setup.ts, and we only need to
// declare it because we want to check how many times it was called. Also, it
// would break the rules of hooks (https://reactjs.org/docs/hooks-rules.html)
// if it wasn't mocked. Tread cautiously!
const { trackEvent } = useTracking()

window.location.assign = jest.fn()

it("Calls tracking and navigates to artworks page", () => {
  const wrapper = mount(
    <TestApp>
      <MyComponent {...props} />
    </TestApp>
  )

  wrapper.find("Button").simulate("click")
  expect(trackEvent).toHaveBeenCalledTimes(1)
  expect(window.location.assign).toBeCalledWith("/artworks")
})
```

That's it! If you're trying to test something similar and found this post, I hope it helps you out. If so, or if
you're still confused, leave a comment!
