---
layout: epic
title: "Making a React Native Components Pod"
date: 2018-03-19
author: orta
categories: [Technology, emission, reaction, reactnative, react, javascript]
css: what-is-react-native
series: React Native at Artsy
# comment_id: 420
---

When we talk about our React Native setup there are two kinds of "[now draw the the tick][draw_tick]" for iOS
developers:

* How do I build this React Native as a CocoaPods setup?
* How do I get all the JavaScript tooling setup up?

We're going to address the first part in this post. By the end of this post we're going to get an Emission-like repo set
up for an existing OSS iOS app called GitHawk. The aim being to introduce any no JavaScript tooling into GitHawk itself,
and to only expose iOS-native UIViewControllers via a CocoaPod which is consumed by GitHawk.

To do this we're going to use the CocoaPods' `pod lib create` template, and React Native's `react-native init` to make a
self-contained React Native repo. It will export a JS file, and some native code which a Podspec will use.

WIP - https://github.com/orta/gitdawg

<!-- more -->

So, I'm going to be annoying here. I will intentionally be adding `$`s before all of the commands, this is specifically
to slow you down and make you think about each command. Also don't use a mobile device.

## GitHawk

Let's get started by having a working [copy of GitHawk][githawk]. I'll leave the README for GitHawk to do that, but if
you want to be certain you're on the same version as me - I'm working from this commit
`84ffeab2555c16e551ddba05fbb7b606ec9a958f`.

Clone a copy of GitHawk, and get it running in your Simulator. Then we can move on to starting our repo.

## GitDawg JS

### Pre-requisites

We need CocoaPods: `$ gem install cocoapods`.

We're going to need node, and a dependency manager. If you run `$ brew install yarn` you will get both. I'm running on
node `8.9.x` and yarn `1.5.x`. Honestly, it shouldn't matter if you're on node 8, or 9. Yarn is basically CocoaPods for
node projects. If you're wondering what the differences are between [yarn][] and [npm][], then TLDR: there used to be
some, but now there's little. I just stock with yarn because I prefer how the CLI works, and I trust its lockfile and
priorities.

We need the React Native CLI, so let's install it globally: `$ yarn global add react-native-cli`.

### Starting with the Pod

We're going to let CocoaPods create the initial folder for our project. Create your repo with `pod lib create GitDawg`.

```sh
$ pod lib create GitDawg

Cloning `https://github.com/CocoaPods/pod-template.git` into `GitDawg`.
Configuring GitDawg template.

------------------------------

To get you started we need to ask a few questions, this should only take a minute.

If this is your first time we recommend running through with the guide:
 - http://guides.cocoapods.org/making/using-pod-lib-create.html
 ( hold cmd and click links to open in a browser. )


What platform do you want to use?? [ iOS / macOS ]
 > iOS

What language do you want to use?? [ Swift / ObjC ]
 > ObjC

Would you like to include a demo application with your library? [ Yes / No ]
 > Yes

Which testing frameworks will you use? [ Specta / Kiwi / None ]
 > None

Would you like to do view based testing? [ Yes / No ]
 > No

What is your class prefix?
 > GD
```

I'd recommend using Objective-C at this point, for simplicities sake. Swift is a great language and all, but I'm after
tooling simplicity. We're not going to write enough native code to warrent the setup for testing. Plus, if we skip
native testing then we can run CI on linux - which is basically instant in comparison.

So this has made a new library. Let's go into that folder with `cd GitDawg`. There shouldn't be too much in here:

```sh
$ ls
Example         GitDawg         GitDawg.podspec LICENSE         README.md
```

Because the core compentency of the repo is the JavaScript, we're going to rename the "GitDawg" folder to be about the
CocoaPod instead of having the name of the project. So run `mv GitDawg Pod` to do that.

Now we want to create our React Native project. I'm hardcoding my versions in these commands to try ensure it always
works, but you never know what amazing changes the future brings.

Let’s create a GitDawg React Native project, and then rename the folder to src:

```sh
# install
$ react-native init GitDawg --version react-native@0.54.0

$ mv GitDawg src
```

We don't want all our project files living in a sub-folder though, so let's move a few of them back to the repo's root,
then remove some unused files.

```sh
# Copy the package metadata, deps, lockfile and dotfiles to root
$ mv -r src/package.json src/node_modules src/yarn.lock .* .`

# Remove the ios and android scaffolds as we have the CP one
$ rm -rf src/ios src/android`
```

Which should make your root look somehting like this:

```
$ ls
Example         GitDawg.podspec LICENSE         README.md       Pods        node_modules    package.json    src             yarn.lock

$ ls src/
App.js    __tests__ app.json  index.js
```

To ensure everything is still hooked up, let's make sure that all of your tests are working in the new repo.

```sg
$ yarn test

