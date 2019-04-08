---
layout: epic
title: "How did Artsy become OSS by Default?"
date: "2019-04-06"
author: [orta]
categories: [community, oss, culture]
---

One of the defining cultural features of the Artsy Engineering team is that we strive to be Open Source by Default.
This didn't happen over-night and was a multi-year effort from many people to push Artsy's engineering culture to
the point where it was acceptable and living up to the ideals still requires on-going effort today.

I think to understand this, we need to dive into the archives of some of member's older posts to grok their
intentions and ideas. Yes, this is a re-cap episode. Let's go.

<!-- more -->

In 2011 Artsy hired [dB][db] to be our first Head of Engineering, You can get a sense of his frustration in trying
to do Open Source work in his previous companies in this [post from 2010 on opensource.com][osscom].

> Armed with a healthy dose of idealism, I went to executive management and proposed we open source the tool. I was
> hoping for a no-brainer and a quick decision at the division level. To my surprise, it took two years, a vast
> amount of bureaucracy, and far more effort than I ever anticipated.

In contrast today, in the culture he set up for Artsy Engineering - you have a ([tiny!][rfc_priv]) bit more
bureaucracy if you wanted to create a new project which is closed source.

# How did we get there?

## 2012 - Open Communications

For the first year Artsy Engineering, we really didn't ship much Open Source. We were likely just trying to get the
baseline of artsy.net shipped. One important step we took during this first year is in creating this blog, and
publishing 33 ([!][33_posts]) blog posts.

This helped established a foundation of openness, it might not yet be code, but posts are an awesome start.

2012 - blog, no idea

## 2013 - Tools & Libraries

We started getting the time to ship

## 2014 - New Apps

2013 - chairs/ARAnalytics, 2013.artsy.net

2014 - eidolon, 2014.artsy.net

## 2015 - iOS OSS by Default

- https://code.dblock.org/2015/02/09/becoming-open-source-by-default.html
- https://www.objc.io/issues/22-scale/artsy/
- eigen, energy, monoliths,

## 2016 - Web OSS by Default,

## Shared tools

## "Open Source by Default"

### Becoming OSS by Default

https://code.dblock.org/2015/02/09/becoming-open-source-by-default.html

> Team heads, including myself, are making open-source their foundation. This means building non-core intellectual
> property components as open source. That’s easily 2/3 of the code you write and we all want to focus on our core
> competencies. Hence open-source is a better way to develop software, it’s like working for a company of the size
> of Microsoft, without the centralized bureaucracy and true competition.

[ref][leave_ms]

[intro_peril]: /blog/2017/09/04/Introducing-Peril/
[peril_readme]: https://github.com/artsy/README/blob/master/culture/peril.md
[settings-contrib]: https://github.com/artsy/peril-settings/graphs/contributors
[peril]: https://github.com/danger/peril
[db]: https://code.dblock.org
[leave_ms]: https://code.dblock.org/2012/03/05/why-you-should-leave-microsoft-too.html
[osscom]: https://opensource.com/life/10/12/corporate-change-contributing-open-source
[rfc_priv]: https://github.com/artsy/README/issues/131
[33_posts]: /blog/archives/
