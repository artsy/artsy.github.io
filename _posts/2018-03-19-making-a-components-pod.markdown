---
layout: epic
title: "Making a React Native Components Pod"
date: 2018-03-19
author: orta
categories: [Technology, emission, reaction, reactnative, react, javascript]
css: what-is-react-native
series: React Native at Artsy
comment_id: 430
---

When we talk about our React Native setup in abstract, there are two kinds of "[now draw The Tick][draw_tick]" for iOS
developers:

* How do I build this React Native as a CocoaPods setup?
* How do I get all the JavaScript tooling setup up?

We're going to address the first part in this post. By the end of this post we're going to get an [Emission-like
repo][emission-y] set up for an existing OSS Swift iOS app called [GitHawk][githawk]. The aim being to introduce no
JavaScript tooling into GitHawk itself, and to only expose iOS-native `UIViewControllers` via a CocoaPod which is
consumed by GitHawk.

To do this we're going to use the CocoaPods' `pod lib create` template, and React Native's `react-native init` to make a
self-contained React Native repo. It will export a JS file, and some native code which Podspec will reference. Read on
to start digging in.

<!-- more -->

[show existing links]

So, I'm **choosing** to be annoying here. I will intentionally be adding `$`s before all of the commands, this is
specifically to slow you down and make you think about each command.

<div class="mobile-only">
<p>
  <strong>Also, before you get started</strong>, it looks like you're using a really small screen, this post expects you would have a terminal around with useful tools for getting stuff done. I'm afraid without that, you're not going to get much out of it. I'd recommend switching to a computer.
</p>
</div>

## GitHawk

Let's get started by having a working [copy of GitHawk][githawk]. I'll leave the README for GitHawk to do that, but if
you want to be certain you're on the same version as me - I'm working from this commit
`84ffeab2555c16e551ddba05fbb7b606ec9a958f`. [todo: this needs to be my merged PR now that 9.3 broke GitHawk]

Clone a copy of GitHawk, and get it running in your Simulator, should take about 5 minutes Then we can move on to
starting our repo.

## GitDawg JS

### Pre-requisites

We need CocoaPods: `$ gem install cocoapods`.

We're going to need node, and a dependency manager. If you run `$ brew install yarn` you will get both. I'm running on
node `8.9.x` and yarn `1.5.x`. Honestly, it shouldn't matter if you're on node 8, or 9. Yarn is basically CocoaPods for
node projects. If you're wondering what the differences are between [yarn][] and [npm][], then TLDR: there used to be
some, but now there's little. I stick with yarn because I prefer how the CLI works, and I trust its lockfile.

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
# Install RN
$ react-native init GitDawg --version react-native@0.54.4
# Rename the folder to src
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

Which should make your app's folder look something like this:

```sh
$ ls
Example         GitDawg.podspec LICENSE         README.md       Pods        node_modules    package.json    src             yarn.lock

$ ls src/
App.js    __tests__ app.json  index.js
```

To ensure everything is still hooked up, let's make sure that all of your tests are working in the new repo.

```sh
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

Our goal with the Example app is to set up an app exclusively for developing components in. In Artsy's case, this app
handles auth and has a series of jump-off points for developing a component (either through Storybooks or directly using
the Pods' `UIViewController`s.)

To get started we need to modify the CocoaPod this repo represents:

* Update our Podspec to handle React Native as a dependency, and our assets
* Add support for native compilation via CocoaPods with [cocoapods-fix-react-native][cpfrn]
* Create a single `UIViewController` subclass for the Welcome Screen using the bundled React Native JS

We want to have our Podspec re-use the metadata from React Native to set up GitDawg's dependencies. So replace
`GitDawg.podspec` with this:

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
`$ pod idc spec GitDawg.podspec` and read the JSON it outputs. With the Podspec set up, it's time to set up the example
project's `Gemfile` and `Podfile`.

We'll start with applying the [React Native hot-fix plugin][cpfrn], sometimes a version of React Native is released that
doesn't support Swift frameworks (as Facebook don't use Swift) and so you have to apply some patches to the code. I made
a CocoaPods Plugin that handles the hot-fixes for you.

Start by making a `Gemfile` in the `Example` folder:

```ruby
source 'https://rubygems.org'

gem 'cocoapods'
gem 'cocoapods-fix-react-native'
```

Then run `bundle install`, and it will be added to your dependencies. Making it possible to reference
`"cocoapods-fix-react-native"` in your `Podfile`.

We want to take the current Podfile and make sure that every React Native dependency comes from the folder in
`node_modules. We can do this using the`:path` operator to redeclare where you can find each Pod.

Note: we also _extend_ the amount of subspecs for `'React'` in this Podfile via `subspecs: ['DevSupport']` - this is
what provide the hot code reloading and other developer tools. You'll want this, it will mean that the example app can
be used as a dev environment, and your main app will only get a production environment.

So edit `Example/Podfile` to look like this:

```ruby
platform :ios, '9.0'

node_modules_path = '../node_modules'
react_path = File.join(node_modules_path, 'react-native')
yoga_path = File.join(react_path, 'ReactCommon/yoga')
folly_spec_path = File.join(react_path, 'third-party-podspecs/Folly.podspec')
glog_spec_path = File.join(react_path, 'third-party-podspecs/glog.podspec')
double_conversion_spec_path = File.join(react_path, 'third-party-podspecs/DoubleConversion.podspec')

plugin 'cocoapods-fix-react-native'

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

Then run `bundle exec pod install` in the Example dir, which will bring all the React Native deps into your project.

We need some native code to represent our Welcome component from the React Native template. So create two new files in
`Pod/Classes`:

```sh
$ touch ../Pod/Classes/GDWelcomeViewController.h ../Pod/Classes/GDWelcomeViewController.m
```

It is a pretty vanilla `UIViewController`, so declare it exists in the interface and then use an `RCTRootView` as it's
`self.view`.

```objc
#import <UIKit/UIKit.h>

