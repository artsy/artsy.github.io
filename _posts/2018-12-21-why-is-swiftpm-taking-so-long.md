---
layout: epic
title: Why is the Swift Package Manager taking so long?
date: 2018-12-21
author: [orta]
categories: [swift, package-management, build tools]
comment_id: 512
---

Last month I was chatting at a bar with an engineer working on the Swift team, and we welcomed someone to our
conversation where they opened with the question: _"When can I stop using CocoaPods and switch to Swift PM?"_ I
chuckled, because I get this a lot (I have been helping to maintain CocoaPods for about 6 years now) but they had
made mistake of asking an Apple employee about something which sounds even remotely like a future product question.
So, it didn't go anywhere.

Well, _person whose name I don't remember_, let me try to re-frame that question into something I can take a
reasonable stab at: **"Why are we all still using CocoaPods now instead of Swift PM for iOS apps three years after
its release?"**

<!-- more -->

Three years ago in December 2015, Swift became open source. Inside the source code was a [pleasant
surprise][tw_spm] that Apple were going to start making their own package manager. Great, CocoaPods was
[sherlocked][], but Apple had control of Xcode and the entire toolchain so they could integrate it natively. I
thought this was pretty cool, and wrote the following about Swift PM in my annual write-up that year:

> [On the Swift PM team] They’re actively talking with the community and us, finding ways to share work and to
> promote collaboration. It’s eased a lot of the friction I had been feeling. Apple has a fresh start in a way we
> could not, and will be able to do things much better than the CocoaPods team could.

> All in all, when people have been asking what I want to do in the next year, I’m feeling pretty done on the
> "lowering the barrier to entry" space, this year it became less fun.

_Fun fact: This is what gave me the space to start working on [Danger][]._

The announcement of Swift PM came out to some fan-fare as the "end of CocoaPods" from the iOS community, and I was
also pretty happy to get some time back to work on other problems. However, a few years down the line it's not
really turned out that way. What gives?

# Why Swift PM exists

Before Swift PM, you couldn't reasonably manage Swift projects in Linux. Apple have exclusively been building dev
tools for macOS because that's what they own, and so, all their dev-tools customers (internal and external) have to
use Macs to make their software. It's not particularly unreasonable.

However, to make Swift a language with a larger scope than "making iOS and macOS apps" and it's usage being limited
to just the Cocoa community: they would need to support running and compiling Swift apps on Linux.

It's safe to say Apple probably has no plans to port Xcode to Linux, (though look at what Microsoft achieved when
they decided that they needed to support Visual Studio on macOS [somehow][vscode]) but what's more important here
is the underlying tooling **above** the compiler but **below** Xcode: `xcodebuild`, wouldn't make any sense in that
context. It's deeply macOS and Cocoa specific.

So, Apple needed something to handle the following problems if you were working in a Xcode-less Swift project:

- Handling build dependencies
- Linking to existing code
- Creating library abstractions
- Creating executable for the language
- Handling sharing code between projects

Roughly in that order of precedence too. In short, they needed a build system first, and then a dependency manager
to support remote packages.

There are a few big existing build systems: [Buck][buck] and [Ninja][ninja] are the biggest players in the game,
but they aim to be language agnostic build tools. This makes them a bit too abstract to be useful as the main way
to build a modular system for building projects in a language. So, each language from Swift's generation of _"As
fast as C, but safe"_ like Rust, Go and D all implement a build system unique to their language.

# llbuild

