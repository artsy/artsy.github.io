---
layout: post
title: "Aspect-Oriented Programming and ARAnalytics"
date: 2014-08-04 14:52
comments: true
categories: [iOS, Analytics, ARAnalytics]
author: ash
---

Analytics are common in iOS applications. They help inform our decisions
about products. Since analytics are so common, Artsy developed a library called
[ARAnalytics](https://github.com/orta/ARAnalytics). This library provides a
single interface to many different backend analytics providers, freeing
developers from having to write code for each of the providers that they're
using.

Let's consider a typical view controller on iOS. View controllers on iOS
represent the glue code between models and views. When a model changes, the view
controller updates the appearance of the UI. Similarly, when the UI is
interacted with by the user, the view controller updates the model. This is the
core of any standard iOS application.

So let's say that a button is pressed. We'll handle that interaction in a
method called `buttonWasPressed:`. We'll want to update our model, but also to
track the analytics event.

``` objc
- (void)buttonWasPressed:(id)sender
{
	self.model.hearted = YES;

	[ARAnalytics event:@"hearted"];
}
```

Simple enough, but consider that the analytics tracking code doesn't fall within
our definition of a view controller – the button handler just happens to be a
convenient place to put the tracking code. Also consider that *every single*
button handler is going to have to have similar code implemented.

## There has to be a better way.

<!-- more -->

[Pete Steinberger](http://twitter.com/steipete) and [Orta Therox](http://twitter.com/orta)
were talking and the topic of [Aspect-Oriented Programming](http://en.wikipedia.org/wiki/Aspect-oriented_programming),
specifically in the context of analytics. AOP takes a look at the different
*conerns* of an application – logical, cohesive units of functionality. While
most programming paradigms, including those used with Objective-C, group and
encapsulate these concerns, there are some concerns that are "cross-cutting"
because they are involved through several other concerns.

Analytics is such a cross-cutting concern. That makes it a prime target for
being abstracted away using AOP. Using [another blog post](http://albertodebortoli.github.io/blog/2014/03/25/an-aspect-oriented-approach-programming-to-ios-analytics/)  as an example, we set about [integrating an AOP-like DSL within ARAnalytics](https://github.com/orta/ARAnalytics/pull/74)
that would allow you to define all of your analytics in one spot.

The interface would be simple. When providing your API keys to the various
backend services you'd like to use with ARAnalytics, you'd also provide a
dictionary specifying the classes you'd like us to "hook into". Whenever a
selector from an instance of the given class was invoked, we'd execute the
analytics event specified in the dictionary.

Since Objective-C has a dynamic runtime, we could have swizzled the instance
methods on the classes you specified in the dictionary. This gets a little
tricky and represents a lot of work for us. We could directly swizzle the
instance methods on the classes in question, but wrapping parameters of variable
types and in various numbers becomes a chore. If we didn't get it done
perfectly, we'd risk introducing bugs into the entire application.

I wrote a proof-of-concept of analytics using AOP with [ReactiveCocoa](http://reactivecocoa.io).
It worked, but was a little hacky since it involved the swizzling of `alloc`.
ReactiveCocoa is also a large framework to be included just for the sake of
analytics. Additionally, its interface exposed ReactiveCocoa's `RACTuple` class,
which smells like a leaky abstraction.

## What could we do?

Well, about the same time, Pete Steinberger open sourced a new framework just
for AOP called [Aspects](https://github.com/steipete/Aspects). Pete did all the
difficult work of swizzling methods with variable parameter lists, including
wrapping primitive parameters in values.

Pete and I worked together to get Aspects working with ARAnalytics, removing our
dependency on ReactiveCocoa.

## How to Use it

Using ARAnalytics with the new DSL is super-easy. Just add either `ARAnalytics`
or `ARAnalytics/DSL` to your podfile, specifying a version of at least 2.6. Run
`pod install` and you're ready to get started.

Since all of your analytics are going to be specified in one spot, and that spot
is going to get rather large, I'd recommend creating an Objective-C category on
your app delegate to set up all of your analytics. Then you can call this
`setupAnalytics` method when your app launches.

``` objc

#import "ARAppDelegate.h"

@interface ARAppDelegate (Analytics)

- (void)setupAnalytics;

@end

```

``` objc


#import <ARAnalytics/DSL.h>

@implementation ARAppDelegate (Analytics)

- (void)setupAnalytics
{
	[ARAnalytics setupWithAnalytics:@{
		/* keys */
    } configuration:
    @{
    	ARAnalyticsTrackedEvents: @[
    		@{
    			ARAnalyticsClass: MyViewController.class,
    			ARAnalyticsDetails: @[
    				@{
    					ARAnalyticsEventName: @"hearted",
    					ARAnalyticsSelectorName: NSStringFromSelector(@selector(buttonWasPressed:)),
    				}
    			]
    		}
    	]
	}];
}

@end

```

Now our `buttonWasPressed:` method is *very* straightforward:

``` objc
- (void)buttonWasPressed:(id)sender
{
	self.model.hearted = YES;
}
```

The view controller is now *only* responsible for what it should be responsible
for: mediating interactions between the view and the model. Awesome! Even
cooler, we can provide fine-grain control over which analytics events are
invoked and with what properties they are sent with. Let's take a look.

``` objc
[ARAnalytics setupWithAnalytics:@{
	/* keys */
} configuration:
@{
	ARAnalyticsTrackedEvents: @[
		@{
			ARAnalyticsClass: MyViewController.class,
			ARAnalyticsDetails: @[
				@{
					ARAnalyticsEventName: @"hearted",
					ARAnalyticsSelectorName: NSStringFromSelector(@selector(buttonWasPressed:)),
					ARAnalyticsEventProperties: ^NSDictionary *(MyViewController *controller, NSArray *parameters) {
                        UIButton *button = parameters.firstObject;
                        NSString *buttonTitle = [button titleForState:UIControlStateNormal];
                        return @{
                            @"view_title" : controller.title ?: @"",
                            @"button_title" : buttonTitle ?: @"",
                        };
                    },
					ARAnalyticsShouldFire: ^BOOL(MyViewController *controller, NSArray *parameters) {
						return /* selective disable firing of analytics */;
					}
				}
			]
		}
	]
}];

@end

```

So you see that even though you're defining your analytics once, at application
startup, you're still able to provide dynamic, per-instance behaviour and event
properties.

Finally, we've also written support for page views. In a few lines, you can
have every view controller track its page view with ARAnalytics.

``` objc
[ARAnalytics setupWithAnalytics:@{
	/* keys */
} configuration:
@{
	ARAnalyticsTrackedScreens: @[
		@{
			ARAnalyticsClass: UIViewController.class,
			ARAnalyticsDetails: @[ // default selector on iOS is viewDidAppear:
				@{
					ARAnalyticsPageNameKeyPath: @"title"
				}
			]
		}
	]
}];

@end

```

This code will track a page view with the title the same as the view
controller's `title` property, but just like with events you can provide
fine-grained handling.

## Some Limitations

There is a [limitation](https://github.com/steipete/Aspects/issues/11) on
Aspects that wasn't fully understood until we used the new AOP approach to
analytics in the Artsy app. Selectors can only be "hooked into" once per class
hierarchy. That  means that you cannot create a tracked events for two
difference view controllers, both on the `viewWillAppear:` selector. This is a
temporary limitation while the Aspects library is being worked on. In the mean
time, you are free to use the [original implementation](https://github.com/orta/ARAnalytics/tree/ashfurrow-temporary-dsl-fix)
with ReactiveCocoa, which doesn't have this limitation and which we are using
currently.

## What we Learnt

AOP is a really cool paradigm that can reduce tight coupling in your code and
increase your overall level of cohesion. Its applications extend beyond just
analytics – any time you have a behaviour that's being exhibited in several
abstractions in your code, you should consider if using AOP to replace that
behaviour might make for cleaner code and more cohesive abstractions.

Finally, I got to make my first significant contribution to open source at
Artsy. It was awesome to be able to collaborate with Pete and Orta on this
project, as well as receive feedback from developers who are already using
ARAnalytics.
