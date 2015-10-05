---
layout: post
title: Data Corruption and Concurrent Updates to Embedded Objects with MongoDB
date: 2013-02-09 21:21
comments: true
categories: [MongoDB, Mongoid]
author: db
---

We use [MongoDB](http://www.mongodb.org/) at Artsy as our primary data store via the [Mongoid ODM](http://mongoid.org/). Eventually, we started noticing data corruption inside embedded objects at an alarming rate of 2-3 records a day. The number of occurrences increased rapidly with load as our user growth accelerated.

The root cause was not a HN-worthy sensational declaration about how MongoDB trashes data, but our lack of understanding of what can and cannot be concurrently written to the database, neatly hidden behind the object data mapping layer.

<!-- more -->

### Data Model

Consider the following artwork model with embedded images.

```ruby
class Artwork
  include Mongoid::Document
  field :title, type: String
  embeds_many :images
end

class Image
  include Mongoid::Document
  embedded_in :artwork
  field :filename, type: String
  field :width, type: Integer  
  field :height, type: Integer
end
```

Let's create a few objects and examine the database queries executed when constructing this relationship by setting a `DEBUG` logger level on the Moped driver used underneath the ODM.

```ruby
Moped.logger = Logger.new($stdout)
Moped.logger.level = Logger::DEBUG

# db.artworks.insert({
#   _id: ObjectId("510f22c5db8e540aab000001"),
#   title: "Mona Lisa"
# })
artwork = Artwork.create!(title: "Mona Lisa")

image1 = Image.new(filename: "framed.jpg")

# db.artworks.update(
#   { _id: ObjectId("510f22c5db8e540aab000001") },
#   { $push :
#     { images:
#       {
#         _id: ObjectId("510f22c5db8e540aab000002"),
#         filename: "framed.jpg"
#       }
#     }
#   }
# )
artwork.images << image1

image2 = Image.new(filename: "unframed.jpg")
# db.artworks.update(
#   { _id: ObjectId("510f22c5db8e540aab000001") },
#   { $push :
#     { images:
#       {
#         _id: ObjectId("510f22c5db8e540aab000003"),
#         filename: "unframed.jpg"
#       }
#     }
#   }
# )
artwork.images << image2
```

Here's the artwork data in MongoDB retrieved from a `mongo` shell:

```
> db.artworks.findOne()
{
  "_id" : ObjectId("510f22c5db8e540aab000001"),
  "title" : "Mona Lisa",
  "images" : [
    {
      "_id" : ObjectId("510f22c5db8e540aab000002"),
      "filename" : "framed.jpg"
    },
    {
      "_id" : ObjectId("510f22c5db8e540aab000003"),
      "filename" : "unframed.jpg"
    }
  ]
}
```

We can modify the attributes of the second image.

```ruby
# db.artworks.update(
#   { _id: ObjectId("510f22c5db8e540aab000001") },
#   { $set : { "images.1.width" : 30, "images.1.height" : 40 } }
# )
image2.update_attributes!(width: 30, height: 40)
```

The image has been updated correctly.

```
> db.artworks.findOne()
{
  "_id" : ObjectId("510f22c5db8e540aab000001"),
  "title" : "Mona Lisa",
  "images" : [
    {
      "_id" : ObjectId("510f22c5db8e540aab000002"),
      "filename" : "framed.jpg"
    },
    {
      "_id" : ObjectId("510f22c5db8e540aab000003"),
      "filename" : "unframed.jpg",
      "height" : 40,
      "width" : 30
    }
  ]
}
```

### Incomplete Record Corruption

Examining the query you will notice that it uses a so-called "positional" operator, `images.1.width` to update the second record. Imagine what would happen if the first record was deleted from another process immediately before the update. That's right, the update will be performed on a record that doesn't exist, in which case the default MongoDB behavior is to create it!

We can simulate this by loading the object in Ruby, pulling the first record directly from the database and then performing the update.

```ruby
artwork.images << image2

# pull the first artwork directly from the database
Artwork.collection.where(_id: artwork.id).update(
  "$pull" => { "images" => { _id: image1.id } })

image2.update_attributes!(width: 30, height: 40)
```

This yields a nasty surprise. We now have two records in the embedded collection, the second one missing an `_id`.

```
> db.artworks.findOne()
{
  "_id" : ObjectId("510f22c5db8e540aab000001"),
  "title" : "Mona Lisa",
  "images" : [
    {
      "_id" : ObjectId("510f22c5db8e540aab000003"),
      "filename" : "unframed.jpg"
    },
    {
      "height" : 40,
      "width" : 30
    }
  ]
}
```

When reloaded, Mongoid will assign an automatic `_id` to the second object, the correct height and width, but no filename.

### Null Record Corruption

A similar scenario can play out by pulling both image records out of the embedded collection and making a positional update. This will create a `null` record, which is much worse, because Mongoid can't even destroy it, attempting to pull a record with an `_id` that does not exist.

```ruby
artwork.images << image2

Artwork.collection.where(_id: artwork.id).update(
  "$pull" => { "images" => { _id: image1.id } })
Artwork.collection.where(_id: artwork.id).update(
  "$pull" => { "images" => { _id: image2.id } })

image2.update_attributes!(width: 30, height: 40)
```

```
> db.artworks.findOne()
{
  "_id" : ObjectId("510f22c5db8e540aab000001"),
  "title" : "Mona Lisa"
  "images" : [
    null,
    {
      "height" : 40,
      "width" : 30
    }
  ],
}
```

### Solutions

A first obvious solution is not to use embedded objects or to never modify them. Both `$push` and `$pull` are atomic operations, but not the positional update.

A general solution to this problem is to make all update operations transactional. You can take a lock on the parent model by using [mongoid-locker](https://github.com/afeld/mongoid-locker). It works, but can be quite tedious depending on the complexity of your application.

Finally, MongoDB supports something called a "positional operator" for embedded objects. This means you can atomically update a record found by its embedded object's field using a reference to the position of that embedded object. This solves our problem, as long as the object is not embedded below the first level. Mongoid 3.1 (currently HEAD) implements this behavior by default (see [#2545](https://github.com/mongoid/mongoid/issues/2545) for details), adjusting the selector to look for the embedded object's `_id` and replacing the position with a `$` positional operator.

```ruby
# db.artworks.update(
#   {
#     _id: ObjectId("510f22c5db8e540aab000001"),
#     "images._id" : ObjectId("510f22c5db8e540aab000003")
#   },
#   { $set : { "images.$.width" : 30, "images.$.height" : 40 }}
# )
image2.update_attributes!(width: 30, height: 40)
```

We've been successfully running this in production for a few weeks now, without any more data corruption issues.

While this is a huge step forward, covering all of our application's scenarios, we would like complete native support for atomic updates inside MongoDB at all levels of nesting. Please add your +1 to [SERVER-831](https://jira.mongodb.org/browse/SERVER-831).

### Links

* [Code to Detect Corrupt Embedded Objects](https://gist.github.com/dblock/4699070)
* [MongoDB SERVER-831: Positional Operator Matching Nested Arrays](https://jira.mongodb.org/browse/SERVER-831)
* [Mongoid #2545: Use $ Positional Operator for Updating Embedded Documents](https://github.com/mongoid/mongoid/issues/2545)
* [Repro Specs for Mongoid #2545 and Similar](https://github.com/dblock/mongoid/tree/master-issues/spec/dblock)
