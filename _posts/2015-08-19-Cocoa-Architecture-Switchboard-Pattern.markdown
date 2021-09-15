---
layout: post
title: 'Cocoa Architecture: ARSwitchboard'
date: 2015-08-19T00:00:00.000Z
comments: false
categories:
  - ios
  - mobile
  - architecture
  - energy
  - eigen
  - eidolon
author: orta
series: Cocoa Architecture
---

As a part of going through the design patterns we've found in the creation of the Artsy iOS apps, I'd like to introduce the Switchboard pattern. This evolved quite naturally out of [ARRouter](/blog/2015/08/15/Cocoa-Architecture:-Router-Pattern/) when applied to generating view controllers instead of API requests.  

<!-- more -->
--------------------------------------------------------------------------------

# Where we started
In what must be one of my best named commits, `b9ff28` aka _"CREATING THE VOID"_ introduced an `ARSwitchboard` to Eigen. Aside from this being the commit where I could finally write `[ARVoidViewController theVoid]` it added support for tapping an Artwork on the home-screen and going to another view controller.

We knew up-front that we needed to emulate the website's URL schemes, so we needed to come up with a way to support two ways of loading up a view controller. Here's what it looked like:

```objc
@implementation ARSwitchBoard

+ (void)setupRouter {
    artsyHosts = [NSSet setWithObjects:@"art.sy", @"artsyapi.com", @"artsy.net", nil];

    [RCRouter map:@"/artwork/:id" to:self with:@selector(loadArtworkFromURL:)];
}

+ (void)navigateToURL:(NSURL *)url {
    if([self isInternalURL:url] && [RCRouter canRespondToRoute:url.path]) {
        [RCRouter dispatch:url.path];
    } else {
//        [self openInternalBrowser:url];
    }
}

+ (BOOL)isInternalURL:(NSURL *)url {
    NSString * host = url.host;
    if(host && [host hasPrefix:@"www"]) {
        host = [host substringFromIndex:3];
    }

    return (host && [artsyHosts containsObject:host]);
}

#pragma mark -
#pragma mark Artworks

+ (void)loadAttachmentCollection:(AttachmentCollection *)collection {
    [[ARVoidViewController theVoid] loadArtworkViewWithAttachmentCollection:collection];
}

+ (void)loadArtwork:(Artwork *)artwork {
    AttachmentCollection * collection = [AttachmentCollection collectionWithItems:@[artwork] andIndex:0];
    [self loadAttachmentCollection:collection];
}

+ (void)loadArtworkFromURL:(NSDictionary *)options {
    [[ARVoidViewController theVoid] loadArtworkViewWithID:options[@"id"]];
}

@end
```

It shows the pattern's humble origins quite well. The `ARSwitchboard` provides an API that any object can call, and it will handle presenting the view controller. Offering an API that can either use arbitrary URLs or model objects.

## Where the pattern evolved
I initially wrote this during my "Class methods look prettier" stage. Our `ARSwitchboard` has evolved into using instance methods, and it uses a sharedInstance. This makes writing tests for the routing extremely simple for [easy use cases](https://github.com/artsy/energy/blob/master/ArtsyFolio%20Tests/Util/ARSwitchboardTests.m), and possible [for the complex](https://github.com/artsy/eigen/blob/2eb00a8050a69ab2e05ffeb11a2bbdcbadf9fb7e/Artsy_Tests/App_Tests/ARSwitchBoardTests.m).

The pattern was established pretty well by the time it was integrated [into Energy](https://github.com/artsy/energy/blob/a35969d232d8309fd2aedaae35f2dbdf6d505004/Classes/Util/App/ARSwitchBoard.m). Some of it's highlights are:

- The sharedInstance is [set up](https://github.com/artsy/energy/blob/a35969d232d8309fd2aedaae35f2dbdf6d505004/Classes/Util/App/ARSwitchBoard.m#L20-L31) with some of the other singletons, from that point on it only acts on properties it owns.

- It deals with setting up entire [view hierarchies](https://github.com/artsy/energy/blob/a35969d232d8309fd2aedaae35f2dbdf6d505004/Classes/Util/App/ARSwitchBoard.m#L229-L259). Not just pushing another view on to a `UINavigationController`.

## Internal Routing
We try to make all view controllers that could represent a URL have two initializers; one that accepts a full model object and another that works off an ID. This means that we can provide as much context as we can initially, but can generate everything at runtime if you've come from a push notification or from another app.

We use an internal routing tool to do the heavy-lifting here, currently this is [JLRoutes](https://cocoapods.org/pods/JLRoutes) which we use to map URLs to blocks and dictionaries.

## Difficulties
With Eigen we're trying to map the whole data-set of Artsy into a single app, which likely an architecture post of it's own. However, one of the issues we're having that really strains this metaphor is ambiguity in the routing system. For us this crops up in two places:
- The URL [routing structure](https://github.com/artsy/eigen/pull/534) you're mapping against can change.
- When one route could have [many types](https://github.com/artsy/eigen/blob/2eb00a8050a69ab2e05ffeb11a2bbdcbadf9fb7e/Artsy/App/ARSwitchBoard.m#L156) of data.

Handling routes that changes is something we ended up building an [API for](https://github.com/artsy/echo/blob/master/app/api/v1/presenters/route_presenter.rb). It provides a JSON package of routes and names, and Eigen updates its routing internally.

Having one route represent multiple _potential_ view controllers is tricky. We didn't want to introduce asynchronicity to the `ARSwitchboard`, so we use [polymorphic view controllers](https://github.com/artsy/eigen/blob/2eb00a8050a69ab2e05ffeb11a2bbdcbadf9fb7e/Artsy/View_Controllers/Fair/ARProfileViewController.m#L55-L66). This is a technique where the view controller returned then looks deeper into what it is representing and using child view controllers, embeds the true view controller inside itself.

## Future
Like all patterns, our `ARSwitchboard` pattern is evolving. With Eigen we have  a complicated navigation stack, due to supporting app-wide tabs and hosting navigation controllers inside view controllers. This adds additional logic to pretty complicated code when we're dealing with URLs that could be root elements of a tab. So we are planning to eventually move the presentation aspect of the `ARSwitchboard` into a separate object.

## Alternatives
We didn't need an `ARSwitchboard` in Eidolon. Which, so far always seems to be the exception in these architecture pattern posts. Instead we opted for Apple's [Dependency Injection tool](http://www.objc.io/issues/15-testing/dependency-injection/#which-di-framework-should-i-use), Interface Builder + Storyboards. Energy pre-dates Storyboards, and they didn't feel like a good fit for Eigen.

We found storyboards to be a really good replacement to this pattern when you have an established series of steps in your application with some well defined connections.

As an example, our on-boarding process for Eigen probably should have been storyboarded, as it's a series of view controllers pushed incrementally. However given that the rest of Eigen is essentially a web of interconnected view controllers, we'd be abusing the tool.

## Wrap up
So the Switchboard is a way that we've managed to contain some of the complexity around having web-like abilities to jump between any two view controllers. This pattern makes it easy to stub a switchboard in tests, and to easily test the routing itself.

When I looked through some of the other open source iOS apps to compare the pattern, I couldn't find anything similar. So if you do have something similar, you should probably Open Source your app ;)
