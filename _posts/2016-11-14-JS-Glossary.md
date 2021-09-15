---
layout: epic
title: "JavaScript Glossary for 2017"
date: 2016-11-14 12:17
author: orta
categories: [javascript, emission, danger]
series: React Native at Artsy
---

Getting to grips with the entire JavaScript ecosystem is a tough job when you're getting started. Coming from the native mobile space, there's a lot to learn. I've spent a few months immersed in the environment now, and can try summerize a lot of topics. This should make it easier to find more information when you need it. This post is semi-opinionated, with links for further reading so you can get a different perspective too.

This post focus specifically on the JavaScript tooling around React Native projects, but is applicable to all JavaScript projects. 

<!-- more -->

Lets start with the entire reason we are using JavaScript for mobile in the first place: React and React Native,

# React 

### React

React is a Facebook project which offers a uni-direction Component model that _can_ replace MVC in a front-end application. React was built out of a desire to abstract away a web page's true view hierarchy (called the DOM) so that they could make changes to all of their views and then React would handle finding the differences between view states.

Its model is that you would create a set of Components to encapsulate each part for the state of the page. React makes it easy to make components that are functional in the [Functional Reactive Programming](https://en.wikipedia.org/wiki/functional_reactive_programming) sense. They act like a function which takes some specially declared state and it is rendered into HTML.


A component optionally uses a language called [JSX](#jsx) to visualise how each component's child components are set up,here's an example of a React component using JSX [from Emission, our React Native library][search-bar]:  

```js
export default class SearchBar extends React.Component {
  render() {
    return (
      <TouchableWithoutFeedback onPress={this.handleTap.bind(this)}>
        <View style={styles.container}>
          <Image style={styles.searchIcon} source={require('../../../images/SearchButton.png')}/>
          <Text style={styles.text}>Search for artists and artworks...</Text>
        </View>
      </TouchableWithoutFeedback>
    )
  }

  handleTap() {
    Switchboard.presentModalViewController(this, '/search')
  }
}
```

By providing a well encapsulated Component model, you can aggressively reduce the amount of redundant code you need to build an application. By not initially writing to the DOM, React can decide what has changed between user actions and that means you have to juggle significantly less [state](#state).

### React Native

I came to this conclusion early this year that writing native apps using compiled code is a pain, and it's been amazing to be able to work in React Native in contrast.

React Native is an implementation of React where instead of having it abstract a web page's DOM, it creates a native view hierarchy. In the case of iOS that is a UIView hierarchy. Note that it does not handle View Controllers. The MVC model from Apple's Cocoa framework does not directly map into React Natives. I've wrote about how we [bridge that gap earlier][our-implmentation].

React Native is cross platform. You write JavaScript like above, which React Native transforms into a native view hierarchy. That view hierarchy could be on a Samsung TV, a Windows phone or Android instead. 

It's a smart move, most "Make apps in JS" try to have a native-like experience where they replicate the platform's UI in HTML. However, this technique tends to feel unnatural very easily. If I showed you our app, you could not distinguish between a view controller in React Native, Swift or Objective-C.

### App State

Think of every variable inside your application, that is your application's state. You could not make an app worth using without state. In MVC, MVVM, VIPER and other native patterns, there is no consistent way to handle changes in those variables. React uses a common state pattern though the use of specific terminology: "[props](#props)", "[context](#context)" and "[state](#state-again)". 

Yes, the "state" and "state" thing is a little confusing, we'll get to it.

### Props

Props are chunks of app state that are passed into your component from a parent component. In [JSX](#jsx) this is represented as an XML attribute.

Let's check out [an example][jsx-example]:

```js
export default class Header extends React.Component {
  [...]
  render() {
    return (
        <View style={styles.followButton}>
            <InvertedButton text={this.state.following ? 'Following' : 'Follow'}
                            selected={this.state.following}
                            onPress={this.handleFollowChange} />
        </View>
    )
  }
}
```

See the `InvertedButton` component, it has three `props` being passed in: `text`, `selected` and `onPress`. If any of those props were to change the entire `InvertedButton` component would be re-rendered to the native view hierarchy. These `props` are the key to passing data downwards through your hierarchy. Note: you cannot access the parent component (without passing it in as a prop.)

You should therefore consider `props` as immutable bits of app state relevant to the component it's being passed into. 

### State-again

A component also has a `state` attribute. The key to understanding the difference between `props` and `state` is: `state` is something controlled within that component that can change - `props` do not. 

The above example is a pretty good example of this, when this component is first added to the hierarchy, we send a networking request to get whether you are following something or not. The parent component (`Header`) does not need to update when we know whether you are following or not, but the `InvertedButton` does. So, it is `state` for the parent, but a `prop` for the `InvertedButton`. This means changing the state for `following` will only cause a re-render in the button.

So state is something which changes within a component, which _could_ be used as `props` for it's children. Examples of this are around handling animation progress, whether you're following something, selection indices and any kind of networking which we do outside of [Relay](#relay).

If you'd like to read more, there is a much deeper explanation in [uberVU/react-guide][react-guide]   

### Context

[The docs][context_docs] are pretty specific about context:

> If you aren't an experienced React developer, don't use context. There is usually a better way to implement functionality just using props and state.

Seems to be something that you should only be using in really, really specific places. If you need it, you don't need this glossary.

### JSX

As we'll find out later, modern JavaScript is a collection of different ideas, and using [Babel](#babel) - you can add them at will into your projects. JSX is one such feature, it is a way of describing nested data using XML-like syntax. These are used inside React's render function to express a component's children and their [props](#props).

Under the hood, JSX is quite simple, with code looking like this:

```js
const element = (
  <h1 className="greeting">
    Hello, world!
  </h1>
);
```

Turning into 

```js
const element = React.createElement(
  'h1',
  {className: 'greeting'},
  'Hello, world!'
);

```

Where `createElement` comes from the React [module](#module). You can find out more in [the React docs][react_jsx]

# Libraries

### GraphQL

TLDR: An API format for requesting only the data you want, and getting back just that. 

If you want the longer explanation, I wrote a [blog post on it](/blog/2016/06/19/graphql-for-mobile/).

### Relay

Relay is what makes working in our React Native app shine. It is a library that allows a component to describe small chunks of a networking request it would need to render. Relay would then look through your component hierarchy, take all the networking fragments, make a single GraphQL request for all the data. Once it has the data, Relay passes in the response as [props](#props) to all of the components in the tree.

This means you can throw away a significant amount of glue code.

### Redux

Redux is a state management pattern, it builds on top of React's "state is only passed down" concept, and creates a single way to handle triggering changes to your state. I'm afraid I don't have any experience with it, so I can't provide much context. I feel like [this post][what_redux] covers it well though.   

# Tooling


### Node

Node is the JavaScript implementation from Google's Chrome (called v8) with an expanded API for doing useful systems tooling. It is a pretty recent creation, so it started off with an entirely asynchronous API for any potentially blocking code.

For web developers this was a big boon, you could share code between the browser and the server. The non-blocking API meant it was much easier to write faster servers, and there are lots of big companies putting a lot of time and money into improving the speed of JavaScript every day.

Node has an interesting history of ownership, I won't cover it here, but [this link][node_history] provides some context.

### NPM

NPM is the Node Package Manager. It is shipped with node, but it is a completely different project and team. NPM the project is ran by a private company.

NPM is one of the first dependency managers to offer the ability to install multiple versions of the same library inside your app. This contributes considerably to the issue of the number of dependencies inside any app's ecosystem.

JavaScript people will always complain about NPM, but people will always complain about their build tools. Dependency Manager's especially. From an outsider's view, it nearly always does what you expect, has a great team behind it and has more available dependencies than any other.

NPM works with a `Package.json` file as the key file to represent all the different dependencies, version, authors and misc project metadata.

### Yarn

Yarn is a NPM replacement (ish) by Facebook. It's very new. It solves three problems, which were particularly annoying to me personally.

* It flattens dependencies - this means that you're less likely to have multiple versions of the same library in your app.
* It uses a lockfile by default - this means that everyone on your team gets the same build, instead of maybe getting it.
* It is significantly faster.

It uses the NPM infrastructure for downloading [modules](#modules), and works with the exact same `Package.json`. I moved most of our projects to it.

### Babel

I mentioned JSX a few times above. JSX is not a part of JavaScript, it is transpiled from your source code (as XML-like code) into real JavaScript. The tool that does this is Babel.

Babel is a generic JavaScript transpilation engine. It does not provide any translation by default, but instead offers a plugin system for others to hook in their own transpilation steps. This becomes important because a lot of JavaScript features have staggered releases between browsers and you can't always guarantee each JavaScript runtime will have the features you want to use.  

Babel's plugins can be configured inside your `Package.json`. To ship your code to the world, you then create a script of some sort to convert your source code into "olde world" JavaScript via Babel.

In the case of a react-native project, Babel is happening behind the scenes.

### Webpack

A JavaScript source code & resource package manager. It can be easy to confuse Babel + Webpack, so in simple: 

* Babel will directly transform your source code file by file 
* Webpack will take source code and merge it all into one file 

They work at different scopes. Webpack is mainly a web front-end tool, and isn't used in React Native. However, you'll come across it, and it's better to know the scope of it's domain. 

### ESLint

How can you be sure your syntax is correct? JavaScript has a really powerful and extensible linter called ESLint. It parses your JavaScript and offers warnings and errors around your syntax. You can use this to provide a consistent codebase, or in my case, to be lazy with your formatting. Fixing a lot of issues is one command away. I have [my editor][using-code] auto indent using ESLint every time I press save.  

# Development

### Live Reload

This is a common feature in JavaScript tooling. If you press save in a source file then some action is taken. Live Reloading tends to be a more blunt action, for example reloading the current view from scratch, or running all of the tests related to the file.  

### Hot-Reloading

Hot Reloading is more rare, because it's significantly harder. Hot Reloading for React projects is injecting new functions into the running application, and keeping it in the same state. 

For example if you had a filled-in form on your screen, you could make styling changes inside your source file and the text inside the form would not change. Hot reloading is amazing.

### Haste Map

Part of what makes React Native support Hot Reloading, and allows [Jest](#jest) to understand changes for testing is by using a Haste Map. A Haste Map is a dependency resolver for JavaScript, looking through every function to know how it connects to every other function within the JavaScript project. 

With the dependencies mapped, it becomes possible to know what functions would need replacing or testing when you press save after writing some changes. This is why it takes a bit of time to start up a React Native project. 

The public API is deprecated, you shouldn't use it in your projects, but the [old README is still around][haste].

# Testing

### Jest

Facebook have their own test runner called Jest. It builds on [Jasmine][jasmine], and offers a few features that kick ass for me:

* Re-runs failing tests first
* Assumes all tests unrelated to changes are green and doesn't run them
* Watch mode that works reliably 

I miss these features when I'm not in a Jest project.

### Jest Snapshots

Jest has a feature called Jest Snapshots, that allows you to take "snapshots" of JavaScript objects, and then verify they are they are the same as they were last time. In iOS we [used visual snapshot][snapshots] testing a lot.

### VSCode-Jest

I created a project to auto-run Jest inside projects that use it as a test runner when using Visual Studio Code: [vscode-jest][vscode-jest]. I've wrote about our usage of VS Code [on this blog series][using-code] also.  

# JavaScript the Language

I'm always told that JavaScript was created in 10 days, which is a cute anecdote, but JavaScript has evolved for the next 21 years. The JavaScript you wrote 10 years ago would still run, however modern JavaScript is an amazing and expressive programming language once you start using modern features.

Sometimes these features aren't available in [node](#node), or your browser's JavaScript engine, you can work around this by using a transpiler, which takes your source code and backports the features you are using to an older version of JavaScript.  

### ES6

JavaScript is run by a committee. Around the time that people were starting to talk about HTML5 and CSS3, work was started on a new specification for JavaScript called ECMAScript 6.

ES6 represents the first point at which JavaScript really started to take a lot of the best features from transpile to JavaScript languages like CoffeeScript. Making it feasible for larger systems programming to be possible in vanilla JavaScript.  

### ES2016

It took forever for [ES6](#es6) to come out, and every time they created / amended a specification there were multiple implementations of the specification available for transpiling via [babel](#babel). This I can imagine was frustrating for developers wanting to use new features, and specification authors trying to put out documentation for discussion as a work in progress. This happened a lot [with the Promises](#promises) API.

To fix this they opted to discuss specification features on a year basis. So that specifications could be smaller and more focused, instead of major multi-year projects. Quite a SemVer jump from 6 to 2016.

### Stages

Turns out that didn't work out too well, so the terminology changed again. The change is mainly to set expectations between the Specification authors and developers transpiling those specifications into their apps.

Now an ECMAScript language improvement specification moves through a series of stages, depending on their maturity. I [believe starting][stages] at 0, and working up to 4. 0 Idea, 1 Proposal, 2 Draft, 3 Accepted and 4 Done. 

So a ECMAScript Stage 0 feature is going to be really new, if you're using it via a transpiler then you should expect a lot of potential API changes and code churn. The higher the number, the longer the spec has been discussed, and the more likely for the code you're transpiling to be the vanilla JavaScript code in time.

The committee who discussed these improvements are the [TC39][tc39] committee, the cool bit is that you can see [all the proposals][tc39-github] as individual GitHub repos so it's convenient to browse. 


### Modules / Imports

A modules is the terminology for a group of JavaScript code. Terminology can get confusing, as the import structure for a library is very similar to importing a local file.

You can import a module using syntax like `import { thin, other } from "thingy"`. Here's some examples [from our project][imports]:

```js
// Import modules
import Relay from 'react-relay'
import React from 'react'
// Import two items from the react-native module 
import { View, TouchableWithoutFeedback } from 'react-native'

// Import the default class from a local file
import ImageView from '../../opaque_image_view'
import SwitchBoard from '../../../native_modules/switch_board'
```

An import can either have [a default export][default-export], or a set of [exportable function/objects][export-func].

You might see an import like `const _ = require("underscore")` around the internet, this is an older format for packaging JavaScript called [CommonJS][commonjs]. It was replaced by the `import` statements above because you can make guarantees about the individual items exported between module boundaries. This is interesting because of [tree-shaking](#tree-shaking), which we'll get to later. 

### Classes

Modern JavaScript has classes introduced in [es6](#es6), this means that instead of writing something like:

```js
const danger = {
  name: "Danger",
  hello: function () {
    console.log("Hi!")
  }
}

danger.hello();
```

Instead you could write:

```js
class Person {
  constructor(name) {
    this.name = name
  }
  hello() {
    console.log("Hi!")
  }
}

const danger = new Person("danger")
danger.hello()
```

Classes provide the option of doing object-oriented programming, which is still a solid way to write code. Classes provide a simple tool for making interfaces, which is really useful when you're working to the [Gang of Four][gof] principals:

> “Program to an interface, not an implementation,” and “favor object composition over class inheritance.”

### Prototypical

So, classes - it took 20ish years before they happened? Before that JavaScript was basically only a prototype-based language. This meant you created "objects" but that they were just effectively just key-value stores, and you used functions to do everything else.

The language is a great fit for functional programming, I ended up building [an Artsy chat bot][mitosis] using only functions by accident. Really, a few days into it when I started looking for an example class to show in this post I realised I didn't have one. Whereas in Danger I do almost exclusive OOP in JavaScript, sometimes the project fits the paradigm too. 

A really good, and highly opinionated post on the values of prototypical/functional programming in JavaScript is [The Two Pillars of JavaScript](https://medium.com/javascript-scene/the-two-pillars-of-javascript-ee6f3281e7f3#.knm7xb7zr) - I agree with a lot of it.

### Mutablilty

JavaScript has had a keyword `var` to indicate a variable forever. You should basically never use this. I've never written one this year, except by accident. It's a keyword that has a really confusing scope, leading to odd bugs. [ES6](#es6) brought two replacements, both of which will give you a little bit of cognitive dissonance if you have a lot of Swift experience.

`let` - the replacement for `var`, this is a _mutable_ variable, you can replace the value of a `let`. The scope of a `let` is exactly what you think from every other programming language.
`const` - this is a `let` that won't allow you to change the _value_. So it creates a mutable object (all JS objects are mutable) but you cannot replace the object from the initial assignment.  

### This

The keyword `this` is a tricky one. It is confusing because `this` gets assigned to the object that invokes the function where you use `this`.

It's confusing because you may have a function inside a class, and would expect `this` to be the instance to which the function is attached to, but it very easily could not be. For [example](https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/artist/articles/article.js#L11-L22):

```js
class Article extends React.Component {
  handleTap() {
    SwitchBoard.presentNavigationViewController(this, this.props.article.href)
  }

  render() {
    [...]
    return (
      <View style={styles.container}>
        <TouchableWithoutFeedback onPress={this.handleTap}>

``` 

In the above example `this` inside `handleTap` does not refer to the instance of Article. Tricky right? 

There are two "easy" fixes, [using arrow functions][arrow-func] instead if normal functions:

```js
class Article extends React.Component {
  handleTap = () => {
    SwitchBoard.presentNavigationViewController(this, this.props.article.href)
  }
  [...]
```

Or you can use the `bind` function to ensure that `this` inside the function is what you want it to be.  

```js
class Article extends React.Component {
  [...]

  render() {
    [...]
    return (
      <View style={styles.container}>
        <TouchableWithoutFeedback onPress={this.handleTap.bind(this)}>
```

This is a great in-depth explanation of the way it works: [Understanding the “this” keyword in JavaScript][this]. 

### Strict Mode

Introduced in ECMAScript 5.1, it provides a way to [opt-in to more errors][strict-mode] inside the JavaScript runtime. As you're likely to be using both a linter and a transpiler to keep your source clean, I'm less worried about including it on every page. 

### Destructuring

Object destructuring is one of those things that saves a little bit of code all the time. It's especially useful given the amount of time you spend passing around plain old JavaScript objects. This is something that CoffeeScript took from Ruby:

```js
> const [orta, danger] = [33, 23]
undefined
> danger
23
> orta
33
```

or for an Object

```
> const user = { name: "Danger", age: 27 }
undefined
> const { name,  age }  = user
undefined
> name
'Danger'
> age
27
```

This makes it really easy to pull out subsets of existing objects and set them as variables.

### Arrow Functions

In JavaScript a function has always looked like:

```js
function(arg1, arg2) {
  [...]
}
```

This gets frustrating when you're doing functional-style programming, where you use closures for mapping, filtering and others. So instead [ES6](#es6) introduced terser ways of doing this. So I'm going to write the same function multiple times:

```js
// The way it's always been
function (lhs, rhs) {
    return lhs.order > rhs.order
}

// An arrow function version
(lhs, rhs) => {
    return lhs.order > rhs.order
}

// An implicit return, and no braced one-liner arrow function
(lhs, rhs) => lhs.order > rhs.order 
```

### Promises

[Node](#node) is renowned for having a non-blocking API from day one. The way they worked around this is by using callbacks everywhere. This can work out pretty well, but eventually maintaining and controlling your callbacks turns into it's own problem. This can be extra tricky around handing errors.

One way to fix this is to have a Promise API, Promises offer consistent ways to handle errors wand callback chaining.

JavaScript now has a built-in a Promise API, this means every library can work to one API when handling any kind of asynchronous task. I'm not sure what ECMA Specification brought it in. This makes it really easy to make consistent code between libraries. However, more importantly, it makes it possible to have async/await.

### Async/Await

Once Promises were in, then a language construct could be created for using them elegantly. They work by declaring the entire function to be an `async` function. An async function is a function which pretends to be synchronous, but behind the scenes is waiting for specific promises to resolve asynchronously.

There are a few rules for an `async` function:

* You cannot use `await` inside a function that has not been declared `async`. 
* Anything you do return will be implicitly wrapped in a Promise
* Non-async functions can just handle the promise an `async` function returns  

So, a typical `async` function

```js
  async getReviewInfo() : Promise<any> {              // this function will do async
    const details = await this.getPullRequestInfo()   // wait for the promise in getPullRequestInfo to resolve 
    return await details.json()                       // wait for the promise in json to resolve
  }                                                   // return the json
```

You aren't always given a promise to work with as not all APIs support promises and callbacks, wrapping a callback function is pretty simple: 

```js
  readFile(path: String): Promise<string> {                       // returns a promise with a string
    return new Promise((resolve: any, reject: any) => {           // create a new promise, with 2 callbacks
      fs.readFile(path, "utf8", (err: Error, data: string) => {   // do the work
        if (err) { return reject(err) }                           // did it fail? reject the promise
        resolve(data)                                             // did it pass? resolve the promise
      })
    })
  }
```

The `await` part of an `async` function using `await readFile` will now wait on the synchronous execution until the promise has resolved. This makes complicated code look very simple.

### Tree Shaking

All development ecosystems have trade-offs which shape their culture. For web developers reducing the amount of JavaScript they send to a client is an easy, and vital part of their day job. This started with minifying their source code, e.g. reducing the number of characters but having the same behavior. 

The current state of the art is tree-shaking, wherein you can know what functions are unused and remove those from the source code before shipping the code to a client. A [haste-map](#haste-map) is one way to handle these dependencies, but it's not the only one. [Rollup][rollup] is considered the de-facto ruler of the space, but it is in [babel](#babel) and [webpack](#babel) also. 

Does this affect you if you're using React Native? Not really, but it's an interesting part of the ecosystem you should be aware of. 

# Types

Types can provide an amazing developer experience, as an editor can understand the shape of all the object's inside your project. This can make it possible to build rich refactoring, static analysis or auto-complete experiences without relying on a runtime.

For JavaScript there are two main ways to use types. [Flow](#flow) and [TypeScript](#typescript). Both are amazing choices for building non-trivial applications. IMO, these two projects are what makes JavaScript a real systems language. 

Both take the approach of providing an optional typing system. This means you can choose to add types to existing applications bit by bit. By doing that you can easily add either to an existing project and progressively add types to unstructured data. 

### Interfaces

As both [Flow](#flow) and [TypeScript](#typescript) interact with JavaScript, the mindset for applying types is through Interfaces. This is very similar to programming with protocols, where you only care about the responsibilities  of an object - not the specific type. Here is a Flow interface from DangerJS:

```js
/** An API representation for a Code Review site */
export interface Platform {
  /** Mainly for logging and error reporting */
  name: string;
  /** Used internally for getting PR/Repo metadata */
  ciSource: CISource;
  /** Pulls in the Code Review Metadata for inspection */
  getReviewInfo: () => Promise<any>;
  /** Pulls in the Code Review Diff, and offers a succinct user-API for it */
  getReviewDiff: () => Promise<GitDSL>;
  /** Creates a comment on the PR */
  createComment: (body: string) => Promise<?Comment>;
  [...]
}
```

This interface defines the shape of an object, e.g. what functions/properties it will it have. Using interfaces means that you can expose the least amount of about an object, but you can be certain that if someone refactors the object and changes any interface properties - it provide errors.


### Flow

[Flow](https://flowtype.org) is a fascinating tool that infers types through-out your codebase. Our React Native uses a lot of Flow, we have a lot of [linter rules](#eslint) for it too, so instead of writing a function like:

```js
function getPlatformForEnv(env, source) {
return [...]
}
```

We would write it like this:

```js
function getPlatformForEnv(env: Env, source: CISource): ?Platform {
return [...]
}
```

Wherein we now have interfaces for our arguments and the return value of the function. This means better error message from Flow, and better auto-complete in your editor.

### TypeScript

TypeScript is a typed language that compiles JavaScript by Microsoft. It's awesome, it has all of the advantages that I talked about with Flow and a lot more. With TypeScript you can get a much more consistent build environment (you are not picking and choosing different features of ES6) as Microsoft implement all of it into TypeScript.

We opted to go for JS + Flow for Artsy's React Native mainly because we could incrementally add types, and you can find a lot more examples of JavaScript on the internet. It also is the way in which React Native is built, so you get the ecosystem advantage. 

That said, if we start a new React Native from scratch project, I would pitch that we should use TypeScript after my experiences with [making PRs][inline-mac] to VS Code. TypeScript feels more comprehensive, I got better error messages and VS Code is very well optimised for working in TypeScript projects.

### Typings/Flow-Typed

Shockingly, not all JavaScript [modules](#modules) ship with a typed interface for others. This makes it a pain to work with any code outside your perfectly crafted/typed codebase. This isn't optimal, especially in JavaScript where you rely on so many external libraries. 

Meaning that you can either look up the function definitions in their individual docs, or you can read through the source. This breaks your programming flow.

Both TypeScript and Flow offer a tool to provide external definitions for their libraries. For typescript that is [typings][typings] and for Flow, [flow-typed][flow-typed]. These tools pull into your project definition files that tell TypeScript/Flow what each module's input/outputs are shaped like, and provides inline documentation for them.

Flow-Typed is new, so it's not really got many definitions at all. Typings on the other hand has quite a lot, so in our React Native we use typings to get auto-complete for our libraries.

### JavaScript Fatigue

So that's my glossary, there's a lot of interesting projects out in the JS world. 

They have a term "[JavaScript fatigue][js-fat]" which represents the concept of the churn in choosing and learning from so many projects. This is very real, which is something we're taking into account. Given the amount of flexibility in the ecosystem, it's really easy to create anything you want. If I wanted to implement a simplified version of Swift's guard function for our JavaScript, I could probably do it in about 2 days using a Babel plugin, then we can opt-in on any project we want.   

This can make it easy to freeze and flip the table, but it also makes JavaScript a weird, kind of ideal, primordial soup where some _extremely_ interesting ideas come out. It's your job to use your smarts to decide which are the ideas which will evolve further, then help them stablize and mature. 

<script>
// Ain't optimal, but it does it for now, need to figure a better way in the future.
$("a[name]").each(function(i, el){
  var $el = $(el)
  $el.attr("name", $el.attr("name").toLowerCase().replace(".", "-"))
})
</script>

[search-bar]: https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/home/search_bar.js
[our-implmentation]: http://artsy.github.io/blog/2016/08/24/On-Emission/
[jsx-example]: https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/artist/header.js
[react-guide]: https://github.com/uberVU/react-guide/blob/master/props-vs-state.md#props-vs-state
[typings]: https://github.com/typings/typings
[flow-typed]: https://github.com/flowtype/flow-typed/
[node_history]: http://anandmanisankar.com/posts/nodejs-iojs-why-the-fork/
[context_docs]: https://facebook.github.io/react/docs/context.html
[react_jsx]: https://facebook.github.io/react/docs/introducing-jsx.html
[what_redux]: http://www.youhavetolearncomputers.com/blog/2015/9/15/a-conceptual-overview-of-redux-or-how-i-fell-in-love-with-a-javascript-state-container
[arrow-func]: http://exploringjs.com/es6/ch_arrow-functions.html
[this]: https://toddmotto.com/understanding-the-this-keyword-in-javascript/
[strict-mode]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode 
[imports]: https://github.com/artsy/emission/blob/master/lib/components/artist/shows/show.js#L4-L9
[default-export]: https://github.com/danger/danger-js/blob/61557ac7b6de37ef9a7e4a1aa0c0cbe0bd00977d/source/ci_source/Fake.js#L6
[export-functions]: https://github.com/danger/danger-js/blob/61557ac7b6de37ef9a7e4a1aa0c0cbe0bd00977d/source/ci_source/ci_source_helpers.js#L6-L30
[haste]: https://github.com/facebookarchive/node-haste/tree/master#node-haste-
[jasmine]: https://jasmine.github.io
[snapshots]: https://www.objc.io/issues/15-testing/snapshot-testing/
[vscode-jest]: https://github.com/orta/vscode-jest
[using-code]: https://artsy.github.io/blog/2016/08/15/vscode/
[commonjs]: https://www.wikiwand.com/en/CommonJS
[export-func]: https://github.com/artsy/Mitosis/blob/0c1d73055122bd61559df3b1a2913cf4e272b4ed/source/bot/artsy-api.js#L31-L94
[rollup]: http://rollupjs.org/
[inline-mac]: https://github.com/Microsoft/vscode/pull/12628
[js-fat]: http://www.confluentforms.com/2016/01/javascript-churn-technology-investment-effect.html
[mitosis]: https://github.com/artsy/Mitosis/
[gof]: http://www.amazon.com/gp/product/0201633612?ie=UTF8&camp=213733&creative=393185&creativeASIN=0201633612&linkCode=shr&tag=eejs-20&linkId=5S2XB3C32NLP7IVQ
[stages]: https://twitter.com/logicoder/status/799919558429736960
[tc39]: http://ecma-international.org/memento/TC39.htm
[tc39-github]: https://github.com/tc39
