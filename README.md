[![Build Status](https://travis-ci.org/artsy/artsy.github.io.svg)](https://travis-ci.org/artsy/artsy.github.io)

The Artsy OSS page and the blog run on top of a default jekyll install. If you'd like an overview of jekyll their [website rocks](http://jekyllrb.com/).

## Setup

```
  git clone git@github.com:artsy/artsy.github.io.git
  cd artsy.github.io
  rake bootstrap
  rake build
```

## Running the OSS Site / Blog locally

Running `rake serve` will _not_ generate category pages. They take a _long_ time to generate. No one wants that when working on the site.

```
  rake serve
```

Categories are generated when the ENV var `PRODUCTION` = `"YES"`.

## Deploying

Travis CI will automatically deploy when new commits are pushed to the `source` branch, so you shouldn't need to deploy from your local computer. However, if you need to deploy locally, the `rake deploy` command is available. 

## Authoring an Article

TLDR
_To generate a new post, create a new file in the `_posts` directory. Be sure to add your name as the author of the post and include a couple of categories to file the post under. Here's some sample header YAML:_

```
---
layout: post
title: "Responsive Layouts with CSS3"
date: 2012-01-17 11:03
comments: true
author: Matt McNierney
github-url: https://www.github.com/mmcnierney14
twitter-url: http://twitter.com/mmcnierney
blog-url: http://mattmcnierney.wordpress.com
categories: [Design, CSS, HTML5]
---
```

More info can be found in the [official docs](http://jekyllrb.com/docs/posts/).

When you have authored an article, `git add` and `git commit` it, then push to the source branch with `git push origin source`. To publish the post, you need to deploy the blog.
