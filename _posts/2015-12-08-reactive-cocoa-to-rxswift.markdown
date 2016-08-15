---
layout: post
title: "Upgrading to RxSwift"
date: 2015-12-08 12:00
comments: true
author: ash
categories: [ios, mvvm, open source, swift, mobile]
series: Swift Patterns
---

When we [built Eidolon last year](http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/), Swift was still pre-1.0 and we couldn't rely on the wide variety of available Swift libraries we enjoy today. I wanted to build it using functional reactive programming, because that's how I believe [everyone should write software](https://realm.io/news/altconf-ash-furrow-functional-reactive-swift/), but there were no Swift-based FRP libraries at the time. As a compromise, I used ReactiveCocoa's Objective-C API (the Swift API was months away from an alpha).

<!-- more -->

The choice to use an Objective-C API – one that heavily relies on the runtime – limited us in terms of what Swift features we could use. We had a lot of closures use `AnyObject!` as parameter types, requiring constant checks for `nil` and conditional casts to specific types. It was a real nightmare. We had a lot of code that looked like this:

```swift
signal.map { object in
    if let castObject = object as? WhateverType {
        return castObject.thingWeAreMappingTo()
    } else {
        return SomeSensibleMissingValue
    }
}
```

Swift 2's `guard` statements helped clean this up, but the fundamental problem was that we were using an FRP library not suited for Swift.

While we had [built replacements](https://github.com/ashfurrow/Swift-RAC-Macros) for the Objective-C runtime features that weren't available in Swift, we knew that a migration away from RAC's Objective-C API would eventually be necessary.

I used a bit of down-time recently to tackle the problem, starting with some small bits and pieces before dedicating two weeks to finish it. Here we go!

### Benefits

The key benefits of using a Swift-based FRP framework include:

- Using the type-checker to catch bugs at compile-time.
- Writing fewer lines of code.
- Writing more expressive code.
- Having fun with the type checker and protocol extensions.

When Apple announced Swift, they stressed how safe of a language it was. Now that we were moving to a Swift-based FRP framework, we would finally benefit from those safety features.

This makes new features easier and faster to build. It gives me more confidence when I make a new deploy that things won't break. And like I mentioned above, it's just a lot more fun to write Swift with Swift-based frameworks.

### Process

When we wrote Eidolon, ReactiveCocoa was more-or-less the only iOS FRP library around. That's fine, because ReactiveCocoa is _awesome_. But today, there are a variety of frameworks and [they're _all_ awesome](https://ashfurrow.com/blog/reactivecocoa-vs-rxswift/). So we have a choice to make. 

Sticking with ReactiveCocoa would mean that we could make a gradual transition (there's a bridge between the Objective-C and Swift APIs). This is _kind of_ a benefit, but also kind of a drawback. I don't really trust myself enough to move off of Objective-C's API completely if a bridge is there – it's just too tempting to leave some parts of the app using the old API.

So instead I decided to not consider the existing code. I asked myself: "If I were choosing an FRP library today for a _brand-new_ app, which one would I choose?"

The answer to that question is [RxSwift](https://github.com/ReactiveX/RxSwift). 

RxSwift is a Swift implementation of the [ReactiveX APIs](http://reactivex.io), which bring a few great benefits. The API is well-defined and unlikely to include breaking changes, there are reference implementations for Rx in other languages, and tutorials/resources for other Rx frameworks apply directly to this library. There is some extra overhead from having to interact with a larger community, and [there are technical distinctions](http://stackoverflow.com/questions/32542846/reactivecocoa-vs-rxswift-pros-and-cons/32581824#32581824) that might influence your decision. Ultimately, though, I chose RxSwift because I've found their community much more pleasant to interact with.

I started the process by [removing ReactiveCocoa and adding RxSwift to our Podfile](https://github.com/artsy/eidolon/commit/8e6e86d733e36d3c0b3db581019d09296d04cd68). Of course, that made the _entire app break_, which was fine. 

I was working off a "develop" branch, so having the app in an uncompilable state for a few weeks would be no problem. 

Then the remaining process was simple: find a compiler error, fix it, and find a new one. 27 days later, [we merged the changes into master](https://github.com/artsy/eidolon/commit/8e6e86d733e36d3c0b3db581019d09296d04cd68).

The process was prioritized in the following way:

1. Get the app compiling again.
2. Get the app more-or-less working (no crashes for common use cases).
3. Get the unit tests compiling again.
4. Get the unit tests _completing_ without crashing.
5. Get the unit tests _passing_ (locally and on CI).
6. Thoroughly test the app to verify it still works properly.

We're currently wrapping up the final stage, but I expect to release a new build for production use later this week.

### Biggest Challenges

The biggest challenges were keeping an eye on the end result. When you go for so long without being able to see the benefits of your work, it's easy to get discouraged. 

This is the first major app I've written in Swift with FRP, so there were new patterns and practices I had to learn. Checking in with the RxSwift team helped a lot, with a lot of assistance from [Junior](https://twitter.com/bontoJR) in particular. Making the changes in the open also [let others provide feedback on our progress](https://github.com/artsy/eidolon/pull/569#commitcomment-14632425).

One of the biggest challenges was the structure of the existing code. Our bid-fulfillment process shares _a lot_ of state – much of it in ways that we wouldn't write today. But I didn't want to increase the scope of the transition to RxSwift to _also_ include removing all shared state from the app – scope creep is really dangerous when your project already spans weeks. It was hard to resist this temptation, but I feel it worked out for the best.

### Things That Were Easier than Expected

Things generally went easier than I had anticipated. Using a new library for the first time in production, I had a persistent fear that I would get close to completing the transition, but some fundamental misunderstanding of mine would completely undermine all my work. This turned out to be mild impostor syndrome – with a few small exceptions, the app worked correctly as soon as it compiled 🎉

I tried to get rid of `dynamic` properties in views, controllers, and view models, but left them on models to use KVO with `rx_observe`. I tried not to use KVO a lot, and instead rely on `Variable` properties, which wrap a value in a type that can be observed. I'm still finding a balance between these two approaches, but this is largely a personal preference.

A common pattern became defining a private `Variable` and a public `Observable`, which would constrain the state (a common theme in FRP).

```swift
private let _password = Variable("")
var password: Observable<String> {
    return _password.asObservable()
}
```

`_password` is now the read/write property accessible only within the type, while `password` is a publicly read-only `Observable`. This pattern takes a bit of typing, so I'm still looking for a way to further abstract it. Maybe a Swift preprocessor would help.

### Lessons Learned

The biggest lesson I learned was not about RxSwift specifically, but more about how to use the type system to [stay DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). For example, I was writing this kind of code in our unit tests _a lot_:

```swift
expect(try! subject.expiryDatesAreValidSignal.asBlocking().first()) == false
```

(By "a lot", I mean that I had to write this code twice before deciding to find a better way.)

So I wrote an extension to the `ObservableType` protocol that would abstract this unit-testing code into a reusable function and operator.

```swift
func equalFirst<T: Equatable>(expectedValue: T?) -> MatcherFunc<Observable<T>> {
    return MatcherFunc { actualExpression, failureMessage in

        failureMessage.postfixMessage = "equal <\(expectedValue)>"
        let actualValue = try actualExpression.evaluate()?.toBlocking().first()

        let matches = actualValue == expectedValue
        return matches
    }
}

func ==<T: Equatable>(lhs: Expectation<Observable<T>>, rhs: T?) {
    lhs.to(equalFirst(rhs))
}
```

So now my unit tests' expectations look like this:

```swift
expect(subject.expiryDatesAreValid) == false
```

Nice – way better.

This is just one example – one that [we will be moving into its own library](https://github.com/artsy/eidolon/issues/570).

Swift's type system is really, really powerful. [Here](https://github.com/artsy/eidolon/blob/cb31168fa29dcc7815fd4a2e30e7c000bd1820ce/Kiosk/UIKit+Rx.swift) are some RxSwift-specific extensions we added to UIKit, and [here](https://github.com/artsy/eidolon/blob/cb31168fa29dcc7815fd4a2e30e7c000bd1820ce/Kiosk/App/SwiftExtensions.swift#L22-L56) are some general Swift extensions that we've found helpful.

There's a danger in going overboard, of course. A few times, I was tempted to make an extension on string-convertible `Variable`s to make them themselves string-convertible, for example. That might make _writing_ code easier, but its functionality would not be obvious when _reading_ it later on.

I tried to keep changes like this as obvious and simple as possible, and every addition was peer-reviewed by Orta.

### Community Impact

Throughout the course of the transition to RxSwift, [I made a few contributions to the framework](https://github.com/ReactiveX/RxSwift/pulls?utf8=✓&q=is%3Apr+author%3Aashfurrow), but the things I wanted to add were outside the immediate scope of the project maintainers' vision. Totally understandable. [With their assistance](https://github.com/ReactiveX/RxSwift/issues/265), Orta and I and others helped to create a [new organization for community-run, RxSwift-based libraries](https://github.com/RxSwiftCommunity). 

Now RxSwift can stay lean and focused while the community has a dedicated space to improve all of our ideas, together. [One library](https://github.com/RxSwiftCommunity/NSObject-Rx) I wrote during this project is already under the organization's umbrella, with [another on the way](https://github.com/RxSwiftCommunity/contributors/issues/4).

Helping to create a new organization gave me an opportunity to practice my community-building skills. It was exciting to [re-apply Moya's contributor guidelines](https://github.com/RxSwiftCommunity/contributors) in a new setting, helping to set a positive tone for a growing community. I had a lot of guidance from Orta and Eloy, who of course have [done this before](https://cocoapods.org).

Making positive changes to the developer community – and, on a larger scale, to the world – is something I've [decided to pursue as my career](https://ashfurrow.com/blog/building-my-career/). I wouldn't have come to that conclusion if it weren't for the thoughtfulness and generosity of my colleagues and of the RxSwift community.

---

This transition project has been exciting, but at times it has been exhausting, too. While I'm [glad it's over](https://github.com/artsy/eidolon/pull/569), the past few weeks have impacted my life in a significant – and positive – way. I've never been more excited to be doing what I'm doing, and to be working in the growing open source Swift community. Thank you, everyone.
