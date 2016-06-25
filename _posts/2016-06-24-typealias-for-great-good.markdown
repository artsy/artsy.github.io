---
layout: post
title: "Swift Type Aliases: Use Early and Often"
date: 2016-06-24 12:00
author: ash
categories: [mobile, swift, eigen]
---

It's been so fun to watch the Swift developer community experiment with Swift and to experiment with what idiomatic Swift will look like. No one really knows the answer yet, but we're starting to see some design patterns used more than others. We're seeing some language features used in key ways that define idiomatic Swift, and other language features that are being mostly ignored. 

Regrettably, one of my favourite features of Swift has not enjoyed the meteoric rise in popularity I believe it deserves: `typealias`.

<!-- more -->

Type aliases allow developers to define synonyms for pre-existing types. It might sound dull because it _is_ dull. In fact, its usefulness isn't even apparent when _writing_ code, mostly when _maintaining_ it.

But before I dig into how `typealias` is useful, let's review what it is to make sure we're all on the same page. Developers use `typealias` to create a new type identifier that's a synonym for another type. For example, we can declare `typealias BigNumber = Int64` and use "BigNumber" any place we could have used "Int64". 

```swift
func multiply(lhs: BigNumber, rhs: BigNumber) -> BigNumber

...

let number: BigNumber = 5

...

let number = BigNumber(5)
```

You can use `typealias` for most any type: classes, enums, structs, tuples, closures, etc. Here are a few examples.

```swift
typealias Name = String
typealias Employees = Array<Employee>
typealias GridPoint = (Int, Int)
typealias CompletionHandler = (ErrorType?) -> Void
```

Now that we're familiar with `typealias`, I want to discuss four examples that show how `typealias` has helped us maintain code.

### Promoting Existing Types Semantics

