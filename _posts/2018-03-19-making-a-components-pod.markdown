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

WIP - https://github.com/orta/gitdawg

<!-- more -->

* clone and run GitHawk
* validate it runs in the sim
* install yarn; `brew install yarn`

`yarn global add react-native-cli`

$ `pod lib create GitDawg`
$ `cd GitDawg`



`$ cd GitDawg`
```
$ ls 
Example         GitDawg         GitDawg.podspec LICENSE         README.md
```
`$  mv GitDawg Pod`

Let’s create a GitDawg project, and rename it to src
`$ react-native init GitDawg --version react-native@0.54.0`
`$ mv GitDawg src`

move the project files back into the root
`$ mv -r src/package.json src/node_modules src/yarn.lock .* .`

remove the iOS and android generated Xcode/Gradle
`$ rm -rf src/ios src/android`

```
$ ls
Example         GitDawg.podspec LICENSE         README.md       _GitDawg        node_modules    package.json    src             yarn.lock
```

```
$ ls src/
App.js    __tests__ app.json  index.js
```

Validate tests works

```
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

Lets ship this one screen to our app

`$ react-native bundle --entry-file src/index.js --bundle-output Pod/Assets/GitDawg.js --assets-dest Pod/Assets`

Time to focus on the CocoaPods side now

We want to:

- Update our Podspec 
- Create a UIViewController for the WelcomeScreen from RN

```
require 'json'

pkg_version = lambda do |dir_from_root = '', version = 'version'|
  path = File.join(__dir__, dir_from_root, 'package.json')
  JSON.parse(File.read(path))[version]
end

gitdawg_version = pkg_version.call
react_native_version = pkg_version.call('node_modules/react-native')

Pod::Spec.new do |s|
  s.name             = 'GitDawg'
  s.version          = gitdawg_version
  s.description      = 'Components for GitHawk.'
  s.homepage         = 'https://github.com/orta/GitDawg'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { 'orta' => 'orta.therox@gmail.com' }
  7777777      s.source           = { git: 'https://github.com/orta/GitDawg.git', tag: s.version.to_s }

  s.source_files   = 'Pod/Classes/**/*.{h,m}'
  s.resources      = 'Pod/Assets/{GitDawg.js,assets}'

  # React
  s.dependency 'React/Core', react_native_version
  s.dependency 'React/CxxBridge', react_native_version
  s.dependency 'React/RCTAnimation', react_native_version
  s.dependency 'React/RCTCameraRoll', react_native_version
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

 we can validate it does what we think by running `pod idc spec GitDawg.podspec` 


OK, update the demo project’s Podfile:

```
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

If you go and change the Storyboard initial view controller to be a GDWelcomeViewController then you’ll get the default “Hello world” react native view provided by the template

This was for the compiled code, and is how your app would consume it.

—

[explain what just happened] 
 aiming to replicate prod env right now

—

OK, let’s go take this and migrate it into GitHawk

we need to add GitDawg to our Podfile:

```
source 'https://github.com/artsy/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'


pod 'GitDawg', :path => '../GitDawg'
pod 'yoga', :podspec => 'Local Pods/yoga.podspec.json'
```

Right now yoga can’t be used from the Artsy Specs repo, so you’ll need to download this file: https://github.com/artsy/Specs/blob/9682688cb3c1759f128cccc3a07000ecd3af44f9/Yoga/0.54.0.React/yoga.podspec.json and place it in the Local Pods folder in GitHawk
