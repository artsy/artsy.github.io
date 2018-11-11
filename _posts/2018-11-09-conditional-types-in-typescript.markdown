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
declare function dispatch(action: Action): void

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
        It's me, the DRY devil.

David heaves a painful sigh of recognition.

                    DAVID
        Not you again! Leave me alone!

                    DRY DEVIL (V.O.)
        DRY stands for "Don't Repeat Yourself"

                    DAVID
        I know, you say that every time! Now
        get lost!

                    DRY DEVIL (V.O.)
        I've noticed an issue with your code.

                    DAVID
        Seriously, go away! I'm busy solving
        user problems to create business value.

                    DRY DEVIL (V.O.)
        Every time you call `dispatch` you
        are typing 6 redundant characters.

                    DAVID
        Oh snap! You're right! I must fix this.

MONTAGE

David spends the next 2 hours wrestling with TypeScript,
accumulating a pile of empty coffee cups and protein ball
wrappers.
```

We've all been there.

I wanted the dispatch function to work like this:

```ts
// first argument is the 'type'
// second is any extra parameters
dispatch("LOG_IN_SUCCESS", {
  accessToken: "038fh239h923908h"
})
```

Deriving the type for that first argument is easy enough

```ts
type ActionType = Action["type"]
// => "INIT" | "LOG_IN" | "LOG_IN_SUCCESS"
```

But what about the second argument? The exact type _depends on_ the first argument. We can use a type variable for
that.

<!-- prettier-ignore -->
```ts
declare function dispatch<T extends ActionType>(
  type: T,
  args: ExtractActionParameters<Action, T>
): void
```

_Woah woah woah, what's this_ `ExtractActionParameters` _voodoo?_

It's a conditional type of course! Here's a first stab at implementing it:

```ts
type ExtractActionParameters<A, T> = A extends { type: T } ? A : never
```

This is a lot like the `ExtractCat` example from before, where we were were refining the `Animals` union by
searching for something that can `meow()`. Here, we're refining the `Action` union type by searching for an action
with a particular `type` property. Let's see if it works:

```ts
type Test = ExtractActionParameters<Action, "LOG_IN">
// => { type: "LOG_IN", emailAddress: string }
```

Almost there! We don't want to keep the `type` field after extraction because then we would still have to specify
it when calling `dispatch`. And that would somewhat defeat the purpose of this entire exercise.

We can get rid the `type` field by combining a **mapped type** with a conditional type and the `keyof` operator.

A **mapped type** lets you create a new type by 'mapping' over a union of keys. You can get a union of keys from an
existing type by using the `keyof` operator. And finally, you can remove things from a union using a conditional
type. Here's how they play together (with some inline test cases for illustration):

```ts
type ExcludeTypeKey<K> = K extends "type" ? never : K

type Test = ExcludeTypeKey<"emailAddress" | "type" | "foo">
// => "emailAddress" | "foo"

// here's the mapped type
type ExcludeTypeField<A> = { [K in ExcludeTypeKey<keyof A>]: A[K] }

type Test = ExcludeTypeField<{ type: "LOG_IN"; emailAddress: string }>
// => { emailAddress: string }
```

Then we can use `ExcludeTypeField` to redefine `ExtractActionParameters`:

<!-- prettier-ignore -->
```ts
type ExtractActionParameters<A, T> = A extends { type: T }
  ? ExcludeTypeField<A>
  : never
```

And now the new version of `dipsatch` is type safe!

```ts
// All clear! :)
dispatch("LOG_IN_SUCCESS", {
  accessToken: "038fh239h923908h"
})

dispatch("LOG_IN_SUCCESS", {
  // Type Error! :)
  badKey: "038fh239h923908h"
})

// Type Error! :)
dispatch("BAD_TYPE", {
  accessToken: "038fh239h923908h"
})
```

But there's one more very serious problem to address: If the action has no extra parameters, I still have to pass a
second empty argument:

```ts
dispatch("INIT", {})
```

That's four whole wasted characters! Cancel my meetings and tell my partner not to wait up tonight, we are going to
_fix this_.

The naïve thing to do would be to make the second argument optional. That would be unsafe because, e.g. it would
allow us to dispatch a `"LOG_IN"` action without specifying an `emailAddress`.

Instead, let's overload the `dispatch` function.

<!-- prettier-ignore -->
```ts
// And let's say that any actions that don't require
// extra parameters are 'simple' actions.
declare function dispatch(type: SimpleActionType): void
// this signature is just like before
declare function dispatch<T extends ActionType>(
  type: T,
  args: ExtractActionParameters<Action, T>
): void

