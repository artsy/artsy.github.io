---
layout: post
title: Create MongoDB Command-Lines from Mongoid Configuration
date: 2013-01-31 21:21
comments: true
categories: [Mongoid, MongoDB, Shell, Rake]
author: db
---

We use MongoDB as our primary store and have built a healthy amount of automation around various database instances and operational environments. For example, we backup databases to S3 using `mongodump`, mirror data between instances with `mongorestore` and often need to open a MongoDB shell with `mongo` to examine data at the lowest level.

Generating MongoDB command-lines is tedious and error-prone. Introducing a new gem called [mongoid-shell](https://github.com/dblock/mongoid-shell) to help with this. The library can generate command-lines for various MongoDB shell tools from your Mongoid configuration.

For example, connect to your production MongoDB instance from a `db:production:shell` Rake task.

```ruby
namespace :db
  namespace :production
    task :shell
      Mongoid.load! "mongoid.yml", :production
      system Mongoid::Shell::Commands::Mongo.new.to_s
    end
  end
end
```

<!-- more -->

Commands can be created for the current default session or you can pass a session as an argument to a new command.

```ruby
# will use Mongoid.default_session
Mongoid::Shell::Commands::Mongodump.new

# use a hand-crafted session
s = Moped::Session.new([ "127.0.0.1:27017" ])
Mongoid::Shell::Commands::Mongodump.new(session: s)
```

Commands accept parameters. Here's how to backup `my_database` to `/tmp/db_backup`.

```ruby
out = File.join(Dir.tmpdir, 'db_backup')
db = 'my_database'
dump = Mongoid::Shell::Commands::Mongodump.new(db: db, out: out)
# mongodump --db my_database --out /tmp/db_backup
system dump.to_s
```

The mongoid-shell gem currently supports `mongo`, `mongodump`, `mongorestore` and `mongostat` and various MongoDB configurations, including replica-sets.

Please note that we don't recommend you store passwords for production environments in your `mongoid.yml`. At Artsy, we set all sensitive values directly on our Heroku instances with `heroku config:add` and use [heroku-commander](https://github.com/dblock/heroku-commander) to retrieve these settings in rake. We also have a bit of convention in our application name, such as "app-staging" and "app-production".

Here's a complete Rake task that dynamically fetches Heroku configuration and opens a MongoDB shell on a production or staging environment.

```ruby
namespace :db do
  [ :staging, :production ].each do |env|
    namespace env do
      task :shell do
        app = "myapp-#{env}"
        config = Heroku::Commander.new(app: app).config
        config.each_pair do |k, v|
          ENV[k] = v
        end
        mongoid_yml = File.join(Rails.root, "config/mongoid.yml")
        Mongoid.load! mongoid_yml, env
        system Mongoid::Shell::Commands::Mongo.new.to_s
      end
    end
  end
end
```

Run `rake db:staging:shell` or `rake db:production:shell`, which works as long as you have access to the Heroku app itself. A bonus feature is that the mongoid-shell gem will automatically connect to the primary node of a replica-set.

```
$ rake db:staging:shell
 mongo db:10007/app-staging --username user --password ************
 MongoDB shell version: 2.0.7
 connecting to: db:10007/app-staging
 >
```
