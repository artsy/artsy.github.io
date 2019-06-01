---
layout: epic
title: It's time to use Swift Package Manager
date: 2019-01-05
author: [orta]
categories: [swift, package-management, build tools, roads and bridges]
comment_id: 517
---

It's been three years, and [Swift Package Manager][spm] (SPM) is at a point where it can be useful for iOS
projects. It'll take a bit of sacrifice and a little bit of community spirit to fix some holes probably but **in my
opinion, it's time for teams to start adopting SPM for their 3rd party dev tools**.

**TLDR:** You should be using SPM for 3rd party dev tools like: [SwiftLint][sl], [SwiftFormat][sf], [Danger][ds],
[Sourcery][srcy], [SwiftGen][sg] and [Git Hook management][kom].

This post covers: What made it feasible to use SPM now? What are the downsides of the status quo? Why use SPM at
all? What are the downsides to using SPM?

<!-- more -->

### What changed to make SPM usable?

From my perspective, David Hart's [addition of `swift run`][swift-run] to SPM which shipped with Swift 4.0 is what
pushed the project over the finish line to being useful for iOS developers. `swift run` is contextually the same as
`bundle exec` in that it will run a locally bundled version of your executable.

This means you can run `swift run swiftlint` and reliably get the same results as your CI and fellow developers.

Second, all of the big third party tools support SPM already. So, you probably don't need to send any upstream PRs.

### What are the downsides of the status quo

**Using Homebrew**

Right now, a lot of folks use [homebrew][hb] to manage these types of dependencies. Homebrew is useful for rarely
updated tools (like unix-y CLI apps) but it does not handle having different versions of tool available. This is a
totally reasonable call from Homebrew's perspective but it makes homebrew a bad choice for your **project**
dependencies - because it only installs things globally.

This means a developer (or your CI) would get the most recent version of that tool when they last installed the
tool. This isn't a problem for many projects (for example, check out their [most installed][brew-top90] formulas to
see that it's lot of system libraries, languages and global tools like `node`, `git` and `python`)

**Using CocoaPods**

You can hijack CocoaPod's dependency resolver, and locking system mixed with consistent dependency paths to handle
your tools. This is better than using Homebrew, because everyone has the same version - and so you could reliably
run SwiftLint via `./Pods/SwiftLint/swiftlint`.

This is a great hack, and CocoaPods is smart here - because these dependencies don't ship any code for your app for
compiling it won't set up a library or framework for you. You can even use CocoaPods to set up [a build
phase][script_phase] for you too (I have feelings on this but we'll get to those later.)

I don't really have much of a "you shouldn't do this" for using hacking CocoaPods for your tools, outside of SPM
it's probably the right way to do it.

### Why Use SwiftPM?

1. SPM works
1. SPM can lock your dependencies correctly. `:tada:`
1. The primary tools used in our ecosystem already support it, so you don't need to do any extra work
1. Easy to cache (everything lives in `.build`) which means fast CI builds
1. You're using Swift's tools to manage tools built in Swift, promoting and encouraging the ecosystem you want to
   thrive
1. Your team can get used to how SPM works now, because it should be useful for code dependencies some day
1. SPM is still in a pretty early phase for usage like this, maybe you can find features to add once you've got
   started and contribute back

### What are the downsides?

1. Running a tool will compile it the first time you use `swift run`. Running `swift run danger-swift` would first
   build `danger-swift` from source and then it would run the executable.

1. SPM's dependency resolution step is very naive, and will clone all the dependencies in the tree - even if you
   don't need them. So, the dependencies of your dependencies (a.k.a transitive dependencies) will have full clones
   locally - e.g. the test runner for SwiftLint has to be fully cloned locally in `.build` if you use SPM for
   SwiftLint. I'm hoping [this PR](https://github.com/apple/swift-package-manager/pull/1918) and subsequent
   improvements will fix this.

1. You need to reference a single Swift file in your project to make this work. SPM today does not support a
   dependencies only project (it won't build), so you'll need to reference one Swift file in your codebase.

All of these are fixable, and the first two can be worked around on CI, by caching the `.build` directory. Locally
these actions normally only happens once when you install, or update.

### Show me it in action

What would this look like for a project? IMO, for a reasonably complex Swift app, I think you should have:

- [SwiftLint][sl] for catching potential code issues
- [SwiftFormat][sf] so you don't argue about code style
- [Komondor][kom] to automate the above tools, so people don't have to remember to run the tools
- [Danger Swift][ds] to handle cultural rules for PRs like "Please add Changelogs entries"

You would write a `Package.swift` file like this:

```swift
// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "Eigen",
    dependencies: [
      .package(url: "https://github.com/danger/swift.git", from: "1.0.0"),
      .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.35.8"),
      .package(url: "https://github.com/Realm/SwiftLint", from: "0.28.1"),
      .package(url: "https://github.com/orta/Komondor", from: "1.0.0"),
    ],
    targets: [
        // This is just an arbitrary Swift file in the app, that has
        // no dependencies outside of Foundation, the dependencies section
        .target(name: "eigen", dependencies: ["Danger"], path: "Artsy", sources: ["Stringify.swift"]),
    ]
)

// The settings for the git hooks for our repo
#if canImport(PackageConfig)
    import PackageConfig

    let config = PackageConfig([
        "komondor": [
            // When someone has run `git commit`, first run
            // SwiftFormat and the auto-correcter for SwiftLint
            "pre-commit": [
                "swift run swiftformat .",
                "swift run swiftlint autocorrect --path Artsy/",
                "git add .",
            ],
        ]
    ])
#endif
```

Which gives you access to the following commands:

- `swift run komondor install` - to set up your repo's git hooks
- `swift run swiftformat .` - to run SwiftFormat over your project
- `swift run swiftlint --autocorrect` - to highlight your linter issues
- `swift run danger-swift ci` - to run Danger Swift on your CI

Because you can reliably run both SwiftFormat and SwiftLint via Komondor on a git hook, you can remove build phase
steps that run these tools.

An iOS app's compile and run cycle already takes on the order of seconds, so you should avoid adding extra build
steps in Xcode. I realise that people are only doing this due to the (unreasonably) limited extension support in
Xcode, but the build steps are critical path code. When your build and run cycle is already on the order of many
seconds that iteration cycle has to be as tight as possible.

This setup gives you version-locked access to common linting/formating tools (with the ability to use komondor to
add extra checks if needed) in a self-contained `Package.swift`.

We've started migrating our Artsy projects to use this setup when we work on our native codebases. With our main
iOS app Eigen already using this pattern for Danger Swift, but we don't created/modify enough `*.swift` files to
warrant linters/formatters yet.

[swift-run]: https://github.com/apple/swift-package-manager/pull/1187
[hb]: https://brew.sh
[brew-top90]: https://formulae.brew.sh/analytics/install/90d/
[script_phase]: https://guides.cocoapods.org/syntax/podfile.html#script_phase
[sf]: https://github.com/nicklockwood/SwiftFormat
[sl]: https://github.com/realm/SwiftLint
[ds]: https://danger.systems/swift/
[srcy]: https://github.com/krzysztofzablocki/Sourcery
[sg]: https://github.com/SwiftGen/SwiftGen/
[kom]: https://github.com/orta/Komondor
[spm]: https://swift.org/package-manager/