yarn run v1.5.1
$ jest
 PASS  src/__tests__/App.js
  ✓ renders correctly (176ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        1.392s
Ran all test suites.
✨  Done in 2.32s.
```

We're now going to be done with our JavaScript side, basically is our React Native "hello world". It's a React Native
project that exposes a single component which says `"Welcome to React Native!"`.

### Deployment

We're going to want to have this exposed to our native libraries, so we're going to ship the bundled JavaScript as our
library's source code. We do this via the React Native CLI, and it's going to place the file inside our Pod folder from
earlier.

```sh
$ react-native bundle --entry-file src/index.js --bundle-output Pod/Assets/GitDawg.js --assets-dest Pod/Assets
```

## GitDawg Pod

With that done, we can start looking at the native side of our codebase. We let `pod lib create` set up an Example app
for us to work with in the repo, which consumes a Podspec in the root. So we're going to take a look at the Podspec, and
update it.

We want to:

* Update our Podspec to handle React Native as a dependency
* Create a `UIViewController` subclass for the Welcome Screen using the bundled React Native

We want to have our Podspec re-use the metadata from React Native to set up GitDawg's dependencies.

```ruby
require 'json'

# Returns the version number for a package.json file
pkg_version = lambda do |dir_from_root = '', version = 'version'|
  path = File.join(__dir__, dir_from_root, 'package.json')
  JSON.parse(File.read(path))[version]
end

# Let the main package.json decide the version number for the pod
gitdawg_version = pkg_version.call
# Use the same RN version that the JS tools use
react_native_version = pkg_version.call('node_modules/react-native')

Pod::Spec.new do |s|
  s.name             = 'GitDawg'
  s.version          = gitdawg_version
  s.description      = 'Components for GitHawk.'
  s.homepage         = 'https://github.com/orta/GitDawg'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'orta' => 'orta.therox@gmail.com' }
  s.source           = { git: 'https://github.com/orta/GitDawg.git', tag: s.version.to_s }

  s.source_files   = 'Pod/Classes/**/*.{h,m}'
  s.resources      = 'Pod/Assets/{GitDawg.js,assets}'

  # React is split into a set of subspecs, these are the essentials
  s.dependency 'React/Core', react_native_version
  s.dependency 'React/CxxBridge', react_native_version
  s.dependency 'React/RCTAnimation', react_native_version
  s.dependency 'React/RCTImage', react_native_version
  s.dependency 'React/RCTLinkingIOS', react_native_version
  s.dependency 'React/RCTNetwork', react_native_version
  s.dependency 'React/RCTText', react_native_version

  # React's dependencies
  s.dependency 'yoga', "#{react_native_version}.React"
  podspecs = [
    'node_modules/react-native/third-party-podspecs/DoubleConversion.podspec',
    'node_modules/react-native/third-party-podspecs/Folly.podspec',
    'node_modules/react-native/third-party-podspecs/glog.podspec'
  ]
  podspecs.each do |podspec_path|
    podspec_json = JSON.parse(`pod ipc spec #{podspec_path}`)
    s.dependency podspec_json['name'], podspec_json['version']
  end
end
```

This Podspec is probably more complex then you're used to, but it means less config. To validate the Podspec, use
`$ pod idc spec GitDawg.podspec` and read the JSON it outputs. With the Podspec set up, it's time to edit the example project's `Podfile`.


```ruby
platform :ios, '9.0'

node_modules_path = '../node_modules'
react_path = File.join(node_modules_path, 'react-native')
yoga_path = File.join(react_path, 'ReactCommon/yoga')
folly_spec_path = File.join(react_path, 'third-party-podspecs/Folly.podspec')
glog_spec_path = File.join(react_path, 'third-party-podspecs/glog.podspec')
double_conversion_spec_path = File.join(react_path, 'third-party-podspecs/DoubleConversion.podspec')

target 'GitDawg_Example' do
  pod 'GitDawg', path: '../'

  # We want extra developer support in React inside this app
  pod 'React', path: react_path, subspecs: ['DevSupport']

  # We're letting CP know where it can find these Podspecs
  pod 'yoga', path: yoga_path
  pod 'Folly', podspec: folly_spec_path
  pod 'DoubleConversion', podspec: double_conversion_spec_path
  pod 'glog', podspec: glog_spec_path
end
```

running `pod install` in the Example dir will bring all the React Native deps into your project.

You want to add a new class to your Pod,

```
touch ../Pod/Classes/GDWelcomeViewController.h ../Pod/Classes/GDWelcomeViewController.m
```

```
#import <UIKit/UIKit.h>

@interface GDWelcomeViewController : UIViewController
@end
```

and

```
#import "GDWelcomeViewController.h"
#import <React/RCTRootView.h>
#import <React/RCTBridgeDelegate.h>
#import <React/RCTBridge.h>

// Let this View Controller handle getting the URL for the JS
@interface GDWelcomeViewController () <RCTBridgeDelegate>
@end

@implementation GDWelcomeViewController

// Set self.view on the VC to be an RCTRootView
- (void)loadView
{
    RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:@{}];
    self.view = [[RCTRootView alloc] initWithBridge:bridge
                                             moduleName:@"GitDawg"
                                    initialProperties:@{}];
}

// Just use our packaged JS for now
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
    NSBundle *emissionBundle = [NSBundle bundleForClass:GDWelcomeViewController.class];
    return [emissionBundle URLForResource:@"GitDawg" withExtension:@"js"];
}

@end
```

If you go and change the Storyboard initial view controller to be a GDWelcomeViewController then you’ll get the default
“Hello world” react native view provided by the template

This was for the compiled code, and is how your app would consume it.

—

[explain what just happened] aiming to replicate prod env right now

—

OK, let’s go take this and migrate it into GitHawk

we need to add GitDawg to our Podfile:

```
source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'


pod 'GitDawg', :path => '../GitDawg'
pod 'yoga', :podspec => 'Local Pods/yoga.podspec.json'
```

Right now yoga can’t be used from the Artsy Specs repo, so you’ll need to download this file:
https://github.com/artsy/Specs/blob/9682688cb3c1759f128cccc3a07000ecd3af44f9/Yoga/0.54.0.React/yoga.podspec.json and
place it in the Local Pods folder in GitHawk

[draw_tick]: http://2.bp.blogspot.com/_PekcT72-PGE/SK3PTKwW_eI/AAAAAAAAAGY/ALg_ApHyzR8/s1600-h/1219140692800.jpg
[githawk]: https://github.com/GitHawkApp/GitHawk
[yarn]: https://github.com/yarnpkg/yarn/
[npm]: https://www.npmjs.com/
