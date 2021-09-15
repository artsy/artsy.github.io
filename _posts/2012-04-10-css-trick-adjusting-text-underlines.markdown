---
layout: post
title: "CSS Trick: Adjusting Text Underlines"
date: 2012-04-10 16:32
comments: true
author: craig
categories: [Design, CSS]
---

Often times people will use _border-bottom: 1px solid_ in favor of _text-decoration: underline_ to give their links some breathing room. But what if you're giving it _too_ much breathing room and want to adjust the height of that underline. With Adobe Garamond that happened to be the case, so we've come up with this little css trick:

``` css
a {
  display: inline-block;
  position: relative;
}
a::after {
  content: '';
  position: absolute;
  left: 0;
  display: inline-block;
  height: 1em;
  width: 100%;
  border-bottom: 1px solid;
  margin-top: 5px;
}
```

This overlays a CSS pseudo element with a border-bottom that can be adjusted by changing margin-top.

For handling browsers that don't support pseudo elements I recommend targeting them with the [Paul Irish class-on-html-trick](http://paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/).

Let your links breathe!
