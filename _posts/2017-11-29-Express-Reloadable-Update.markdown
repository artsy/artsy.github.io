---
layout: post
title: "Express Reloadable: Optimizing Express.js Development Speed"
date: 2017-12-05 14:18
comments: true
author: chris
categories: [Express, Node, DX, express-reloadable]
---

In [Modernizing Force](artsy.github.io/blog/2017/09/05/Modernizing-Force/) we discussed some of the tools we've been working with to modernize [Artsy.net](https://www.artsy.net/)'s development environment, from introducing Babel and React to the creation of [@artsy/stitch](https://github.com/artsy/stitch). Increasing overall development speed was another aim, and to that end we released [@artsy/express-reloadable](https://github.com/artsy/express-reloadable) which automatically hot-swaps Express.js code without the restart. In this post I'd like to cover some of the issues we've faced since then, and in particular our solution to library code-sharing in Express apps.

<!-- more -->

It's common to share NPM packages across projects, and oftentimes packages are developed in parallel. Package `A` depends on `B`, but `B` has a bug and you don't want to have to republish (and reinstall) the package in order to see changes made locally. `yarn link` (or `npm link`) was developed for instances like this and while it works great for stop and start processes where boot time is quick, it falls short if the development environment takes a while to load. In UI-rich environments like [Positron](https://github.com/artsy/positron) (our Publishing CMS called "Writer") and [Force](https://github.com/artsy/force), each boot would come at a high time-cost due to upfront compilation of assets. Tools like [nodemon](https://github.com/remy/nodemon) would automatically stop and start our server process when assets changed but that still didn't alleviate slow iteration times.

To recap from a [previous post](/blog/2017/09/05/Modernizing-Force#iteration-time), [@artsy/express-reloadable](https://github.com/artsy/express-reloadable) allows devs to immediately see changes to running Express.js app code:

```javascript
import express from 'express'
import { createReloadable, isDevelopment } from '@artsy/express-reloadable'

const app = express()

if (isDevelopment) {
  const mountAndReload = createReloadable(app, require)
  mountAndReload('./api')
}
```

Changes made within the `api` folder are detected and instantly hot-swapped in, and all that's required is a new http request; this is down from an average dev cycle of about 40 seconds for Artsy.net. However, we found an exception while building out Artsy's new [editorial pages](https://www.artsy.net/article/artsy-editorial-midwest-made-artists-mike-kelley-jim-shaw), which involved sharing React components from our UI library [Reaction](https://github.com/artsy/reaction) [between Positron](https://github.com/artsy/positron/blob/master/client/apps/edit/components/content/section_tool/index.jsx#L11) [and Force](https://github.com/artsy/force/blob/master/desktop/apps/article/components/InfiniteScrollArticle.js#L9). Even though we ran `yarn link @artsy/reaction` in each consumer app, changes would not be detected and so we had to do a full restart.

To address this, a new `watchModules` feature [was added](https://github.com/artsy/express-reloadable/pull/3):

```javascript
mountAndReload('./api', {
  watchModules: [
    '@artsy/reaction',
  ]
})
```

Similar to how files in `api/` are hot-swapped in on change, symlinked NPM modules placed in the `watchModules` array will now be reloaded, too.

References:

- [@artsy/express-reloadable](https://github.com/artsy/express-reloadable)
- [Positron](https://github.com/artsy/positron)
- [Reaction](https://github.com/artsy/reaction)
- [Force](https://github.com/artsy/force)
