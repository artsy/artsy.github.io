---
layout: post
title: Infinite Scroll with MongoDB
date: 2013-02-15 21:21
comments: true
categories: [MongoDB, Mongoid]
author: db
---

An infinite scroll can be a beautiful and functional way to present feed data. You can see ours on the [homepage of artsy.net](https://artsy.net/). It works by fetching a few items from the API, then fetching some more items as the user scrolls down the feed. Each API call returns the items along with a "cursor", which marks the position of the last item retrieved. Subsequent API calls include the cursor in the query string and the iteration resumes from there.

Why use a cursor and not standard pagination? Because inserting an item on top of the feed would shift the existing items down, causing the API to return a duplicate item on the page boundary. Removing an item from the top of the feed would pull the remaining items up, causing an item to be missed in the next request on the page boundary.

Today we're open-sourcing a small gem called [mongoid-scroll](https://github.com/dblock/mongoid-scroll), which implements this cursor-like behavior for MongoDB using mongoid or moped. Here's how it works.

<!-- more -->

Example
-------

Define a sample `FeedItem` model with an index on `position`. We'll be iterating over our feed, starting with the newest item first.

```ruby
module Feed
  class Item
    include Mongoid::Document
    field :title, type: String
    field :position, type: Integer
    index({ position: -1, _id: 1 })
  end
end
```

Insert some sample unordered data manufactured with [faker](https://github.com/stympy/faker).

```ruby
total_items = 20
rands = (0..total_items).to_a.sort { rand }[0..total_items]
total_items.times do |i|
  Feed::Item.create! title: Faker::Lorem.sentence, position: rands.pop + 1
end
```

Iterate over this collection using a cursor, 7 items at a time.

```ruby
next_cursor = nil
while true
  current_cursor = next_cursor
  next_cursor = nil
  Feed::Item.desc(:position).limit(7).scroll(current_cursor) do |item, cursor|
    puts "#{item.position}: #{item.title}"
    next_cursor = cursor
  end
  break unless next_cursor
  # destroy an item, the scroll is not affected
  Feed::Item.desc(:position).first.destroy
end
```

The result is, as expected, all 20 items in reverse order.

```text
20: Quae eveniet est a.
19: Ab voluptatem aut possimus.
18: Tenetur voluptatem aut modi eos et fugiat ipsa impedit.
17: Autem enim qui illum ut sed et et pariatur.
16: Est molestias quidem adipisci culpa non.
15: Incidunt ad atque minus fuga illum ex earum.
14: Ullam et cum harum tempore nostrum consequatur.
13: Porro nostrum laboriosam aperiam blanditiis est.
12: Facere non a vel est sapiente sit officiis.
11: Itaque commodi deserunt aut exercitationem aut voluptatem.
10: Veritatis mollitia libero hic velit quos.
9: Iste ea dicta ut culpa.
8: Voluptatibus vel et minima.
7: Possimus molestiae quis consectetur iusto sed.
6: Aut fugit omnis incidunt.
5: Recusandae corrupti est in dolor est commodi aut.
4: Tenetur veniam ut id.
3: Voluptas exercitationem eos quia rem quia quas qui quae.
2: Eveniet repellendus corrupti molestiae molestias qui ullam.
1: Sapiente impedit iste quos eligendi cupiditate accusantium ad.
```

We've used 4 queries to iterate over this collection.

First Query
-----------

The first ordered query without an existing cursor uses a `limit`.

```javascript
db.feed_items.find().sort({ position: -1, _id: -1 }).limit(7)
```

The last item returned has a position of 14 (we scrolled from 20 down to 14, including the boundaries).

Second and Third Query
----------------------

The second ordered query has to fetch any item that comes after 14, including any other item that has the same position further in the same direction as the MongoDB order (there're no duplicates in our example, but it's entirely possible).

```javascript
db.feed_items.find({ "$or" : [
 { "position" : { "$lt" : 14 }},
 { "position" : 14, "_id": { "$lt" : ObjectId("511d7c7c3b5552c92400000e") }}
]}).sort({ position: -1, _id: -1 }).limit(7)
```

Note that we're sorting by `_id` as well because MongoDB may relocate a document and therefore alter the natural order. See [this commit](https://github.com/dblock/mongoid-scroll/commit/3cd75ded93f82adfcb1c17a8b9c98715c536b680) for a test that reproduces this behavior.

Last Query
----------
We've chosen to break out of the loop after getting no data back in the 4th iteration. You can check whether the item retrieved is the last one in the collection as an alternative to prevent this fourth empty database query.

Cursors
-------

Cursors consist of the item's position and the item's BSON id. The cursor for the item at position 14 is `14:511d7c7c3b5552c92400000e`. This cursor is parsed to construct the query on subsequent requests or can be supplied as a `Mongoid::Scroll::Cursor` object.

Links
-----

* [mongoid-scroll on Github](https://github.com/dblock/mongoid-scroll)
