---
layout: post
title: "Testing Core Data Migrations"
date: 2014-06-11 10:50
comments: false
sharing: false
categories: [Testing, Objc, Cocoa, iOS]
author: orta
---

The first time I released a patch release for [Artsy Folio](http://orta.github.io/#folio-header-unit) it crashed instantly, on every install. Turns out I didn't understand Core Data migrations, now a few years on I grok it better but I've still lived with the memories of that dark dark day. Because of this I've had an informal rule of testing migrations with all the old build of Folio [using chairs](http://artsy.github.io/blog/2013/03/29/musical-chairs/) the day before submitting to the app store.

This time round, I've made vast changes to the Core Data models but skipped the manual work. Here's how:

<!-- more -->

Context: Folio is a big Core Data app, that now has hundreds of [tests](https://speakerdeck.com/orta/getting-eigen-out?slide=40) that I've added in the past 6 month, tests that cover everything from [the views](https://speakerdeck.com/orta/getting-eigen-out?slide=40) to simple model checks. It was originally built with a CoreDataManager singleton that contains a reference to a per-thread main managed object context. As I started to apply tests to the app I needed to start creating in-memory managed object contexts for [dependency injection](http://www.bignerdranch.com/blog/dependency-injection-ios/). Making my class (roughly) end up like this:

```objc
@interface CoreDataManager : NSObject
+ (NSManagedObjectContext *)mainManagedObjectContext;
+ (NSManagedObjectContext *)stubbedManagedObjectContext;
@end

```

With a simplified implementation of:

```objc

static BOOL ARRunningUnitTests = NO;
static NSManagedObjectModel *managedObjectModel = nil;
static NSManagedObjectContext *mainManagedObjectContext = nil;

@implementation CoreDataManager

+ (void)initialize
{
    if (self == [CoreDataManager class]) {
        NSString *XCInjectBundle = [[[NSProcessInfo processInfo] environment] objectForKey:@"XCInjectBundle"];
        ARRunningUnitTests = [XCInjectBundle hasSuffix:@".xctest"];
    }
}

+ (NSManagedObjectModel *)managedObjectModel
{
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ArtsyPartner" withExtension:@"momd"];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) return persistentStoreCoordinator;

    NSURL *storeURL = [NSURL fileURLWithPath:[ARFileUtils coreDataStorePath]];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES)};

    NSError *error = nil;
    NSManagedObjectModel *model = [CoreDataManager managedObjectModel];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
    return persistentStoreCoordinator;
}

+ (NSManagedObjectContext *)mainManagedObjectContext
{
    if (ARRunningUnitTests) {
        @throw [NSException exceptionWithName:@"ARCoreDataError" reason:@"Nope - you should be using a stubbed context somewhere." userInfo:nil];
    }

    if (mainManagedObjectContext == nil) {
        mainManagedObjectContext = [self newManagedObjectContext];
    }
    return mainManagedObjectContext;
}


+ (NSManagedObjectContext *)newManagedObjectContext
{
    NSManagedObjectContext *context = nil;
    NSURL *storeURL = [NSURL fileURLWithPath:[ARFileUtils coreDataStorePath]];
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES) };

    NSError *error = nil;
    NSManagedObjectModel *model = [CoreDataManager managedObjectModel];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    return context;
}

+ (NSManagedObjectContext *)stubbedManagedObjectContext
{
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption: @(YES), NSInferMappingModelAutomaticallyOption: @(YES) };

    NSError *error = nil;
    NSManagedObjectModel *model = [CoreDataManager managedObjectModel];

    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error];

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = persistentStoreCoordinator;
    return context;
}

@end
```

This meant it was very easy to quickly make tests that look like:


```objc
    it(@"shows sync info when there are no CMS albums", ^{
        NSManagedObjectContext *context = [CoreDataManager stubbedManagedObjectContext];

        ARAddAlbumThatIsEditableInContext(YES, context);
        ARAddAlbumThatIsEditableInContext(NO, context);

        ARAddToAlbumViewController *controller = [[ARAddToAlbumViewController alloc] initWithManagedObjectContext:context];
        controller.view.frame = (CGRect){ CGPointZero, [controller preferredContentSize]};
        expect(controller.view).to.haveValidSnapshot();
    });

```

This made it very cheap conceptually to make a new in-memory context and to be sure that the changes wouldn't affect the development data store. However, once I had this framework in place it became a pretty simple jump to taking the existing sqlite files that I already had around in my [chairs folder](http://artsy.github.io/blog/2013/03/29/musical-chairs/) and make to force a migration from that build to the latest managed object model. Here's the test suite in full:

```objc
//
//  ARAppDataMigrations.m
//  Artsy Folio
//
//  Created by Orta on 12/05/2014.
//  Copyright (c) 2014 http://artsy.net. All rights reserved.
//

NSManagedObjectContext *ARContextWithVersionString(NSString *string);

SpecBegin(ARAppDataMigrations)

__block NSManagedObjectContext *context;

it(@"migrates from 1.3", ^{
    expect(^{
        context = ARContextWithVersionString(@"1.3");
    }).toNot.raise(nil);
    expect(context).to.beTruthy();
    expect([Artwork countInContext:context error:nil]).to.beGreaterThan(0);
});

it(@"migrates from  1.3.5", ^{
    expect(^{
        context = ARContextWithVersionString(@"1.3.5");
    }).toNot.raise(nil);
    expect(context).to.beTruthy();
    expect([Artwork countInContext:context error:nil]).to.beGreaterThan(0);
});

it(@"migrates from  1.4", ^{
    expect(^{
        context = ARContextWithVersionString(@"1.4");
    }).toNot.raise(nil);
    expect(context).to.beTruthy();
    expect([Artwork countInContext:context error:nil]).to.beGreaterThan(0);
});

it(@"migrates from  1.6", ^{
    expect(^{
        context = ARContextWithVersionString(@"1.4");
    }).toNot.raise(nil);
    expect(context).to.beTruthy();
    expect([Artwork countInContext:context error:nil]).to.beGreaterThan(0);
});

SpecEnd

NSManagedObjectContext *ARContextWithVersionString(NSString *string) {

    // Allow it to migrate
    NSDictionary *options = @{
        NSMigratePersistentStoresAutomaticallyOption: @YES,
        NSInferMappingModelAutomaticallyOption: @YES
    };

    // Open up the the _current_ managed object model
    NSError *error = nil;
    NSManagedObjectModel *model = [CoreDataManager managedObjectModel];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    // Get an older Core Data file from fixtures
    NSString *storeName = [NSString stringWithFormat:@"ArtsyPartner_%@", string];
    NSURL *storeURL = [[NSBundle bundleForClass:ARAppDataMigrationsSpec.class] URLForResource:storeName withExtension:@"sqlite"];

    // Set the persistent store to be the fixture data
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Error creating persistant store: %@", error.localizedDescription);
        @throw @"Bad store";
        return nil;
    }

    // Create a stubbed context, check give it the old data, and it will update itself
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = persistentStoreCoordinator;
    return context;
}

```

Nothing too surprising, but I think this is important that these tests are the slowest tests in the app, at a whopping 0.191 seconds. I'm very willing to trade a fraction of a second on every test run to know that I'm not breaking app migrations.
