---
layout: epic
title: "React Suspense: What it is, how to use it, gotchas, patterns and more"
subtitle:
  A brief guide on how to use Suspense, and some gotchas we've encountered along
  the way
date: 2022-09-09
categories: [React, Suspense]
author: [chris]
---

With the release of React 18, React's new concurrent mode (aka
[Suspense][suspense]) was [officially released][react]. Finally! It was first
demoed at React Conf in [2018][reactconf], has been discussed and debated [for
years][umbrella], and the first parts started to ship in [v16][v16]. And now,
with React 18 shipping to a client app near you, it's time to discuss some of
the patterns that are emerging in the community and how to avoid some common
pitfalls that you might encounter when implementing Suspense (or refactoring)
your UI in support of it.

<!-- more -->

Before we begin, it's worth noting that Suspense is a dense subject. It's more
than just a pattern for efficient data-fetching; it's a new way to think about
your UI by elevating concurrency to the status of first-class citizen. When
first trying to understand how this fits together it can feel overwhelming, and
for that reason it's important to take things slow and ideally build a simple
app that uses the pattern. At that point you'll likely experience an "ah hah!"
moment that renders the pattern clear and from which more complex UI
interactions can be designed. May this post be your guide!

## Definitions

First, what is Suspense? Quoting the React Docs:

> Suspense lets your components “wait” for something before they can render

"Waiting" could mean showing a spinner while an API request takes place, a
bundle split component is lazy-loaded via [`React.lazy`][splitting], or even a
long-running, expensive computation is performed (without locking up the UI).
It's a way to declaratively state that in some fashion or another _we need to
explicitly manage time_.

To demonstrate, imagine an app that renders logged-in user info along with a
list of artists and artworks that they follow:

```tsx
const App = () => {
  return (
    <Suspense fallback="Loading...">
      <UserInfo />

      <Suspense fallback="Fetching Artists...">
        <FollowedArtists />
      </Suspense>
      <Suspense fallback="Fetching Artworks...">
        <FollowedArtworks />
      </Suspense>
    </Suspense>
  )
}
```

A couple things are happening here that are important to pay attention to, most
notably the structure of the component tree and the nesting of various Suspense
boundaries. Breaking it down a bit:

1. `<App />` is wrapped in a top-level `<Suspense />` boundary. This tells React
   that it is waiting for something to happen
1. The first component nested within the top-level suspense boundary is
   `<UserInfo />`. React attempts to render it
1. Inside of `<UserInfo />` there's a mechanism for fetching user data. When
   triggered, this tells React that we need to "suspend"
1. At this moment the top-level "Loading..." fallback indicator appears.
1. `<FollowedArtists />` and `<FollowedArtworks />` execute and also trigger
   fallback loading states
1. `<UserInfo />` finishes loading and reveals the page
1. `<FollowedArtists />` and `<FollowedArtworks />` render and show their
   content as soon as they finish loading

The nested suspense boundaries give us fine-grained control over time management
in our UI. We're able to say: before the user data is fetched, visually pause
everything (as user info is critical); once that's done render artists and
artworks as they are secondary, and the order in which they resolve is
unimportant. The structure of the boundaries are like adding breakpoints to ones
code, and some breakpoints are clearly more important than others judging by the
depth in which the Suspense boundaries appear in the component tree.

The question is: how does a component tell React that it needs to suspend?

## Building your first Suspense component

This is where things get interesting and kind of weird and we discover that what
seems complex is actually deceptively simple. To instruct React to suspend, you
simply `throw` a promise in the same way that you would `throw` an error:

```tsx
const UserInfo = () => {
  throw new Promise(...)

  return (
    <div>...</div>
  )
}
```

That's Suspense's mechanism in a nutshell and all you really need to know to
understand some of the more complex ideas that follow. In a React component
render cycle, `throw promise` means: suspend.

## But why?

