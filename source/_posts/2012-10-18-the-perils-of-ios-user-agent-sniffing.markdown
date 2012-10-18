---
layout: post
title: "The perils of iOS user agent strings"
date: 2012-10-18 15:19
comments: true
author: Brennan Moore
github-url: https://www.github.com/zamiang
twitter-url: http://twitter.com/zamiang
categories: [iOS, JavaScript, User Agent]
comments: true
---

There is a great deal of misinformation on the web about detecting an
iPad or an iPhone in JavaScript. The
[top answer on stackoverflow](http://stackoverflow.com/a/4617648) -
and many blogposts using its technique - are all incorrect.

The conventional wisdom is that iOS devices have a user agent for
Safari and a user agent for the uiWebview. This assumption is
incorrect as iOS apps can and do
[customize their user agent](http://stackoverflow.com/a/8666438). The
main offender here is Facebook, who iOS app alone accounts for about
1-3% of Art.sy's daily traffic.

Compare these user agent strings from iOS devices:
```
# iOS Safari
iPad: Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3
iPhone: Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3

# UIWebview
iPad: Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/98176
iPhone: Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Mobile/8B117

# Facebook UIWebview
iPad: Mozilla/5.0 (iPad; U; CPU iPhone OS 5_1_1 like Mac OS X; en_US) AppleWebKit (KHTML, like Gecko) Mobile [FBAN/FBForIPhone;FBAV/4.1.1;FBBV/4110.0;FBDV/iPad2,1;FBMD/iPad;FBSN/iPhone OS;FBSV/5.1.1;FBSS/1; FBCR/;FBID/tablet;FBLC/en_US;FBSF/1.0]
iPhone: Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_1_1 like Mac OS X; ru_RU) AppleWebKit (KHTML, like Gecko) Mobile [FBAN/FBForIPhone;FBAV/4.1;FBBV/4100.0;FBDV/iPhone3,1;FBMD/iPhone;FBSN/iPhone OS;FBSV/5.1.1;FBSS/2; tablet;FBLC/en_US]
``` 

The old way to identify iPhone / iPad in JavaScript
```coffeescript
IS_IPAD = navigator.userAgent.match(/iPad/i)?
IS_IPHONE = navigator.userAgent.match(/iPhone/i)? or navigator.userAgent.match(/iPod/i)?
```

If you were to go with this approach for detecting iPhone and iPad,
you will end up for isiPhone AND isiPad both being true if a user
comes from Facebook on an iPad. That could create some odd behavior!

Given that I have no other examples of people customizing user agents
to such a gross degree, here is some code that will cope with
Facebook's user agent:

The correct way to identify iPhone / iPad in JavaScript
```coffeescript
IS_IPAD = navigator.userAgent.match(/iPad/i)?
IS_IPHONE = navigator.userAgent.match(/iPhone/i)? or navigator.userAgent.match(/iPod/i)?
IS_IPHONE = false if IS_IPAD
```

This is why USER AGENT SNIFFING IS BAD (and unreliable). If there is
any way you can avoid this behavior (hint: css media queries). DO IT.
