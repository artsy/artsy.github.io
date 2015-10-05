---
layout: post
title: "On Grid Thumbnails"
date: 2012-09-13 16:40
comments: true
categories: [iOS, Objective C, Speed, Retina]
author: orta
---

<img src="/images/2012-09-13-on-grid-thumbnails/grid.jpg">

Artsy Folio, our free iPad app for Gallery Partners, had been in the App Store for a couple of weeks before the iPad with a Retina display was announced. This had been something we expected internally and felt the application would be ready. We had all our image assets available in _@2x_ versions and an image pipeline that would take scaling into account. With that in mind, we changed our artwork grid view to show a double resolution image. Finally, once we were happy that it worked fine on the simulator, we sent the build off to Apple for review.

The app passed review, and was Retina-ready before the actual release. But within hours of getting our hands on a real Retina iPad, we had to pull the app. This post will explain why, and what we did to work it out.

<!--more-->

Scrolling the grid view was slow. Extremely slow. The reason why wasn't obvious initially, but thanks to digging around using [Instruments](http://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Introduction/Introduction.html), we saw that a great deal of time was spent in Apple's image processing libraries. This was a strong hint that the problem involved taking the file and getting it to the screen.

In our naiveté, Folio was originally using `UIImage`'s `initWithContentsOfFile:` to load (without caching) a jpg from the file system. Once the file was loaded into memory, we displayed it onscreen in an `UIImageView.` This was fast enough to deal with our small thumbnails of _240x240_ but the moment that you start asking it to pull 3 or 4 _480x480_ jpg files off the filesystem, decompress them and then put them on the screen, you're not going to have a smooth scroll.

<img src="/images/2012-09-13-on-grid-thumbnails/thumbnails.jpg">

As we knew that we were looking at an issue with getting images from a file, it made sense to start looking at ways to move image processing off the main thread. This Stack Overflow thread on [UIImage lazy loading](http://stackoverflow.com/questions/1815476/cgimage-uiimage-lazily-loading-on-ui-thread-causes-stutter) proved to be an essential start to dealing with our issue. We needed a thread-safe way to get the contents of a file and to pass them through once the images had been decoded. What we needed was [initImmediateLoadWithContentsOfFile](https://gist.github.com/3715588), a thread-safe way to go from a filepath to a `UIImage`.

Now that we had a way to get an image that was safe to go on a background thread, we gave our grid an `NSOperationQueue` and created a method to kick off a `NSInvocationOperation` with our the cell we're looking at and the address it needs to load the thumbnail.

``` objc
- (void)setImageAsyncAtPath:(NSString *)imageAddress forGridCell:(ARImageGridViewCell *)cell {
    NSDictionary *operationOptions = @{@"address": imageAddress, @"cell": cell};
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(asyncLoadImage:) object:operationOptions];

    [_operationQueue addOperation:operation];
}
```

When we had the simplest implementation of `asyncLoadImage` we found that scrolling would sometimes result in grid cells displaying the wrong image. It turned out that in the time it took to decode the jpg,  the cell had already been reused for a different artwork. This one totally caught us off guard!

``` objc
- (void)asyncLoadImage:(NSDictionary *)options {
    @autoreleasepool {
        NSString *address = options[@"address"];
        ARImageGridViewCell *cell = options[@"cell"];

        // don't load if it's on a different cell
        if ([cell.imagePath isEqualToString:address]) {
            UIImage *thumbnail = [[UIImage alloc] initImmediateLoadWithContentsOfFile:address];

            // double check that during the decoding the cell's not been re-used
            if ([cell.imagePath isEqualToString:address] && thumbnail) {
                [cell performSelectorOnMainThread:@selector(setImage:) withObject:thumbnail waitUntilDone:NO];
            }
        }
    }
}
```

This meant we could have our UI thread dealing with scrolling, whilst [Grand Central Dispatch](https://developer.apple.com/technologies/mac/core.html) would deal with ensuring the image processing was done asynchronously and as fast as possible.However, this still wasn't enough. We were finding if you scrolled fast enough, you could still see images pop in after the grid cell was visible. For this, we actually went back to the beginning, and made our image pipeline create a _120x120_ thumbnail for each artwork that we use `initImmediateLoadWithContentsOfFile` to load on the UI thread. This is fast enough to smoothly scroll, and is replaced by the higher resolution image practically instantly.

<img src="/images/2012-09-13-on-grid-thumbnails/hover-thumbnails.jpg">

The rest of the story is pretty straightforward. We wrapped all this up within a few days and got out a version of Folio for the Retina iPad, I ended up doing a talk about the issues involved in doing this in [Leeds LSxCafé](http://lsx.co/lsxcafe/), and you got a blog post out of it.
