---
layout: post
title: "So you want to do a CSS3 3D transform?"
comments: true
author: brennan
categories: [CSS3, JavaScript]
comments: true
---

This post details the first of many challenges we faced in 3D
transforming the [homepage of Artsy](http://artsy.net) (inspired by
[Meny](https://github.com/hakimel/meny)): detecting CSS 3D transform
support.

Front-end development is messy in today's fragmented world. At Artsy,
our goal is to do what it takes to provide an incredible experience
for *all* of our users (IE8+, iOS and the usual suspects). Deploying
bleeding edge tech, like CSS 3D transforms, is an exercise in
compromising principals for practicality -- and managing these
"compromises" in well-documented code.

We looked to [Modernizr's](http://modernizr.com/) feature detection approach to provide us with
a reliable way to detect CSS3 3D transform support across browsers. They have some
[well](https://github.com/Modernizr/Modernizr/issues/590)-
[documented](https://github.com/Modernizr/Modernizr/issues/465)
[struggles](https://github.com/Modernizr/Modernizr/issues/240) around
the issue. After flipping most of the tables in the office ┻━┻ ︵ヽ
(`Д´)ﾉ︵﻿ ┻━┻ , we settled on user agent sniffing as the most robust
method for detecting CSS3 3D transform support. But why did none
of the available methods work for us?

<!-- more -->

CSS3 3D transforms involve interaction between the browser and the
graphics card. The browser may be able to parse the 3D declarations
but may not be able to properly instruct the graphics card in how to
render your page. There are many possible outcomes ranging from the
page rendering with lines across it (Safari 4) to the page rendering
beautifully then crashing the browser seconds later (Safari on
iOS4). Any 'feature detection' approach would unacceptably flag these
as 'supports CSS3 3D transforms'. This is one case where 'feature
detection' fails and user agent sniffing (and lots of testing) wins
hands down.

Most feature detection assumes a "supports" or "does not support"
binary. This is not the case with CSS3 3D transforms -- there is a
"gradient of support". Additionally, enabling 3D transforms causes the
page to be re-rendered in an entirely different rendering engine which
then causes other problems (more on this in a later post).

CSS3 3D transform support can be separated into 4 levels:

1. Reliably supports 3D transforms across most machines. For example:
Safari 6.
2. Can parse and apply 3D transform declarations but ignores the 3D
parts. For example: Chrome on a Retina MacBook Pro.
3. Can parse and apply 3D transform declarations but renders in
unacceptable ways. For example: Safari 4 and Safari 4/5 on Windows
show lines across the page.
4. Cannot apply 3D transform declarations in any way. For example:
IE or Firefox < v10.

Here are a few popular ways of detecting CSS3 3D transform support and why
they don't work for us:

*Meny / Hakim's method*

```coffeescript
# apply these styles to the body in css then see if they are applied in JS
docStyle = document.body.style
supports3DTransforms =  'WebkitPerspective' in docStyle or
                        'MozPerspective' in docStyle or
                        'msPerspective' in docStyle or
                        'OPerspective' in docStyle or
                        'perspective' in docStyle
```
This works best and is straightforward code. The only
issue is that it throws a positive for iOS4 causing the browser to
crash and a positive for Safari on Windows and Safari 4 OSX which both
display a grid over the page when using the 3D renderer.

*iScroll4 method*

```coffeescript
has3D = -> 'WebKitCSSMatrix' in window && 'm11' in new WebKitCSSMatrix()
```
This only works reliably Safari in our testing.

*Modernizer method*

```coffeescript
ret = !!testPropsAll('perspective')
if ( ret and 'webkitPerspective' in docElement.style )
  # create a dib and see if it moves
  injectElementWithStyles('@media (transform-3D), (-webkit-transform-3D){#modernizr{left:9px;position:absolute;height:3px;}}', (node, rule) ->
    ret = node.offsetLeft === 9 && node.offsetHeight === 3;
```

This creates a div, transforms it, and then checks if it's position
has changed as expected. It only works in reliably in Safari.
It [sometimes works in Chrome](https://github.com/Modernizr/Modernizr/issues/590)
but throws a false positive in the case of Chrome on Retina MacBook
Pro as the element does move -- just not in 3D space.

*User Agent method*

We want to maintain wide support of new tech while ensuring all users
have a great experience. Modernizr and the feature detection group
have their heart in the right place and do a great job most of the
time. That said, user agent sniffing is the only way to handle the
complex support scenarios inherent in bleeding edge CSS3 tech such as
3D transforms.

Here is our method/hack for identifying browsers that support CSS3 3D
transforms well:

```coffeescript
(->
  docElement = document.documentElement
  uagent = navigator.userAgent.toLowerCase()

  browsers = [
    ['webkit',  530]        # not well supported in Safari 4, Safari 5 webkit version is 530.17
    ['chrome',  12]
    ['mozilla', 10]
    ['opera',   Infinity]   # not supported
    ['msie',    Infinity] ] # not supported

  # From: http://api.jquery.com/jQuery.browser
  uaMatch = (ua) ->
    match =
      /(chrome)[ \/]([\w.]+)/.exec(ua) or
      /(webkit)[ \/]([\w.]+)/.exec(ua) or
      /(opera)(?:.*version|)[ \/]([\w.]+)/.exec(ua) or
      /(msie) ([\w.]+)/.exec(ua) or
      ua.indexOf("compatible") < 0 and /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) or
      []
    { browser: (match[ 1 ] or ""), version: (match[2]?.split('.')[0] or 0) }

  addNo3DTransform = ->
    docElement.className = docElement.className.replace 'csstransforms3D', ''
    docElement.className += ' no-csstransforms3D'

  add3DTransform = ->
    docElement.className = docElement.className.replace 'no-csstransforms3D', ''
    docElement.className += ' csstransforms3D'

  # default to no CSS3 3D transform support
  addNo3DTransform()

  match = uaMatch uagent
  for browser in browsers
    if browser[0] == match.browser
      if match.version >= browser[1]
        add3DTransform()
      else
        addNo3DTransform()
      break

  IS_IPHONE = uagent.search('iphone') > -1 or uagent.search('ipod') > -1
  IS_IPAD = uagent.search('ipad') > -1
  IS_IOS = IS_IPHONE or IS_IPAD

  # iOS 6 is our support cut off for iPad
  match = /\os ([0-9]+)/.exec uagent
  IS_LT_IOS6 = match and match[1] and Number(match[1]) < 6

  # 3D transforms are supported but do not work well on iPhone
  if IS_IPHONE
    addNo3DTransform()

  # disable 3D transform for older versions of Safari on iPad
  else if IS_IPAD and IS_LT_IOS6
    addNo3DTransform()

  # deactivate 3D transform for Safari on Windows
  else if navigator.userAgent.search('Safari') > -1 and navigator.userAgent.search('Windows') > -1
    addNo3DTransform()
)()
```

If you would like to take issue with or improve this code please check
it out [on Github](https://github.com/zamiang/detect-css3-3D-transform).