When writing web socket communication for eigen, Orta and I were using [JSON Web Tokens](https://jwt.io) to authenticate the user. If you've never used JWTs before, don't worry, here's the tl;dr JWTs are a way to authenticate users in a way that clients can cryptographically verify. It's _basically_ a base64 encoded string of JSON.

Clients don't need to verify the JWT in order to use them, and in fact when Orta and I began using them, we treated them only as strings retrieved from one API and sent to another (like an access token). However, instead of using the `String` type, I decided to define a `JWT` type alias.

```swift
typealias JWT = String
```

I used the new `JWT` type throughout the code as a hint to other developers about what _kind_ of string it is. This gave it some semantic meaning on top of being a string. Neat. Only later, when we needed to start decoding the JWT itself did this really come in handy. 

After deleting the `typealias` and replacing it with a class of the same name, we didn't have to worry about changing function definitions and property types all throughout our codebase. We made the changes locally, in one file, and most all the rest of our code still compiled. Pretty cool! Here's the [relevant portion of the pull request](https://github.com/artsy/eigen/pull/1638/files/911473424849240bb71b89c412b0a1887e5c1418#diff-6d73ebd58fdd2d00c32813f60608fbd1R10) that made that change.

### Consolidating Tuple Types

I [recently wrote about UICollectionView](https://ashfurrow.com/blog/uicollectionview-unjustly-maligned/) and how I used them to solve a difficult layout problem. I detailed how I created a pipeline of simple math functions that used previous results to calculate the next step of the layout. What I didn't mention was that I used tuples to help, specifically tuples with `typealias`.

Tuples are useful for composing several different values into a lightweight type. Think of tuples as junior structs. I was writing functions to do some calculations and return their result as a tuple. Something like this:

```swift
func layoutMetricsForPosition(position: CellPosition, aspectRatio: CGFloat) -> (restingWidth: CGFloat, restingHeight: CGFloat, targetWidth: CGFloat, targetHeight: CGFloat)
```

And because of how the layout pipeline worked, I then needed to use the _same_ tuple as a parameter for the next function.

```swift
func centersForPosition(position: CellPosition, metrics: (restingWidth: CGFloat, restingHeight: CGFloat, targetWidth: CGFloat, targetHeight: CGFloat)) -> ...
```

Any time you use the same tuple type more than once, consider making a `typealias`. In this case, the code became a lot shorter and easier to skim and understand. 

```swift
typealias LayoutMetrics = (restingWidth: CGFloat, restingHeight: CGFloat, targetWidth: CGFloat, targetHeight: CGFloat)
typealias CenterXPositions = (restingCenterX: CGFloat, targetCenterX: CGFloat)

func layoutMetricsForPosition(position: CellPosition, aspectRatio: CGFloat) -> LayoutMetrics

func centersForPosition(position: CellPosition, metrics: LayoutMetrics) -> CenterXPositions
```

If we need to change something about the tuple later on, we only need to change it in one place. We've also made it easier to promote this tuple to a struct or class later on, just like in the JWT example, because all the functions are already referring to it as its own type. You can check out how we used type alias'd tuples [in the code](https://github.com/artsy/eigen/blob/12eac80948bcfd1e5c6fc2aa85b22ccb2a4421dd/Artsy/View_Controllers/Live_Auctions/Views/LiveAuctionFancyLotCollectionViewLayout.swift#L104).

### Defining Closures Signatures

Objective-C developers, burdened with [arcane syntax for blocks](http://goshdarnblocksyntax.com), use C's `typedef` to isolate that syntax strangeness in one place. And even though Swift's closure syntax is _awesome_, we can still benefit from Objective-C's example – we can use type aliases for closure signatures.

[Moya](https://github.com/Moya/Moya) uses this technique quite a bit, because it has so many closures. Let's take a look at the `StubClosure`, which [defines if (and how) a network request should be stubbed](https://github.com/Moya/Moya/blob/6666947219f231091d5c3e0b9d5f63ac4091718d/Source/Moya.swift#L78-L79).

```swift
typealias StubClosure = Target -> StubBehavior
```

We use this type as an initializer parameter instead of the full closure syntax, making our code a lot shorter and more legible. Nice! Since the user usually doesn't want to customize this parameter, so we've [defined a default value](https://github.com/Moya/Moya/blob/6666947219f231091d5c3e0b9d5f63ac4091718d/Source/Moya.swift#L97).

```swift
init(...
    stubClosure: StubClosure = MoyaProvider.NeverStub,
    ...)
```

`MoyaProvider` has a class function on it called `NeverStub` [whose type](https://github.com/Moya/Moya/blob/6666947219f231091d5c3e0b9d5f63ac4091718d/Source/Moya.swift#L246-L248) matches our closure.

```swift
class func NeverStub(_: Target) -> Moya.StubBehavior {
    return .Never
}
```

This particular function doesn't use the `typealias`, but another one does. We have a function named `DelayedStub` that returns the `typealias` instead of the raw closure. Take a look!

```swift
class func DelayedStub(seconds: NSTimeInterval) -> Moya.StubClosure {
    return { _ in return .Delayed(seconds: seconds) }
}
```

Super cool! Closures are a powerful tool in Swift already, but by using a `typealias`, we refer to it as `StubClosure` throughout our code. 

In isolation, this gain may not seem significant, but the dividends have accrued dramatically for the project. `typealias` has made it easy to maintain Moya as it has evolved alongside Swift. Check out more examples of type aliasing closures [in this eigen class](https://github.com/artsy/eigen/blob/12eac80948bcfd1e5c6fc2aa85b22ccb2a4421dd/Artsy/View_Controllers/Live_Auctions/LiveAuctionStateManager.swift#L20-L21), which uses them for dependency injection.

### Extending Typealiases

The last example I want to discuss is extensions, specifically extensions to _your own_ types.

When writing classes, especially view controllers, developers have a habit of writing long, unwieldy files that are difficult to navigate and maintain. Preventing such files is far easier than fixing them, which is why I use `typealias` early, and I use it often.

I recommend using a descriptive `typealias` that is private to your file, and then extending that `typealias` so you can keep things neat and tidy. It's a bit confusing, so let's take a look at an example.

```swift
private typealias PrivateHelperFunctions = MyViewController
extension PrivateHelperFunctions {
    ...
}

private typealias TableViewMethods = MyViewController
extension TableViewMethods: UITableViewDelegate, UITableViewDataSource {
   ...
}
```

We're still extending the view controller, but specifically we're extending the `typealias` so that the extension has a helpful name. This is another way that `typealias` can help add semantic meaning to your code.

Beyond helping you find code quickly, having code in extensions also makes it _way_ easier to move that extension to another file or create a new helper class altogether. So not only does it keep classes tidy, but it also helps you keep classes _small_.

This technique can also serve as a workaround for Swift's [awful Xcode sectioning syntax](http://stackoverflow.com/questions/24017316/pragma-mark-in-swift).

![Xcode Jumpbar](/images/2016-06-24-typealias-for-great-good/jumpbar.png)

You can [search through eigen](https://github.com/artsy/eigen/search?l=swift&q=private+typealias&utf8=✓) for more examples of using a private `typealias` to divide your code into manageable pieces.

---

Look, I'm not saying that using `typealias` more is universally a good idea. You might disagree with some of the use cases in this post, which is fine! And this isn't meant to be an exhaustive list of examples, either. 

My point is, used in a few key ways, `typealias` has helped me maintain my code more easily. It's a good tool to be familiar with. Even if it won't revolutionize the way you write software, `typealias` can help make your job a smidgen easier, and who could argue with that?
