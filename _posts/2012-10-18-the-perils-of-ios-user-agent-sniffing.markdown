---
layout: post
title: "The perils of iOS user agent strings"
date: 2012-10-18 15:19
comments: true
author: brennan
categories: [iOS, JavaScript, User Agent]
comments: true
---

There is a great deal of misinformation on the web about detecting an
iPad or an iPhone in JavaScript. The
[top answer on stackoverflow](http://stackoverflow.com/a/4617648) -
and many [blog posts](http://www.sitepoint.com/identify-apple-iphone-ipod-ipad-visitors/) using [this technique](http://www.askdavetaylor.com/detect_apple_iphone_user_web_site_server.html) - are all incorrect.

The conventional wisdom is that iOS devices have a user agent for
Safari and a user agent for the UIWebView. This assumption is
incorrect as iOS apps can and do
[customize their user agent](http://stackoverflow.com/a/8666438). The
main offender here is Facebook, whose iOS app alone accounts for about
1-3% of Artsy's daily traffic.

Compare these user agent strings from iOS devices:
```
# iOS Safari
iPad: Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3
iPhone: Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3

# UIWebView
iPad: Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/98176
iPhone: Mozilla/5.0 (iPhone; U; CPU iPhone OS 4_1 like Mac OS X; en-us) AppleWebKit/532.9 (KHTML, like Gecko) Mobile/8B117

# Facebook UIWebView
iPad: Mozilla/5.0 (iPad; U; CPU iPhone OS 5_1_1 like Mac OS X; en_US) AppleWebKit (KHTML, like Gecko) Mobile [FBAN/FBForIPhone;FBAV/4.1.1;FBBV/4110.0;FBDV/iPad2,1;FBMD/iPad;FBSN/iPhone OS;FBSV/5.1.1;FBSS/1; FBCR/;FBID/tablet;FBLC/en_US;FBSF/1.0]
iPhone: Mozilla/5.0 (iPhone; U; CPU iPhone OS 5_1_1 like Mac OS X; ru_RU) AppleWebKit (KHTML, like Gecko) Mobile [FBAN/FBForIPhone;FBAV/4.1;FBBV/4100.0;FBDV/iPhone3,1;FBMD/iPhone;FBSN/iPhone OS;FBSV/5.1.1;FBSS/2; tablet;FBLC/en_US]
```

<!-- more -->

The old way to identify iPhone / iPad in JavaScript:
```javascript
IS_IPAD = navigator.userAgent.match(/iPad/i) != null;
IS_IPHONE = navigator.userAgent.match(/iPhone/i) != null) || (navigator.userAgent.match(/iPod/i) != null);
```

If you were to go with this approach for detecting iPhone and iPad,
you would end up with IS_IPHONE *and* IS_IPAD both being true if a user
comes from Facebook on an iPad. That could create some odd behavior!

The correct way to identify iPhone / iPad in JavaScript:
```javascript
IS_IPAD = navigator.userAgent.match(/iPad/i) != null;
IS_IPHONE = (navigator.userAgent.match(/iPhone/i) != null) || (navigator.userAgent.match(/iPod/i) != null);
if (IS_IPAD) {
  IS_IPHONE = false;
}
```

We simply declare `IS_IPHONE` to be `false` on iPads to cover for the
bizarre Facebook UIWebView iPad user agent. This is one example of how
*user agent sniffing is unreliable*. The more iOS apps that customize
their user agent, the more issues user agent sniffing will have. If
you can avoid user agent sniffing (hint: CSS Media Queries), DO
IT.