Apple's approach to building a build system is smart. Instead of from scratch creating a build tool for Swift, they
created an abstraction which makes it feasible to build complex builds systems quicker. That's [llbuild][], a
low-level build system. This was used to create the Swift build system. Then, llbuild was re-used to create
[Xcode's build system][xcbuild].

The new build system for Xcode came out in 2017 with Xcode 9, and became the default in 2018 with Xcode 10. What's
impressive about the new build system is how much it was just like the last, but better, to quote [James
Dempsey][jd-build-system]:

> New build system. Same build settings

Which is impressive, because the existing system is [complex][bs].

# Build System != Package Manager

CocoaPods was "useful" for Cocoa development very quickly in comparison (roughly a month from initial commit to
supporting a few existing libraries in an app back in 2011), this was because CocoaPods completely skipped the
build tool stage. There was no need, Xcode has a working build system and you can control it via `.xcodeproj`
files. This meant that the key output for CocoaPods is to reliably support generating xcode projects and the
underlying abstractions making it actually compile is left to the Xcode team.

The Swift PM team couldn't do this without making it deeply dependent on Xcode. CocoaPods can be in-different to
something like Linux support (fun fact: last month [Windows support][winders] was added) because no-one is writing
Cocoa apps on Linux, and it's only concern is shipping those Xcode project files to your project's file system.

This difference in abstraction level allowed CocoaPods to work on comprehensive support of the existing library
ecosystem considerably sooner. The config options were already set, the types of projects were known they had to
map to whatever Xcode supported rather than the more mundane task of actually figuring out how to make a project
build, compile and scale.

CocoaPods got focus on more user-facing issues that a dependency manager has considerably quicker, and could focus
on building the most used features first then moving to more niche features (which could be the abstractions those
popular feature relied on) when someone needed it. This meant that the user-facing, and interesting to me, work was
feasible considerably earlier:

- Discovery of packages
- A lot of documentation
- Access rights for owners
- Creating plugin systems giving hooks for all sorts of projects to be built
- Support for esoteric compiler features
- Support for esoteric Xcode features
- Providing useful metrics on quality/usage
- Cool stickers

Which generally speaking are problems that Swift PM will eventually have to hit, but instead of jumping straight to
it, the team has to first build the foundations before making the decorations.

# The cost

These choices came with a cost though, right now there's only 1 or 2 contexts where Swift PM is useful, the most
prominent is Swift on a Server. It's likely that Swift on a server probably isn't as widely adopted as Apple hoped
it would be by the programming community on whole. Unless you are an iOS developer with existing skills, Swift
probably doesn't even register as being a language you would consider building your web API/apps in. Yes, I know
there are a [few][few] [good][objcio] exceptions, but they come from the iOS community.

Which probably hasn't helped with resourcing Swift PM at Apple, where the user-facing team has
[basically][swift-pm-contrib] been a one-man operation for about a year and a half. From my external perspective,
this is lower than I'd like. It's a problem close to my heart though.

Given that we're talking about Apple, you shouldn't judge activity entirely from their open source contributions,
but given the project isn't useful for most people who could contribute, they don't. I started working on CocoaPods
because it was fixing a really hard problem that I had, and I knew that working on this would fix it for everyone
else in the industry too, making it worth my time. So, external contributions outside Apple are pretty low.

Build systems are a hard problem, and the Swift PM team very reasonably needs to work on that first, but is
basically doing it pretty much solo. I think this is one of those "[skate where the puck will be][puck]"
situations, instead of where it is, which CocoaPods' aimed for. This means it's going to take a much longer time to
be useful and widely adopted. While I don't really know where Swift PM aims to be in the long-term, I think Xcode
integration will probably be the major adoption turning point but in the meantime I've got an idea for a smaller
way to make Swift PM useful to the iOS community. That, however, is another blog post.

[tw_spm]: https://twitter.com/orta/status/672436829250052102
[sherlocked]: https://www.urbandictionary.com/define.php?term=sherlocked
[danger]: https://danger.systems/
[vscode]: https://code.visualstudio.com
[buck]: https://www.github.com/facebook/buck
[ninja]: https://ninja-build.org
[llbuild]: https://www.github.com/apple/swift-llbuild
[jd-build-system]: https://jamesdempsey.net/2017/06/13/new-xcode-build-system-and-buildsettingextractor/
[bs]: https://pewpewthespells.com/blog/xcode_build_system.html
[winders]: https://github.com/CocoaPods/CocoaPods/pull/8189
[swift-pm-contrib]: https://github.com/apple/swift-package-manager/graphs/contributors
[puck]: https://ryanparman.com/posts/2011/skating-to-where-the-puck-will-be/
[few]: https://www.pointfree.co
[objcio]: https://talk.objc.io/collections/server-side-swift
[xcbuild]: https://lists.swift.org/pipermail/swift-build-dev/Week-of-Mon-20170605/001019.html
