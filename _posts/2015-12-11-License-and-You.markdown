---
layout: post
title: 'Licenses for OSS Code'
date: 2015-12-10T00:00:00.000Z
comments: false
categories: [ios, mobile, licensing, video, oss]
author: orta
series: Open Source by Default
---

As a part of our internal Lunch and Learn series, I  gave a talk to our developers with an overview of the different types of source code licenses available.

We always recommend MIT within Artsy, but understanding what the other ones are and [why we made](http://artsy.github.io/blog/2012/01/29/how-art-dot-sy-uses-github-to-build-art-dot-sy/) the choices we have done is valuable.

Jump [to YouTube](https://www.youtube.com/watch?v=0r7JcN3Q_LY) for the video, or click more for a smaller inline preview, as well as all of the speakers notes.

<!-- more -->

{% youtube 0r7JcN3Q_LY %}

### Licenses For Code

Attn:*I am not a lawyer*, but I have to care about this from an app dev perspective, and a dependency manager perspective.

Recommendation for further reading:

* http://choosealicense.com
* https://tldrlegal.com/

We'll talk about 3 types of licenses:

- Permissive: MIT/BSD, used by jQuery, Rails, Artsy OSS
- Mostly Permissive: Apache/Mozzila, used by SVN, Firefox
- Copyleft: GPL, used by Git, Linux, Wordpress

### Common Components

All share one important thing:

  * YOU MAY USE THIS
  * NO WARRANTY
  * DISCLAIMER OF LIABILITY

Which is basically the crux of how we can all actually use and write OSS without ending up bankrupt. E.g. when a major component of your infrastructure "fails" - it's not the fault of the author. Example: [Shellshock](https://en.wikipedia.org/wiki/Shellshock_(software_bug)) - no-one tried suing the maintainers of Bash.

### License Free

By choosing to not include a license, you only applying your copyright to the code. All code is the copyright of someone, because creation of anything is covered by copyright. Copyright is, err, complex. Roughly speaking though, there is no contract between you and someone using your code. This means _all_ of the power is in favour of the library author. A library consumer would need to email the author and ask for permission on a case by case basis, even then there is nothing stopping a developer revoking the ability for you to use their library after the fact. It's also different depending on the country the library author is in. However in the end the default copyright is not a license, so add one.


[This is basically the default license for code. ](http://blog.codinghorror.com/pick-a-license-any-license/)

This means that code on a blog could not be safe to use unless they've declared its license, whereas for something like stack overflow all of the contents there are licensed under the Creative Commons. Which I'll talk about later.

Just uploading some code to GitHub actually does put it under a license of sort, which includes the ability for someone to fork and view the code. It's explicit in the GitHub T&C, they could not have those features without it. Other than that though, you offer no contract with the library user.

### OSI

So when we say Open Source license, we are talking about licenses that come from the Open Source Initiative. They are a pragmatic group who say whether a license should be classed as 'open source' or not. A bit weird, but they generally just debate a lot of the legal stuff in these licenses and try to find holes so that everyone is protected. It's basically a seal of approval. There are very few licenses that are not OSI approved, the one you might know is the WTFPL - which is basically default copyright anyway.

On the mobile team we requested that dependencies of ours convert from WTFPL so that we don’t have the issue mention about the public domain, we as Artsy have little protection against the library authors future wishes.

### Permissive

What you think of as open source is the modern day permissive license.

These are the least restrictive, and are considered "business friendly." They apply very little rules between author and library consumer.

People use permissive licenses because conceptually they allow the most programmer freedom to use, change and improve a library.

They also protect the author, in the sense that a consumer cannot claim that the author created the product the consumer made. They protect the author from liability.

#### The one thing

For example someone could take your library, and rename it, then apply a different license. Not breaking any rules, unless they ignore attribution.

This happened this year with [WinObjC](https://github.com/Microsoft/WinObjC)
Microsoft's version of Objective-C, which also aimed for API compatibility with Apple's developer frameworks. They built it up with a lot of other source code, but didn't provide attribution.

https://github.com/Microsoft/WinObjC/issues/35
https://news.ycombinator.com/item?id=10024377

> The ONE SINGLE requirement of the Cocotron MIT license is that the license text, including copyright holders, remains in the source. THAT'S IT, can you please manage to do that.


### Patently Permissive

Moving up in terms WRT strength of the contract, there is the permissive+patent libraries. These allow library authors to have patents on the software. This can make it more business friendly, depending on the business goals. The most common are Apache and the Mozilla Public License.

### Viral

The GPL, and it's crew. Roughly speaking, they say that if you want to include any GPL'd code in your projects, you need to make your entire project GPL. There is an important distinction in the GPL in that version 2, and version 3 differ in important ways. The one that I think is most important is that GPL 3 allows sub-licensing. This means that you can say "I can give Artsy a license for this code under BSD terms", allowing for some flexibility in how you apply the license.

It's considered viral because if you have any GPL code anywhere, then everything becomes GPL.  Rule of thumb is to avoid this license, however I'd like to offer a reason why Artsy might ship GPL code.

On the OSS iOS side, we release all of our apps as MIT. I could be quite worried about people shipping copies of our applications. For example there could be fake versions of the Artsy app on the App Store, or competitors could use it to bootstrap. If I was very, very worried I would ship it as GPL 3 with an MIT sublicense to Artsy. This means that anyone who ships a copy of our app to the app store without our express permission for a sublicense that allows DRM.

Generally though we don’t need to do this because we have the ability to revoke an app’s access to the API, meaning it cannot talk to Artsy, and our apps are pretty useless at that point.

### Creative Commons

So, the Creative Commons is a license on content like videos, images and corpuses of text. They are not OSI approved, and [actively recommend](https://wiki.creativecommons.org/wiki/Frequently_Asked_Questions#Can_I_use_a_Creative_Commons_license_for_software.3F) that people use an OSI license for code. This is because software licenses have more to care about: distribution, compilation  and working with other license / patents. Things that you don't have to deal with WRT other types of content.

All CC-licensed code requires attribution of [some sort](http://blog.stackoverflow.com/2009/06/attribution-required/).

In CocoaPods all the design assets are released under CC, but all the code is BSD.

## Twitter Q & A

### Can I re-license after the fact?

So, have you wondered why sometimes you have to sign a CLA ( contributors license agreement ) to work on a repo? Relicensing is one of these things. Let's take 3 examples.

* *VLC* - Wanted to put an app on the app store, VLC was GPL. As each contributor owned their contributions if one single party who had contributed to the codebase didn't agree with putting an app on the store then they couldn't ship. It took an extra year and a half to get VLC re-licensed to get on the store.

* *Swift* - New language by Apple, they _specifically_ ensure that people keep the rights to their contributions. This means Apple are not special. They cannot decide to suddenly switch license if Google decide it to be the new language for Android. There is no self destruct button.

* *Solaris* - When Sun got bought by Oracle a bunch of projects got canned, one of the ways that they were able to do this and to nuke the code was because they owned all the copyrights to every contribution made to the codebases owned by Sun. They closed the source for the entire OS. It was totally within their rights.

[Sources](https://news.ycombinator.com/item?id=10669891), [History of Solaris](https://www.youtube.com/watch?v=-zRN7XLCRhc)

###  Do I need to include a copyright banner on every file?

No, it's possible that if it's likely that specific files will be used outside of the project ( e.g. your code is not totally atomic ) then it's valuable to note the license multiple times. However as long as a license is shipped with the code then you're good, if that license states something to the effect of “this software and associated documentation files (the "Software")”.