@interface GDWelcomeViewController : UIViewController
@end
```

We're going to handle the React bridging in this `UIViewController`, because that is the simplest option for our Hello
World app. We'll be going back to this later.

```objc
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

// Use our bundled JS for now
- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
    NSBundle *gitdawgBundle = [NSBundle bundleForClass:GDWelcomeViewController.class];
    return [gitdawgBundle URLForResource:@"GitDawg" withExtension:@"js"];
}

@end
```

Run `bundle exec pod install` inside the `Example` folder again to update the Pod with the new files. Then you're good
to go. As the `pod lib create` template uses storyboards, you will need to open up the example app's storyboard and
change the initial view controller to be a `GDWelcomeViewController`. Then run the app in the simulator, and you should
get this screen:

<center><img src="/images/making_cp_pod/success.png" width="50%" /></center>

This is the default screen from the React Native template, and it's proof that everything has worked.

Let's take a second to re-cover what has happened to get us to this point.

1.  We used the `pod lib create` template to make a library repo

2.  We used `react-native init` to make a React Native environment, which has the settings in the root and the source
    code inside `src`

3.  We've bundled the React Native code into our CocoaPod's asset folder

4.  We set up the Podspec for GitDawg, and then the Podfile for the example project to consume it

5.  We added [cocoapods-fix-react-native][cpfrn] to hotfix the native files

6.  We added a UIViewController for the default screen from `react-native init` to our CocoaPod, and ran
    `bundle exec pod install` to update the example project

7.  We changed the storyboard reference to point to the UIViewController from our Pod, and ran the simulator to see our
    welcome screen.

This is a full run-through of how your Pod would look when integrated into your main app's codebase. At this point you
have a unique, isolated app which is going to be your development environment. In our case this app is a menu of
different root screens and admin flags.

—

OK, let’s go take this and migrate it into GitHawk. This is what our end-goal looks like:

<center><img src="/images/making_cp_pod/githawk.gif" width="75%" /></center>

Our setup is going to be different here because we can't rely on React Native coming from the file-system, as we want to
make sure our app has no hint of JS tooling. So we will use CocoaPods to handle downloading and setting up our versions
of the React Native libraries. As of 0.54.x, that is React and Yoga.

We want to have a local copy of the JSON version of Podspecs for each of these. They can be generated from the Podspecs
using `bundle exec pod ipc spec [file.podspec]`. Let's generate one for React:

```sh
$ cd GitDawg/node_modules/react-native/; pod ipc spec React.podspec
```

It will output a bunch of JSON to your terminal. This is :+1:. Let's move a copy to your desktop.

```sh
$ pod ipc spec node_modules/react-native/React.podspec > ~/Desktop/React.podspec.json
```

You'll see no output if everything went fine. Before you grab that podspec, let's get the one for yoga too.

```sh
$ cd ReactCommon/yoga/; pod ipc spec yoga.podspec > ~/Desktop/yoga.podspec.json
```

Again, no output means everything is great. You should now have two JSON files in your Desktop. Grab them, move them
into a the `Local Pods` folder inside GitHawk.

```sh
$ cd GitHawk # However it takes to get back there.
$ mv ~/Desktop/*.podspec.json "Local Pods"
```

Modify the `Gemfile` to include [cocoapods-fix-react-native][cpfrn]:

```ruby
source 'https://rubygems.org'

gem 'cocoapods', '~> 1.4.0'
gem 'cocoapods-fix-react-native'
```

Then run `bundle install`. Next we need to add GitDawg, and its dependencies to the Podfile:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

[...]

pod 'GitDawg', :path => '../GitDawg'
pod 'React', :podspec => 'Local Pods/React.podspec.json'
pod 'yoga',  :podspec => 'Local Pods/yoga.podspec.json'
```

Then run `bundle exec pod install`. That should grab and set up React Native for you.

Open up the Xcode Workspace - `Freetime.xcworkspace`, and we're gonna make the code changes - it's all in one file. Open
the file `RootNavigationController.swift` and add a new `import` at the top for `GitDawg`:

```diff
import UIKit
import GitHubAPI
import GitHubSession
+ import GitDawg
```

Then add our new view controller by replacing the bookmarks view controller

```diff
        tabBarController?.viewControllers = [
            newNotificationsRootViewController(client: client),
            newSearchRootViewController(client: client),
+            GDWelcomeViewController(),
-            newBookmarksRootViewController(client: client),
            settingsRootViewController ?? UIViewController() // simply satisfying compiler
        ]
```

That should get you to the same point as we were in the dev app.

[summary of native changes]

---

So what now?

* Convert dev mode to actually use RNP
* Switch to deploys for GitDawg, instead of `:path`

[draw_tick]: http://2.bp.blogspot.com/_PekcT72-PGE/SK3PTKwW_eI/AAAAAAAAAGY/ALg_ApHyzR8/s1600-h/1219140692800.jpg
[githawk]: https://github.com/GitHawkApp/GitHawk
[yarn]: https://github.com/yarnpkg/yarn/
[npm]: https://www.npmjs.com/
[cpfrn]: https://github.com/orta/cocoapods-fix-react-native#readme
[emission-y]: /blog/2016/08/24/On-Emission/
[githawk]: https://github.com/GitHawkApp/GitHawk/
