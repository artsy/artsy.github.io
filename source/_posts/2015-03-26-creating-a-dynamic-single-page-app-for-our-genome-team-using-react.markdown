---
layout: post
title: "Creating a dynamic single page app for our Genome Team using React"
date: 2015-03-26 10:42
comments: true
categories: [React]
author: Sarah Weir
github-url: https://www.github.com/sweir27
twitter-url: http://twitter.com/sweir27
---
We recently picked up a Rails application that was a few bugs away from completion. This application allows our [Genome Team](https://www.artsy.net/about/the-art-genome-project) to genome (classify artworks based on visual and art historical characteristics) multiple artworks at once. These characteristics, or "genes" can be added, removed and changed for any of the artworks on the panel. There are many ways to find and add genes to an artwork in this app. For example, a genomer may pull up an existing artist genome to use as a 'template' from which they can batch apply certain genes to multiple artworks. With these and other dynamic views required, our consumers desired an interaction-heavy single page app.

![screenshot](http://cl.ly/image/310O3U3J3T2c)

The backend was organized, modular, and interfaced seamlessly with the Artsy API. However, the single page app needs of our customer were met with a multitude of javascript-heavy files declaring global event listeners, needless to say, these were clunky and difficult to maintain. When we were tasked with resurrecting this app by fixing the critical bugs preventing it from being adopted, we found that simple requests took much more time than they should, and often resulted in a shamefully hacky fix. We intended to contribute as little work as possible up front in order to get the app out the door as soon as possible, and then to refactor retroactively. After a month of frustration with no end to bugs in sight, we decided to stop trying to patch our leaky roof and build a new one.

### Choosing a suitable framework 

We spent a day researching different front end frameworks to see what would best fit our needs. Our requirements were:
- A robust view layer that could work on top of our already-solid Rails backend
- Performant enough for an interaction-heavy single-page app, with hundreds of editable fields autosaving on change
- We preferred light, streamlined frameworks, and valued freedom over unnecessary structure
 
After deliberating with other members of our team and the vast online community, we were introduced to [React](http://facebook.github.io/react/), Facebook's view layer framework. We chose React because it provides much-needed structure and support for components in a single page app, without too much boilerplate. 
 
Our plan was to eventually replace all of the existing `*.haml.erb` templates and global coffeescript mixins with discrete React components. We used the [react-rails](https://github.com/reactjs/react-rails) gem, which easily integrates React components with Rails views.
 
In line with the React tutorial, we began by breaking up our UI into functional and visual components. For each component we found the relevant haml template, converted it into jsx and React components using dummy data, and eventually updated it to accept the correct props/state from our top-level component which did all of the dynamic fetching and saving. Then we deleted the associated haml and javascript code and breathed a sigh of relief.
 
### Thinking the React way
 
We love React because it forces you to follow certain [ideological conventions](http://www.reactivemanifesto.org/), but it does not force you into a structure that may not exactly align with your goals.
 
In React, there is an ideal to have a single source of truth. Gone are liberally distributed global event listeners that can conflict and cause pages to get bogged down with transition logic. State is held at the topmost level in React and when state changes, React automatically rerenders only the components that are affected. You can define your components and interactions in a declarative style instead of stringing together possible tranisions triggered by events. Before converting this app to React, we had many bugs around form submission and saving genome progress. However, by modeling state instead of UI transitions, we could easily track changes and save progess incrementally in the background without requiring a page refresh from the user.
 
### Challenges

#### React's phantom DOM
React keeps track of a phantom DOM created by components you define. This can lead to issues, especially when trying to integrate React with jQuery plugins. For example, our modals kept showing up within other components until we explicitly rendered them on the outermost level.

We also unearthed a mysterious bug in which the browser was automatically inserting a `tbody` tag when it saw a table rendered without one... causing React (and therefore our entire app) to crash.

#### Avoiding Javascript
Sometimes it is unavoidable to model transitions directly with javascript. For example, in one case we had to dynamically change the top padding of a component based on the height of a different one. Although we tried to do it using the React lifecycle methods, there ended up being too many edge cases and we were having to add more and more states just to avoid: 
```
currentTemplateHeight=$('.panel-template-wrap').height();
$('.panel-data-items').css('padding-top', currentTemplateHeight);
```

In this case, we found it more straightforward to go with the jQuery solution.
 
##### Drag and drop
To implement drag and drop in React, you have to both move the items around visually and change the state of the page every time something changes. Because we were moving around large components, we basically had to rerender the entire page when a component moved. In order to avoid excessive page lag, we wrote our own drag/drop functions using native HTML5 listeners.

Our solution was to store the dragged element and starting mouse position in the panel's state, and to swap the elements when the dragging element != the element you are currently hovering over. We use the change in mouse position to determine if you are moving up or down and reorder the page elements accordingly.

A snippet of our drag/drop code:
```
  dragStart: function(e) {
    this.setState({dragMouseStart: e.clientY, draggingElementId: e.currentTarget.getAttribute('data-slug')})
    e.dataTransfer.effectAllowed = 'move';
  },
  dragOver: function(e) {
    e.preventDefault();

    var over = e.currentTarget; // element we're hovering over
    var draggingId = this.state.draggingElementId;
    var toElId = over.getAttribute('data-slug');
    var movingUp = (this.state.dragMouseStart > e.clientY);

    if (draggingId != toElId) {
      orderCopy = this.state.artworksOrder
      var toIndex = orderCopy.indexOf(toElId)
      var fromIndex = orderCopy.indexOf(draggingId)
      if (movingUp) {
        // add a comment for what this clever line does?
        orderCopy.splice(toIndex, 0, orderCopy.splice(fromIndex, 1)[0])
      } else {
        orderCopy.splice(fromIndex, 0, orderCopy.splice(toIndex, 1)[0])
      }
      this.setState({artworksOrder: orderCopy})
    }
  }
```
 
### Writing Specs

All of the existing specs for the app were written in Rspec, so we chose to write integration tests using Rspec+Capybara. The headless Capybara webkit did not integrate with our React setup, so we switched to Selenium (which also conveniently let us debug our specs within the browser).
 
Our main challenge with specs had to do with Rspec not waiting long enough for components (such as autocomplete results) to appear, perhaps due to the fake React-DOM. We spent many sad hours debugging mysteriously spurious tests, and even including a few dreaded 'sleep' commands. Eventually, we integrated the [rspec-retry](https://github.com/y310/rspec-retry) gem to retry spurious tests during CI.

### Conclusion
 
Converting our app to have a React-based front end was surprisingly simple. We were able to incrementally change certain templates to React components, which made it easy to test as we went along. Additionally, our development time (and emotional state) to add new features since then has decreased dramatically. It is much easier to add new components or edit existing ones when there is a single source of truth and you don't have to search through semantically unorganized coffeescript files.

Choosing the *right* front end framework is non-trivial but incredibly important, and we are glad we found React. It is hard to let go of time seemingly 'wasted' on short-term solutions, but often the best course is to stop hacking and build something new.
