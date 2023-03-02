---
layout: epic
title: "TypeScript magic"
date: 2023-03-01
categories: [TypeScript, Types, Tools, Palette]
author: [pvinis]
---

At Artsy, we love TypeScript. We use it in most of our node/web/mobile repos.
Today, I want to talk about a specific case we found while trying to make our
types more strict on [palette-mobile](https://github.com/artsy/palette-mobile),
which is our Design System for React Native.

Check this out:

```ts
const welp: "hello" | "world" | string // `welp` is of type `string`.
```

Like the comment says, even though we have two specific strings, the fact that
we do a union with `string`, makes `welp` have a type of just `string`. This is
because both `"hello"` and `"world"` are strings, and the union tends to go to
the type that includes the most.

Think of set theory and bubbles.

<!-- more -->

<figure class="illustration">
  <img src="/images/2023-02-20-typescript-magic/hello-world.png">
</figure>

`"hello"` is a type by itself, and `"world"` is a type by itself. Unioning them
together gives us a new type, which is a bubble that contains both `"hello"` and
`"world"`. In that `"hello" | "world"` union bubble, we see both `"hello"` and
`"world"` types as subsets.

The `string` bubble contains all strings, so it contains `"hello"` and `"world"`
and `"hello" | "world"`, so the union of them with string is string.

<figure class="illustration">
  <img src="/images/2023-02-20-typescript-magic/string.png">
</figure>

That is usually ok, but for our case, it didn't work. Here is what we wanted to
do.

## The problem

In our Design System, we have certain color, named like `black100`, `black80`,
`blue100`, `red150` etc. We can have a type like

```ts
type ColorDSValue = "black100" | "black80" | "blue100" | "red150" // | etc
```

and that works great. We get to have autocomplete, typechecking, all the good
stuff that TypeScript brings.

But we also want to support any other string, like `"#000000"`, `"#000"`,
`"rgb(0,0,0)"`, `"rgba(0,0,0,0.5)"`, `"hsl(0,0%,0%)"`, `"hsla(0,0%,0%,0.5)"`.
Ok, you might say, just make more types like

```ts
type ColorHexValue = `#${string}`
type ColorRGBValue = `rgb(${number},${number},${number})`
type ColorRGBAValue = `rgba(${number},${number},${number},${number})`
type ColorHSLValue = `hsl(${number},${number}%,${number}%)`
```

and so on. That's great. So far, so good.

We also want to make sure CSS color names are accepted. So then we add something
like

```ts
type ColorCSSString = "red" | "blue" | "hotpink" // | etc
```

and now we have a type with all the values. That seemed ok, but it also felt a
bit too much. If CSS names change, we need to update. Also what we wanted to do
is actually have autocomplete and typechecking for our DS values, and just leave
it loose for all the rest.

So we tried

```ts
type ColorDSValue = "black100" | "black80" | "blue100" | "red150" // | etc
type ColorOtherString = string

type Color = ColorDSValue | ColorOtherString
```

but we ended up with `Color` being just `string`, which automatically means no
autocomplete and no typechecking.

## Now check this out!

```ts
const wow: ("hello" | "world") | (string & {}) // `wow` is of type `"hello"` or `"world"` or `string`.
```

This weird-looking intersection of `string & {}` makes it so that the specific
strings `"hello"` and `"world"` are distinguished from `string` as a whole type.

The way this works is this:

- the intersection of `string` and `{}` (which is `string & {}`), is essentially
  the same as `string`, but it is a new type, different from `string`.
- the union of `"hello"` and `"world"` is `"hello" | "world"`, which is a new
  type, different from `"hello"` and `"world"`. It contains both.
- the union of `"hello" | "world"` and `string` expands the type to `string`,
  since that is the common type. `"hello"`, `"world"`, and `"hello" | "world"`,
  all inherit from `string`.
- the union of `"hello" | "world"` and `string & {}` is
  `"hello" | "world" | (string & {})`, which is a new type, different from just
  `string`. This is because `"hello"` and `"world"` DO NOT inherit from
  `string & {}`, so they are distinguished from `string & {}` as a whole type.

With this type trick, essentially we can tell the type system that we want
specific string, but also any other string.

Here is a complete view of the sets.

<figure class="illustration">
  <img src="/images/2023-02-20-typescript-magic/everything.png">
</figure>

It seems pretty funky that `string` and `string & {}` are same in a way, but
different in another way. They both tell the type system that any string is
accepted. But one is inherited by every type that is a string (like
`type Hi = "hello"`), where as the other is not inherited, so they are
distinguished from each other.

That is so cool to me! I wanted to do this and didn't even have the words to
describe it, I didn't know how to google it. We kind of found it accidentally.

This is so so useful for types or props where you want the general type for
support (`string`), but you also want the specific type for autocomplete
(`"black100"`). It made my whole week when I figured that out and made that
color type.

Here is the final type:

```ts
type ColorDSValue = "black100" | "black80" | "blue100" | "red150" // | etc
type ColorOtherString = string & {}

type Color = ColorDSValue | ColorOtherString
```

Now we have autocomplete and typechecking.

## Final thoughts

This is such a useful little TypeScript trick. Thanks to
[Sultan](https://github.com/MrSltun) for finding this. He found it in a
[TypeScript issue](https://github.com/microsoft/TypeScript/issues/29729#issuecomment-567871939).
Then we tried it and figured out how to work with this, and how to make our type
exactly what we wanted, for the best DX we can get.

Link to palette-mobile, where we use this type:
[link](https://github.com/artsy/palette-mobile/blob/v11.0.0/src/types.ts#L17)

Link to a TypeScript playground with the examples:
[link](https://www.typescriptlang.org/play?#code/MYewdgzgLgBA7gUwDYAcBcMBEALZSSYwA+WcIATkgCaEnTkCWYA5jALxa5L6YBQvUAJ4oEMAMIh85ACIBlAGoBDJAFdRHTACMki4AGsAjAAYjtLNt16AHKeLnVCY7ZKZyCKgYCstgPQ+7CFDAAsKiAEKKVBJSAPJQuOSyUIws7DD0TMz8QiIwEVGSFGnRFHJKDnb5JeRxCUkpWbygkLCakdUYVYXkaTiKEDBgIDCKKlAgoAC2KEiBCHz8zdDwIHAYABQ4eAR2mGSUNACUdusZqQBkMADeAL7HGlw82aEwAOIgIAWx8QiJyZlpM6sS63Z65d6farFbplZRqOwQr4UWq-eqZRbgZbMD5I8gYRFQh79EZjCYgaazKAIAB0MGSgjpw2A2EULFE8QYAyBMAS7OGFn0TgAhHwgA)
