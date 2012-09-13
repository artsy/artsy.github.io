---
layout: post
title: "On Grid Thumbnails"
date: 2012-09-13 16:40
comments: true
categories: [iOS, Objective C, Speed, Retina]
author: orta therox
github-url: https://www.github.com/orta
twitter-url: http://twitter.com/orta
blog-url: http://orta.github.com
---

<img src="/images/folio-thumbnails/grid.jpg">


Artsy Folio version 1.1 had been in the App Store for a couple of weeks before the iPad with a Retina display was announced, this had been something we expected internally and we felt the application would be ready. We had all our image assets like buttons available in with a _@2x_ version taken and we had an image pipe-lining system that would take scaling into account. With that in mind we changed our artwork grid view to show double resolution image and once we were happy that it worked fine on the simulator we send the build off to Apple for review. 

The app passed review, and we had the app ready for Retina before the hardware release, and we pulled the app within a few minutes of testing it on a real Retina iPad. This post will explain why, and what we did to make it smooth.

<!--more-->

In our simple naivety Folio was originally using `UIImage`'s `initWithContentsOfFile:` to load (without caching) a JPG from the file system into memory where we can then pass it through to the screen via `UIImageView` this was fast enough to deal with our small thumbnails of _240x240_ but the moment that you start asking it to pull 3 or 4 _480x480_ jpg files off the filesystem and decompress them and then put them on the screen, you're not going to have a smooth scroll. Even the extra boost in processor speed wouldn't get you close with the simplest implementation.

<img src="/images/folio-thumbnails/thumbnails.jpg">

The problem of why it was slow initially wasn't obvious, it was only thanks to digging around using [Instruments](http://developer.apple.com/library/mac/#documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/Introduction/Introduction.html) that we saw a whole lot of time was being spent in jpeg decoding that we knew the direction to look in. Though from a users perspective the biggest problem here was that this work was all being done on the main thread.

As we knew that we were looking at an issue with threading and images, this Stack Overflow thread on [UIImage lazy loading](http://stackoverflow.com/questions/1815476/cgimage-uiimage-lazily-loading-on-ui-thread-causes-stutter) proved to be an essential start to dealing with our issue. We needed a threadsafe way to get the contents of a file and to pass them through once the images had been decoded. What we needed was [initImmediateLoadWithContentsOfFile](https://gist.github.com/259357). This function is a threadsafe way to go from a filepath to a UIImage, we made some [minor adjustments](https://gist.github.com/3715588) related to dealing with gray-scale images.

So now had a way to get an image that was safe to go on a background thread, so we opted for giving our grid an `NSOperationQueue` so we can create operations to load the thumbnail, and so we created a method to create an `NSInvocationOperation` with our the cell we're looking at and the address it needs. 

``` objc
- (void)setImageAsyncAtPath:(NSString *)imageAddress forGridCell:(ARImageGridViewCell *)cell {
    NSDictionary *operationOptions = @{@"address": imageAddress, @"cell": cell};
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(asyncLoadImage:) object:operationOptions];
    
    [_operationQueue addOperation:operation];
}
```

When we had the simplest implementation of `asyncLoadImage` we found that scrolling would sometimes result in grid cells getting the wrong image, this was because in the time it took to decode the jpg the cell could already have been reused for a completely other artwork. This one totally caught me off guard! Anyway, this is what we did in order to make sure all our artworks images were actually their images.

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

This meant we could have our UI thread dealing with scrolling, whilst [Grand Central Dispatch](https://developer.apple.com/technologies/mac/core.html) would deal with ensuring the image processing was done as fast and asyncronously as possible. In Folio however this wasn't enough, we were finding if you scrolled fast enough you could still see the images pop in after the grid cell was visible. For this we actually went back to the beginning, we made our image pipeline create a _120x120_ thumbnail for each artwork that we use `initImmediateLoadWithContentsOfFile` to load on the UI thread. This is fast enough to smoothly scroll, and should be replaced by the higher resolution image practically instantly.
  
<img src="/images/folio-thumbnails/hover-thumbnails.jpg">

The rest of the story is pretty obvious, we wrapped all this up within a few days and got out a version of Folio for the Retina iPad and I ended up doing a talk about the issues involved in doing this in [Leeds LSxCafé](http://lsx.co/lsxcafe/), and you got a blog post out of it.