When I first started exploring Suspense I asked myself this question a lot,
because I was only thinking about suspense as a way to fetch data, and I had
already been fetching data with sequential loading states just fine for years.
Why is it necessary to introduce a strange new JavaScript pattern ("throwing a
promise?") for something that I can easily do in a `useEffect`?

What I didn't understand is that Suspense is designed for something other than
_fetching on render_; it's designed around the concept of _rendering as you
fetch_. This is _the_ crucial idea to understand about Suspense: that **one
should be able to execute an entire component tree in one go with nothing
preventing any other component from executing, regardless of whether there are
required data dependencies needed for rendering the display**. The performance
implications of this are very cool and a bit mind-bending once fully understood!
Lets demonstrate with a few examples.

> Note: In the following sections I'm using the word "fetch" to mean anything
> that takes time to complete. We could just as easily replace "render as you
> fetch" with "render as you wait".

## Fetch-on-render vs Render-as-you-fetch

The old, common way of doing things is `fetch-on-render`:

```tsx
const App = () => {
  const [isLoading, setIsLoading] = useState(true)
  const [artistData, setArtistData] = useState(null)

  useEffect(() => {
    const load = async () => {
      const response = await fetchArtistData()

      setArtistData(response)
      setIsLoading(false)
    }
    load()
  }, [])

  if (isLoading) {
    return "Loading..."
  }

  return <Artist artistData={artistData} />
}
```

When `<App />` first renders we fire off a `useEffect` call to fetch data for
the `<Artists>` component. This all seems fine and good and conventional, but
when you squint your eyes you'll notice something: if `isLoading` is `true`,
code within the `<Artist />` component never executes. There could be lots of
stuff inside of there that does things independent of what the component finally
renders to the screen, and all of that has to wait for `<App />`'s `isLoading`
flag to be `true`.

Now, imagine that waiting waterfall cascading out to _all_ of the components in
an app tree, at scale. It's slow. And it doesn't have to be this way thanks to
Suspense.

### A better way: `render-as-you-fetch`

Lets refactor the above example to introduce a more suspense-friendly way of
doing things.

First, wrap the `<Artist />` component with a suspense boundary:

```tsx
import { Artist } from "./Artist"

const App = () => {
  return (
    <Suspense fallback="Loading...">
      <Artist />
    </Suspense>
  )
}
```

Now lets wire up the `<Artist />` component:

```tsx
const artistData = prepareArtistData()

export const Artist = () => {
  const data = artistData.read()

  return (
    <>
      {data && (
        <>
          {data.name}, {data.birthday}
        </>
      )}

      <Artworks />
    </>
  )
}
```

You'll notice a few interesting things here:

1. The call to `prepareArtistData()` is outside of the component
1. We're not using `async/await` here, but rather just calling a function to
   "prime" the data to be read (which happens the moment that `App.tsx` imports
   `Artist.tsx`).
1. Inside of the component we're calling `artistData.read()`, and again _not_
   `async/await`ing the response
1. With no use of `async/await` and no internal `setState` toggling an
   `isLoading` flag, there's nothing that blocks the `<Artworks />` component
   from executing, even though we're still potentially fetching (and thus
   triggering the parent's `<Suspense>` fallback boundary)

With this `render-as-you-fetch` pattern setup across the span of a whole app
what you get is a _clear separation between data and code_, vs the
`fetch-on-render` pattern which effectively ties your code to your data layer as
a hard dependency which blocks further execution until its resolved, slowing
everything down throughout.

The next step is understanding the nuances of what's happening in
`prepareArtistData()` and what happens when `artistData.read()` is called.

### Setting up your data layer for Suspense

There's no React-specific API methods here that one needs to call, which is
wonderful; this is only a JS pattern and one can expand or contract it in any
way they see fit and depending on their needs.

Here's our `prepareArtistData` function:

```tsx
export const prepareArtistData = () => {
  let status = "pending"
  let result
  let error

  const promise = fetch("https://api.artsy.net/artist")
    .then((data) => {
      status = "success"
      result = data
    })
    .catch((err) => {
      status = "error"
      error = err
    })

  return {
    read: () => {
      if (status === "pending") {
        throw promise
      } else if (status === "error") {
        throw error
      } else if (status === "success") {
        return result
      }
    },
  }
}
```

Building on the concept we learned above -- that all one needs to do to trigger
a suspense boundary's fallback loading state is `throw` a promise -- we can
understand what's happening in the `prepareArtistData` function:

1. When `prepareArtistData` is first called at the top of `Artist.tsx` file and
   outside of the component, the initial `status` is set to `"pending"`
1. We use the native `fetch` function to make an API call to fetch our data and
   assign the promise to a variable
1. When `artistData.read()` is called within the component, we see that
   `status === "pending"` and `throw promise`, which React sees and triggers the
   suspense boundary.
1. If there's an error, we set `status` to `error` and `throw error`, which is
   exactly what it seems: throwing an error
1. If fetch is successful, we set `status` to `success` and simply
   `return result`

And that's it. Looking at our `Artist` component again we can see how it all
fits together:

```tsx
const artistData = prepareArtistData()

export const Artist = () => {
  const data = artistData.read() // throw promise, throw error or return result

  return (
    <>
      {data && (
        <>
          {data.name}, {data.birthday}
        </>
      )}

      <Artworks />
    </>
  )
}
```

No `awaiting` anything, and nothing to slow your app code execution down
because, again, data and code have been effectively separated. On `render` the
whole component tree executes and areas that need loading states simply
_display_ the loading state via `Suspense` boundary, not block execution. And if
you need formal error handling, wrap `<Suspense>` in an additional [Error
Boundary][error] for display.

Here's another pseudocode example, using a router which preloads all route data
ahead of time:

```tsx
const routes = makeRoutes([
  {
    path: '/':
    query: loadQuery(homeQuery)
    Component: () => {
      const data = usePreloadedQuery(homeQuery)
      ...
    }
  },
  {
    path: '/artists':
    query: loadQuery(artistsQuery)
    Component: () => {
      const data = usePreloadedQuery(artistsQuery)
      ...
    }
  }
])

bootApp(() => (
  <Suspense fallback="Loading route...">
    {routes}
  </Suspense>
))
```

This pattern is _flexible_. One can imagine any number of ways we could
`prepare()` this data to be `read()`. And underneath it all the mechanism is
_simple_; its just us throwing a promise to suspend, throwing an error, or
returning data to be used in the component. Very cool.

## Gotchas and Emerging Patterns Around Them

Now that suspense is properly understood lets discuss some common patterns that
one can use to get around the gotchas. Suspense is new; it's like the transition
period when hooks came out and people were moving from class-based components
with explicit lifecycle methods to functional components with hooks. And
remember when render props were a thing? They were a way to use dependency
injection to "inject" props into a component, allowing us to share data
dependencies across a react tree. That pattern was cool at the time but it
wasn't without its headaches, and the community hadn't yet settled on contexts
as they're now commonly understood. It was a pattern that we had to come up
with. It's the same thing with Suspense. React has provided the tools for us to
work with concurrency patterns in our UI, but since Suspense is so new we still
need to figure out just how to do it right.

The following bits of code have been made generic for demonstration purposes,
but if you use [Relay][relay] (like we do at Artsy) you're officially in a
suspense-based world and all of the following patterns will apply.

### An example

Say you've got an `<Autocomplete />` component that allows you to enter some
text which fetches data to render a dropdown list. The data is being requested
via a hook that uses suspense, and the request is being triggered on each
keystroke:

```tsx
const ArtistAutocomplete = () => {
  const [query, setQuery] = useState(null)
  const options = useArtistQuery(query) // uses suspense

  return (
    <Autocomplete
      onChange={(value) => {
        startTransition(() => {
          setQuery(value)
        })
      }}
      options={options}
      isLoading="???" // where do we get loading state?
    />
  )
}
```

> Note how we're wrapping the `setQuery` in `startTransition`. When updating
> state in a component that is wrapped by `<Suspense>` this is
> [now required](https://17.reactjs.org/docs/concurrent-mode-patterns.html?#wrapping-setstate-in-a-transition)
> in order to ensure that state changes can perform smoothly. Google it!

And then higher up, in `<App />`, we wrap `<ArtistAutocomplete />` in a suspense
boundary:

```tsx
const App = () => {
  return (
    <Suspense fallback="Loading...">
      <ArtistAutocomplete />
    </Suspense>
  )
}
```

On each keystroke `setQuery` is called which in turn calls `useArtistQuery`.
Since `useArtistQuery` suspends on fetch, it throws a promise which in turn
triggers the `<Suspense>` boundary in `<App />`. This isn't a good user
experience! Every change to the query shows a `Loading...` indicator in the UI,
hiding the `<ArtistAutocomplete />` component until the promise is resolved,
causing things to flicker back and forth.

Further, there's no way to inform our `<Autocomplete isLoading>` prop that
anything is happening, because there's no way to ask React if a given suspense
boundary has been triggered or not. (This is quite annoying and something I
suspect React will resolve in later releases.) So how do we address these two
very common UX issues?

The first thing we need to do is rearrange things. Rather than wrapping the
whole `<ArtistAutocomplete />` component in a suspense boundary, we need to
isolate the data-fetching aspect of it and then wrap _that_:

```tsx
<Suspense fallback="Loading...">
  <Fetcher />
</Suspense>

<Autocomplete ... />
```

Full example:

```tsx
const ArtistAutocomplete = () => {
  const [query, setQuery] = useState(null)
  const [options, setOptions] = useState([])

  const handleOnChange = (response) => {
    setOptions(response)
  }

  return (
    <>
      <Suspense fallback="Loading...">
        <Fetcher query={query} onChange={handleOnChange} />
      </Suspense>

      <Autocomplete
        onChange={setQuery}
        options={options}
        isLoading="???" // where do we get loading state?
      />
    </>
  )
}

const Fetcher = ({ query, onChange }) => {
  const response = useArtistQuery(query) // triggers suspense boundary

  useEffect(() => {
    onChange(response)
  }, [response])

  return null
}
```

The `Fetcher` component doesn't actually render anything; it just fetches data
via the `useArtistQuery` hook -- and hooks, as you know, can **only** be used in
React components. Once the data has been returned it sends the response back to
the parent via the `onChange` callback prop. This then pipes the data into our
`<Autocomplete />` component.

With our flickering UI problem now solved, we're left with figuring out how to
update the `isLoading` prop on our `<Autocomplete />` component. How? We need to
create a loading toggle component that is updated every time a component
suspends and pass that in as the suspense fallback:

```tsx
<Suspense fallback={<LoadingToggle />}>
  <Fetcher />
</Suspense>

<Autocomplete ... />
```

Full example:

```tsx
const ArtistAutocomplete = () => {
  const [query, setQuery] = useState(null)
  const [options, setOptions] = useState([])
  const [isLoading, setIsLoading] = useState(false)

  const handleOnChange = (response) => {
    setIsLoading(false)
    setOptions(response)
  }

  return (
    <>
      <Suspense fallback={<LoadingToggle onChange={setIsLoading} />}>
        <Fetcher query={query} onChange={handleResponse} />
      </Suspense>

      <Autocomplete
        onChange={setQuery}
        options={options}
        isLoading={isLoading}
      />
    </>
  )
}

const Fetcher = ({ query, onChange }) => {
  const response = useArtistQuery(query)

  useEffect(() => {
    onChange(response)
  }, [response])

  return null
}

const LoadingToggle = ({ onChange }) => {
  useEffect(() => {
    onChange(true)
  }, [])

  return null
}
```

When the suspense boundary fallback has been triggered the `<LoadingToggle />`
component renders, and instantly we call the `onChange` callback with `true` to
alert the parent that our component has suspended. And again, similar to
`<Fetcher />`, we return `null` from the `LoadingToggle` because all we're
concerned about is learning when the suspense boundary has been triggered to set
the state in the parent, and we don't need to render visuals for the fallback;
our aim is solely to update the `isLoading` prop on `<Autocomplete />`.

At this point you might be scratching your head and asking yourself "what the
heck??". Well, me too. Without the ability to query a specific suspense boundary
about its loading state we're left with `null`-returning placeholder components
used to execute hooks and callbacks used to update parent state. It's not
pretty, but it's also not too complex to understand, thankfully. And maybe it's
just worth it given everything that Suspense has to offer in terms of
performance. And maybe -- just maybe -- React will release some DX additions to
suspense that render these work-arounds moot.

Code like the above lends itself well to a library, so if you're curious about
how we handled it at Artsy [check out our `<LazyQueryRenderer />`
component][lazy] in Forque, our [internal tools app][forque].

## Conclusion

If you've made it this far, congrats! You now understand React Suspense. Or
rather, you might _think_ you understand Suspense -- because really, who fully
understands the often-futuristic visions that Meta's engineers invent? Their
tech usually takes a few years for people to grasp, and then when they do it
sweeps over everything. Suspense, I think, will be no different. It's a
fundamentally different way of working in UI and as more and more libraries
start implementing its time-managing concurrency patterns the UI's we build will
get drastically faster -- but it will take time. My initial reaction to it was
not unique: First it was confusion, then anger at the new hoops we need to jump
through, and after all of that settled I'm thoroughly :mindblown:.

p.s. To all of the very-large-app maintainers needing to make the upgrade from
React 17: we wish you the best. It will not be easy, and many will not be able
to cross the great waters. For those that wish to try, however, we [are
hiring][hiring]. Drop us a line!

[suspense]: https://17.reactjs.org/docs/concurrent-mode-suspense.html
[react]: https://reactjs.org/blog/2022/03/29/react-v18.html
[umbrella]: https://github.com/facebook/react/issues/13206
[reactconf]: https://reactjs.org/blog/2018/11/13/react-conf-recap.html
[v16]: https://reactjs.org/blog/2018/11/27/react-16-roadmap.html
[splitting]: https://reactjs.org/docs/code-splitting.html
[error]: https://reactjs.org/docs/error-boundaries.html
[relay]: https://relay.dev/
[lazy]:
  https://github.com/artsy/forque/blob/main/src/components/LazyQueryRenderer.tsx
[forque]: https://github.com/artsy/forque
[hiring]: https://www.artsy.net/jobs
