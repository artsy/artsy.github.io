---
layout: post
title: Using Docker for Development
date: 2015-12-09T00:00:00.000Z
comments: false
categories: [Docker, development]
author: barry
---

When I first proposed using Docker for development, and began doing my work that way, there were some doubts.

* Doesn't it seem like a lot of trouble to set up Docker to get my work done? 
* Isn't it easier to use [Homebrew](http://brew.sh/) to install the services and database servers I need?

<!-- more -->

At Artsy, our main API aka Gravity uses MongoDB, Solr, Elasticsearch, and memcached. In development, we use [Mailcatcher](http://mailcatcher.me/) so we can view emails. When a new software engineer starts, that person studies a big Getting Started document, and spends most of a day to get everything installed and configured. Not only do they need to get the software installed, figuring out all of the environment variables that need to be set up can take some time too. While we have good documentation, it is still a tedious process. 

For our applications (including Gravity) which have been dockerized, getting set up consists of a one-time install of [Docker Toolbox](https://www.docker.com/docker-toolbox) followed by running 

```bash
docker-compose build && docker-compose up
```

in the root directory of the checked-out Gravity repo. Here is a simplified version of our [docker-compose](https://docs.docker.com/compose/) setup. Because we run a web server and a delayed_job process, `docker-compose.yml` uses a `common.yml` file for shared setup:

```yaml
gravity:
  build: .
  environment:
    MEMCACHE_SERVERS: memcached
    SOLR_URL: http://solr4:8983/solr/gravity
    MONGO_HOST: mongodb
    ELASTICSEARCH_URL: elasticsearch:9200
    SMTP_PORT: 1025
    SMTP_ADDRESS: mailcatcher
  env_file: .env
```
The `.env` file is used for secrets such as Amazon Web Services credentials we don't want to put into the git repository.

Our `docker-compose.yml` looks like this:


```yaml
mongodb:
  image: mongo:2.4
  command: bash -c "rm -f /data/db/mongod.lock; mongod --smallfiles --quiet --logpath=/dev/null"
  ports: 
  - "27017:27017"

solr4:
  image: artsy/solr4

memcached:
  image: memcached

elasticsearch:
  image: artsy/elasticsearch
  ports:
  - "9200:9200"
  - "9300:9300"

web:
  extends:
    file: common.yml
    service: gravity
  command: script/rails s -b 0.0.0.0 -p 80
  ports:
  - "80:80"
  volumes:
  - .:/app
  links:
  - elasticsearch
  - mongodb
  - memcached
  - solr4
  - mailcatcher

dj:
  extends:
    file: common.yml
    service: gravity
  command: bundle exec rake jobs:work
  volumes:
  - .:/app
  links:
  - elasticsearch
  - mongodb
  - memcached
  - solr4

mailcatcher:
  image: zolweb/docker-mailcatcher
  ports:
  - "1080:1080"
```

The command for the MongoDB section removes a lock file that can remain in place sometimes when the container is killed. Do not use that in production! We mount the local directory into the container with a `volumes:` command, so that local changes are reloaded in the running containers.

Recently, [Ashkan Nasseri](https://github.com/ashkan18) began to move our delayed jobs from [delayed_job_mongoid](https://github.com/collectiveidea/delayed_job_mongoid) to [sidekiq](http://sidekiq.org/), which brings in Redis and another process that needs to run during development. Since we are using Docker, all we have to do is add a couple of new sections to our `docker-compose.yml` file:

```yaml
redis:
  image: redis
  ports:
  - "6379:6379"

sidekiq:
  extends: 
    file: common.yml
    service: gravity
  command: bundle exec sidekiq
  volumes:
  - .:/app
  links:
  - elasticsearch
  - mongodb
  - memcached
  - solr4
  - redis
```

and add this line to `common.yml`:

```yaml
REDIS_URL: redis://redis
```

For development which involves multiple applications in separate git repositories, we use [Dusty](http://dusty.gc.com/), which was created by [GameChanger](https://gc.com/). Some of the advantages of using Dusty include the use of `rsync` so that performance is better, and a built-in nginx proxy along with modifications to your `/etc/hosts` file so that you can more easily connect to your applications. The shared volumes approach with the `volumes:` directive can be rather slow with the default Docker Toolbox setup using VirtualBox.

With Dusty, you set up services, apps, and bundles of apps with YAML files. Our MongoDB service is defined as:

```yaml
# services/mongo2.yml
image: mongo:2.4
volumes:
- /persist/persistentMongo:/data/db
entrypoint: ["sh", "-c", "rm -f /data/db/mongod.lock; mongod --smallfiles --quiet --logpath=/dev/null"]
ports:
- "27017:27017"
```

It's not necessary to expose the ports, but in case we want to connect directly to the MongoDB instance with the `mongo` command without shelling into a container, we need it to be available on our Docker VM's IP address.

Our Gravity app's YAML file is:

```yaml
# apps/gravity.yml
repo: github.com/artsy/gravity
mount: /app
build: .

depends:
  services:
  - mongo2
  - memcached
  - solr4
  - es15
  - mailcatcher
  - redis
  apps:
  - radiation

host_forwarding:
- host_name: gravity
  host_port: 80
  container_port: 80

compose:
  environment:
    RADIATION_URL: http://radiation
    MONGO_HOST: mongo2
    MEMCACHE_SERVERS: memcached
    SOLR_URL: http://solr4:8983/solr/gravity
    ELASTICSEARCH_URL: es15:9200
    SMTP_ADDRESS: mailcatcher
    SMTP_PORT: 1025
    REDIS_URL: redis://redis

commands:
  once:
  - bundle install -j 10
  - bundle exec rake db:client_applications:create_all
  - bundle exec rake db:admin:create
  always:
  - rails s -b 0.0.0.0 -p 80
```

For now, Dusty doesn't have a way of sharing common setup like `common.yml` above, so there are similar configurations for our Sidekiq and Delayed Job workers.

Dusty uses bundles for clusters of applications that need to work together. An example bundle, for a CMS application that needs many APIs, is:

```yaml
# apps/volt.yml
description: Volt
apps:
  - tangentApi
  - radiation
  - superposition
  - gravity
  - volt
```

We bring up that cluster of applications with

```bash
dusty bundles activate volt
dusty up
```

As we have added new services over time, using Docker and Dusty to bring clusters of apps together has made it much easier for developers to work on projects without having to spend time on installations and configuration. Having configuration in code means that we need less documentation, and fewer documentation updates, for how a given application is configured and its dependencies.

We are also starting to use Docker to run integrated testing across multiple applications using Selenium. That will be covered in a future blog post.

