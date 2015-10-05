---
layout: post
title: "Octopress and Jekyll"
date: 2012-01-18 23:03
comments: true
categories: [Blog, Open-Source]
author: db
---
This blog is powered by static pages.

I think it's quite ironic that, while we spend a lot of time building complex large scale dynamic websites, our new favorite publishing platform is a system that compiles static content. But, in many ways, [Octopress](http://octopress.org/) and [Jekyll](https://github.com/mojombo/jekyll) fit our philosophy and developer workflow perfectly. Writing an article for this blog means using the same tools and processes as contributing to a project on Github. And everyone is welcome to browse and learn from [the source](https://github.com/artsy/artsy.github.com/tree/source) of this blog, and even fork it and contribute fixes to the layout or even blog features.

Here's what Artsy engineers do to get setup (once) and publish a new post.

``` bash
    $ git clone git@github.com:artsy/artsy.github.com.git
     Cloning into artsy.github.com...

    $ cd artsy.github.com

    artsy.github.com$ git checkout source
     Branch source set up to track remote branch source from origin.
     Switched to a new branch 'source'

    artsy.github.com$ mkdir _deploy

    artsy.github.com$ cd _deploy

    artsy.github.com/_deploy$ git init
     Initialized empty Git repository in artsy.github.com/_deploy/.git/

    artsy.github.com/_deploy$ git remote add origin git@github.com:artsy/artsy.github.com.git

    artsy.github.com/_deploy$ git pull origin master
     From github.com:artsy/artsy.github.com
      * branch            master     -> FETCH_HEAD

    artsy.github.com/_deploy$ cd ..

    artsy.github.com$ rake create_post["Octopress and Jekyll"]
     Creating new post: source/_posts/2012-01-18-octopress-and-jekyll.md

    artsy.github.com$ git commit -am "Octopress and Jekyll"
     1 files changed, 52 insertions(+), 0 deletions(-)
     create mode 100644 source/_posts/2012-01-18-octopress-and-jekyll.md

    artsy.github.com$ rake deploy
```

(If you're confused by the setup, check out [this post](http://code.dblock.org/octopress-setting-up-a-blog-and-contributing-to-an-existing-one)).

We believe in simple systems and love the opportunity to understand technology in-depth. Everything you see, short of the blog content and styles, is written in Ruby by very smart people. The source is open and free, which helps us learn and make progress, together.
