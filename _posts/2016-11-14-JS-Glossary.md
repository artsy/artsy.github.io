---
layout: post
title: "JavaScript Glossary for 2017"
date: 2016-11-14 12:17
author: orta
categories: [javascript, emission, danger]
series: React Native at Artsy
---

Getting to grips with the entire JavaScript ecosystem is a tough job when you're getting started. Coming from the native mobile space, there's a lot to learn. I've spent a lot of time in the environment now, and can distill so you can grok, then dig into places when you choose.

This post will try to provide a glossary around the tools that are being used inside a React Native project, as well as some code examples.  

<!-- more -->

# React 

### React

React is a Facebook project which offers a uni-direction Component model that _can_ replace MVC in a front-end application. It was built out of a desire to mock a web page's view heirarchy (called the DOM) so that they could make changes as differences between view states.

Its model is that you would create a set of Components to encapsulate each part for the state of the page. React makes it easy to make components that are functional in the FRP sense. They act like a function which takes some specially declared state and it is rendered into HTML.

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

By providing a well encapulated Component model, you can really reduce the amount of code you need to build an application. By not initially writing to the DOM, React can decide what has changed between user actions and that means you have to juggle significant less [state](#state).

### React Native

Writing native apps is now officially a pain. I came to this conclusion early this year, and it's been amazing to be able to work in React Native.

React Native is an implmentation of React where instead of having it abstract a web page's DOM, it create a native view heirarchy. In the case of iOS that is a UIView heriarchy. Note that it does not handle View Controllers. The MVC model from Apple's Cocoa framework does not directly map into React Natives. I've wrote about how we [bridge that gap earlier][our-implmentation].

React Native is cross platform. You write JavaScript like above, which React Native transforms into a native view heirarchy. That view heirarchy could be on a Samsung TV, a Windows phone or Android instead. 

It's a smart move, most "Make apps in JS" try to have a native-like experience where they replicate the platform's UI in HTML. However, that tends to feel unnatural very easily. If I showed you our app, you could not distinguish between a view controller in React Native, Swift or Objective-C.

### App State

Think of every variable inside your application, that is your application's state. You could not make an app worth using without state. In MVC, MVVM, VIPER and other native patterns, there is no consistent way to handle changes in those variables. React uses a common state pattern though the use of specific terminology: "[props](#props)", "[context](#context)" and "[#state](#state-again)". 

Yes, the "state" and "state" thing is a little confusing, we'll get to it.

### Props

Props are chunks of app state that are passed into your component from a parent component. In [JSX](#jsx) this is represented as an XML attribute.

Let's check out [an example][jsx-example]:

```js
return (
    <View style={styles.followButton}>
        <InvertedButton text={this.state.following ? 'Following' : 'Follow'}
                        selected={this.state.following}
                        onPress={this.handleFollowChange} />
    </View>
)
```

See the `InvertedButton` component, it has three `props` being passed in: `text`, `selected` and `onPress`. If any of those props were to change the entire `InvertedButton` component would be re-rendered to the native view heirarchy. These `props` are the key to passing data downwards through your heirarchy. Note: you cannot access the parent component (without passing it in as a prop.)

You should therefore consider `props` as immutable bits of app state. 

### State-again

A component also has a `state` attribute. The key to understanding the difference between `props` and `state` is, `state` is something controlled within that component that can change `props` does not. 

The above example is a pretty good example of this, when this component is first added to the heirarchy, we send a networking request to get whether you are following something or not. The parent component does not need to update when we know whether you are following or not, but the button does. So it is in `state` for the parent, but a `prop` for the `InvertedButton`. This means changing the state for `following` will only cause a re-render in the button.

So state is something which changes within a component, which _could_ be used as `props` for it's children. Examples of this are around handling animation progress, whether you're following something, selection indices and any kind of networking which we do outside of [Relay](#relay).

If you'd like to read more, there is a much deeper explaination in [uberVU/react-guide][react-guide]   

### Context

Hrm

### JSX

As we'll find out later, modern JavaScript is a collection of different ideas, and using [Babel](#babel) - you can add them at will into your projects. JSX is one such feature, it is a way of describing nested data using XML-like syntax. These are used inside React's render function to express a component's children and their [props](#props).

Under the hood, JSX is quite simple, with code looking like this:

```js
return (<View><Button/></View>)
```

Turning into (VERIFY)

```js
return react.createElement("View", react.createElement("Button"))
```

Where `createElement` comes from the React [module](#module).

# Libraries

### Relay
### Redux

# Tooling



### Node

Node is the JavaScript implmentation from Google's Chrome (called v8) with an expanded API for doing useful systems tooling. It is a pretty recent creation, so it started off with an entirely synchronous API for any potentially blocking code.

For web developers this was a big boon, you could share code between the browser and the server. The blocking API meant it was much easier to write faster servers, and there are lots of big companies putting a lot of time and money into improving the speed of JavaScript every day.

Node has an interesting history of ownership, I won't cover it here, but [this link][node_history] provides some context.

### NPM

NPM is the Node Package Manager. It is shipped with node, but it is a completely different project and team. NPM the project is ran by a private company.

NPM is one of the first dependency managers to offer the ability to install multiple versions of the same library inside your app. This contributes considerably to the issue of the number of depenencies inside any app's ecosystem.

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

### ESLint

How can you be sure your syntax is correct? JavaScript has a really powerful and extensible linter called ESLint. If parses your JavaScript and offers warnings and errors around your syntax. You can use this to provide a consistant codebase, or in my case, to be lazy with your formatting. Fixing a lot of issues is one command away. 

# Development

### Live Reload
### Hot-Reloading
### Haste Map

# Testing

### Jest
### VSCode-Jest

# JS

I'm always told that JavaScript was created in 10 days, which is a cute anecdote, but JavaScript has evolved for the next 20 years (TODO: how long?). The JavaScript you wrote 10 years ago would still run, however modern JavaScript is an amazing and expressive programming language once you start using modern features.

Sometimes these features aren't available in [node](#node), or your browser's JavaScript engine, you can work around this by using a transpiler, which takes your source code and backports the features you are using to an older version of JavaScript.  

### ES6

JavaScript is run by a commitee. Around the time that people were starting to talk about HTML5 and CSS3, work was started on a new specification for JavaScript called ECMAScript 6. [What IS ECMA?]

ES6 represents the first point at which JavaScript really started to take a lot of the best features from transpile to JavaScript languages like CoffeeScript. Making it feasible for larger systems programming to be possible in vanilla JavaScript.  

### ES2016

It took forever for [ES6](#es6) to come out, and every time they wrote up / changed a spec there were multiple implmentations of the spec availble for transpiling via [babel](#babel). This I can imagine was frustrating for developers wanting to use new features, and specification authors trying to put out documentation for discussion as a work in progress. This happened a lot [with the Promises](#promises) API.

To fix this they opted to discuss specification features on a year basis. So that specifications could be smaller and more focused, instead of major multi-year projects. Quite a SemVer jump from 6 to 2016.

### Stages

Turns out that didn't work out too well, so the terminology changed again. The change is mainly to set expectations between the Specification authors and developers transpiling those specs into their apps.

Now an ECMAScript language improvement specification moves through a series of stages, depending on their maturity. I believe starting at 4, and working down to 1. So a ECMAScript Stage 4 feature is going to be really new, if you're using it via a transpiler then you should expect a lot of potential API changes and code churn. The lower the number, the longer the spec has been discussed, and the more likely for the code you're transpiling to be the vanilla JavaScript code in time.


### Mutablilty

JavaScript has had a keyword `var` to indicate a variable forever. You should basically never use this. I've never written one this year, except by accident. It's a keyword that has a really confusing scope, leading to odd bugs. [ES6](#es6) brought two replacements, both of which will give you a little bit of cognative dissonance if you have a lot of Swift experience.

`let` - the replacement for `var`, this is a _mutable_ variable, you can replace the value of a `let`. The scope of a `let` is exactly what you think from every other programming language.
`const` - this is a `let` that won't allow you to change the _value_. So it creates a mutable object (all JS objects are mutable) but you cannot replace the object from the initial assignment.  

### Modules


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
//TODO - function?
}

const danger = new Person("danger")
```

Classes provides the option of doing object-oriented programming, which is still a pretty solid way to write code. You can get useful errors 

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

[Node](#node) is renound for having a non-blocking API from day one. The way they worked around this is by using callbacks everywhere. This can work out pretty well, but eventually maintaining and controlling your callbacks turns into it's own problem. This can be extra tricky around handing errors.

One way to fix this is to have a Promise API, Promises offer consitent wawys to handle errors wand callback chaining.

JavaScript now has a built-in a Promise API, this means every library can work to one API when handling any kind of asyncronous task. I'm not sure what ECMA Specification brought it in. This makes it really easy to make consistent code between libraries. However, more importantly, it makes it possible to have async/await.

### Async/Await

Once Promises were in, then a language construct could be created for using them elegantly. They work by declaring the entire function to be an `async` function. An async function is a function which pretends to be syncronous, but behind the scnes is waiting for specific promises to resolve asynchronously.

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

### Spreads


# Types

Types can provide an amazing developer experience, as an editor can understand the shape of all the object's inside your project. This can make it possible to build rich refactoring, static analysis or auto-complete experiences without relying on a runtime.

For JavaScript there are two main ways to use types. [Flow](#flow) and [TypeScript](#typescript). Both are amazing choices for building non-trivial applications. IMO, these two projects are what makes JavaScript a real systems language. 

Both take the approach of providing an optional typing system. This means you can choose to add types to existing applications bit by bit. By doing that you can easily add either to an existing project and progressively add types to unstructured data. 

### Interfaces

As both [Flow](#flow) and [TypeScript](#typescript) interact with JavaScript, the mindset for applying types is through Interfaces. This is very similar to protocol oriented programming, where you only care about the responsabilities of an object - not the specific type. Here is a Flow interface from DangerJS:

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

This interface defines the shape of an object, e.g. what functions/properties it will it have. Using interfaces means that you can expose the least amount of about an object, but you can be certain that if someone refactors the object it provide errors.


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
### Typings/Flow-Typed

Shockingly, not all JavaScript [modules](#modules) ship with a typed interface for others. This makes it a pain to work with any code outside your perfectly crafted/typed codebase. This isn't optimal, especially in JavaScript where you rely on so many external libraries. 

Meaning that you can either look up the function definitions in their individual docs, or you can read through the source. This breaks your programming flow.

Both TypeScript and Flow offer a tool to provide external definitions for their libraries. For typescript that is [typings][typings] and for Flow, [flow-typed][flow-typed]. These tools pull into your project definition files that tell TypeScript/Flow what each module's input/outputs are shaped like, and provides inline documentation for them.

Flow-Typed is new, so it's not really got many definitions at all. Typings on the other hand has quite a lot, so in our React Native we use typings.


[search-bar]: https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/home/search_bar.js
[our-implmentation]: asdasdas
[jsx-example]: https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/artist/header.js
[react-guide]: https://github.com/uberVU/react-guide/blob/master/props-vs-state.md#props-vs-state
[typings]: TNJDNKSJDNFKJSDNF
[flow-typed]: aSADAFA
[node_history]: aSDASDASD
