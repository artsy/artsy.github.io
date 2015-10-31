---
layout: post
title: On Our Objective-C Code Standards
date: 2012-08-14 14:23
comments: true
categories: [iOS, Objective C, Standards]
author: orta
---

With the release of Xcode 4.4 I've taken a look back at our existing code standards and tried to come up with something that is cleaner and more elegant. Here are a few of the ideas I've been using to modernize the codebase.

### Remove private method declarations and use class extensions to add ivars.

First to get chopped by the deletion button are private method declarations. After Xcode 4.2 came out we took to using the class extension feature to add private method declarations at the top of implementation files. This was a nice way of keeping private methods out of the header files. Now that the compiler will check for pre-existing method signatures within the same object there's no need to define their interfaces.

<!--more-->

Occasionally it's necessary for subclass to know about private methods defined by its superclass, so we use a shared category to let them know what they respond to. Like Apple, we also quit using `@private` in header files.

Ivars now should go in class extensions, and be prefixed by an underscore. Apple advises that you don't use method names with underscores but encourage underscored variable names. This also can free up method parameters from having ugly names such as anArtwork or aString.

### Use object literals when possible.

Object literals are ways of adding syntacitcal sugar to the Objective-C language, they let you access keys and values easily on `NSDictionary`s and objects in `NSArray`s. There's no reason to not be using them if you're supporting iOS 4 and above. It's simple a matter of `_artworks[2]` vs `[_artworks objectAtIndex:2]`.

### Dot syntax is OK for non-properties.

OK so, I admit it. I whined when properties came out. It was back in 2007 and the Objective-C was ranked 40th in the world, it's now ranked [3nd most popular programming language.](http://www.tiobe.com/index.php/paperinfo/tpci/Objective-C.html) Within timeframe, my opinion on the subject of properties changed also.

Originally when properties came out they exclusively were given the right to use dot notation on objects. This makes sense as they were created to provide public access to ivars which normally you can only access internally using the dot notation. With Xcode 4.3, that also changed. Now, if a method doesn't have any arguments it can be called using dot notation. I'm in favour of using this. For me a good rule of thumb has been if a method returns something, dot notation is OK. For example, `_artworksArray.count` is fine whilst `_parsingOperation.stop` isn't.

### Keep external code out of your project.

External, or vendored code should be kept out of the main body of your code. You can use CocoaPods to keep all that code in check and up-to-date. CocoaPods is a project that aims to be what bundler does for ruby projects, or npm for node. It will deal with your dependancies whilst you can concentrate on your own code. It will create a seperate Xcode project that handles all you dependancies leaving your project only as your own code.

### Use umbrella imports.

To try and keep the amount of noise we have at the top of our implementation files we have started to reduce the number of `#import "ARModel.h"` lines we use. By creating a `Models.h` file and having that include all the models it means we can still have a look through the `#imports` at the top to get an idea of the connections between the objects as that will only show the important imports. These can optionally be moved into your precompiled header files.

### Keep your code clean.

Whitespace can and does slowly accumulate at the line-endings of your code. You should make sure that the new preference for automatically trimming whitespace is turned on in the text editing section of Xcode's preferences.

### IBOutlets should probably go in your class extensions.

With modern versions of Xcode, it doesn't matter that your IBOutlets are defined in places other than in headers. As Objective-C developers, we've come a long way from having to repeatedly drag a .h from Xcode to Interface Builder, so maybe it's time to rethink the idea that our interface outlets should be publicly accessible. My opinion is that a controller's views are for the most part a private affair and that if you want to expose their functionality you do it through custom methods in the controller. There are some downsides to this, in that  initially you have to change to the implementation file when using hybrid view when connecting them.   

These decisions have come from internal discussions and from watching many WWDC sessions on the topic. We highly recommend watching the following [WWDC sessions](https://developer.apple.com/wwdc/).

  [WWDC 2011](https://developer.apple.com/videos/wwdc/2011/): 105 Polishing Your App, 112 Writing Easy To Change Code and 322 - Objective-C Advancements in Depth.


  [WWDC 2012](https://developer.apple.com/videos/wwdc/2012/): 405 Modern Objective-C and 413 Migrating to Modern Objective-C
