---
layout: post
title: "Swift Trek 2: The Wrath of count()"
date: 2015-08-27 5:00
comments: true
author: ash
categories: [ios, open source, mobile, swift]
---

On Tuesday at our mobile practice standup, I mentioned that I was in-between projects and looking for something to do. Orta suggested migrating Eidolon, the Artsy bidding kiosk app, to Swift 2.

Our CI is [broken anyway](https://github.com/artsy/eidolon/pull/466), so now is the perfect opportunity to make changes that would break CI. Additionally, Swift 2 seems to have more-or-less stabilized in the latest betas, so we don't expect many gotchas leading up to the GM. Finally, this is an enterprise-distributed app, so we don't have to worry about submitting to the App Store using betas of Xcode.

So Swift 2 it is!

<!-- more -->

![When your boss tells you that you can use the new Swift version.](http://media1.giphy.com/media/7PzALWNJotBxS/giphy.gif)

I didn't think it would take long, but Orta was less optimistic. I knew that we would need to start with the dependencies, which was tricky since I was updating to the latest beta (only one day old at this point). Our [Podfile needed some changes](https://github.com/artsy/eidolon/commit/b77a9c2add780a52aac2c48b9cd3a5eb257ab003#diff-4a25b996826623c4a3a4910f47f10c30R59), but a lot of this was work I had done before when initially moving Eidolon to CocoaPods frameworks, then to Swift 1.2.

Dependencies are weird. Different libraries take different approaches to Swift changes, so I had to evaluate each one individually. Usually it was a matter of telling CocoaPods to use the branch that the library was using for Swift 2 support. It took about an hour or two, but I got our dependencies working.

![When pod update works.](http://i.imgur.com/IO1QU8E.gif)

Two of our dependencies, [Quick](https://github.com/Quick/Quick) and [Nimble](https://github.com/Quick/Nimble), were a breeze to update – even though we were using way out-of-date versions. We're really impressed by the well thought-out foundations of their libraries.

The next thing was getting _our own_ code to work. This was a lot more work than I had anticipated, since the automatic migrator in Xcode didn't work.

![When the Xcode migrator fails.](http://i.imgur.com/abykDJa.gif)

No problem – a lot of the time, Xcode's autosuggest worked fine, like adding labels to function calls. But it doesn't catch everything. It turns out that a few hours of manually changing `count(array)` to `array.count` etc was a great way to zone out and enjoy a summer afternoon.

After the low-hanging fruit, it was time to move on to the more... esoteric problems. For example, Swift was getting confused by the ambiguity of the `<~` we use for ReactiveCocoa 2.x bindings, vs the `<~` operator ReactiveCocoa 3.x uses for bindings. Weird.

I tracked down the problem to precedence. ReactiveCocoa's `<~` has a [precedence of 93](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/5b19af9b2777462e37ead2dfea95e1fea74b7d63/ReactiveCocoa/Swift/Property.swift#L193). After I changed [ours to match](https://github.com/ashfurrow/Swift-RAC-Macros/commit/57b041d8a99a3e2a90583709ed7ed91f8ca271b8), everything was fine.

![When your code compiles but you don't know why.](http://media3.giphy.com/media/PrAMyghZaYjm/giphy.gif)

I noticed a lot of changes surrounding the way Swift handles strings. Apple themselves [have discussed changes](https://developer.apple.com/swift/blog/?id=30), which were fine. I tried to use their `.isEmpty` property where I could, but I often had to test if a string _wasn't_ empty. `!str.isEmpty` doesn't really sit well with me, so we used `str.isEmpty == false`.

However, the problem was further compounded by the changes to `UITextField`, whose `text` property now returns an _optional_ string. So there was a lot of this code:

```swift
if (textField.text ?? "").isEmpty == false { ...
```

_Gross_. We've since moved onto [something nicer](https://github.com/artsy/eidolon/pull/498), an experiment with Swift 2's power protocols. The above code can now be written as:

```swift
if textField.text.isNotNilNotEmpty
```

Very neat.

![It works!](https://38.media.tumblr.com/tumblr_m8mpwh1gTe1qciljio1_500.gif)

While Orta and I reviewed the [pull request](https://github.com/artsy/eidolon/pull/496), we noted some things we liked, and some things we didn't like. I _really_ like that UIKit now uses Objective-C generic NSArrays so I don't have to cast so much. I really _don't_ like that libraries, mostly the ones that we maintain, don't use that feature of Objective-C yet. That's now [on our todo list](https://github.com/artsy/mobile/issues/54).

![When you put it on your todo list.](http://media3.giphy.com/media/52VjAeGgj78GY/giphy.gif)

I am amazed at how quickly Swift is changing – as a community, we are still seeing new patterns and methodologies emerge. Not all of them will catch on, of course. But what I'm really excited about is that Swift's engineers are building tools that let us do _so much_. They aren't making architectural decisions for us, but letting us experiment and discover for ourselves what works and what doesn't. The future of iOS development has never felt more exciting.
