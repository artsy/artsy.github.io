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

```jsx
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

Props are chunks of app state that are passed into your component. In [JSX](#jsx) this is represented as an XML attribute.

Let's check out [an example][jsx-example]:

```jsx
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

### JSX

# Types

### Flow
### TypeScript
### Typings/Flow-Typed

# Libraries

### Relay
### Redux

# Tooling

### Node
### NPM
### Yarn
### Babel
### ESLint

# Development

### Live Reload
### Hot-Reloading
### Haste Map

# Testing

### Jest
### VSCode-Jest

# JS

### ES6
### ES2016
### Stages
### Modules
### Destructuring
### Arrow Functions
### Promises
### Async/Await
### Spreads


[search-bar]: https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/home/search_bar.js
[our-implmentation]: asdasdas
[jsx-example]: https://github.com/artsy/emission/blob/c558323e4276699925b4edb3d448812005ae6b5d/lib/components/artist/header.js
[react-guide]: https://github.com/uberVU/react-guide/blob/master/props-vs-state.md#props-vs-state
