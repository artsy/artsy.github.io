---
layout: epic
title: Conditional types in TypeScript
date: 2018-10-19
author: [david]
categories: [programming, api, graphql, design]
css: graphql
comment_id: 495
---

\_Note: This is a straightforward adaptation of a 35-minute presentation given at
[Futurice London's TypeScript Night meetup](https://www.meetup.com/Futurice-London-Beer-Tech/events/255295412/),
and therefore gives a lot more context than an ordinary blog post might. I hope a lot of that context is
interesting and useful even for seasonsed TypeScript developers, but if you want the short-and-sweet version check
out the
[TypeScript 2.8 Release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-8.html)
instead.

TypeScript 2.8, released earlier this year, came with a new feature that punches far above its weight: Conditional
types.

Conditional types probably aren't something you'll write every day, but you might end up using them indirectly all
the time. That's because they're great for writing 'plumbing' or 'framework' code, and for dealing with API
boundaries. So even though they're mainly a behind-the-scenes kind of tool, I think it's good to learn how the
sausage is made. Then you can make sausage of your own! Typewurst! 🌭

> Working through our (enormous) backlog of unsorted TypeScript "Suggestions" and it's remarkable how many of them
> are solved by conditional types.

-- [Ryan Cavanaugh](https://twitter.com/SeaRyanC/status/1029846761718702081), TypeScript maintainer

## Your first conditional type

To get an initial impression of what conditional types are about, let's jump right into some code.

```ts
function process(text) {
  return text && text.replace(/f/g, "p")
}

process("foo").toUpperCase()
```

Above I have a plain javascript function that processes some given text. And then I'm calling the function, and
doing something with the result. Reading the code, it's clear to a human that this usage is safe. Notice that the
function checks first whether the value is truthy before using it, so we know that whenever a string is passed in,
a string will be returned.

Let's add types to this function so we can let TypeScript worry about whether it is safe or not.

```ts
function process(text: string | null): string | null {
  return text && text.replace(/f/g, "p")
}
```

Here we've told TypeScript that the function takes a `string | null` and returns a `string | null`. What happens if
we try to use it like before?

```ts
//            ⌄ Type Error! :(
process("foo").toUpperCase()
```

TypeScript complains because it thinks that the result of `process("foo")` might be null. It can't figure out the
semantics of the function on its own.

One way of helping TS understand the function better is to use 'overloading'. Overloading involves providing
multiple type signatures for a single function, and letting TypeScript figure out which one is most appropriate in
any given context.

```ts
function process(text: null): null;
function process(text: string): string;
function process(text: any) {
  ...
}
```

Here we've said that if we pass a `string`, it returns a `string`, and if we pass `null`, it returns `null`. _(The
`any` type is ignored but still needs to be there for some reason 🤷‍♀️)_

That works nicely:

```ts
// All clear! :)
process("foo").toUpperCase()
//           ⌄ Type Error! :)
process(null).toUpperCase()
```

See that if we pass a string, TS doesn't complain, and if we pass null, there's a type error, just like you'd
expect. But there's a problem:

```ts
declare const maybeFoo: string | null

//      ⌄ Type Error! :(
process(maybeFoo)
```

TypeScript won't let us pass something that is of type `string | null` because it's not smart enough to collapse
the overloaded signatures when that's possible. So we can either add yet another overload signature for the
`string | null` case, or we can be like (╯°□°）╯︵ ┻━┻ and switch to using **conditional types**.

```ts
function process<T extends string | null>(
  text: T
): T extends string ? string : null {
  ...
}
```

Here we create a generic type variable for the `text` parameter: `T`. It is constrained to be something that
extends `string | null`. Then we use `T` as part of a conditional return type: `T extends string ? string : null`.
You probably noticed that this looks just like a ternary expression! Indeed, it's doing the same kind of thing, but
within the type system at compile time.

And that takes care of all our use cases:

```ts
typeof process("foo") // => string
typeof process(null) // => null
typeof process(maybeFoo) // => string | null
```

So that's what a conditional type is! A kind of ternary type expression. It always has this form:

```
A extends B ? C : D
```

`A`, `B`, `C`, and `D` can be any old type expressions, but all the important stuff is happening on the left there.
In the `A extends B` condition.

## Assignability

This `extends` keyword is the heart of a conditional type, and its semantics are very important and maybe a little
counterintuitive if you come from a Java or C# background.

To begin with, when we say that `A extends B`, what we really mean is that any value of type `A` can safely be
assigned to a varaible of type `B`. In type system jargon we can say that "`A` is _assignable_ to `B`". But how
does TypeScript decide whether one type is assignable to another?

It uses a system called 'structural typing'. You might have heard of 'duck typing' in relation to dynamically-typed
languages. The phrase 'duck typing' comes from the proverb

> If it looks like a duck, swims like a duck, and quacks like a duck, then it probably is a duck.

In duck typing, you judge a thing by how it behaves, rather than what it is called or who its parents are. It's a
kind of meritocracy. Structural typing is a way of applying that same idea to static typing. So, when it comes to
assignability, TypeScript only cares about what types can do, not what they are called or where they exist in a
type hierarchy.

Take this simple example:

```ts
class A {}
class B {}

const b: B = new A() // ✔ all good
const a: A = new B() // ✔ all good

new A() instanceof B // => false
```

TypeScript is happy treating two completely unrelated classes as equivalent because they have the same _structure_
and the same _capabilities_. Meanwhile, when checking the types at runtime, we discover that they are actually not
equivalent.

This is a notable example of where the semantics of TypeScript are at odds with JavaScript. It might seem like a
problem, but in practice structural typing is a lot more flexible than Java-esque 'nominal' typing, where names and
hierarchy matter. The two aren't mutually exclusive, however. Some languages, like Scala and Flow, allow you to mix
and match.

Aside from that, the way that assignability works in TypeScript is quite intuitive.

```ts
interface Shape {
  color: string
}

class Circle {
  color: string
  radius: number
}

// ✔ All good! Cirlces have a color
const shape: Shape = new Circle()
// ✘ Type error! Not all shapes have a radius!
const circle: Circle = shape
```

Speaking structurally we can say that `A extends B` is a lot like '`A` is a superset of `B`', or, to be more
verbose, '`A` has all of `B`'s properties, and maybe some more'.

There's one minor caveat though, and that's with literal types. In TypeScript you can use literal values of
primitive types as types themselves.

```ts
let fruit: "banana" = "banana"

// Type Error! "apple" is not assignable to "banana"
fruit = "apple"
```

The string `"banana"` doesn't have any more or fewer properties than any other `string`. But the type `"banana"`
is, conceptually, more _specific_ than the type `string`.

So another way to think of it is that `A extends B` is like '`A` is a possibly-more-specific version of `B`'.

Which brings us to 'top' and 'bottom' types: the _least_ and _most_ specific types, respectively.

In type theory a 'top' type is one which all other types are assignable to. It is the type you use to say "I have
absolutely no information about what this value is". TypeScript has two top types: `any` and `unknown`.

- Using `any` is like saying "I have no idea what this value looks like. So, TypeScript, please assume I'm using it
  correctly, and don't complain if anything I do seems unsafe.".
- Using `unknown` is like saying "I have no idea what this value looks like. So, TypeScript, please make sure I
  check what it is capable of at run time."

A 'bottom' type is one which no other types are assignable to, and that no values can be an instance of. TypeScript
has one bottom type: `never`. That's a nice descriptive name because it literally means _this can never happen_.

Top and bottom types are useful to know about when working with conditional types. `never` is especially useful
when using conditional types to refine unions...

## Refining unions with distributive conditional types

Conditional types let you filter out particular members of a union type. To illustrate, let's say we have a union
type called `Animal`:

```ts
type Animal = Lion | Zebra | Tiger | Shark
```

And imagine that we needed to write a function that used only those animals which are also cats. We might write
some helper type called `ExtractCat` to do that:

```ts
type ExtractCat<A> = A extends { meow(): void } ? A : never

type Cat = ExtractCat<Animal>
// => Lion | Tiger
```

_I know lions and tigers don't meow, but how cute would it be if they did_ ^\_^

This seemed vague and magical to me at first. Let's see what TypeScript is doing under the hood when it evaluates
`ExtractCat<Animal>`.

First, it applies `ExtractCat` recursively to all the members of `Animal`:

<!-- prettier-ignore -->
```ts
type Cat =
  | ExtractCat<Lion>
  | ExtractCat<Zebra>
  | ExtractCat<Tiger>
  | ExtractCat<Shark>
```

Then it evaluates the conditional types:

```ts
type Cat = Lion | never | Tiger | never
```

And then something fun happens... Remember that no values can ever be of type `never`? That makes it totally
meaningless to include `never` in a union type, so TypeScript just gets rid of it.

```ts
type Cat = Lion | Tiger
```

The TypeScript jargon for this kind of conditional type is **distributive conditional type**.

That 'distribution', where the union is unrolled recursively, only happens when the thing on the left of the
`extends` keyword is a plain type variable. We'll see what that means and how to work around it in the next
section.

## A real use-case for distributive conditional types.

A while ago I was building a Chrome extension. It had a 'background' script and a 'view' script that ran in
different execution contexts. They needed to communicate and share state, and the only way to do that is via
serializable message passing. I took inspiration from Redux and defined a global union type called `Action` to
model the messages that I wanted to be able to pass between the contexts.

```ts
type Action =
  | {
      type: "INIT"
    }
  | {
      type: "SYNC"
    }
  | {
      type: "LOG_IN"
      emailAddress: string
    }
  | {
      type: "LOG_IN_SUCCESS"
      accessToken: string
    }
// ...
```

And then there was a global `dispatch` function that I could use directly to broadcast messages across contexts

```ts
declare function dispatch(action: Action): void;

// ...

dispatch({
  type: "INIT"
})

// ...

dispatch({
  type: "LOG_IN",
  emailAddress: "david.sheldrick@artsy.net"
})

// ...

dispatch({
  type: "LOG_IN_SUCCESS",
  accessToken: "038fh239h923908h"
})
```

These usages are all typesafe and good and I could have left it there. I could have moved on to other things.

But there's this little voice inside my head. I think most developers have this voice.

```
INT. HIPSTER CO-WORKING SPACE - DAY

DAVID sits on an orange bean bag. His laptop rests askew on
his lap. He stares at colorful text on a dark screen.

A tiny whisper.

                    VOICE (V.O.)
        Psst!

David looks around for a moment and then stares back at the
laptop.

                    VOICE (V.O.)
        Psst! Hey!

Startled this time, David looks around again. He speaks to
nobody in particular.

                    DAVID
        Is someone there?

                    VOICE (V.O.)
        It's me, the conciseness devil.

A painful sigh of recognition.

                    DAVID
        Not you again! Leave me alone!

                    CONCISENESS DEVIL (V.O.)
        I've got an idea for you.

                    DAVID
        Go away! I'm busy solving user problems
        and creating business value.

                    CONCISENESS DEVIL (V.O.)
        But every time you call `dispatch` you
        are typing 6 characters of redundant
        code.
                    DAVID
        Oh no you're right! I must fix this.

MONTAGE

David proceeds to spend the next 2 hours wrestling with
TypeScript trying to figure out how to get rid of those
6 characters while retaining type safety.
```

We've all been there.

I wanted the dispatch function to work like this:

```ts
// first argument is 'type'
dispatch("LOG_IN_SUCCESS", {
  accessToken: "038fh239h923908h"
})
// no need to specify a second argument if the
// action has no parameters.
dispatch("INIT")
```
