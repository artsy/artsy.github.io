---
layout: epic
title: "Why We Run Our Own Blog"
date: "2019-01-20"
author: [orta]
categories: [tooling, dependencies]
comment_id: 524
---

This blog just passed the 7 year mark from our initial ["Hello World"][hw] post. We've always built and hosted our
own blog, initially [using OctoPress][octo] but eventually migrating to just plain old Jekyll. This means our 221
posts are just plain markdown files in a GitHub repo.

Artsy uses 3 separate editorial platforms now, we built our own for Artsy Magazine, use Medium for our [Life at
Artsy blog][laab] and Jekyll for the engineering blog. There was a healthy debate about whether we would migrate to
one, or two systems, but I had pretty strong opinions on migrating the engineering blog to Medium and nipped that
in the bud pretty quickly.

With [Signal vs Noise][svn] being a high profile of a example of migrating to Medium and back again, I thought it's
worth taking the time to examine our reasoning for doing it ourselves.

<!-- more -->

## Dependencies

Almost all parts in the process of creation rely on you depending on others. For this blog, that we rely on
GitHub's static site hosting, RubyGems + Bundler and Jekyll. Luckily for us, there are powerful incentives for
those projects to continue long into the future.

We call the process of making sure you understand and vet your dependencies ["Owning your Dependencies"][oyd], and
in this case we'd be switching from a long-lived and mature set of dependencies to a single startup. This greatly
increases your long-term risks.

