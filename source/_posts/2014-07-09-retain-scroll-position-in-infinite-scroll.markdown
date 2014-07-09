---
layout: post
title: "Retain scroll position in infinite scroll"
date: 2014-07-09 17:29
comments: true
categories: 
---

<!---
References:
https://news.ycombinator.com/item?id=7314965
http://www.slideshare.net/danmckinley/design-for-continuous-experimentation
http://blog.codinghorror.com/the-end-of-pagination/
http://eviltrout.com/2013/02/16/infinite-scrolling-that-works.html

XKCD image

Contentious problem that has caused people to abandon infinite scroll

Introduce scroll-frame

GIF in action

We use it in all of our filtering UIs

Main use case of click item to detail page > click back button confused users.

Looking toward sites like pinterest a clever little solution became clear: What if the next page opened up in a modal.
-->

![XKCD Infinite Scroll Comic](https://camo.githubusercontent.com/4b7e6aefa00b96ba2804b235aaaa811bbb893c4e/687474703a2f2f7777772e6578706c61696e786b63642e636f6d2f77696b692f696d616765732f352f35362f696e66696e6974655f7363726f6c6c696e672e706e67)

Infinite scroll can be a contentious topic. Just look at [this hacker news thread](https://news.ycombinator.com/item?id=7314965) full of comments lamenting the usability of infinite scroll. At Artsy we've found it to be a useful interface in many portions of our site such as our filtering UIs.