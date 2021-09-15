---
layout: post
title: "How To Write Unit Tests Like a Brood Parasite"
date: 2015-07-06 13:54
comments: true
author: sarahscott
article-class: "expanded-code"
categories: [iOS, ocmock, open source, oss, mobile, beginners, testing]
---

To a beginner, [OCMock](http://ocmock.org/) looks scary. The syntax is strange, the idea of stubbing seems complicated, and skirting around the need to use it at all times kind of works out for a while.

```objc
[[[mock stub] // three brackets!!

[OCMockObject niceMockForClass:UINavigationItem.class]; // it has to be told to be nice?
```

All of this can be overwhelming for someone who just wants to write simple unit tests for a particular view controller.

Once you look into the specifics of OCMock, however, things get less terrifying really quickly. It is helpful to compare OCMock’s approach to stubbing to the [behaviors of certain bird species](https://vimeo.com/60553870). As always, the soothing voice of David Attenborough brings clarity and joy to even the most mundane puzzles of life’s journey.


<!-- more -->

----------------

For those who hate birds and videos of them, the cuckoo duck is known for leaving its eggs in the nests of other birds precisely as their unsuspecting victims lay their own. The new host parents cannot differentiate their offspring from those of the duck and inadvertently raise the duck chicks to maturity.

In a similar fashion, OCMock can place trick objects in your ~~nest~~ test code with whichever custom configuration suits your needs. The ‘host’ subject under test can’t differentiate these mock objects from the objects they’ve been written to use, and you can decide exactly how you’d like the mock objects to behave in your testing environment. This was especially helpful for a method I created that relies on information from an asynchronous network request. We’ll call it the ```DataSource``` of a ```StatusMonitor``` class.

```objc
- (BOOL)updatedStatus
{
 	[DataSource getNewDataWithNetworkRequest];
	/// some code that relies on this new data
}
```
In my view controller, I can use a ```StatusMonitor``` to decide whether or not a notification should appear in my view:

```objc
- (void)viewWillAppear
{
 	[super viewWillAppear];

/// show or hide a notification based on this status
	BOOL shouldShowNotification = [self.statusMonitor updatedStatus];
}
```

When I’m writing tests for this view controller, I don’t care about ```DataSource``` - I just want to make sure the view controller knows when to show or hide a notification correctly depending on the new value from its StatusMonitor. I’d really like to avoid making any network requests within these kinds of tests. This is where the bird strategy comes in.

In my tests, I can create a decoy ```StatusMonitor``` with its corresponding methods using OCMock.

```objc
StatusMonitor *statusMonitor = [[ARCMSStatusMonitor alloc] init];
id mockMonitor = [OCMockObject partialMockForObject:statusMonitor];

[[[mockMonitor stub] andReturn:@YES] checkStatus];
```

----------------

I can then assign mockMonitor to the ```statusMonitor``` property of my view controller under test. In this way, the dependency on a network connection disappears, my view controller is happy, and my test can isolate the functionality I care about. OCMock provides some excellent documentation of what they mean by ‘nice’ and some other interesting things you can do with mock objects [here](http://ocmock.org/features/). For those interested in David Attenborough, birds, or natural history in general, I recommend  [Nature](http://www.bbc.co.uk/nature/collections/p0048522).

<div style="text-align:center;">
<img src = "/images/2015-07-06-how-to-write-unit-tests-like-a-brood-parasite/attenborough.gif">
</div>
