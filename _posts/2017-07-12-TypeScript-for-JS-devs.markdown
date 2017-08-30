---
layout: epic
title: An overview of TypeScript 
date: 2017-07-12
categories: [emission, reaction, javascript, typescript]
author: [orta, christina]
---

# Types in My JavaScript?!

Yep, TS adds types to JavaScript.

As a general gist over the last few years we’ve gone from JS -> CoffeeScript -> TypeScript.

CoffeeScript has always been a very a separate language from JS, taking a lot of the best ideas from Ruby and applying that to JS.

TypeScript on the other hand is about taking JS and applying a lot of current language best practices to it

There are holes, it’s not a perfect language as it aims to reflect some of JS's language issues but it fills a lot of holes and provides a great dev experience once you’ve got past the learning curve.

[pitch the post]

<!-- more -->

# Why?

Can be used to help catch simple typos in you JS-like code, this is just the simplest thing - we’ll cover a lot of the hows soon. For now I wanna cover the why

```ts
const talk = {
  name: "TypeScript",
  audience: "Artsy"
}

console.log(talk.audlence)
                   ^~~~~~
```

## Many chefs, One codebase

This can make it easier to share code among multiple teams: the boundaries between code sections can have tighter contracts

## Many chefs, One codebase

The additional safety can help a lot with when it takes a while to get your code shipped

## Long-lasting builds

This problem can be compounded by having a heterogeneous series of deploys

# What is TypeScript?

## Type Inference 

Type inference, think static typing and dynamic typing and having the best of both worlds where you can opt out of irrelevant types, but still have the benefits of type checking.

There are a couple of way that TS goes about type inference.

```ts
const foo = 11 // type number
const bar = "abc" // type string


function add(a: number, b: number) {
  return a + b; // returns number
}
```

This can handle structuring/destructing too

```ts
let person = {
  name: "Jane",
  age: 20
}

person.age = "20"
```

And will generate common types for you

```ts
// infers an array of type number
const x = [1, 2, 3]

// a: (string | number)[]
const a = [1, null, '2']

// type any[]
const fruitBowl = [
  new Apple(), 
  new Pear(), 
  new Banana()
]
```

Contextual typing is where the type of an expression is implied by its location.


```ts
window.onmousedown = function(mouseEvent) {
  console.log(mouseEvent.buton) // compile Error
}
```

In this case the left side of the equals is used to infer the type on `window.onmousedown` so when we pass in an event parameter when know what methods we can use on and which are not available to it.

# Generally Opt-In

These systems allow you to integrate slowly because some of [...]

This allows you to pick and choose whether you want to implement types and how strict they should be.

```json
{
  "compilerOptions": {
    /* Basic Options */
    "target": "es5",
    "module": "commonjs",

    /* Strict Type-Checking Options */
    "strict": true               /* Enable all strict type-checking options. */
    // "noImplicitAny": true,    /* Raise error on expressions and declarations with an implied 'any' type. */
    // "strictNullChecks": true, /* Enable strict null checks. */
    // "noImplicitThis": true,   /* Raise error on 'this' expressions with an implied 'any' type. */
    // "alwaysStrict": true,     /* Parse in strict mode and emit "use strict" for each source file. */

    /* Additional Checks */
    // "noUnusedLocals": true,                /* Report errors on unused locals. */
    // "noUnusedParameters": true,            /* Report errors on unused parameters. */
    // "noImplicitReturns": true,             /* Report error when not all code paths in function return a value. */
    // "noFallthroughCasesInSwitch": true,    /* Report errors for fallthrough cases in switch statement. */
  }
}
```

# Flexible with Typing

There are ways around types, for example, using things like the type any.

```ts
let foo = 11;
foo = 'eleven'
foo = 'eleven' as any
```

Always emits JS even when there are compile errors.

# Interfaces

Interfaces are a great way to define contracts within you code. Interfaces provide shape when declaring things like variables. 

The person object fails to compile because an object with type of person expects to have the property isMillennial.

