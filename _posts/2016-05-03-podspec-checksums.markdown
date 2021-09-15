---
layout: post
title: "Why does my team's Podfile.lock Podspec checksums change?"
date: 2016-05-03 12:09
author: orta
categories: [mobile, cocoapods, dependencies]
---

We use CocoaPods, and [we don't check in our Pods](https://github.com/artsy/eigen/issues/418) directory for one of our fastest moving apps, [Eigen](https://github.com/artsy/eigen/). This sometimes can cause an [interesting data churn](https://github.com/artsy/eigen/pull/1464) inside the `Podfile.lock` when developers have different sha checksums for their Pods. This is weird, what gives?

<!-- more -->

### What are the Lockfiles?

First off, to ensure we're talking about the same thing, this is our [Podfile.lock](https://github.com/artsy/eigen/blob/master/Podfile.lock). The lockfile is used on `pod install` to ensure all the members of your team have the _exact same_ version of the libraries as each other. Otherwise, with a Podfile like:

```ruby
platform :ios, '9.3'
pod 'AFNetworking/Serialization', '~> 3.0'
target 'MyApp'
```

A developer running `pod install` would get the latest `3.x` version, which could be `3.1` originally, but then 6 months later they could get `3.4` - without a lockfile there is no way to keep track of the specific build. This is why it should always be in your code repo. In the case above my lockfile looks like this:

``` yaml
PODS:
  - AFNetworking/Serialization (3.1.0)

DEPENDENCIES:
  - AFNetworking/Serialization (~> 3.0)

SPEC CHECKSUMS:
  AFNetworking: 5e0e199f73d8626b11e79750991f5d173d1f8b67

PODFILE CHECKSUM: 876ceaa409f4ade2b3d58d310dbe026393824bcc

COCOAPODS: 1.0.0.beta.8
````

### What do the Spec Checksums do?

With the CocoaPods Master Specs repo, we do our best [to try](https://github.com/CocoaPods/Specs/pull/12199) and ensure a write-once repository of Podspecs for the public. However, there are many times when you cannot guarantee that every you have the same version of a Podspec as everyone else in your team.

So, CocoaPods makes a checksum of the JSON representation of your Podspec and keeps that in the lockfile. You can easily [replicate](https://github.com/CocoaPods/CocoaPods/issues/3371) the work to generate a checksum with:

``` sh
~/D/MyApp ⏛  pod ipc spec ~/.cocoapods/repos/master/Specs/AFNetworking/3.1.0/AFNetworking.podspec.json  | openssl sha1
5e0e199f73d8626b11e79750991f5d173d1f8b67
```

### So why am I seeing churn?

A normal git development flow when working with libraries is to:

* Fork a library, change your Podfile to reflect that change
* Make some changes
* Commit them back to the main repo
* Update the Podspec, then make changes bringing your Podfile back to a real (tagged) release

CocoaPods is smart about updating your libraries behind the scenes, but it's not perfect. In order to avoid re-creating your entire Pods folder every time it will check whether your libraries are at the expected version and skip re-creating the whole process.

In the example above, we used the CocoaPods' Specs repo version of the Podspec. In forked repos, e,g,

``` ruby
pod 'AFNetworking/Serialization', :git => "https://github.com/orta/AFNetworking.git", :commit => "6f31b5c7bcbd59d4dac7e92e215d3c2c22f3400e"
```

The Podspec is saved into the `Pods` directory in JSON format at `Pods/Local\ Podspecs/AFNetworking.podspec.json`, this is to ensure there's always access within the CocoaPods sandbox for the Podspecs, and speed probably. This is the podspec used for generating the checksum.

**So how can this get out of sync?**

* During the development cycle, when working with a library you would have used `pod update [library]` to update just that library you were working on.  This could happen multiple times as you build your changes.
* You continued working against your fork till it was ready for review. At this point you have a working version, you submit a PR for code review on the library.
* There are changes that affect the podspec that come up in review, you don't do a `pod update [library]` but send the code back to review ( maybe you changed some metadata for example, which doesn't warrant another update to pass CI. )
* Once all code is reviewed, everything is merged back into master.
* You `pod install` - which continues to use the older version of the Podspec inside the Pods dir, e.g. `Pods/Local\ Podspecs/AFNetworking.podspec.json`.
* You now have the older `AFNetworking.podspec.json` inside your local Pods folder, when the next person runs `pod install` with your changes merged, they get a different SHA, as they've got the version with the metadata changes.

### Simple Fix

The best option is to run `pod update [library]` on the computer which is causing churn, this will tell CocoaPods specifically to request a new version of the library. If that fails to give the same checksum as the rest of your team, there's the good old fasioned `rm -rf Pods &&  pod install`.
