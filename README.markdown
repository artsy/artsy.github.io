The dev blog is at [http://artsy.github.com](http://artsy.github.com) and is powered by [Octopress](http://octopress.org/).

Setup
-----

The blog is two branches in https://github.com/artsy/artsy.github.com - *master* for the live site and *source* for the contents of the blog. You first check out the source and then create a *_deploy* subfolder that points to the master branch. The rest is taken care by Octopress Rake tasks.

```
$ git clone git@github.com:artsy/artsy.github.com.git
$ cd artsy.github.com
artsy.github.com$ git checkout source
artsy.github.com$ mkdir _deploy
artsy.github.com$ cd _deploy
artsy.github.com/_deploy$ git init
artsy.github.com/_deploy$ git remote add origin git@github.com:artsy/artsy.github.com.git
artsy.github.com/_deploy$ git pull origin master
artsy.github.com/_deploy$ cd ..
artsy.github.com$
```

One Liner of above
--------------
```
git clone git@github.com:artsy/artsy.github.com.git;cd artsy.github.com;git checkout source;mkdir _deploy;cd _deploy;git init;git remote add origin git@github.com:artsy/artsy.github.com.git;git pull origin master;cd ..
```

See it Locally
--------------
```
artsy.github.com$ rake generate
artsy.github.com$ rake preview
```

Authoring an Article
--------------------

See [blogging basics](http://octopress.org/docs/blogging/).

To generate a new post, run `rake new_post["Title of Post"]`. This will generate a markdown file in `source/_posts`. Be sure to add your name as the author of the post and include a couple of categories to file the post under. Here's some sample header YAML:

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

When you have authored an article, `git add` and `git commit` it, then push to the source branch with `git push origin source`. To publish the post, you need to deploy the blog.

Deploy
------
```
artsy.github.com$ rake generate
artsy.github.com$ rake deploy
```
