---
layout: post
title: "Cocoa Architecture: ARSwitchboard"
date: 2015-08-19
comments: false
categories: [ios, mobile, architecture, energy, eigen, eidolon]
author: Orta Therox
github-url: https://www.github.com/orta
twitter-url: http://twitter.com/orta
blog-url: http://orta.io
---

As a part of going through the design patterns we've found in the creation of the Artsy iOS apps, I'd like to introduce the Switchboard pattern. This evolved quite naturally out of [ARRouter](/blog/2015/08/15/Cocoa-Architecture:-Router-Pattern/) when applied to generating view controllers instead of API requests.

<!-- more -->

----------------

## Where we started

In what must be one of my best named commits, `b9ff28` aka *"CREATING THE VOID"* introduced an ARSwitchboard to Eigen. Aside from this being the commit where I could finally write `[ARVoidViewController theVoid]` it added support for tapping an Artwork on the home-screen and going to another view controller.

We knew up-front that we needed to emulate the website's URL schemes, so we needed to come up with a way to support two ways of loading up a view controller. Here's what it looked like:

```objc
@implementation ARSwitchBoard

+ (void)setupRouter {
    artsyHosts = [NSSet setWithObjects:@"art.sy", @"artsyapi.com", @"artsy.net", nil];

    [RCRouter map:@"/artwork/:id" to:self with:@selector(loadArtworkFromURL:)];
}

+ (void)navigateToURL:(NSURL * )url {
    if([self isInternalURL:url] && [RCRouter canRespondToRoute:url.path]) {
        [RCRouter dispatch:url.path];
    } else {
//        [self openInternalBrowser:url];
    }
}

+ (BOOL)isInternalURL:(NSURL * )url {
    NSString * host = url.host;
    if(host && [host hasPrefix:@"www"]) {
        host = [host substringFromIndex:3];
    }

    return (host && [artsyHosts containsObject:host]);
}

#pragma mark -
#pragma mark Artworks

+ (void)loadAttachmentCollection:(AttachmentCollection * )collection {
    [[ARVoidViewController theVoid] loadArtworkViewWithAttachmentCollection:collection];
}

+ (void)loadArtwork:(Artwork * )artwork {
    AttachmentCollection * collection = [AttachmentCollection collectionWithItems:@[artwork] andIndex:0];
    [self loadAttachmentCollection:collection];
}

+ (void)loadArtworkFromURL:(NSDictionary * )options {
    [[ARVoidViewController theVoid] loadArtworkViewWithID:options[@"id"]];
}

@end
```

It shows the pattern's humble origins quite well. It provides an API that any other view controller can call to handle pushing a view controller on to a stack somewhere, but not only that it can deal with being given an arbitrary URL and handle that too.

### Where the pattern evolved

I initially wrote this during my "Class methods look prettier" stage. Our `ARSwitchboard` has evolved into using instance methods, and it uses a sharedInstance. This makes writing tests for the routing extremely simple for [easy use cases](https://github.com/artsy/energy/blob/master/ArtsyFolio%20Tests/Util/ARSwitchboardTests.m), and possible [for the complex](https://github.com/artsy/eigen/blob/2eb00a8050a69ab2e05ffeb11a2bbdcbadf9fb7e/Artsy_Tests/App_Tests/ARSwitchBoardTests.m).

The pattern was established pretty well by the time it was integrated [into Energy](https://github.com/artsy/energy/blob/a35969d232d8309fd2aedaae35f2dbdf6d505004/Classes/Util/App/ARSwitchBoard.m). Some of it's highlights are:
* The sharedInstance is [set up](https://github.com/artsy/energy/blob/a35969d232d8309fd2aedaae35f2dbdf6d505004/Classes/Util/App/ARSwitchBoard.m#L20-L31) with some of the other singletons, from that point on it only acts on properties it owns.
* It deals with setting up entire [view hierarchies](https://github.com/artsy/energy/blob/a35969d232d8309fd2aedaae35f2dbdf6d505004/Classes/Util/App/ARSwitchBoard.m#L229-L259). Not just pushing another view on to a `UINavigationController`.

### Alternatives

We didn't need an ARSwitchboard in Eidolon. Which, so far always seems to be the exception in these architecture pattern posts. Instead we opted for Apple's [Dependency Injection tool](http://www.objc.io/issues/15-testing/dependency-injection/), Interface Builder + Storyboards. Energy pre-dates Storyboards, and they didn't feel like a good fit for Eigen.

We found storyboards to be a really good replacement to this pattern when you have an established series of steps in your application. With some well defined connections.

As an example, our on-boarding process for Eigen probably should have been storyboarded, as it's a series of view controllers pushed incrementally. However given that the rest of Eigen is essentially a web of interconnected view controllers, we'd be abusing the tool.