Medium is totally incentivized to get your post in front of as many people as possible, and that's awesome.
However, as a business they've not found a way to be profitable, and have taken a lot of [VC cash][cb] which
eventually needs to be paid back. (Artsy has too, so yeah, that's kinda hypocritical, but we're not aiming to
disrupt the writing market we're augmenting the existing Art Industry)

When newspapers like [Forbes][forbes] and [Bloomberg][bloomberg] are worried about their business model, then it
doesn't look good for the longevity of your companies blog.

## #branding

{% include epic_img.html url="/images/hosting-our-own-blog/1.png" title="Screenshots" %}

I consider our blog, and the rest of the site, to be the canonical representation of the Artsy Engineering team
online. We've carefully grown an Artsy Engineering aesthetic around it s.

In contrast, had we choose to host on Medium, we'd get a few templates and a highlight color. For example, check
out: [AirBnB](https://medium.com/airbnb-engineering), [Harrys](https://medium.com/harrys-engineering),
[Pintrest](https://medium.com/@Pinterest_Engineering), [Vimeo](https://medium.com/vimeo-engineering-blog) or
[Lyft](https://eng.lyft.com)'s pages.

Not memorable at all, because you can't really work with the design constraints to do anything creative other than
a banner image.

These constrains become worse on a post page, where you completely lose any sense of connection with the company,
and the team the moment someone scrolls an inch until the footer. Your team's writing becomes just "a medium post"
at that point. You've got limited options for attaching images, and no ability to use HTML/JS to showcase
[problems][rn] [interactively][ar].

These aren't blockers in any way, most of our posts don't do that - but the constraints mean you will never think
to try and explain something outside of that sandbox.

Then at the bottom of your post, readers are redirected to other posts from other teams. For example, I opened a
post on Vimeo's announcement of [Psalm v3][psalm] (a cool looking PHP dev tool), there were three recommended
posts: one was about missiles being fired in Syria, another was a beginners guide to PHP and then a third was how
to set up Docker to work with a PHP framework. They're not that related, maybe they all have the keyword of PHP
behind the scenes?

{% include epic_img.html url="/images/hosting-our-own-blog/3.jpg" title="Artsy as a slideshow" %}

Writing takes a lot of time, and provides so much value. It should be presented as [quality worthy of art][qwoa].
By using to a generic platform for your writing, you're trading that simplicity for building your team's online
presence.

## Breaking the Sandbox

We've grown to need to showcase quite a few different types of posts

- Small posts that with only a few paragraphs
- Long-form posts that take forever to read
- Sequential posts, in the form of a series
- YouTube embed posts
- Announcements
- Guest Posts

None of these need to be treated the same, and since we created the blog, we've added:

- Category pages - [GraphQL][graphql]
- Author pages - [mine][author]
- Site series - [React Native at Artsy][rnaa]
- [4 separate post layouts][layouts]
- Multi-author posts - [Pair Programming][pp]
- [GitHub Issue Powered Comments][ghc]

When we've wanted to add a new feature to the blog to fit a particular post, we added the feature. This gave us the
chance to not constrain ourselves in ideas. For example, we've explored [building a podcast][podcast] into our blog
treating it as a first class feature in ways that no-one would ever build if it was a platform. Or we're interested
in making a way to highlight useful links for the

## Reviews

Because our [blog posts][_posts] are markdown in a GitHub repo, we don't treat a review for a blog post any
different than a normal pull request for code.

## Migrating

Using Medium is a very reasonable call if you are just trying to get some writing out and online as fast as
possible. It's not the only payer in eco-system, Wordpress's company Automattic has been profitable for years and
hosts all sorts of really big blogs, so it's not going anywhere.

However, it's really worth noting how low the barrier to entry it is now to create a blog using a static site
generator:

- [Jekyll][jekyll] - Ruby, the default for GitHub pages and lowest barrier to entry.

```sh
gem install jekyll bundler
jekyll new myblog
cd myblog
bundle exec jekyll serve
```

- [Gatsby][gatsby] - JS, the project we regularly consider moving to. JS folks have such a great focus on developer
  experience.

```sh
npx gatsby new myblog https://github.com/gatsbyjs/gatsby-starter-blog
cd myblog
yarn dev
```

- [Hugo][hugo] - Go, looks pretty reasonable if you have strong opinions against the others

```sh
brew install hugo
hugo new site myblog
cd myblog

git init
git submodule add https://github.com/budparr/gohugo-theme-ananke.git themes/ananke
echo 'theme = "ananke"' >> config.toml

hugo new posts/my-first-post.md
hugo server -D
```

They come with theme support so getting started could probably take about an hour to get a static site up and
running using a host like [GitHub Pages][pages], [Netlify][netlify] or [Now][now]. All three of these you can set
up automatic hosting from GitHub in about 10-15m.

[hw]: /blog/2012/01/05/hello-world/
[ar]: /blog/2018/03/18/ar/
[rn]: /blog/2017/07/06/React-Native-for-iOS-devs/#React
[octo]: /blog/2012/01/18/octopress-and-jekyll/
[laab]: https://www.artsy.net/life-at-artsy
[svn]: https://m.signalvnoise.com/signal-v-noise-exits-medium/
[oyd]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#own-your-dependencies
[pd]: https://github.com/artsy/artsy.github.io/issues/355#issuecomment-315605280
[cb]: https://www.crunchbase.com/organization/medium
[forbes]: https://www.forbes.com/sites/theodorecasey/2017/08/14/why-medium-doesnt-matter-anymore/#1fea7cdf49ad
[bloomberg]: https://www.bloomberg.com/opinion/articles/2017-01-05/why-medium-failed-to-disrupt-the-media
[psalm]: https://medium.com/vimeo-engineering-blog/announcing-psalm-v3-76ec78e312ce
[jekyll]: https://jekyllrb.com
[gatsby]: https://www.gatsbyjs.org
[hugo]: https://gohugo.io
[qwoa]: https://github.com/artsy/README/blob/cb73cb/culture/what-is-artsy.md#quality-worthy-of-art
[graphql]: /blog/categories/graphql/
[author]: /author/orta/
[rnaa]: /series/react-native-at-artsy/
[ghc]: /blog/2017/07/15/Comments-are-on/
[pp]: /blog/2018/10/19/pair-programming/
[layouts]: https://github.com/artsy/artsy.github.io/tree/9f65b5/_layouts
[pages]: https://pages.github.com
[netlify]: https://www.netlify.com
[now]: https://zeit.co/now
[podcast]: https://github.com/artsy/artsy.github.io/issues/355#issuecomment-315605280
[_posts]: https://github.com/artsy/artsy.github.io/tree/9f65b5/_posts
