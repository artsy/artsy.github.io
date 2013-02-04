---
layout: post
title: Concurrent Updates to Embedded Objects with Mongoid
date: 2013-02-04 21:21
comments: true
categories: [MongoDB, Mongoid]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---

We use [MongoDB](http://www.mongodb.org/) as our primary data store via the [Mongoid ODM](http://mongoid.org/). Occasionally, we noticed random data issues in our MongoDB database at the rate of 1-2 records per week, significantly increasing with load. We quickly narrowed it down to embedded objects or embedded collections of objects.

The root cause was not a Hacker News worthy sensational declaration about how MongoDB trashes data, but our lack of understanding of what can and what cannot be concurrently written to the database, neatly hidden behind an ORM layer.

<!-- more -->

Consider an artwork with images.

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

Examine the database queries executed when constructing this relationship.

```ruby
Moped.logger = Logger.new($stdout)
Moped.logger.level = Logger::DEBUG

# db.artworks.insert({ _id: "510f22c5db8e540aab000001", title: "Mona Lisa" })
artwork = Artwork.create!(title: "Mona Lisa")

# db.artworks.update({ _id: "510f22c5db8e540aab000001" }, { $push : { images: { _id: "510f22c5db8e540aab000002", filename: "framed.jpg" } } })
artwork.images << Image.new(filename: "framed.jpg")

# db.artworks.update({ _id: "510f22c5db8e540aab000001" }, { $push : { images: { _id: "510f22c5db8e540aab000003", filename: "unframed.jpg" } } })
artwork.images << Image.new(filename: "unframed.jpg")
```

The artwork in MongoDB:

```
> db.artworks.findOne()
{
  "_id" : "510f22c5db8e540aab000001",
  "images" : [
    {
      "_id" : "510f22c5db8e540aab000002",
      "filename" : "framed.jpg"
    },
    {
      "_id" : "510f22c5db8e540aab000003",
      "filename" : "unframed.jpg"
    }
  ],
  "title" : "Mona Lisa"
}
```