type SimpleActionType = ExtractSimpleAction<Action>['type']
```

But how can we define this `ExtractSimpleAction` conditional type? We know that if we remove the `type` field from
an action and the result is an empty interface, then that is a simple action. So something like this might work

```ts
type ExtractSimpleAction<A> = ExcludeTypeField<A> extends {} ? A : never
```

Except that doesn't work. `ExcludeTypeField<A> extends {}` is always going to be true, because `{}` is like a top
type for interfaces. _Pretty much everything_ is more specific than `{}`.

So we have to switch the arguments around:

```ts
type ExtractSimpleAction<A> = {} extends ExcludeTypeField<A> ? A : never
```

Now if `ExcludeTypeField<A>` is empty, the condition will be true, otherwise it will be false.

But this still doesn't work! On-the-ball readers might remember this:

> That 'distribution', where the union is unrolled recursively, only happens when the thing on the left of the
> `extends` keyword is a plain type variable. We'll see what that means and how to work around it in the next
> section.

-- Me

_We're in the next section right now_ 🤯.

A plain type variable looks like this: `A`. Or like this: `Foo`. Or like this: `ROFL`.

A plain type variable does not look like this: `{}`. Or like this: `ExcludeTypeField<A>`. And probably not like
this: `string`.

TODO: Explicitly define a type variable. This is not great.

When I discovered that the thing to the left of `extends` needed to be a plain type variable I thought that it
signalled a fundamental limitation in the way distributive conditional types work under the hood. I thought it was
some kind of concession to algorithmic complexity. I thought that my use case was too advanced, and that TypeScript
had just thrown its hands up in the air and said, "Sorry mate, you're on your own".

But it turns out I was wrong. This is just a bizzare and unintuitive bit of language design and you can work around
it easily:

<!-- prettier-ignore -->
```ts
type ExtractSimpleAction<A> = A extends any
  ? {} extends ExcludeTypeField<A>
    ? A
    : never
  : never
```

All we did is wrap the meat of our logic in a flimsy tortilla of inevitability, since the outer condition
`A extends any` will, of course, always be true.

The unrolling happens specifically to `A` because that's just how you decide which union to unroll: by placing it
to the left of `extends`.

And finally we can delete those four characters 🎉🕺🏼💃🏽🎈

```ts
dispatch("INIT")
```

One yak successfully shaved ✔

---

TypeScript has a couple of built-in types that we could have used in this section:

```ts
// Exclude from U those types that are assignable to T
type Exclude<U, T> = U extends T ? never : U

// Extract from U those types that are assignable to T
type Extract<U, T> = U extends T ? U : never
```

e.g. instead of defining `ExcludeTypeField` like this:

```ts
type ExcludeTypeField<A> = { [K in ExcludeTypeKey<keyof A>]: A[K] }
```

we could have done this:

```ts
type ExcludeTypeField<A> = { [K in Exclude<keyof A, "type">]: A[K] }
```

And instead of defining `ExtractActionParameters` like this:

<!-- prettier-ignore -->
```ts
type ExtractActionParameters<A, T> = A extends { type: T }
  ? ExcludeTypeField<A>
  : never
```

we could have done this:

```ts
type ExtractActionParameters<A, T> = ExcludeTypeField<Extract<A, { type: T }>>
```

TODO: add ts playground links for the various stages of this tutorial

## Destructuring types with `infer`

Conditional types have another trick up their sleeve: the `infer` keyword. It can be used anywhere in the type
expression to the right of the `extends` keyword. It gives a name to whichever type would appear in that place.
e.g.

```ts
type Unpack<A> = A extends Array<infer E> ? E : A

type Test = Unpack<Apple[]>
// => Apple
type Test = Unpack<Apple>
// => Apple
```

It handles ambiguity gracefully:

```ts
type Stairs = Unpack<Apple[] | Pear[]>
// => Apple | Pear
```

You can even use `infer` multiple times.

```ts
type Flip<T> = T extends [infer A, infer B] ? [B, A] : never
type Stairs = Flip<[Pear, Apple]>
// => [Apple, Pear]

type Union<T> = T extends [infer A, infer A] ? A : never
type Stairs = Union<[Apple, Pear]>
// => Apple | Pear
```

## Other built-in conditional types

We've already seen `Exclude` and `Extract`, and TypeScript provides a few other conditional types out of the box.

<!-- prettier-ignore -->
```ts
// Exclude null and undefined from T
type NonNullable<T> =
  T extends null | undefined ? never : T

// Obtain the parameters of a function type in a tuple
type Parameters<T> =
  T extends (...args: infer P) => any ? P : never

// Obtain the parameters of a constructor function type in a tuple
type ConstructorParameters<T> =
  T extends new (...args: infer P) => any ? P : never

// Obtain the return type of a function type
type ReturnType<T> =
  T extends (...args: any[]) => infer R ? R : any

// Obtain the return type of a constructor function type
type InstanceType<T> =
  T extends new (...args: any[]) => infer R ? R : any
```

## Further reading

- [TypeScript 2.8 release notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-2-8.html)
- [Microsoft/Typescript#21316](https://github.com/Microsoft/TypeScript/pull/21316) Conditional types pull request
- [Microsoft/Typescript#21496](https://github.com/Microsoft/TypeScript/pull/21496) `infer` pull request
- [lib.es5.d.ts#L1446](https://github.com/Microsoft/TypeScript/blob/a2205ad53d8f65a129a552b752d1e06fee3d41fc/lib/lib.es5.d.ts#L1446)
  built-in conditional type definitions
