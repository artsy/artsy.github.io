---
layout: post
title: Upgrading to Mongoid 4.x
date: 2013-11-07 12:34
comments: true
categories: [MongoDB, Mongoid]
author: db
---

I recently went through an exercise of upgrading one of Artsy's largest web projects to the current HEAD of Mongoid 4.x. This is going to be a major release with numerous changes and I wanted to flush out bugs before the final version of the ODM is released. All Mongoid changes currently live on [master](https://github.com/mongoid/mongoid).

```ruby
gem 'mongoid', github: 'mongoid/mongoid'
```

In the process I've worked on making a few gems compatible with Mongoid 4 and learned a couple of things that should help you make this process smooth for your own applications.

<!-- more -->

Moped::BSON::ObjectId
---------------------

Moped's BSON implementation has been removed in favor of the MongoDB bson gem 2.0 and higher. All `Moped::BSON` references must change to `BSON`. This is rather annoying and forces many libraries to have to fork behavior at runtime.

```ruby
module Mongoid
  def self.mongoid3?
    ::Mongoid.const_defined? :Observer # deprecated in Mongoid 4.x
  end

  def self.mongoid2?
    ::Mongoid.const_defined? :Contexts # deprecated in Mongoid 3.x
  end
end
```

The `mongoid2?` implementation is borrowed from [mongoid_orderable](https://github.com/pyromaniac/mongoid_orderable) and I wrote the `mongoid3?` version by parsing the CHANGELOG - observers are deprecated in 4.0.

Now, instead of calling `Moped::BSON::ObjectId.legal?(id)`, you have to do something like this:

```ruby
if Mongoid.mongoid3?
  Moped::BSON::ObjectId.legal? id
else
  BSON::ObjectId.legal? id
end
```

Furthermore, you can no longer convert a string into a `Moped::BSON::ObjectId(id)`, you must explicitly call `from_string`:

```ruby
if Mongoid.mongoid3?
  Moped::BSON::ObjectId(id)
else
  BSON::ObjectId.from_string(id)
end
```

Libraries should then adjust their dependencies on Mongoid and specify `>= 3.0`, and maybe `< 5.0`.

Testing Against Multiple Mongoid Versions
-----------------------------------------

The [mongoid-orderable](https://github.com/pyromaniac/mongoid_orderable) gem has a neat system for testing against all versions of Mongoid with [Travis CI](https://travis-ci.org/). First, the *.travis.yml* file declares a test matrix that sets `MONGOID_VERSION`. Note that Mongoid 3.x or newer doesn't run with Ruby 1.8.x or 1.9.2.

```ruby .travis.yml
rvm:
  - 1.8.7
  - 1.9.2
  - 1.9.3
  - ruby-head

env:
  - MONGOID_VERSION=2
  - MONGOID_VERSION=3
  - MONGOID_VERSION=4

matrix:
  exclude:
    - rvm: 1.8.7
      env: MONGOID_VERSION=3
    - rvm: 1.8.7
      env: MONGOID_VERSION=4
    - rvm: 1.9.2
      env: MONGOID_VERSION=3
    - rvm: 1.9.2
      env: MONGOID_VERSION=4

services: mongodb
```

The library's *Gemfile* locks a different version depending on the environment variable, defaulting to 3.x. You can also test against a very specific version, if you must.

```ruby Gemfile
source "http://rubygems.org"

gemspec

case version = ENV['MONGOID_VERSION'] || "~> 3.1"
when /4/
  gem "mongoid", :github => 'mongoid/mongoid'
when /3/
  gem "mongoid", "~> 3.1"
when /2/
  gem "mongoid", "~> 2.8"
else
  gem "mongoid", version
end
```

Upgraded Gems
-------------

I used the above method to make a few gems Mongoid 4.x compatible, via the following pull requests.

* [mongoid-slug](https://github.com/digitalplaywright/mongoid-slug/pull/146)
* [mongoid-scroll](https://github.com/dblock/mongoid-scroll/commit/b67e2867b133cd6bd1b8361ea51409f80ae91ffd)
* [mongoid_orderable](https://github.com/pyromaniac/mongoid_orderable/pull/18)
* [mongoid-history](https://github.com/aq1018/mongoid-history/pull/83)
* [mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot/pull/5)
* [delayed_job_shallow_mongoid](https://github.com/joeyAghion/delayed_job_shallow_mongoid/pull/6)

Upgrading a Rails Project
-------------------------

If you're using Rails, you're in for upgrading both Mongoid 4.x and Rails to 4.x. This means you will suffer a lot of pain trying to find compatible versions of various interdependent gems. I suggest locking Rails, Mongoid and ActiveSupport to begin with.

``` ruby Gemfile
gem 'rails', '4.0.1'
gem 'activesupport', '4.0.1'
gem 'mongoid', github: 'mongoid/mongoid'
```

Bulk search & replace `Moped::BSON::ObjectId` references.

Calls to `inc`, `set` and `add_to_set` now take hashes, eg. `artist.inc(likes_count: 1)`.

If you're converting Mongoid objects to JSON and seeing data such as `{ "$oid" => "..." }` instead of an ID, monkey-patch `BSON::ObjectId.as_json`. See [this discussion thread](https://groups.google.com/forum/#!msg/mongoid/MaXFVw7D_4s/T3sl6Flg428J).

``` ruby config/initializers/bson/object_id.rb
module BSON
  class ObjectId
    def as_json(options = {})
      to_s
    end
  end
end
```

If you're using Warden (including via Devise) and/or rely on session cookies that may contain a user ID, add an implementation for the deprecated `Moped::BSON::Document`. This will prevent all old cookies from causing a serialization error and logging all those users out.

``` ruby config/initializers/bson/
module Moped
  module BSON
    ObjectId = ::BSON::ObjectId

    class Document < Hash
      class << self
        def deserialize(io, document = new)
          __bson_load__(io, document)
        end

        def serialize(document, io = "")
          document.__bson_dump__(io)
        end
      end
    end
  end
end
```

Updates
-------

Please post your updates below and questions to the [mongoid mailing list](https://groups.google.com/forum/#!forum/mongoid). I'll update this post up until Mongoid 4.x ships.
