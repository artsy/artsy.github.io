# Authoring Articles

- [Authoring Articles](#authoring-articles)
  - [1. Adding an Author](#1-adding-an-author)
  - [2. Creating a Post](#2-creating-a-post)
  - [3. Submitting Your Post](#3-submitting-your-post)
  - [4. Enabling Comments](#4-enabling-comments)
  - [5. After Deploying](#5-after-deploying)
  - [6. Generating Related Articles](#6-generating-related-articles)

---

## 1. Adding an Author

Authors are key-value stored in [\_config.yml](../_config.yml). Add yourself with a key:

```yaml
joey:
  name: Joey Aghion
  github: joeyAghion
  twitter: joeyAghion
  site: http://joey.aghion.com
```

Everything but name is optional.

## 2. Creating a Post

Create a new file in the `_posts` directory. Templates are available in the [`Post-Templates`](../Post-Templates) directory.

Include this YAML header:

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

Categories are aggregated from individual posts - adding a new one is as easy as including it in your post.

More info in the [Jekyll docs](http://jekyllrb.com/docs/posts/).

## 3. Submitting Your Post

```bash
git add .
git commit -m "Add blog post: Your Title"
git push origin your-branch
```

Create a PR to the `source` branch. It will be deployed when merged.

After authoring, consider [regenerating related articles](#6-generating-related-articles).

## 4. Enabling Comments
 
 _(optional)_
Comments are managed with [GitHub Issues](https://github.com/artsy/artsy.github.io/issues).

1. [Create an issue](https://github.com/artsy/artsy.github.io/issues/new) - quote the opening paragraph(s) and name it "Comments: My Fantastic New Post"
2. Add the `Comment Thread` label
3. Add `comment_id: <issue-number>` to your post's front matter

## 5. After Deploying

Tweet from [@ArtsyOpenSource](https://twitter.com/ArtsyOpenSource) (credentials in Engineering 1Password vault):

```
[pithy observation] [description of problem] [@ author's twitter]

[link to blog post]
[link to GitHub repo, if applicable]
[attach a screenshot of the first few paragraphs]
```

Add image description for accessibility:

> Screenshot of the title and first two paragraphs of the linked-to blog post.

## 6. Generating Related Articles

_(optional)_

The "related articles" section is generated offline using our staging vector database.

**Prerequisites**

1. Install foreman: `gem install foreman`
2. Copy environment file: `cp .env.example .env`
3. Connect to the staging VPN to access Weaviate (our vector database)

**Generate**

```sh
foreman run bundle exec rake related_articles
```

Commit the resulting changes to `related-articles.json`.
