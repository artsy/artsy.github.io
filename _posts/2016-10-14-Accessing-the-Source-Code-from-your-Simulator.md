---
layout: post
title: "Accessing the app's Source Code from your Simulator"
date: 2016-10-14 12:17
author: orta
categories: [mobile, ios, eigen, emission]
---

In the last few months twice I've wanted to access the source code of our application. The first time I did it I came up with a pretty neat hack, but it wouldn't really work in many places. The second time however, I [asked the internet](https://twitter.com/orta/status/786470282093625344), and the [internet](https://twitter.com/saniul/status/786470857635827712) [replied](https://twitter.com/0xced/status/786619335116750848).

TLDR: You can use your [project's scheme](https://github.com/artsy/emission/pull/350/commits/2a39c743bcaaf2e3b848ad60621198f40365fdd2) to expose derived Xcode environment variables to your source code.

The rest of the blog post is a little bit about _why_ I wanted to do that and what I did with it.

<!-- more -->

Both times I've wanted to access the source code of our apps is because I've wanted to make better admin tools. It should come as no surprise to people who know me that I care about tooling, but I also care a lot about making it possible for our admins to do their own thing. As such, our [admin settings panel](https://github.com/artsy/eigen/blob/master/Artsy/View_Controllers/Admin/ARAdminSettingsViewController.m) in Eigen is extensive.

### Root React Components 

The first time came when I started to think about what admin options I'd like to see for people using our React Native side. These are the options I came up with:

 ![/images/source-code-sim/react-admin-eigen.png](/images/source-code-sim/react-admin-eigen.png)

There are two interesting things about it:
 
 - We support running any master commit of our React Native code inside Eigen, for Admins, [via AppHub](https://apphub.io)
 - We allow loading arbitrary React components as an admin.

 It's this last bit that's interesting, right now I'm working on a new root Gene component (read: new view controller) in Emission, our React Native implementation. As this work has not moved upstream into Eigen, I can access it through a commit on AppHub, and then open it using our custom module loader:

![/images/source-code-sim/react-module-eigen.png](/images/source-code-sim/react-module-eigen.png)

In order to show the available root components (Artist/Home/Gene), we use GitHub's raw URLs to download the source code of our Open Source apps. Hah, a nice hack right? I [created](https://github.com/artsy/eigen/blob/master/Artsy/View_Controllers/Admin/ARAdminNetworkModel.m) a `ARAdminNetworkModel` with an API like this:

```objc
@interface ARAdminNetworkModel : NSObject

- (void)getEmissionJSON:(NSString *)path completion:(void (^)(NSDictionary *json, NSError *error))completion;

- (void)getEmissionFile:(NSString *)path completion:(void (^)(NSString *fileContents, NSError *error))completion;

@end
``` 

Which simply uses `NSURLSession` under the hood:

```objc
- (void)getEmissionData:(NSString *)path completion:(void (^)(NSData *data, NSError *error))completion;
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *urlFormat = @"https://raw.githubusercontent.com/artsy/emission/master/%@";
    NSString *url = [NSString stringWithFormat: urlFormat, path];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            completion(data, error);
    }];
    [task resume];
}
```

Nothing special, but it required a cognitive jump to get there.

### Submodule Introspection

The second time I wanted this is inside [the example app](https://github.com/artsy/emission/tree/master/Example) for Emission. This is a typical example application for a library made by `pod lib create`. This example app is basically just the admin settings panel from Eigen, shown above. 

When I [switched the](https://github.com/artsy/emission/pull/347) example app to use a similar theme and menu DSL as Eigen, I also took the chance to expand on the buttons we had available. Previously there was the ability to load the view controller for one specific artist, but I knew we had a [giant list of artist slugs](https://github.com/artsy/metaphysics/blob/master/schema/artist/maps/artist_title_slugs.js) inside one of our optional sub-modules. What I wanted to do, was offer a random Artist from that if the submodule was `init`'d. 

This required introspecting the source, which I could have also done via the GitHub API, but it was also feasible to do by accessing the filesystem outside of the simulator. This is totally possible ( and is [how FBSnapshots works](https://www.objc.io/issues/15-testing/snapshot-testing/) ) but I needed to access the project root, then I could build relative links. Thus, [I asked the internet](https://twitter.com/orta/status/786470282093625344). I knew these variables existed, but that they were a part of the build process - and not exposed to the app runtime. 

There are two ways to do it, both make sense for different contexts:

* [Baking the value into your Info.plist](https://github.com/artsy/emission/blob/74d0bc6cc45da906436f8bbc33710ea030657ee8/Example/Emission/Info.plist#L5-L6) - which makes it available for all consumers at runtime, e.g. you could deploy this value, but it's not too useful for my problem.
* [Exposing it as an environment variable via your scheme](https://github.com/artsy/emission/pull/350/commits/2a39c743bcaaf2e3b848ad60621198f40365fdd2) - perfect for this case, the variable won't be exported when you deploy.   

Now our scheme looks like this:

{% expanded_img /images/source-code-sim/scheme-settings-emission.png %}

I can then use the value of `SRCROOT` as the start of an absolute path to get to any of the source code in our project. Making the [final code](https://github.com/artsy/emission/blob/dda57636e424ab7d4517de57f3e8bd917fcb3c6f/Example/Emission/ARRootViewController.m#L85-L108):

```obj-c
- (ARCellData *)jumpToRandomArtist
{
  NSString *sourceRoot = [NSProcessInfo processInfo].environment[@"SRCROOT"];
  NSString *artistListFromExample = @"../externals/metaphysics/schema/artist/maps/artist_title_slugs.js";
  NSString *slugsPath = [sourceRoot stringByAppendingPathComponent:artistListFromExample];

  NSFileManager *manager = [NSFileManager defaultManager];

  // Don't have the submodule? bail, it's no biggie
  if (![manager fileExistsAtPath:slugsPath]) { return nil; }

  // Otherwise lets support jumping to a random Artist
  return [self tappableCellDataWithTitle:@"Artist (random from metaphysics)" selection: ^{
    NSString *data = [NSString stringWithContentsOfFile:slugsPath encoding:NSUTF8StringEncoding error:nil];

    ... and so on
```

### Tooling

Paying attention to your admin tools, and improving your development experience for the whole team is a great way to win friends and influence people. Introspecting your source code may help that. 
