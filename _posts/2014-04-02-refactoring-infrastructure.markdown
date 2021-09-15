---
layout: post
title: Refactoring Infrastructure
date: 2014-04-02 10:32
comments: true
categories: [dev-ops]
author: joey
---

[Refactoring](http://martinfowler.com/books/refactoring.html) usually describes chages to _code_. Specifically, small changes that bring a codebase closer to the desired state. By making these changes incrementally and without modifying the end-to-end behavior, we avoid risk and the intermediate broken states that usually plague large-scale changes. But refactoring need not be limited to code. It's also an effective way to make infrastructure improvements.

Take the most common--and simplest--example: database schema changes. Environments that demand constant uptime have long had to chunk schema changes into steps that allow for a graceful transition. In the simple case of replacing a column, this might look like:

1. Add the new column
2. Redirect code references there from the old column
3. Migrate data as necessary, and finally
4. Remove the old column

The same sequencing applies to making larger infrastructure changes gracefully. Some recent examples from our own experience:

<!-- more -->

Splitting databases
---

When MongoDB's [database-level write-lock](http://docs.mongodb.org/manual/faq/concurrency/) started to impact our API performance, we explored switching certain batch insertions to a separate database. We made the transition seamless by first adding a version number to the batch logic. Existing batches would default to "v1" treatment and be read from the main database, while new batches would get "v2" treatment and be inserted into (and then read from) a secondary database. (See [this gist](https://gist.github.com/joeyAghion/9955727) for a more concrete demonstration.) After a few cycles, legacy collections had all been replaced by more recent batches in the new database and could be removed.

Extracting a web front-end from a monolithic app
---

The [artsy.net](https://artsy.net) site was recently extracted from our main Rails application into a dedicated Node.js app and a true client of our API. We rolled it out almost page-by-page; we simply configured [Nginx](http://wiki.nginx.org/Main) to proxy requests for a whitelist of paths to the new site. That allowed us to start with the simplest of pages and incorporate new ones as they were developed. Nginx supports [sophisticated proxying rules](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_pass), but our example can be as simple as:

```
location ^~ /about|press {
  proxy_pass http://next.artsy.net;
}
```

Once the new app was feature-complete, we removed the proxying layer and updated DNS so it would handle all requests.

New hosting environment
---

When we [switched hosting providers](http://artsy.github.io/blog/2013/08/27/introduction-to-aws-opsworks/) for our main application, it required changes to _many_ related tools and services (for logs, deploys, background queues, etc.). To mitigate risk, we set up a "double-deploy" to the legacy and new environments as soon as the basic elements were in place. The environments ran the same code and shared a data store. First, we targeted the new environment from only a few internal apps. As we surfaced and fixed bugs, we directed more client applications away from the old, eventually winding it down altogether. The process was spread over months, but since each individual change was small and low-risk, we were confident and could adjust course as necessary.

Full application rewrite
---

Occasionally--but rarely--it's awkward to partially roll out a new system. Maybe it's a significant enough re-imagining that it won't play nicely with the legacy application (e.g., a clashing UI that's difficult to back-port). It's _still_ possible to take a refactoring approach. When the new application is minimally viable, new customers can be directed to it. As more customers join and the new application reaches feature parity (and beyond), the user base naturally shifts toward the new and away from the old. Legacy customers can be transitioned when it's more convenient.

Trying a refactoring approach over the course of these large infrastructure changes has convinced me of the following lessons:

**1. There's _always_ a more incremental approach.** Repeat after me.

**2. Your culture will benefit.** Just as the tools and vocabulary of code refactoring yield benefits to development workflow, there are cultural benefits to viewing infrastructure as more dynamic and flexible. We're able to make more aggressive changes, and with greater confidence in the result. Nothing is sacred, "fixed," or can't be undone.

**3. Ship sooner.** By exercising the ability to roll out infrastructure changes incrementally, bugs and mistaken assumptions are surfaced earlier.

**4. Transitions can be ugly.** There will likely be some embarrassing intermediate stages. Embrace it. As a rule of thumb, it's OK to compromise the old system's integrity (i.e., _hack_) to ease the transition as you work toward the new ideal.

The tools for managing infrastructure have been improving steadily (see [Chef](http://www.getchef.com/chef/), [Ansible](http://www.ansible.com/home), [Docker](https://www.docker.io/)), making infrastructure changes more lightweight, testable, and repeatable--closer to code. Refactoring infrastructure is the natural extension of this. From [Kent Beck](https://twitter.com/KentBeck):

<blockquote class="twitter-tweet" lang="en"><p>for each desired change, make the change easy (warning: this may be hard), then make the easy change</p>&mdash; Kent Beck (@KentBeck) <a href="https://twitter.com/KentBeck/statuses/250733358307500032">September 25, 2012</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