This means when you refactor, then you’ll start getting messages throughout your app saying where changes need to be applied. This means you can trust your code a lot more.

```ts
interface Person {
  name: string
  interest: any
  isMillennial: boolean
  phoneNumber?: string
}

const myPerson: Person = {
  name: "Jane",
  interest: ["music", "reading", "dancing"],
  phoneNumber: "555-555-5555"
}
```

A very common technique in our code is to extend interfaces:

```ts
interface ArtsyPerson extends Person {
  role: string
  joined: string
  floor?: string
}

const artsyEmployee: ArtsyPerson = {
  name: "Christina",
  role: "Engineer",
  joined: "2 years ago",
  floor: "25"
}

```

You might wonder how this fits with ES6 classes? You can use classes as at Type. TypeScript classes are not much different then the first class language construct in Traditional JS. In TypeScript you can use classes to define a specific type.

```ts
interface Point {
  x: number 
  y: number
}

class MyPoint implements Point {
   x: number; y: number; 
}

let point: MyPoint = new MyPoint()
point.x = 3;
point.y = 8;

point.y = "10"; // compile error
```

# Generics



TypeScript (especially code we write with React) heavily uses generics to handle related classes. 

In this case, we’re saying we want an Array with an associated type of string. This allows TypeScript to know what type of object would be returned from a get function.

```ts
const names: Array<string> = [
  "christina", 
  "orta",
  "danger"
]
```

Without generics, you’d have to create a version of the array that only returns a specific type. Instead you would say “this is an array - and everything inside it is going to be a string” [...]

```ts
const names: ArrayString = [
  "christina", 
  "orta",
  "danger"
]
```

There is shorthand for this in the form of `array[]`.

## Generic Promises

Let’s look at another example - Promises

In this case we are stating that the promise will return a number. This associates the returned value inside the promise with the API. It means we would get compiler errors if that is treated as a string.

```ts
const getAge:Promise<number> = new Promise(res => 5)

const age = await getAge()
if (age === "18") {
  ...
}
```

## Generic Functions

These are useful for when you have a function which allows you to work with many types, and keep them consistent. 

For example this reverse array function will take a type called T, which comes from the param and it will return an array of the same type

This is generally only useful for utilities funds, classes or libraries

```ts
function reverseArray<T>(arr:T[]): T[] {
  return arr.reverse()
}

const nums = [1, 2, 3]
console.log(reverseArray(nums)) // [3, 2, 1]

const strs = ["1", "2", "3"]
console.log(reverseArray(strs)) // ['3', '2', '1']
```

## Generics in Production

Speaking of which, this is the definition of a React component. Let’s clean this up.

```js
// Base component for plain JS classes
class Component<P, S> implements ComponentLifecycle<P, S> {
    constructor(props?: P, context?: any);
    setState<K extends keyof S>(f: (prevState: S, props: P) => Pick<S, K>, callback?: () => any): void;
    setState<K extends keyof S>(state: Pick<S, K>, callback?: () => any): void;
    forceUpdate(callBack?: () => any): void;
    render(): JSX.Element | null;

    props: Readonly<{ children?: ReactNode }> & Readonly<P>;
    state: Readonly<S>;
    context: any;
    refs: {
        [key: string]: ReactInstance
    };
}
```

If we cut this down to size:

```ts

class Component<P, S> {
    constructor(props?: P, context?: any)
 
    props: Readonly<{ children?: ReactNode }> & Readonly<P>
    state: Readonly<S>
    context: any
}
```

OK, so this is a generic class - it has 2 associated types: P and S. You can see that in the constructor it take a P.

Next you can spot that props is a Readonly version of P, and under that is state which is a Readonly version of S

We’ll dig into this at the end, but for now you can have a rough idea that a class, or a function can associate with different types - and that is called generics.

# Nullability

Wanna cover nullability, this is a concept introduced to me in Swift that maps well to TypeScript. It works with inference and can really help remove a whole set of potential bugs. Before we can talk about nullability, we need to talk about union types.


