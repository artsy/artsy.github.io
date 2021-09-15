---
layout: post
title: "Retain scroll position in infinite scroll"
date: 2014-07-09 17:29
comments: true
categories: [Infinite, Infinite Scroll, Iframe, Modal, Scroll Position, Retain Scroll Position, force]
author: craig
---

![Maybe we should give up on the whole idea of a 'back' button. 'Show me that thing I was looking at a moment ago' might just be too complicated an idea for the modern web.](https://camo.githubusercontent.com/4b7e6aefa00b96ba2804b235aaaa811bbb893c4e/687474703a2f2f7777772e6578706c61696e786b63642e636f6d2f77696b692f696d616765732f352f35362f696e66696e6974655f7363726f6c6c696e672e706e67)

Although [some find infinite scroll to be a contentious topic](https://news.ycombinator.com/item?id=7314965) at Artsy we've found it to be a useful element in many portions of our site such as [filtering](https://artsy.net/browse/artworks?medium=prints&price_range=-1%3A1000). However, we've run into a common and painful usability issue with infinite scroll. That is clicking on an item redirects to the next page, losing your scroll position, and losing your place when going back. To solve this we have come up with a clever little solution using an iframe.

<!-- more -->

We're pleased to announce we've open sourced this solution into [scrollFrame](https://github.com/artsy/scroll-frame).

scrollFrame borrows from sites like Pinterest that avoid this problem by opening the next page in a [modal window](http://en.wikipedia.org/wiki/Modal_window). Only instead of having to build your entire page client-side, scrollFrame will intercept your click and open the next page in an iframe that sits on top of your current page and covers your viewport (acting as a sort of modal that doesn't look like a modal). scrollFrame will then hook into the [HTML5 history API](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history) to remove the iframe modal on back button and keep your URL up to date. [See it in action on our browse page!](https://artsy.net/browse)

scrollFrame only solves this specific problem with infinite scroll but we've gotten a lot of mileage out of it and we hope you will too!
