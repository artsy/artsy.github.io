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

One important step we took during this first year is in creating this blog, and publishing 33 ([!][33_posts]) blog
posts.

This really helped established a baseline that external communications could be a foundation of openness, it might
not yet be code, but blog posts are an awesome start. I know my first blog durign this time was specifically built
because I had solved a hard problem which I expected others would have done.My answer wasn't generic enough to
warrant making a library but it was big enough to write a [blog post sharing the code][search] and providing
context.

Shipping this many blog posts in our first year of creating a blog is a pretty solid achievement in my opinion, and
the blog has always represented Artsy's Engineering team in one way or another:

> I consider our blog, and the rest of the site, to be the canonical representation of the Artsy Engineering team
> online. We've carefully grown an Artsy Engineering aesthetic around it.

- [Why We Run Our Own Blog][why-run]

Getting people into a space where they feel like contributions to this blog are not _big deals_ but are _iterative
improvements_ was step one towards OSS by Default. That said, we weren't sitting on our hands, in the process of
shipping Artsy to the public we still shipped a bunch of libraries:
[ARAnalytics](https://github.com/orta/ARAnalytics),
[resque-heroku-scaling-canary](https://github.com/aaw/resque-heroku-scaling-canary),
[heroku-forward](https://github.com/dblock/heroku-forward), [Garner](http://github.com/artsy/garner),
[spidey](https://github.com/joeyAghion/spidey), [guard-rack](https://github.com/dblock/guard-rack),
[rspec-rerun](https://github.com/dblock/rspec-rerun),
[hyperloglog-redis](https://github.com/aaw/hyperloglog-redis),
[cartesian-product](https://github.com/aaw/cartesian-product),
[space-saver-redis](https://github.com/aaw/space-saver-redis) &
[mongoid-cached-json](https://github.com/dblock/mongoid-cached-json)

Some of which we still use today.

## 2013 - Tools & Libraries

<!-- a["oss_projects"].select { |o| o["created"].include? "2012" }.map { |o| '[' + o["title"] + '](' + o["repository"] + ')'  }.join(", ") -->

In 2013 we really started to get into the flow of abstracting our problems into libraries

[Musical Chairs](https://github.com/orta/chairs), [Ezel.js](https://github.com/artsy/ezel),
[browserify-dev-middleware](https://github.com/artsy/browserify-dev-middleware),
[backbone-cache-sync](https://github.com/artsy/backbone-cache-sync),
[backbone-super-sync](https://github.com/artsy/backbone-super-sync), [benv](https://github.com/artsy/benv),
[bucket-assets](https://github.com/artsy/bucket-assets), [sharify](https://github.com/artsy/sharify),
[jquery-poplockit](https://github.com/zamiang/jquery.poplockit),
[ORStackView](https://github.com/orta/ORStackView),
[ORSimulatorKeyboardAccessor](https://github.com/orta/ORSimulatorKeyboardAccessor),
[DRBOperationTree](https://github.com/dstnbrkr/DRBOperationTree),
[heroku-commander](https://github.com/dblock/heroku-commander),
[artsy-ruby-client](https://github.com/artsy/artsy-ruby-client),
[gem-licenses](https://github.com/dblock/gem-licenses),
[canonical-emails](https://github.com/dblock/canonical-emails),
[mongoid-tag-collectible](https://github.com/dblock/mongoid-tag-collectible),
[mongoid-shell](https://github.com/dblock/mongoid-shell),
[mongoid-scroll](https://github.com/dblock/mongoid-scroll), [forgetsy](https://github.com/cavvia/forgetsy)

It also represented the first time we explored working entirely in the open. We built small, one-off websites like
[iphone.artsy.net][iphone] ([flare](https://github.com/artsy/flare)) and [2013.artsy.net][2013]
([artsy-2013](https://github.com/artsy/artsy-2013)) -

Explored giving back at scale with CocoaDocs

[CocoaDocs](https://github.com/CocoaPods/cocoadocs.org),

Shipping [flare]() and [artsy-2013](https://github.com/artsy/artsy-2013) as fully-open sourced applications.

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
[search]: /blog/2012/05/11/on-making-it-personal--in-iOS-with-searchbars/
[why-run]: /blog/2019/01/30/why-we-run-our-blog/
[hk_cmd]: /blog/2013/02/01/master-heroku-command-line-with-heroku-commander/
[chairs]: /blog/2013/03/29/musical-chairs/
[ms]: https://github.com/mongoid/mongoid-shell
[garner]: /blog/2013/01/20/improving-performance-of-mongoid-cached-json/
[analytics]: /blog/2013/04/10/aranalytics/
[iphone]: https://iphone.artsy.net
[2013]: https://2013.artsy.net
