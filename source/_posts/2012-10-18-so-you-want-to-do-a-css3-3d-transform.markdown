---
layout: post
title: "So you want to do a CSS3 3d transform?"
comments: true
author: Brennan Moore
github-url: https://www.github.com/zamiang
twitter-url: http://twitter.com/zamiang
categories: [CSS3, JavaScript]
comments: true
---

This post details the first of many challenges we faced in 3d
Transforming the homepage of Art.sy (inspired by
(Meny)[https://github.com/hakimel/meny]): Detecting CSS 3d transform
support

Front-end development is messy in today's fragmented world. At Art.sy,
our goal is to do what it takes to provide an incredible experience
for ALL of our users (IE8+, iOS and the usual suspects). Deploying
bleeding edge tech, like CSS 3d transforms, is an exercise in
compromising principals for practicality -- and managing these
'compromises' in well documented code.

We looked to Modernizr to provide us with a reliable way to detect
CSS3 3D transforms. They have some well documented struggles and a
plethora of github tickets around the issue. After flipping most of
the tables in the office ┻━┻ ︵ヽ(`Д´)ﾉ︵﻿ ┻━┻ , we settled on
useragent sniffing as the most robust method for detecting 3d
transform support. Sad times. But why did none of the available
methods work for us?

CSS3 3D transforms involve interaction between the browser and the
graphics card. The browser may be able to parse the 3D declarations
but may not be able to properly instruct the graphics card in how to
render your page. There are many possible outcomes from rendering with
the graphics card. The page may render with lines across it or the
page may render but then crash the browser after a couple seconds. Any
'feature detection' approach would flag these as 'supports CSS3 3d
transforms' but that is not acceptable. This is one case where
'feature detection' fails and user agent sniffing (and lots of
testing) wins.

Most feature detection assumes a 'supports' or 'does not support'
binary. This is not the case with css 3d transforms - there is a
'gradient of support'. Additionally, enabling 3d transforms causes the
page to be re-rendered in an entirely different rendering engine which
causes other problems (more on this in a later blogpost).

CSS 3D transform support can be separated into 4 levels:
- reliably supports 3d transforms across most machines
  For example: Safari 6 & Firefox 16+
- can parse and apply 3d transform declarations but ignores the 3d parts
  For example: Chrome on retina Macbook pros (more on this later)
- can parse and apply 3d transform declarations but renders in unacceptable ways
  For example: Safari 4 and Safari 4/5 on Windows show lines across the page. iOS4 Safari renders but crashs Safari shortly after.
- cannot apply css 3d transform declarations in any way (IE, Opera, Firefox < 10…)

Here are a few popular ways of detecting 3d transform support and why they don't work for us:
```coffeescript
# meny's method
supports3DTransforms =  'WebkitPerspective' in document.body.style ||
   						'MozPerspective' in document.body.style ||
						'msPerspective' in document.body.style ||
						'OPerspective' in document.body.style ||
						'perspective' in document.body.style
```

This works the best and is really straight forward. It will crash
Safari on iOS4 and shows lines across the page in old versions of
Safari on Windows and OSX but otherwise is great.


```coffeescript
# Based on iScroll4's tests to determine if a browser supports CSS3 3D transforms.
has3d = -> 'WebKitCSSMatrix' in window && 'm11' in new WebKitCSSMatrix()
```
Only works reliably Safari and is rumored to sometimes not work in Chrome on some Version / OS combinations http://code.google.com/p/chromium/issues/detail?id=129004

# Modernizer method - create a div and transform it then see if it's position has changed as expected. This only works in Chrome and Safari but throws a false 'true' in the case of Chrome on Retina macbook pros.
```coffeescript
ret = !!testPropsAll('perspective')
if ( ret and 'webkitPerspective' in docElement.style )
    # create a dib and see if it moves
    injectElementWithStyles('@media (transform-3d), (-webkit-transform-3d){#modernizr{left:9px;position:absolute;height:3px;}}', (node, rule) ->
            ret = node.offsetLeft === 9 && node.offsetHeight === 3;
```



Fuck it. Here is the code:
```coffeescript
(->
  # detect 3d transforms. This loads before jQuery or underscore so we cannot use their util methods
  # currently, sept 30 12, there is no reliable way to detect css3dtransforms so we use useragent sniffing
  # for example, prior solition succeeds for chrome 22 but fails for chrome 22 on retina display

  docElement = document.documentElement

  # defined as array of arrays to avoid defining object.keys
  browsers = [
    ['webkit',  530]    # not well supported in Safari 4, Safari 5 webkit version is 530.17
    ['chrome',  12]
    ['mozilla', 10]
    ['opera',   Infinity]   # not supported
    ['msie',    Infinity] ] # not supported

  # More details: http://api.jquery.com/jQuery.browser
  uaMatch = (ua) ->
    ua = ua.toLowerCase()
    match =
      /(chrome)[ \/]([\w.]+)/.exec(ua) or
      /(webkit)[ \/]([\w.]+)/.exec(ua) or
      /(opera)(?:.*version|)[ \/]([\w.]+)/.exec(ua) or 
      /(msie) ([\w.]+)/.exec(ua) or
      ua.indexOf("compatible") < 0 and /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) or
      []

    { browser: (match[ 1 ] or ""), version: (match[2]?.split('.')[0] or 0) }

  addNo3dTransform = ->
    docElement.className = docElement.className.replace 'csstransforms3d', ''
    docElement.className += ' no-csstransforms3d'

  add3dTransform = ->
    docElement.className = docElement.className.replace 'no-csstransforms3d', ''
    docElement.className += ' csstransforms3d'

  # default to no 3d transform support
  addNo3dTransform()

  match = uaMatch navigator.userAgent
  for browser in browsers
    if browser[0] == match.browser
      if match.version >= browser[1]
        add3dTransform()
      else
        addNo3dTransform()
      break

  # 3d transfors are supported but do not work well on iPhone
  if IS_IPHONE
    addNo3dTransform()

  # disable 3d transform for older versions of Safari on iPad
  else if IS_IPAD and IS_LT_IOS6
    addNo3dTransform()

  # deactivate 3d transform for Safari on Windows
  else if navigator.userAgent.search('Safari') > -1 and navigator.userAgent.search('Windows') > -1
    addNo3dTransform()
)()
```

Later posts will go into:
- Coping with flickering when enabling and disabling 3d transforms in Safari
- iPad useragent(s)
- Perspective transforming long pages
