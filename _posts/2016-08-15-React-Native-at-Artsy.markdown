---
layout: epic
title: "React Native at Artsy"
date: 2016-08-15 21:17
comments: true
article-class: "expanded-code"
categories: [React, eigen, Mobile, reactnative]
author: eloy
series: React Native at Artsy
---

<center>
<img src="/images/react-native/artsy_react_logo.svg" style="width:300px;">
</center>

As [the Artsy iOS app](https://github.com/artsy/eigen) grew larger, we started hitting pain
points:

* We want to support other future platforms such as Android without creating more teams.
* We want different business teams to work on the app without disrupting each other.
* We want our architecture to evolve in order to increase programmer efficiency.

It took us [about a year](https://github.com/artsy/mobile/issues/22) to start resolving these issues. 
Ideally, we wanted to find a solution to our architectural issues that would also improve the user 
experience. Notably we wanted more efficient networking, due to mobile device constraints.

It would have been an easy leap to start using Swift and, as a matter of fact, we do use Swift in parts of
our flagship application and entirely in [2 other apps](http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/).

However, while Swift is a great language, it’s also just that: _another_ language. It does not do much in terms of new
paradigms that solved our architectural needs, it does not help in terms of cross-platform - as most of our code is
building views and thus very framework specific, and it did not really offer anything in terms of more efficient network
data fetching.

We've seen that the web teams integrate React in their projects with really great results. We've been
[paying attention](https://github.com/artsy/mobile/issues/22) to React Native since it came out; the solutions provided
by the React ecosystem ticked all of our boxes.

Six months ago we took the plunge, and last month we formalized that this is the direction we want to go.

<!-- more -->

# Cons

So you decided to read the full post and the first thing you got confronted with is a list of cons… _boo_. Let’s just get
these out of the way first, it will only get better afterwards.

* Dependencies, dependencies, dependencies, both in libraries and tooling. Once you open this can, you’ll have worms
  _everywhere_ in no time; 593 packages to be exactly, at the time of writing, for a new React Native project. Good luck
  maintaining that.

  Having created [a dependency manager](https://cocoapods.org), I’m not afraid of some dependencies and don’t subscribe
  to NIH, but the JavaScript community has gone _way_ overboard for my taste. If, like me, you subscribe to the idea
  that dependencies are _part_ of your application and you want to be able to know what packages are being pulled in so
  you can maintain them, then you probably won’t like this aspect very much either.

  I’m not quite sure yet how I feel about this in the long run and what we can do about it, short of trying to get the
  maintainers of the packages we directly depend on to accept changes that simplify their dependency graphs.

* As is often the case, error reporting does not always receive the attention it should get. With the amount of tools
  and libs that make up the full stack you need to work with, this lack in attention to failure resolution can quickly
  cascade into deep rabbit holes.

* React Native is still very young and fast moving. If you don’t like living on the edge (i.e. lots of updating and
  dealing with breaking changes) nor have an interest in shaping an unfinished framework, this currently is not for you. 

* All Facebook open-source code is made to solve the problems that Facebook has first, thus with young projects you may
  well need to put in a bunch of time to make it work for your problem set. React Native provides a lot of basic view
  building blocks, but you do lose a lot that you would get with UIKit for free, e.g. `UICollectionView`.

  However, it is important to note that this is only a heads-up for those that might think they can solve any problem
  out-of-the-box; in terms of open-source code I prefer code used in production over other code _any_ day.

* There are currently many more people trying to get help, with often arguably simple questions in the context of iOS
  development, compared to those willing to spend time on answering questions. Most forums I’ve seen suffer from the
  tragedy of the commons problem, which can be a real problem if you have incidental framework specific questions, but
  jumping to React Native probably is a complete disaster if you know very little about iOS development yet.

  If you’re not already knowledgeable about iOS development, are not motivated to put in the time to learn about the
  platform specific details, and think making rich iOS applications with React Native will be a breeze, you’ll
  [come home from a very cold fair](http://www.dwotd.nl/2008/06/443-van-een-kouwe-kermis-thuiskomen.html) indeed. 
  
  While you can definitely make applications that way, in my experience those often end up not feeling like proper 
  citizens of the platform they inhibit.

* Due to React Natives immaturity, you will not be able to find nuanced post-mortems on the subject. The project
  is only at the beginning of the [hype cycle](https://en.wikipedia.org/wiki/Hype_cycle), meaning there is a lot 
  to gain in writing about how great it is, but less incentive to discuss where it doesn't work out well. 

# Pros, why we wanted to use React Native

* From [the React website](https://facebook.github.io/react/):
  > React will efficiently update and render just the right components when your data changes.
  > Build encapsulated components that manage their own state, then compose them to make complex UIs.

  The functional model that React introduces that allows you to reason about the state of your views in much simpler
  ways has for us been a welcome change that should make it much easier to write decoupled code going forward.

  I’m by no means a functional programming purist, nor do I really care for being one. I found the React/React Native
  communities to be very welcome to functional enthusiasts and pragmatists alike, a healthy mix that I find leads to
  more productive outcomes.

* Relay. From [its website](https://facebook.github.io/relay/):
  > Queries live next to the views that rely on them, so you can easily reason about your app.
  > Relay aggregates queries into efficient network requests to fetch only what you need.

  The clarity this brings to the view codebase - coupled with its smart caching, networking is just ground-breaking. 
  No more multiple levels of model code in your application that you need to trace, just a single file with
  [the view component](https://github.com/artsy/emission/blob/a2e4dbdb/lib/components/artist/header.js#L87) _and_
  [the data it needs](https://github.com/artsy/emission/blob/a2e4dbdb/lib/components/artist/header.js#L143-L144). Neat.

  We do still have ‘view models’, however, those now pretty much all live in
  [our GraphQL service](http://artsy.github.io/blog/2016/06/19/graphql-for-mobile/). The added benefit here is that we
  share that model logic with Artsy’s other (web) clients.

* “Learn once, write anywhere.” is the neo-cross-platform slogan deployed by React, which is a play on the tried
  “Write once, run anywhere.” slogan of yesteryear. The difference being that you can use the same paradigms to create
  products on various platforms, rather than pure code-reuse.

  While we haven’t put this to the test yet at Artsy, we do plan to team up people across platforms to implement single
  features on each respective platform, rather than having multiple people implement the same feature _on their own_.
  The hope is that this will lead to better understanding of features and thus the implementations thereof, while still
  taking each platform’s unique nature into account. The added benefit would be that people learn to understand and
  appreciate those unique platform traits, thus making them more well-rounded engineers.

  In the long run, we hope to extend this way of working as we start work on a React Native Android client.

* While Auto Layout is a great step up from manual frame calculation, most of our views don’t need the granularity that
  Auto Layout offers. React Native ditches Auto Layout and instead uses
  [flexbox](https://en.wikipedia.org/wiki/CSS_Flex_Box_Layout) for its layout. While my head has never been able to
  fully wrap around classic CSS, I find that flexbox is an abstraction that nicely fits most of our needs.

  I can definitely imagine situations in which more granularity would be required, however, in those cases we can always
  decide to ‘drop down’ to native view code, so I don’t really worry too much about that.

* Layout calculations are performed on a background thread, the so-called ‘shadow’ thread. This can make a big
  difference when e.g. scrolling through a large complex list view.

  Granted, you _can_ do this with `UIView`, but the pattern is not as ingrained in UIKit thus usually leading to more holistic
  replacements such as [AsyncDisplayKit](http://asyncdisplaykit.org).

* Great separation of declarative view layout (JS, single-threaded) and technical details (native code, multi-threaded).
  Because of the hard constraint of having a JS/native bridge, there really is no way to take shortcuts (e.g. spaghetti
  code) that in the long run would only lead to technical debt. Constraints are great.

* Because there’s very little code that needs to be compiled and how the isolated component nature of React makes it
  it very easy to reload code in-process, development velocity lies much higher than with your typical native UIKit-based
  development.

* While, as mentioned above, there are definitely issues with the tooling and libs, on the flip-side it is all
  open-source software and you _can_ (officially) dive in and figure it out, unlike e.g. Xcode and UIKit. (Granted, you
  still need to deal with these when using React Native, but it can be kept to a minimal surface.)

* Because React Native is still young, fast moving, and open-source, this is a great time to help shape the framework
  you’d _want_ to use.

# Things we learned

* When we started out with React Native, I didn't want to have to re-write our application in order to take advantage of
  the technology. To address this I worked within our existing application structure. We consider the App to 
  [be a browser](https://artsy.github.io/blog/2015/08/24/Cocoa-Architecture-Hybrid-Apps/) of native and web view controllers. So, 
  we added routes [to our SwitchBoard](http://artsy.github.io/blog/2015/08/19/Cocoa-Architecture-Switchboard-Pattern/) for 
  view controllers which are created in React Native. To the rest of the app, there is no difference between a Swift view controller, 
  or one with React Native inside.

* All of the React Native code is kept in a completely separate repo, [Emission](https://github.com/artsy/emission), which
  when deployed generates a minified version of the JavaScript. This means to build the Artsy iOS app you do not need to have
  a JavaScript development environment.

* We reused a lot of our existing native views, starting with loading indicators and native switch views.

* We used new native classes to improve integration, for example the `<OpaqueImageView>` 
  [component](https://github.com/artsy/emission/blob/master/lib/components/opaque_image_view.js) is a 
  [native](https://github.com/artsy/emission/tree/master/Pod/Classes/OpaqueImageViewComponent) `UIImageView`
  subclass that works with our application-wide [SDWebImage](https://cocoapods.org/pods/SDWebImage) image cache.

# Conclusion 

To really shine with React Native, you need native experience. JavaScript has not eaten everything yet. However, 
you don't need a team of native experts. For example, we expect to be able to get quite far with Android support based on 
our work in React Native, but to make it amazing, we will need someone with history and context in the space.

This frees up our engineers to widen their [T-shaped skills](https://artsy.github.io/blog/2016/01/30/iOS-Junior-Interviews/), 
and to help remove the idea that the mobile team has to be a completely separate team with foreign tools and ideas.

This is only the tip of the iceberg for our writings about React Native. Follow [@ArtsyOpenSource](https://twitter.com/ArtsyOpenSource)
to stay up to date.
