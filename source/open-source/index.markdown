---
layout: page
title: "Artsy Open Source"
section: opensource
comments: false
sharing: true
footer: true
---

We love open-source at Artsy. We use a ton of it. We've also contributed to numerous projects and created many of our own since early 2011. Below is a list of projects that we have either created or that we are core contributors or maintainers of. Our projects fall mostly into the following categories: [Ruby](#ruby), [Javascript](#javascript), [iOS](#ios) and [Heroku](#heroku).

# &nbsp;
<h1 id="ruby">Ruby<h1>
----------------------

[Grape](https://github.com/intridea/grape)
------------------------------------------

An opinionated micro-framework for creating REST-like APIs in Ruby.

[artsy-ruby-client](https://github.com/artsy/artsy-ruby-client)
---------------------------------------------------------------

A Ruby client for the Artsy API.

[momentum](https://github.com/artsy/momentum)
----------------------------------------

Shared utilities for managing and deploying OpsWorks apps at Artsy.

[garner](http://github.com/artsy/garner)
----------------------------------------

Garner is a practical Rack-based cache implementation for RESTful APIs with support for HTTP 304 Not Modified based on time and ETags, model and instance binding and hierarchical invalidation.

To "garner" means to gather data from various sources and to make it readily available in one place, kind-of like a cache!

[spidey](https://github.com/joeyAghion/spidey)
-------------------------------------------------------------
Spidey provides a bare-bones framework for crawling and scraping web sites. Its goal is to keep boilerplate scraping logic out of your code. The companion [spidey-mongo](https://github.com/joeyAghion/spidey-mongo) gem adds MongoDB as a data store.

[pixmatch](https://github.com/dblock/pixmatch)
----------------------------------------------

TinEye Pixmatch Ruby client library. [PixMatch](http://ideeinc.com/products/pixmatch/) is a general image matching engine that
allows you to perform large scale image comparisons for a variety of tasks. PixMatch is delivered as a hosted Web Services API.
It runs over HTTP using a REST protocol and JSON formatted responses, wrapped by this library.

[gem-licenses](https://github.com/dblock/gem-licenses)
------------------------------------------------------

A library for generating a list of licensed software from Gemspec. The overwhelming majority of 3rd party licenses require the
application that uses them to reproduce the license verbatim in an artifact that is installed with the application itself.
Are you currently copying individual license.txt files "by hand" or are you including license text in your documentation with
copy/paste? This project aims at improving this situation.

[canonical-emails](https://github.com/dblock/canonical-emails)
--------------------------------------------------------------

Combine email validation and transformations to produce canonical email addresses.

[guard-rack](https://github.com/dblock/guard-rack)
--------------------------------------------------

Want to restart your Rack development with rackup whilst you work? Now you can!

[rspec-rerun](https://github.com/dblock/rspec-rerun)
----------------------------------------------------

The rspec-rerun gem is a drop-in solution to retry (rerun) failed RSpec examples. It may be useful, for example, with finicky Capybara tests. The strategy to rerun failed specs is to output a file called `rspec.failures` that contains a list of failed examples and to feed that file back to RSpec via `-e`.

[hyperloglog-redis](https://github.com/aaw/hyperloglog-redis)
-------------------------------------------------------------
This gem is a pure Ruby implementation of the HyperLogLog algorithm for estimating cardinalities of sets observed via a stream of events. A Redis instance is used for storing the counters.

[cartesian-product](https://github.com/aaw/cartesian-product)
-------------------------------------------------------------
A cartesian product implementation in Ruby that doesn't materialize the product in memory.

[space-saver-redis](https://github.com/aaw/space-saver-redis)
-------------------------------------------------------------
A pure Ruby implementation of the SpaceSaver algorithm for estimating the top K elements in a data stream.

[mongoid_fulltext](https://github.com/aaw/mongoid_fulltext)
-----------------------------------------------------------

A Ruby full-text search implementation for the Mongoid ODM. MongoDB currently has no native full-text search capabilities,
so this gem is a good fit for cases where you want something a little less than a full-blown indexing service like Solr. The
mongoid_fulltext gem lets you do a fuzzy string search across relatively short strings, which makes it good for populating
autocomplete boxes based on the display names of your Rails models but not appropriate for, say, indexing hundreds of thousands
of HTML documents.

[mongoid-cached-json](https://github.com/dblock/mongoid-cached-json)
--------------------------------------------------------------------

Typical as_json definitions may involve lots of database point queries and method calls. When returning collections of objects, a single call may yield hundreds of database queries that can take seconds. This library mitigates the problem by implementing a module called CachedJson.

CachedJson enables returning multiple JSON formats from a single class and provides some rules for returning embedded or referenced data. It then uses a scheme where fragments of JSON are cached for a particular (class, id) pair containing only the data that doesn't involve references/embedded documents. To get the full JSON for an instance, CachedJson will combine fragments of JSON from the instance with fragments representing the JSON for its references. In the best case, when all of these fragments are cached, this falls through to a few cache lookups followed by a couple Ruby hash merges to create the JSON.

Using Mongoid::CachedJson we were able to cut our JSON API average response time by about a factor of 10.

[mongoid-tag-collectible](https://github.com/dblock/mongoid-tag-collectible)
----------------------------------------------------------------------------

Easily maintain a collection of Tag instances with aggregate counts from your model's tags.

[delayed_job_shallow_mongoid](https://github.com/joeyAghion/delayed_job_shallow_mongoid)
-------------------------------------------------------------------------------------

Short-circuit serialization of Mongoid model instances when a delayed job is called on them, or when they're passed as arguments to delayed jobs.

[mongoid_collection_snapshot](https://github.com/aaw/mongoid_collection_snapshot)
---------------------------------------------------------------------------------

Easy maintenance of collections of processed data in MongoDB with the Mongoid ODM.

[mongoid-shell](https://github.com/dblock/mongoid-shell)
--------------------------------------------------------

Create MongoDB command-lines from Mongoid configuration.

[mongoid-scroll](https://github.com/dblock/mongoid-scroll)
--------------------------------------------------------------

Mongoid extension that enables infinite scrolling with MongoDB.

[forgetsy](https://github.com/cavvia/forgetsy)
--------------------------------------------------------------
Forgetsy is a highly scalable trending library using [Forget Table](http://word.bitly.com/post/41284219720/forget-table) data structures, backed by Redis.

[dzt](https://github.com/dblock/dzt)
------------------------------------

Slice deep-zoom images for [OpenSeaDragon](http://openseadragon.github.io/) or [ARTiledImageView](https://github.com/dblock/ARTiledImageView).

[doppler](https://github.com/artsy/doppler)
-------------------------------------------

The [Artsy Developer website](http://developers.artsy.net), a Rails app that talks to the Artsy public API.

[actionmailer-text](https://github.com/dblock/actionmailer-text)
----------------------------------------------------------------

Automatically insert a text/plain part into your HTML multipart e-mails.

[email-example-spec](https://github.com/dblock/email-example-spec)
------------------------------------------------------------------

Integration testing with e-mail examples.


# &nbsp;
<h1 id="javascript">Javascript<h1>
----------------------------------

[ezel](https://github.com/artsy/ezel)
-------------------------------------

A boilerplate for Backbone projects that share code server/client and scale through modular architecture.

[force](https://github.com/artsy/force-public)
----------------------------------------------

The [Artsy.net](https://artsy.net) frontend. This application renders the html and provides rich interaction for artsy.net.

[artsy-2013](https://github.com/artsy/artsy-2013)
-------------------------------------------------

Artsy's "2013 year in review" page using node for some preprocessors.

[browserify-dev-middleware](https://github.com/artsy/browserify-dev-middleware)
-------------------------------------------------------------------------------

Middleware to compile browserify files on request for development purpose.

[backbone-cache-sync](https://github.com/artsy/backbone-cache-sync)
-------------------------------------------------------------------

Server-side Backbone.sync adapter that caches requests using Redis.

[jquery.konami.coffee](https://github.com/craigspaeth/jquery.konami.coffee)
--------------------------------------------------------------------------------------------

A jQuery plugin to listen for a user entering the konami code.

[backbone-super-sync](https://github.com/artsy/backbone-super-sync)
-------------------------------------------------------------------

Node server-side Backbone.sync adapter using [super agent](https://github.com/visionmedia/superagent).

[benv](https://github.com/artsy/benv)
-------------------------------------

Stub a browser environment in node.js and headlessly test your client-side code.

[bucket-assets](https://github.com/artsy/bucket-assets)
-------------------------------------------------------

Node module that uploads a folder of static assets to an s3 bucket with convenient defaults.

[sharify](https://github.com/artsy/sharify)
-------------------------------------------

Node module to easily share data between your server-side and browserify modules.

[nap](https://github.com/craigspaeth/nap)
-----------------------------------------

Node Asset Packager helps compile and package your assets including stylesheets, javascripts, and client-side javascript templates.

[flare](https://github.com/artsy/flare)
---------------------------------------

Artsy iPhone Launch Marketing Page

[jquery-poplockit](https://github.com/zamiang/jquery.poplockit)
---------------------------------------------------------------

A jQuery plugin for 'locking' short content in place as the user scrolls by longer content. For example, it will lock metadata and share buttons in place as the user scrolls by a long essay or series of images.

[jquery-fillwidth](https://github.com/craigspaeth/jquery.fillwidth)
-------------------------------------------------------------------

A jQuery plugin that given a `ul` with images inside their `li`s will do some things to line them up so that everything fits
inside their container nice and flush to the edges. It's like google image search but also retaining the integrity of the
original images (no cropping or stretching/squishing).

[api-sandbox](https://github.com/mmcnierney14/API-Sandbox)
----------------------------------------------------------

API Sandbox is a jQuery plugin written in CoffeeScript that allows web apps to easily implement sandbox environments for an API explorer.
The plugin includes two parts: apiSandbox, which aids in the creation of inline sandboxes for individual API paths, and APIExplorer,
which is a full API explorer solution.


# &nbsp;
<h1 id="ios">iOS<h1>
--------------------

[CocoaPods](https://cocoapods.org)
----------------------------------

[CocoaPods](http://cocoapods.org/) is the dependency manager for iOS. Artsy provides occasional sponsorship, and provides developer time for features &amp; related projects.

[CocoaDocs](https://github.com/CocoaPods/cocoadocs.org)
-------------------------------------------------------

[CocoaDocs](http://cocoadocs.org/) documents every public OSS library in [CocoaPods](http://cocoapods.org/). Artsy pays for hosting.

[Eigen](https://github.com/artsy/eigen)
-------------------------------------------

The Artsy iOS app, the Art World in Your Pocket

[Eidolon](https://github.com/artsy/eidolon)
-------------------------------------------

 A bidding kiosk for the Artsy auctions platform written in Swift.

[ARAnalytics](https://github.com/orta/ARAnalytics)
--------------------------------------------------

ARAnalytics is for Objective-C what Analytics.js is to Javascript. It lets you use multiple analytics providers with the same API.</p>

[ORStackView](https://github.com/orta/ORStackView)
--------------------------------------------------

Vertically stack views using Auto Layout, with an order specific subclass that uses view tags for ordering.

[ORSimulatorKeyboardAccessor](https://github.com/orta/ORSimulatorKeyboardAccessor)
----------------------------------------------------------------------------------

ORSimulatorKeyboardAccessor allows you to use your keyboard in the iOS simulator with a blocks based API.

[DRBOperationTree](https://github.com/dstnbrkr/DRBOperationTree)
----------------------------------------------------------------

DRBOperationTree is an iOS and OSX API to organize NSOperations into a tree so that each node's output becomes the input for its child nodes.

[Fui](https://github.com/dblock/fui)
------------------------------------

Fui stands for _Find Unused Interfaces_, a Ruby gem that works against an Objective-C codebase.

[ARTiledImageView](https://github.com/dblock/ARTiledImageView)
--------------------------------------------------------------

Display, pan and deep zoom with tiled images on iOS.

[obcd](https://github.com/dblock/obcd)
--------------------------------------

Deal with obsessive compulsive issues of programmers in Objective-C.

[EXPMatchers+FBSnapshotTest](https://github.com/dblock/ios-snapshot-test-case-expecta)
--------------------------------------------------------------------------------------

Expecta matchers for ios-snapshot-test-case.

[ARASCIISwizzle](https://github.com/dblock/ARASCIISwizzle)
----------------------------------------------------------

Swizzle your iOS project into ASCII art.

[ARCollectionViewMasonryLayout](https://github.com/AshFurrow/ARCollectionViewMasonryLayout)
-------------------------------------------------------------------------------------------

A UICollectionViewLayout subclass for creating flow-like layouts with dynamic widths or heights.

[musical chairs](https://github.com/orta/chairs)
------------------------------------------------

A gem for swapping iOS simulator states. Saves all the documents, library and cache for the most recently user iOS app into the current folder with a named version. Commands are modelled after git.


# &nbsp;
<h1 id="heroku">Heroku<h1>
----------------------

[resque-heroku-scaling-canary](https://github.com/aaw/resque-heroku-scaling-canary)
-----------------------------------------------------------------------------------

Defines a Resque plugin that allows you to automatically scale up the number of workers running on Heroku and then automatically scale them down once no work is left to do.

[heroku-forward](https://github.com/dblock/heroku-forward)
----------------------------------------------------------
Beat Heroku's 60s boot timeout with a proxy.

Heroku will report an application crashed and log an `R10 Boot Timeout` error when a web process took longer than 60 seconds to bind to its assigned port. Setup a proxy that will start immediately, report an `up` status to Heroku, and forward requests to your application that takes more than 60 seconds to boot.

[heroku-bartender](https://github.com/sarcilav/heroku-bartender)
----------------------------------------------------------------

A tool to deploy web applications to Heroku.

[heroku-commander](https://github.com/dblock/heroku-commander)
--------------------------------------------------------------
Master the Heroku CLI from Ruby.


Want to write some open-source at Artsy? [Join us](https://artsy.net/about/jobs).
