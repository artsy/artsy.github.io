---
layout: post
title: Bootstrapping JSON Data with Rails and Backbone.js
date: 2013-04-13 12:21
comments: true
categories: [Rails,Backbone.js]
author: db
---

The [artsy.net website](http://artsy.net) is a Backbone.js application that talks to a server-side RESTful Grape API sitting on top of a Rails app which serves minimal HTML markup. The latter includes such things as a page title, along with links to JavaScript and stylesheet packages. A page loads, scripts run, data is fetched from the API. The result is merged into a HAMLJS template and rendered client-side.

Building this kind of one-page apps allows for clean separation between the presentation and API layers. The downside is that it will slow page render times - fetching data after page load means waiting for an AJAX request to complete before displaying anything.

There're many solutions to this problem, all involving some kind of server-side rendering. You could, for example, share views and JavaScript between client and server. This would be a major paradigm shift for a large application like ours and not something we could possibly maneuver in a short amount of time.

Without changing the entire architecture of the system, how can we bootstrap JSON data server-side and avoid the data roundtrip on every page load?

<!-- more -->

### Model Repository

First, we need to keep track of our objects on the client. We've implemented a simple data repository. It ensures that the same model is passed around instead of instantiating new models each time. This helps prevent unnecessary trips to the server, and makes sure events are bound to the same model instance.

``` coffeescript
App.Repository =

  # Gets a model from the repository or fetches it from the server.
  getOrFetch: (id, options) ->
    model = @get(id)
    if model?
      options?.success? options, model
      model
    else
      model = new @model({ id: id })
      model.fetch options
      @add model
    model

# Function to extend a collection in to a repository
App.Repository.extend = (collectionClass) ->
  collection = new collectionClass
  repository = _.extend collection, App.Repository
  repository.collectionClass = collectionClass
  repository
```

Objects of the same type are stored together in a repository collection.

``` coffeescript
class App.Collections.Artists extends Backbone.Collection

  model: App.Models.Artist
  App.Repositories.Artists = App.Repository.extend @

```

### Fetching Data

A view requires data before it can be rendered. For example, navigating to [artsy.net/artist/hendrik-kerstens](https://artsy.net/artist/hendrik-kerstens) (a Dutch photographer who obsessively took pictures of his daughter in all kinds of artificial setups for 20 years) will call the following.

``` coffeescript
class App.Views.ArtistView extends Backbone.View

  render: ->

    App.Repositories.Artists.getOrFetch @options.artistId,
      success: (artist) =>
        @$el.html(JST['templates/artist/show']({ artist: artist }))

```

### Bootstrapping Data

Since our implementation sits on top of a Rails app, we can now bootstrap the data in a server-side Rails view without any JavaScript code changes. The following example lives in `app/views/artists/_bootstrap.html.haml`.

``` javascript
:javascript
  var json = $.parseJSON("#{j @artist.to_json}")
  App.Repositories.Artists.add(new App.Models.Artist(json));
```

You must encode JSON data inside a Rails template, otherwise unicode characters like U+2028 become actual line-endings. This has been discussed [here](http://stackoverflow.com/questions/2965293/javascript-parse-error-on-u2028-unicode-character) and [here](http://stackoverflow.com/questions/9691611/print-valid-non-escaped-json-in-a-view-with-rails). The `j` above is an alias for `escape_javascript`.

The Rails view layout calls `yield :javascript` and the `show.html.haml` template includes the bootstrapped data as a partial.

``` haml
= content_for :javascript do
  = render partial: "artists/bootstrap"
```

The generated HTML includes the escaped JSON representation of the artist, which will be parsed client-side when the page loads and inserted into `App.Repositories.Artists`. The `App.Views.ArtistView` will no longer need to fetch the data from the server with an AJAX call.
