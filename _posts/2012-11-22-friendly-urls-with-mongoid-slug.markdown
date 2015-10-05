---
layout: post
title: Friendly URLs with Mongoid::Slug
date: 2012-11-22 21:21
comments: true
categories: [Ruby,MongoDB,Mongoid,User Experience]
author: db
---
All Artsy URLs shared publicly are humanly readable. For example, you'll find all Barbara Kruger's works at [artsy.net/artist/barbara-kruger](https://artsy.net/artist/barbara-kruger) and a post by Hyperallergic entitled "Superfluous Men Can't Get No Satisfaction" at artsy.net/hyperallergic/post/superfluous-men-cant-get-no-satisfaction. This is a lot prettier than having `id=42` in the browser's address and is a big improvement for SEO.

<img src="/images/2012-11-22-friendly-urls-with-mongoid-slug/barbara-kruger.png">

We construct these URLs with a gem called [mongoid_slug](https://github.com/digitalplaywright/mongoid-slug). Interesting implementation details under the cut.

<!-- more -->

Mongoid-Slug Basics
-------------------

Include the gem in Gemfile.

``` ruby Gemfile
gem "mongoid_slug", "~> 2.0.1"
```

The basic functionality of mongoid-slug is achieved by adding the `Mongoid::Slug` a mixin and declaring a slug.

``` ruby post.rb
class Post
  include Mongoid::Document
  include Mongoid::Slug

  belongs_to :author, class_name: "User"

  field :title, type: String
  slug :title, history: true, scope: :author

  field :published, type: Boolean
end
```

This adds a `_slugs` field of type `Array` into the `Post` model. Every time the title of the post changes, a new slug is generated and, depending on the value of the `history` option, either replaces the existing slug or appends the new slug to the array of slugs. A database index ensures that these are unique: two posts of the same title will have different slugs, such as "post-1" and "post-2". Our example is also scoped to the author of the post.

You can now find this post by `_id` or `slug` with the same `find` method. And with `history: true`, you can find a document by any of its older slugs!

```
# find by ID
user.posts.find("47cc67093475061e3d95369d")

# find by slug
user.posts.find("superfluous-men-cant-get-no-satisfaction")
```

Mongoid-slug is smart enough to figure out whether you're querying by a `Moped::BSON::ObjectId` or a slug. Performance-wise the lookup by slug is cheap: mongoid_slug ensures an index on `_slugs`. This all works, of course, because MongoDB builds a B-tree index atop all elements in each `_slugs` array.

The `find` method will naturally respect Mongoid's `raise_not_found_error` option and either raise `Mongoid::Errors::DocumentNotFound` or return `nil` in the case the document cannot be found.

Avoiding Too Many Slugs
-----------------------

Users writing posts may want to edit them many times before they are published. This can potentially create a large number of unnecessary slugs. We've used a simple trick to generate slugs only after a post has been published by defaulting the slug of an unpublished post to its `_id`. Mongoid-slug will append `-1` to such slugs, so we monkey-patch `Mongoid::Slug::UniqueSlug` with the code in [this gist](https://gist.github.com/4131766). Special care must be taken not to destroy a slug of a post that has been published earlier, then unpublished.

``` ruby
slug :title, :published, scope: :author, history: true do |p|
  if p.published? || p.has_slug?
    p.title.to_url
  else
    p.id.to_s
  end
end

def has_slug?
  ! slug.blank? && slug != id.to_s
end
```

The parameters to `slug` include all fields that may cause the slug to change. When a post is published by setting `published` to `true`, the slug will be re-generated with a call to `build_slug` as long as the `published` field is included in that list.

Please note an interesting discussion about allowing model ids in the `_slugs` [here](https://github.com/digitalplaywright/mongoid-slug/pull/91).

Caching by Slug
---------------

Because slugs can now change, but lookups by old slugs should hit the cache, caching by slug makes cache invalidation difficult. A two-layered cache that maps slugs to ids and then caches objects by id can solve this at the expense of an additional cache lookup. We have yet to implement this in [Garner](https://github.com/artsy/garner), see [#13](https://github.com/artsy/garner/issues/13).

International Slugs
-------------------

We have a large international audience with names and posts in all kinds of languages. An escaped UTF-8 URL would be much worse than a BSON ObjectId. Fortunately, mongoid-slug uses [stringex](https://github.com/rsl/stringex) under the hood. This gem defines `to_url` and rewrites special symbols and transliterates strings from many languages into English. Here're some examples of generated slugs.

``` ruby
"ITCZ 1 (21°17ʼ51.78”N / 89°35ʼ28.18”O / 26-04-08 / 09:00 am)".to_url
# => itcz-1-21-degrees-17-51-dot-78-n-slash-89-degrees-35-28-dot-18-o-slash-26-04-08-slash-09-00-am

"“水／火”系列 No.8".to_url
# => "shui-slash-huo-xi-lie-no-dot-8"

"трактат по теории этики".to_url
# => "traktat-po-tieorii-etiki"
```

Pretty amazing!
