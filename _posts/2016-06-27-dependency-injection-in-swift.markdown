---
layout: post
title: "Depedency Injection in Swift"
date: 2016-06-27 12:00
author: ash
categories: [mobile, swift, eigen, eidolon]
series: Swift Patterns
---

Dependency Injection (DI) is a [$25 word for a 5¢ idea](http://www.jamesshore.com/Blog/Dependency-Injection-Demystified.html), but it's an idea that has become wholly foundation to how I write software. I want to take a look at some of the ways our team have been using DI in Swift.

<!-- more -->

DI users in Swift (and Objective-C) are generally in one of a few camps: 

- Use [initializer injection](https://www.natashatherobot.com/unit-testing-swift-dependency-injection/) to provide objects with their dependencies.
- Use property injection ([with laziness even!](https://ashfurrow.com/blog/lazy-property-setup-in-swift/)).
- Use [frameworks like Swinject](https://github.com/Swinject/Swinject) to build dependency graphs at run time. 

If you've used storybards or nibs before, you have probably already used property injection via IBOutlets. I actually consider initializer injection and property injection to be roughly the equivalent, just with different timing. 

If I had to pick a favourite, I like the initializer injection because it fits appropriately with the level of dynamism Swift offers. But Swift is still _super_ young and there're lots of programming techniques to explore, so I've been experimenting with something new.

The idea is similar to initializer injection, where you provide an instance's dependencies, but instead of providing the dependencies directly, you provide closures that return a dependency. It sounds odd, and is best explained using an example that starts without any DI at all.

Okay, we've got a network layer that communicates with an API. We're writing the class that takes the parsed data from the `NetworkProvider` class and turns it into models consumable by the rest of the app. Right now it looks like this. 

```swift
class StateManager {
    let networkProvider: NetworkProvider
    
    init() {
        networkProvider = NetworkProvider("https://api.wherever.com")
    }
}
```

There are some limitations to this, specifically around testing it. It would be better to have the `networkProvider` passed in as an argument to `init()`. That's initializer injection, and my opposition to it is that we've moved the responsibility for creating the `networkProvider` up the stack. 

```swift
class StateManager {
    let networkProvider: NetworkProvider
    
    init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }
}

...

let stateManager = StateManager(
    networkProvider: NetworkProvider("https://api.wherever.com")
    )
```

The thing is, now some _other_ object has to know how to do create the `NetworkProvider`. Hrm. You can repeat this process of injecting dependencies from further up the stack until you have a general-purpose DI framework, and that's not my bag.

My approach passes a closure that _returns_ a network provider instead of passing in a `networkProvider` instance directly. The parameter can be given a default implementation, too.

```swift
class StateManager {
    let networkProvider: NetworkProvider
    
    init(
        networkProviderCreator: () -> NetworkProvider = StateManager.defaultNetworkCreator()
        ) {
        networkProvider = networkProviderCreator()
    }
    
    class func defaultNetworkCreator() -> (() -> NetworkProvider) {
        return {
            NetworkProvider("https://api.wherever.com")
        }
    }
}
```

There's a lot to unpack here, so let's take it slowly. The initializer has a new `networkProviderCreator`, a closure that returns a `NetworkProvider`. In the initializer, we set our property to the return value of the closure. We also have a class method that gives us a default implementation that's used in production. 

But in tests, we can initialize the `StateManager` with a stub closure, something like:

```swift
let fakeNetworkProvider = ...
let testSubject = StateManager({ fakeNetworkProvider })
```

Now you get the benefits of initializer injection, but the flexibility to only use DI when you need to. 

Note: we should still test the `defaultNetworkCreator()` function to make sure it works, too. Having code behave differently specifically while being tested is not generally a good idea.

Applying the advice on using `typealias` from [my last post](http://artsy.github.io/blog/2016/06/24/typealias-for-great-good/), we can tidy our code up a little bit.

```swift
class StateManager {
    typealias NetworkCreator: () -> NetworkProvider

    let networkProvider: NetworkProvider
    
    init(
        networkProviderCreator: NetworkCreator = StateManager.defaultNetworkCreator()
        ) {
        networkProvider = networkProviderCreator()
    }
}

private typealias ClassFunctions = StateManager
extension ClassFunctions {
    class func defaultNetworkCreator() -> NetworkCreator {
        return {
            NetworkProvider("https://api.wherever.com")
        }
    }
}
```

### But wait, there's more!

The other benefits of passing in a closure instead of an instance is that it lets the initializer customize the dependency based on other data. For example, let's say the state manager uses an `enum` to differentiate between staging and production API endpoints (btw, [two-case enums are great at this](https://ashfurrow.com/blog/the-wrong-binary/)). How might our initializer change? 

```swift
enum APIEnvironment {
    case Staging, Production
}

class StateManager {
    typealias NetworkCreator: (String) -> NetworkProvider

    let networkProvider: NetworkProvider
    
    init(
        environment: APIEnvironment,
        networkProviderCreator: NetworkCreator = StateManager.defaultNetworkCreator()
        ) {
        let baseURLString: String
        switch environment {
        case .Staging:
            baseURLString = "https://staging-api.wherever.com"
        case .Production:
            baseURLString = "https://api.wherever.com"
        }
        
        networkProvider = networkProviderCreator(baseURLString)
    }
}

private typealias ClassFunctions = StateManager
extension ClassFunctions {
    class func defaultNetworkCreator() -> NetworkCreator {
        return { baseURLString in
            NetworkProvider(baseURLString)
        }
    }
}
```

I really dig this. The closure to create the dependency is close to the code that uses it, but is insulated from any specific instance, so we get the benefits of using DI. 

You could argue that picking a base URL for an API shouldn't belong here, and you could probably convince me. But my point isn't that this specific example is ideal, it's that the pattern of using closures for initializer injection is pretty neat. 

The logic to create dependencies has to go _somewhere_. I think it makes sense to keep it close to the code that actually uses the dependency, but isolated in a `class` function so no actual instance is involved in its creation. As a result, developers get the benefits of initializer injection and none of the added cognitive overhead when writing your production code.

It may not be a perfect pattern (what is?) but we've been using it on [eidolon](https://github.com/artsy/eidolon) and [eigen](https://github.com/artsy/eigen) for nearly two years and – combined with generous use of protocols – we've been really happy with the results. 

Now that I have more free time to explore the pattern, I want to take it a step further and see where it could be used outside of unit testing. It's possible that using this approach could make all our types less tightly coupled and provide a more modular codebase.
