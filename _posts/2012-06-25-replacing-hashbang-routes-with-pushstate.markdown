---
layout: post
title: "Replacing #! Routes with PushState Using Backbone.js"
date: 2012-06-25 11:35
comments: true
categories: [Hashbang, PushState, ThickClient, JavaScript, Backbone.js]
author: gib
---

> The only constant is change, continuing change, inevitable change, that is the dominant factor in society
> [and web apps!] today. No sensible decision can be made any longer without taking into account not only
> the world as it is, but the world as it will be.
>
> &ndash; Isaac Asimov

## R.I.P #!

It did not take us long to discover we shared the concerns of Twitter's
[Dan Webb on hashbang routes](http://danwebb.net/2011/5/28/it-is-about-the-hashbangs),
but it was almost a year before we were able to remove them from Artsy. Here's how it went down.

Artsy relies on the [Backbone.js](http://documentcloud.github.com/backbone/) framework for our client application
which offers a solid pushState routing scheme. This includes a seamless hashtag fallback for
[browsers that don't support the HTML5 History API](http://caniuse.com/#feat=history) (looking at you IE 9).

The pushState routing is optional, but *"the world as it should be"* suggests we say "Yes!" (or true) to pushState.
```coffeescript
Backbone.history.start({ pushState: true })
```

<!-- more -->

### The Client

At Artsy, we had left Backbone out of the loop for most of our internal linking. Our markup href attributes all
began with '/#!' and expected the browser's default hash behavior to keep the page from refreshing. For a proper
pushState scheme, the app's internal linking should begin with an absolute route. Backbone.js defaults to '/', but
this is configurable.
```coffeescript
# Optional root attribute defaults to '/'
Backbone.history.start
  pushState: true
  root: "/specialized/client/"
```
#### Internal Links
All internal links need to begin with your configured root ('/' for Artsy).
Be sure to leave out your domain (~~http://artsy.net~~).
```html
<a href="/">Home</a>

<a href="/artwork/matthew-abbott-lobby-and-supercomputer">My Favorite Work</a>
```

We now needed a global link handler that will leverage Backbone's `navigate` method which takes
care of updating the URL and avoiding a page refresh or alternatively wiring up the hashtag fallback.
Since we follow the convention of starting all `href` attributes with our application's root, we
can match on that in our selector to get all anchors whose link begins with our root, `a[href^='/']`.
This link handler is a great place to ensure backward compatibility while #!s are removed from
internal links.

```coffeescript
# Globally capture clicks. If they are internal and not in the pass
# through list, route them through Backbone's navigate method.
$(document).on "click", "a[href^='/']", (event) ->

  href = $(event.currentTarget).attr('href')

  # chain 'or's for other black list routes
  passThrough = href.indexOf('sign_out') >= 0

  # Allow shift+click for new tabs, etc.
  if !passThrough && !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
    event.preventDefault()

    # Remove leading slashes and hash bangs (backward compatablility)
    url = href.replace(/^\//,'').replace('\#\!\/','')

    # Instruct Backbone to trigger routing events
    App.router.navigate url, { trigger: true }

    return false
```
Thank you TenFarms for the excellent write up on [proper link handling for pushState enabled browsers](http://dev.tenfarms.com/posts/proper-link-handling).

#### External Links
The application will need a small check early in the initialization process to redirect external
links still expecting the #! routing scheme.
```coffeescript
# Our Backbone App namespace
window.App =
  # Namespace Backbone components
  Models: {}
  Collections: {}
  Views: {}
  redirectHashBang: ->
    window.location = window.location.hash.substring(2)

# DOM is ready, are we routing a #!?
$ ->
  if window.location.hash.indexOf('!') > -1
    return App.redirectHashBang()
  # else... continue on with initialization
```

### The Server

Now that our app will receive requests to full URLs
'https://artsy.net/artwork/mattew-abbott-lobby-and-supercomputer'
instead of 'https://artsy.net/#!/artwork/mattew-abbott-lobby-and-supercomputer',
we need to update our Rails setup.

Below is an excerpt from our Rails application's router.
Note references to our home and artworks controllers. Both use a `before` filter
to determine a user's authentication state and serve a different layout, with
unique assets or Backbone applications.

Controllers related to specific models now have the opportunity to
bootstrap associated JSON or mark up and we now get expected 404 (file not found)
error behavior without extra work required by a hash routing scheme.

```ruby
# Server - Rails
Application.routes.draw do

  root :to => "home#index"

  # Controller logic determines the layout and could bootstrap data
  resources :artworks, path: "artwork", only: :show

  # Plural to singular redirect - mistakes happen!
  get "/artworks/:id" => redirect('/artwork/%{id}')

  # No match? Rails handles routing the 404 error.

end
```

An added bonus here is a near one to one mapping with the Rails and client routes.

```coffeescript
# Backbone.js - Client
class App.Routers.Client extends Backbone.Router

  routes:
    ''            : 'home'
    'artwork/:id' : 'artwork'
    'artworks/:id': 'redirectToArtwork'
```


## URLs R 4 Ever

Dan Webb's assertion that [URLs are forever](http://danwebb.net/2011/5/28/it-is-about-the-hashbangs) is correct,
but so is Isaac Asimov's statement on change. You can't predict the future.
You make decisions based on the best data you have at the time. We started our app with hashtag routing
in early 2011 and added the ! around five months later (about the same time Dan Webb wrote his post).
Had we started Artsy today, even six months ago, I'm confident we would have enabled Backbone's pushState routing.
There's no need to look back. The future is here and its URLs are #! free!


### Footnotes

* [Backbone.js](http://documentcloud.github.com/backbone)
* [Google offers #! to aid the crawlability of AJAX hash routed applications](https://developers.google.com/webmasters/ajax-crawling/docs/getting-started)
* [Browser support for the HTML5 History API (aka pushState)](http://caniuse.com/#feat=history)
* [Twitter advocates #!](http://www.adequatelygood.com/2011/2/Thoughts-on-the-Hashbang)
* [Dan Webb's critique _It's About the Hashbangs_](http://danwebb.net/2011/5/28/it-is-about-the-hashbangs)
* [Twitter ditches #!](http://engineering.twitter.com/2012/05/improving-performance-on-twittercom.html)
