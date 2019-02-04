---
layout: epic
title: "Why We Run Our Own Blog"
date: "2019-01-30"
author: [orta]
categories: [tooling, dependencies]
comment_id: 524
---

This blog just passed the 7 year mark from our initial ["Hello World"][hw] post. We've always built and hosted our
own blog, initially [using OctoPress][octo] but eventually migrating to just plain old Jekyll.

Artsy uses 3 separate editorial platforms now, we built our own for [Artsy Magazine][mag], use Medium for our [Life
at Artsy blog][laab] and Jekyll for the engineering blog. There was a healthy debate about whether we would migrate
to one, or two systems, but I had pretty strong opinions on migrating the engineering blog to Medium and nipped
that in the bud pretty quickly.

With [Signal vs Noise][svn] being a high profile of a example of migrating to Medium and back again, I thought it's
worth taking the time to examine our reasoning for doing it ourselves.

<!-- more -->

## Dependencies

In programming, the process of creation rely on you depending on others. That ranges from operating systems, to
system dependencies like SQLite or VSCode to app level dependencies from CocoaPods/Node/Whatever. For this blog,
that we rely on GitHub's static site hosting, RubyGems + Bundler and Jekyll. Luckily for us, there are powerful
incentives for those projects to continue long into the future.

That's not even too much of a worry either:

- If GitHub pages stop being a priority, we can switch Netlify or plain S3 in an hour (we already ship to netlify
  for post draft previews)
- If RubyGems or Jekyll goes down, we can switch to another static site builder in another language,

Because the code is some markdown, some HTML and CSS - that's all portable to whatever we want.