TODO: Inline comments
```ts
interface ContrivedButton {
  state: true | false
  enabled: "on" | "off"
  
  color: string | string[]
  colors: string | string[]

  delegate: any | null
  callback?: (enabled: boolean) => void
}

```

[...]

```ts
interface User {
  displayName: string | null
}

const person: User = [...]

// Cannot assume that `displayName`
// is a string value.
console.log(
  person.displayName.split(" “)
)
```

[Deviate from the slides here, explain nullability.]

# Types for Tools

The source code for TypeScript is contains two projects, the compiler and the server.

TSC the typescript compiler is a pretty simple compiler, files in -> files out. It’s a progressive compiler, so you can choose which version of JS you want, as well as some options around language features.

It’s not babel though. Options are limited.

## TSServer

The TypeScript server is the reference implementation of a standard for handling languages to IDE support. 

## Lang protocol

This means you create the lang server in your own language, with its own tools and so long as you conform to the protocol an editor only needs to concentrate on building support for the protocol. This means most lang servers are built in the same language it aims to support.

[diagram of lang server]

You need a simple JSON RPC client that passes messages between the two. 

By using a type system, the compiler can understand connections much better.
These can be inferred, or explicit. By making those connections you get:
autocompletion, jump to definition, inline documentation, inline errors, recommended fixes, inline errors/warnings or actionable annotations

These can work together to speed up your dev-time process, by catching things before you’ve even saved a file, or when a dependency has updated and it’s change the API surface.

# It's an Untyped World

NPM has a lot of untyped code 

There are 4 ways to handle this [...]

## Inference
## Write it in TS
## Add a d.TS to your lib

An example of this is the spotify web api library. Within the library there is a searchTracks function and this interface describes what parameter it accepts `spotifyApi.searchTracks(queryTerm, {limit: 5})`

```ts
declare namespace SpotifyApi {

    //
    // Parameter Objects for searching
    //

    /**
     * Object for search parameters for searching for tracks..
     * See: [Search for an item](https://developer.spotify.com/)
     *
     */
    interface SearchForItemParameterObject {
        q?: string;
        type?: string;
        market?: string;
        limit?: number;
        offset?: number;
    }
    // …

```


## Add to DefinitelyTyped

Every library author hasn’t hoped on the the TS train and a d.ts may not exist in library. In this case anyone can add a declaration file in the DefinitelyTyped project that contains type definition for a number of projects.

For example: Relay recently updated the library to add relay modern which has a whole new set of types. I’ve been working on updating the types for relay modern and this is a code snippet of what that looks like.

```ts
// Type definitions for react-relay 0.9.2
// Project: https://github.com/facebook/relay
// Definitions by: Johannes Schickling <https://github.com/graphcool>
// Definitions: https://github.com/DefinitelyTyped/DefinitelyTyped
// TypeScript Version: 2.1

// import * as Relay from "react-relay"

declare module "react-relay/modern" {
    import * as React from "react";

    interface QueryRendererProp {
        cacheConfig?: any,
        environment: Environment | ClassicEnvironment,
        query: GraphQLTaggedNode,
        render: (readyState: ReadyState) => (React.ReactElement<any>) | null,
        variables: Variables,
    }

    interface ReadyState {
        error: any,
        props: any,
        retry: any,
    }

    class QueryRenderer extends React.Component<QueryRendererProp,ReadyState> {}

```

# TypeScript with React

[todo: annotate this]

```ts
const BorderClassname = "border-container"

export interface InputProps extends React.HTMLProps<HTMLInputElement> {
  error?: boolean
  block?: boolean
  rightView?: JSX.Element
}

interface InputState {
  borderClasses: string
}

class Input extends React.Component<InputProps, InputState> {
  constructor(props) {
    super(props)
    this.state = {
      borderClasses: BorderClassname,
    }
  }

  onFocus(e: React.FocusEvent<HTMLInputElement>) {
    this.setState({
      borderClasses: `${BorderClassname} focused`,
    })
  }

  ...
}
```


[TODO: wrapup]
