---
layout: post
title: "Replacing #! Routes with Browser pushState Using Backbone.js"
date: 2012-06-25 11:35
author: Gilbert Reimschüssel (gib)
comments: true
categories: [Hashbang, PushState, ThickClient, JavaScript, Backbone.js]
github-url: https://www.github.com/gib
twitter-url: http://twitter.com/greims
blog-url: http://shortforgilbert.com
---

> The only constant is change, continuing change, inevitable change, that is the dominant factor in society 
> [and web apps!] today. No sensible decision can be made any longer without taking into account not only 
> the world as it is, but the world as it will be.
>
> &ndash; Isaac Asimov

## R.I.P #!

It did not take us long to discover we shared conerns with Twitter's 
[Dan Webb on hashbang routes](http://danwebb.net/2011/5/28/it-is-about-the-hashbangs), 
but it was almost a year before we were able to remove them. 

Art.sy relies on the [Backbone.js](http://documentcloud.github.com/backbone/) framework for our client application
which offers a solid pushState routing scheme. This includes a seamless hash tag fallback for 
[browsers that don't support the HTML5 History API (looking at you IE 9)](http://caniuse.com/#feat=history).

The pushState routing is optoinal, but I suggest that you just say "Yes" (or `true`) to pushState! 
```coffeescript
Backbone.history.start({ pushState: true })
```

### The Client

At Art.sy, we had left Backbone out of the loop for most of our internal linking. Our markup href attributes all 
began with '/#!' and expected the browser's default hash behavoir keep the page from refreshing. For a proper
pushState scheme, the app's internal linking should begin with an absolute route. Backbone.js defaults to '/', but
you can configure your app's root.
```coffeescript
Backbone.history.start({ pushState: true, root: "/public/search/" })
```
All internal links you expect to utilize the Backbone routing need to begin with this route. 
Be sure to leave out your domain (no `http://art.sy`).
```html
<a href="/">Home</a>

<a href="/artwork/andy-warhol-skull">Andy Warhol's Skull</a>
```

We now needed a global link handler that will leverage Backbone's navigate method. This ensures the page is updated without a
reload and non pushState supporting browsers fall back to the hash scheme seamlessly.

```coffeescript
# Globally capture clicks. If they are internal and not sign_out,
# route them through Backbone's navigate method.
$(document).on "click", "a[href^='/']", (event) ->
  href = $(event.currentTarget).attr('href')
  passThrough = href.indexOf('sign_out') >= 0 # chain 'or's for other black list routes
  # Allow shift+click for new tabs, etc.
  if !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey && !passThrough
    event.preventDefault()
    # Remove leading slashes and hash bangs
    url = href.replace(/^\//,'').replace('\#\!\/','')
    App.router.navigate url, { trigger: true }
    return false
```
We get some backward compatability and coverage if our conteint adminstrators accidentally sneak in any #!s 
by replacing #! with '' if found in a link.

Thank you TenFarms for an excellent write up on 
[proper link handling for pushState enabled browsers](http://dev.tenfarms.com/posts/proper-link-handling).

### The Server

Now that we will receive requests to full URLs `http://art.sy/artwork/mattew-abbott-lobby-and-supercomputer` 
instead of `http://art.sy/#!/artwork/mattew-abbott-lobby-and-supercomputer`, we need some server updates. 

The first excerpt below refers to our Rails app's home and artworks controllers. Both use a before filter 
for determining if the user is authenticated and what assets to deliver. 

The client still makes many subsequent requests to build a page, but we now have the option to easily bootstrap 
JSON or mark up for specific URLs. 

We also get expected 404 (file not found) errors without extra work required by a hash routing scheme.

```ruby
# Server - Rails
Application.routes.draw do

  root :to => "home#index"

  # Controller logic determines the layout and could bootstrap data
  resources :artworks, path: "artwork", only: :show

  # Plural to singular redirect - mistakes happen!
  get "/artworks/:id" => redirect('/artwork/%{id}')

  # No route matches? Rails handles routing 404!

end
```
```coffeescript
# Backbone.js - Client
class App.Routers.Client extends Backbone.Router

  routes:
    ''                        : 'home'
    'artwork/:id'             : 'artwork'
    'artworks/:id'            : 'redirectToArtwork'
```


## URLs R 4 Ever

Art.sy will keep a very small check in our client application initialization script to redirect URLs if !s are found.
This way any URLs shared before we made the change will continue to work.
```coffeescript
# Store our Backbone app inside a namespaced App var
window.App =
  # Namespace Backbone components
  Models: {}
  Collections: {}
  Views: {}
  redirectHashBang: ->
    window.location = window.location.hash.substring(2)

# Wait for the DOM and any initial javascript to finish before initializing the app
$ ->
  return App.redirectHashBang() if window.location.hash.indexOf('!') > -1
  # else... continue on with initialization
```

Dan Webb's assertion that URLs are forever is correct, but so is Isaac Asimov's statement on change. You can't predict
the future. You make decisions based on the best data you have at the time. Had we started Art.sy today, even six months ago, 
I'm confident we would have used the history API from the beginning. 
The future is here, it's got a history API. Enjoy!


###### Footnotes

* [Art.sy &heart; Backbone.js](http://documentcloud.github.com/backbone)
* [Browser support for the HTML5 History API (aka pushState)](http://caniuse.com/#feat=history)
[Browser support is growing](http://caniuse.com/#feat=history)
[Twitter](http://www.adequatelygood.com/2011/2/Thoughts-on-the-Hashbang), although 
[not](http://isolani.co.uk/blog/javascript/BreakingTheWebWithHashBangs) 
[without](http://intertwingly.net/blog/2011/02/09/Breaking-the-Web-with-hash-bangs)
[controversy](http://danwebb.net/2011/5/28/it-is-about-the-hashbangs).

