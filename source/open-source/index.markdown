---
layout: page
title: "Art.sy Open Source"
comments: false
sharing: true
footer: true
---

We love open-source at Art.sy. We use a ton of it. We've also contributed back to numerous projects, including [Grape](https://github.com/intridea/grape),
[Analytical](https://github.com/jkrall/analytical), [Fog](https://github.com/fog/fog), [Kaminari](https://github.com/amatsuda/kaminari), [Barista](https://github.com/Sutto/barista) or [TaxCloud](https://github.com/drewtempelmeyer/tax_cloud). And we have built a few open-source projects from scratch since beginning of 2011.

[hyperloglog-redis](https://github.com/aaw/hyperloglog-redis)
-------------------------------------------------------------
This gem is a pure Ruby implementation of the HyperLogLog algorithm for estimating cardinalities of sets observed via a stream of events. A Redis instance is used for storing the counters.

[https://github.com/aaw/hyperloglog-redis](https://github.com/aaw/hyperloglog-redis)

[rspec-rerun](https://github.com/dblock/rspec-rerun)
----------------------------------------------------

The rspec-rerun gem is a drop-in solution to retry (rerun) failed RSpec examples. It may be useful, for example, with finicky Capybara tests. The strategy to rerun failed specs is to output a file called `rspec.failures` that contains a list of failed examples and to feed that file back to RSpec via `-e`.

[https://github.com/dblock/rspec-rerun](https://github.com/dblock/rspec-rerun)

[resque-heroku-scaling-canary](https://github.com/aaw/resque-heroku-scaling-canary)
-----------------------------------------------------------------------------------

Defines a Resque plugin that allows you to automatically scale up the number of workers running on Heroku and then automatically scale them down once no work is left to do.

[https://github.com/aaw/resque-heroku-scaling-canary](https://github.com/aaw/resque-heroku-scaling-canary)

[garner](http://github.com/artsy/garner)
----------------------------------------

Garner is a practical Rack-based cache implementation for RESTful APIs with support for HTTP 304 Not Modified based on time and ETags, model and instance binding and hierarchical invalidation.

To "garner" means to gather data from various sources and to make it readily available in one place, kind-of like a cache!

[https://github.com/artsy/garner](https://github.com/artsy/garner)

[guard-rack](https://github.com/dblock/guard-rack)
--------------------------------------------------

Want to restart your Rack development with rackup whilst you work? Now you can!

[https://github.com/dblock/guard-rack](https://github.com/dblock/guard-rack)

[mongoid-cached-json](https://github.com/dblock/mongoid-cached-json)
--------------------------------------------------------------------

Typical as_json definitions may involve lots of database point queries and method calls. When returning collections of objects, a single call may yield hundreds of database queries that can take seconds. This library mitigates the problem by implementing a module called CachedJson.

CachedJson enables returning multiple JSON formats from a single class and provides some rules for returning embedded or referenced data. It then uses a scheme where fragments of JSON are cached for a particular (class, id) pair containing only the data that doesn't involve references/embedded documents. To get the full JSON for an instance, CachedJson will combine fragments of JSON from the instance with fragments representing the JSON for its references. In the best case, when all of these fragments are cached, this falls through to a few cache lookups followed by a couple Ruby hash merges to create the JSON.

Using Mongoid::CachedJson we were able to cut our JSON API average response time by about a factor of 10.

[https://github.com/dblock/mongoid-cached-json](https://github.com/dblock/mongoid-cached-json)

[mongoid_fulltext](https://github.com/aaw/mongoid_fulltext)
-----------------------------------------------------------

A Ruby full-text search implementation for the Mongoid ODM. MongoDB currently has no native full-text search capabilities,
so this gem is a good fit for cases where you want something a little less than a full-blown indexing service like Solr. The
mongoid_fulltext gem lets you do a fuzzy string search across relatively short strings, which makes it good for populating
autocomplete boxes based on the display names of your Rails models but not appropriate for, say, indexing hundreds of thousands
of HTML documents.

[https://github.com/aaw/mongoid_fulltext](https://github.com/aaw/mongoid_fulltext)

[jquery-fillwidth](https://github.com/craigspaeth/jquery.fillwidth)
-------------------------------------------------------------------

A jQuery plugin that given a `ul` with images inside their `li`s will do some things to line them up so that everything fits
inside their container nice and flush to the edges. It's like google image search but also retaining the integrity of the
original images (no cropping or stretching/squishing).

[https://github.com/craigspaeth/jquery.fillwidth](https://github.com/craigspaeth/jquery.fillwidth)

[api-sandbox](https://github.com/mmcnierney14/API-Sandbox)
----------------------------------------------------------

API Sandbox is a jQuery plugin written in CoffeeScript that allows web apps to easily implement sandbox environments for an API explorer.
The plugin includes two parts: apiSandbox, which aids in the creation of inline sandboxes for individual API paths, and APIExplorer,
which is a full API explorer solution.

[https://github.com/mmcnierney14/API-Sandbox](https://github.com/mmcnierney14/API-Sandbox)

[nap](https://github.com/craigspaeth/nap)
-----------------------------------------

Node Asset Packager helps compile and package your assets including stylesheets, javascripts, and client-side javascript templates.

[https://github.com/craigspaeth/nap](https://github.com/craigspaeth/nap)

[mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot)
---------------------------------------------------------------------------------

Easy maintenance of collections of processed data in MongoDB with the Mongoid ODM.

[https://github.com/aaw/mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot)

[delayed_job_shallow_mongoid](https://github.com/joeyAghion/delayed_job_shallow_mongoid)
-------------------------------------------------------------------------------------

Short-circuit serialization of Mongoid model instances when a delayed job is called on them, or when they're passed as arguments to delayed jobs.

[https://github.com/joeyAghion/delayed_job_shallow_mongoid](https://github.com/joeyAghion/delayed_job_shallow_mongoid)

[heroku-bartender](https://github.com/sarcilav/heroku-bartender)
----------------------------------------------------------------

A tool to deploy web applications to Heroku.

[https://github.com/sarcilav/heroku-bartender](https://github.com/sarcilav/heroku-bartender)

[gem-licenses](https://github.com/dblock/gem-licenses)
------------------------------------------------------

A library for generating a list of licensed software from Gemspec. The overwhelming majority of 3rd party licenses require the
application that uses them to reproduce the license verbatim in an artifact that is installed with the application itself.
Are you currently copying individual license.txt files "by hand" or are you including license text in your documentation with
copy/paste? This project aims at improving this situation.

[https://github.com/dblock/gem-licenses](https://github.com/dblock/gem-licenses)

[vertebrae](https://github.com/craigspaeth/vertebrae)
-----------------------------------------------------

Vertebrae extends Backbone.js with some useful functions and assumptions to help DRY up your backbone app.

[https://github.com/craigspaeth/vertebrae](https://github.com/craigspaeth/vertebrae)

[sentry](https://github.com/craigspaeth/sentry)
-----------------------------------------------

A simple node tool to watch for file changes (using a path, wildcards, or regexes) and execute a function or shell command.
It's like a watchr or guard for node.

[https://github.com/craigspaeth/sentry](https://github.com/craigspaeth/sentry)

[jquery\.konami\.coffee](https://github.com/craigspaeth/jquery.konami.coffee)
-----------------------------------------------------------------------------

A jQuery plugin to listen for a user entering the konami code.

[https://github.com/craigspaeth/jquery.konami.coffee](https://github.com/craigspaeth/jquery.konami.coffee)

[pixmatch](https://github.com/dblock/pixmatch)
----------------------------------------------

TinEye Pixmatch Ruby client library. [PixMatch](http://ideeinc.com/products/pixmatch/) is a general image matching engine that
allows you to perform large scale image comparisons for a variety of tasks. PixMatch is delivered as a hosted Web Services API.
It runs over HTTP using a REST protocol and JSON formatted responses, wrapped by this library.

[https://github.com/dblock/pixmatch](https://github.com/dblock/pixmatch)

