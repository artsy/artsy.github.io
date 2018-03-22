[![Build Status](https://travis-ci.org/artsy/artsy.github.io.svg)](https://travis-ci.org/artsy/artsy.github.io)

The Artsy OSS page and the blog runs on top of a default jekyll install. If you would like an overview of jekyll their [website rocks](http://jekyllrb.com/).

## Setup

```
  git clone git@github.com:artsy/artsy.github.io.git
  cd artsy.github.io
  bundle exec rake bootstrap
  bundle exec rake build
```

## Running the OSS Site / Blog locally

Running `rake serve` will _not_ generate category pages. They take a _long_ time to generate. No one wants that when working on the site.

```
  bundle exec rake serve
```

Categories are generated when the ENV var `PRODUCTION` = `"YES"`.

## Deploying

Travis CI will automatically deploy when new commits are pushed to the `source` branch, so you should not need to deploy from your local computer. However, if you need to deploy locally, the `rake deploy` command is available.

## Adding an Author

Authors are key-value stored, so you will need to give yourself a key inside [_config.yml](_config.yml) - for example:

```yaml
  joey:
    name: Joey Aghion
    github: joeyAghion
    twitter: joeyAghion
    site: http://joey.aghion.com
```

Everything but name is optional.

## Authoring an Article

Note: we now have some templates to help get you started writing a blog post. Check out the [`Post-Templates` directory](Post-Templates).

TLDR
_To generate a new post, create a new file in the `_posts` directory. Be sure to add your name as the author of the post and include several categories to file the post under. Here is a sample header YAML:_

Note: categories are aggregated from the individual posts, so adding one is as
easy as adding it to your post!

```yaml
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

More info can be found in the [Jekyll docs](http://jekyllrb.com/docs/posts/).

When you have authored an article, `git add` and `git commit` it, then push to a named branch with `git push origin [branch]`, and create a pull request to the `source` branch, it will be deployed to the site by travis when merged.

## After Deploying an Article

Every article on our blog needs one more thing: a snappy tweet! You can ask Ash or Orta to do this for you, but you're also welcome to log into the [@ArtsyOpenSource](https://twitter.com/ArtsyOpenSource) twitter account and tweet yourself (credentials are in the Engineering 1Password vault). Tweets usually follow the following format:

```
[pithy observation] [description of problem] [@ the article author's twitter handle]

📝 [link to blog post]
💻 [link to GitHub repo, if applicable]
📷 [attach a screenshot of the first few paragraphs of the post]
```

We attach screenshots of the post because tweets with images get more traction. But! Images aren't accessible to screen readers, so make sure to use the twitter.com web interface and add a description to the image when posting:

> Screenshot of the title and first two paragraphs of the linked-to blog post.

You can look at previous tweets from our account to get a feel for these. If you'd like help, just ask in Slack.