We call the process of making sure you understand and vet the full stack your dependencies ["Owning your
Dependencies"][oyd], and in this case we're sitting on a long-lived and mature set of dependencies.

To switch from our mature set of dependencies to a start-up which still hasn't found out how it can make money
greatly increases the long-term risks.

Medium is totally incentivized to get your post in front of as many people as possible, and that's awesome.
However, as a business they've not found a way to be profitable, and have taken a lot of [VC cash][cb] which
eventually needs to be paid back. (Artsy has too, so yeah, that's kinda hypocritical, but we're not aiming to
disrupt & replace the existing "writing online" market we're [augmenting][aug] the existing Art Industry.)

When newspapers like [Forbes][forbes] and [Bloomberg][bloomberg] are worried about the Medium business model, then
it doesn't look great for the longevity of your companies blog. For example, today Medium [removed the developer
API][dev] for your posts. Folks who used Medium to make money have [found themselves surprised][publishers] time
and time again when that changes.

It's important to note here that I think a lot of this churn is reasonable, they are a start-up and that is
literally what start-ups do. Start-ups iterate through business plan ideas until they find one that scales in a way
that they want and that process takes time. It's when that ambiguity about what a company does or doesn't do with
your writing which makes it a dependency which doesn't pay its weight.

## #branding

{% include epic_img.html url="/images/hosting-our-own-blog/1.png" title="Screenshots" %}

I consider our blog, and the rest of the site, to be the canonical representation of the Artsy Engineering team
online. We've carefully grown an Artsy Engineering aesthetic around it.

In contrast, had we chosen to host on Medium, we'd get a few templates and a highlight color. For example, check
out: [AirBnB](https://medium.com/airbnb-engineering), [Harrys](https://medium.com/harrys-engineering),
[Pintrest](https://medium.com/@Pinterest_Engineering), [Vimeo](https://medium.com/vimeo-engineering-blog) or
[Lyft](https://eng.lyft.com)'s pages.

Not memorable at all, because you can't really work with the design constraints to do anything creative other than
a banner image and a color.

These constrains become worse on a post page, where you completely lose any sense of connection with the company,
and the team the moment someone scrolls an inch until the footer. Your team's writing becomes just "a medium post"
at that point. You've got limited options for attaching images, and no ability to use HTML/JS to showcase
[problems][rn] [interactively][ar] or explore [new post styles][int].

These aren't blockers in any way, most of our posts don't do that - but the constraints mean you will never think
to try and explain something outside of those constraints.

Then at the bottom of your post, readers are redirected to other posts from other teams. For example, when I opened
a post on Vimeo's announcement of [Psalm v3][psalm] (a cool looking PHP dev tool), there were three recommended
posts: one was about missiles being fired in Syria, another was a beginners guide to PHP and then a third was how
to set up Docker to work with a PHP framework. They're not that related, maybe they all have the keyword of PHP
behind the scenes?

{% include epic_img.html url="/images/hosting-our-own-blog/3.jpg" title="Artsy x React Native" %}

Writing takes a lot of time, and provides so much value. It should be presented as [quality worthy of art][qwoa].
By using to a generic platform for your writing, you're trading that simplicity for building your team's online
presence.

## Breaking the Sandbox

We've grown to need to showcase quite a few different types of posts:

- Small posts that with only a few paragraphs
- Long-form posts that take forever to read
- Long-form interview style posts for many contributors
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
- Real-time [search][search] on our static pages

When we've wanted to add a new feature to the blog to fit a particular post, we added the feature. This gave us the
chance to not constrain ourselves in ideas. For example, we've explored [building a podcast][podcast] into our blog
treating it as a first class feature in ways that no-one would ever build if it was a platform. Or we're interested
in making a way to highlight useful links for the

All of those features were made by people whose background was iOS development, which gave us the chance to expand
the horizons of our engineers knowledge.

## Blog as Code

Because our [blog posts][_posts] are markdown in a [GitHub repo][ghr], we don't treat a review for a blog post any
different than a normal pull request for code. It means our [company Peril rules][peril] will run, and all of
engineering has the ability to contribute to the review process.

Having a static site in a GitHub repo means we don't have to special case our writing in comparison to every-day
work.

## Call to Action

Using Medium is a very reasonable call if you are just trying to get some writing out and online as fast as
possible. If you want to be scrappy and announce something - do it. If you want to do something more serious
though, you should really consider owning your engineering blog and identity. Giving that away to Medium in
exchange for hosting your content and getting more eyeballs isn't a great trade.

There aren't many shortcuts for getting folks to visit your blog, and relying on Mediums' recommendations or SEO
isn't a good path compared to say Twitter adverts or just writing interesting stuff and letting folks know via a
mailing list.

If self-hosting is an issue, Medium is not the only payer in eco-system, [Wordpress][wp]'s company
[Automattic][autom] has been profitable for years and hosts all sorts of really big blogs. It's not going anywhere,
and you have the ability to customize it to your style and use a whole massive marketplace of plugins (free and
paid for) - it's a really great choice.

However, it's really worth noting how low the barrier to entry it is now to create a blog using a static site
generator:

- [Jekyll][jekyll] - Ruby, the default for GitHub pages and lowest barrier to entry.

```sh
gem install jekyll bundler
jekyll new myblog
cd myblog
bundle exec jekyll serve
```

- [Gatsby][gatsby] - JS, the project we regularly consider moving our blog to. JS folks have such a great focus on
  developer experience, and the abstraction of having an in-direction layer for your content via an internal
  GraphQL API for your static site is a very, very smart abstraction which will take them a long way.

```sh
npx gatsby new myblog https://github.com/gatsbyjs/gatsby-starter-blog
cd myblog
yarn dev
```

- [Hugo][hugo] - Go, looks pretty reasonable if you have strong opinions against the others somehow

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

All of these come with some sort of theme or templating support so getting started could probably take about an
hour to get a static site up and running using a host like [GitHub Pages][pages], [Netlify][netlify] or [Now][now].
All three of these you can set up automatic hosting from GitHub in about 10-15m.

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
[wp]: https://wordpress.com
[autom]: https://automattic.com
[ghr]: https://github.com/artsy/artsy.github.io
[mag]: https://www.artsy.net/articles
[aug]: https://www.theverge.com/2017/7/18/15983712/artsy-fine-art-galleries-online-auction-sales
[dev]: https://write.as/blog/ending-our-medium-integration
[search]: https://github.com/artsy/artsy.github.io/pull/332
[peril]: https://github.com/artsy/README/blob/master/culture/peril.md
[int]: http://artsy.github.io/blog/2019/01/23/artsy-engineering-hiring/

<!-- prettier-ignore-start -->
[publishers]:  http://www.niemanlab.org/2018/05/medium-abruptly-cancels-the-membership-programs-of-its-21-remaining-publisher-partners/
<!-- prettier-ignore-end -->
