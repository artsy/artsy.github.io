---
layout: post
title: Reliably Testing Asynchronous UI w/ RSpec and Capybara
date: 2012-02-03 11:45
comments: true
categories: [RSpec, Capybara, Selenium, UI, Testing]
author: db
---
tl;dr - You can write 632 rock solid UI tests with Capybara and RSpec, too.

![/images/2012-02-03-reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/jenkins-ci.png](Miami Weather in NYC)

We have exactly 231 integration tests and 401 view tests out of a total of 3086 in our core application today. This adds up to 632 tests that exercise UI. The vast majority use [RSpec](http://rspec.info/) with [Capybara](https://github.com/jnicklas/capybara) and [Selenium](http://seleniumhq.org/). This means that every time the suite runs we set up real data in a local MongoDB and use a real browser to hit a fully running local application, 632 times. The suite currently takes 45 minutes to run headless on a slow Linode, UI tests taking more than half the time.

While the site is in private beta, you can get a glimpse of the complexity of the UI from the [splash page](http://artsy.net). It's a rich client-side Javascript application that talks to an API. You can open your browser's developer tools and watch a combination of API calls and many asynchronous events.

Keeping the UI tests reliable is notoriously difficult. For the longest time we felt depressed under the Pacific Northwest -like weather of our Jenkins CI and blamed every possible combination of code and infrastructure for the many intermittent failures. We've gone on sprees of marking many such tests "pending" too.

We've learned a lot and stabilized our test suite. This is how we do UI testing.

<!-- more -->

An Asynchronous Application
---------------------------

The splash page on [Artsy](http://artsy.net) is a [Backbone.js](http://documentcloud.github.com/backbone/) application where views fade in and out depending on user actions. It also implements a responsive layout because some elements cannot render on mobile devices or shouldn't depending on the size of your browser.

The application is initialized in a usual Backbone way.

``` coffeescript
window.Splash =
  Views: {}
  Routers: {}
  Models: {}
  initialize: ->
    contentWindow = new @Models.ContentWindow()
    @router = new @Routers.Client contentWindow
    new @Views.Responsive contentWindow
```

From here, everything is asynchronous. The router will wire up the events and the different views that make up the page will render themselves.

Testing a Login Form
--------------------

When a user clicks on a "Log In" link, he sees the `Splash.Views.Login` Backbone view. There's no page reload or server roundtrip: the current view is swapped out by the Backbone view coming in. Some CSS animates the transition.

``` coffeescript

class Splash.Routers.Client extends Backbone.Router

  routes:
    'log_in' : 'log_in'

  log_in: ->
    Splash.login = new Splash.Views.Login()
    @navigate 'log_in'

```

The log-in view has two input fields: an e-mail address and password. We can write a Capybara test that enters valid values and ensures that the user logged in by checking for a specific header.

``` ruby
require 'spec_helper'

feature "Log In" do
  context "using a browser", :js => true do
    scenario "allows a user to login" do
      user = Fabricate(:user)
      visit "/"
      click_link "log_in"
      fill_in "user[email]", :with => user.email
      fill_in "user[password]", :with => user.password
      click_button "sign in"
      find("h1", :visible => true).text.should == "Login Successful"
    end
  end
end
```

This test works well with Capybara, because it tries to wait for elements to appear on the page. For example, when you use `fill_in` it attempts to locate an element with the `user[email]` id, several times, until it times out or until the element is on the page.

Waiting for Explicit Events
---------------------------

The above test is "reliable" within some limits. It works as long as all the necessary asynchronous events run within a timeout period. But what if they don't? What if the test hardware is taking a break from flushing to disk? Or waiting on Google Analytics when the network cable is unplugged, which shouldn't affect the outcome of the test? These external issues make this code very brittle, so everyone keeps increasing the default timeout values.

A winning strategy to avoid this is to introduce explicit wait controls inside the tests. These wait `Capybara.default_wait_time` for a true result and no longer force you to know which method in Capybara waits for a timeout and which doesn't. It effectively breaks up a single wait into multiple waits.

Consider a widget that needs to be saved by making a postback.

``` coffeescript
@$el.removeClass("saved").addClass('saving')
@widget.save
  success: =>
    @$el.removeClass("saving").addClass("saved")
```

When the widget is saved, its element will get a `.saved` CSS class. The test can wait for it.

``` ruby
it "saves the widget" do
  widget_count = Widget.count
  find("save").click
  wait_until { find(".saved", visible: true) }
  Widget.count.should == widget_count + 1
end
```

There's Just Too Much Going On
------------------------------

Sometimes, waiting on explicit events is just not practical. You may have many AJAX requests going on at the same time and after those are done, you may still be executing JavaScript that modifies the DOM in meaningful ways. Lets attempt to answer the following two questions:

* How can we wait on all remaining AJAX requests to finish?
* How can we wait on all remaining DOM events to finish?

Remaining AJAX Requests
-----------------------

If you're using jQuery, you can test the number of active connections to a server. The number is zero when all pending AJAX requests have finished. This was an original idea from [Pivotal](http://pivotallabs.com/users/mgehard/blog/articles/1671-waiting-for-jquery-ajax-calls-to-finish-in-cucumber).

``` ruby spec/support/wait_for_ajax_helper.rb
def wait_for_ajax(timeout = Capybara.default_wait_time)
  page.wait_until(timeout) do
    page.evaluate_script 'jQuery.active == 0'
  end
end
```

Remaining DOM Events
--------------------

This one is a bit tricker. We can leverage the fact that JavaScript engines are updating the UI on a single thread. If you defer an action it will execute after everything else that has been deferred before it. Therefore we can queue an addition of an empty DIV with a new id and finally wait for it. By using a unique ID we allow the waits to stack up nicely in a single spec.

``` ruby spec/support/wait_for_dom_helper_.rb
def wait_for_dom(timeout = Capybara.default_wait_time)
  uuid = SecureRandom.uuid
  page.find("body")
  page.evaluate_script <<-EOS
    _.defer(function() {
      $('body').append("<div id='#{uuid}'></div>");
    });
  EOS
  page.find("##{uuid}")
end
```

We do have to make sure that the body element is loaded, first. This allows a `wait_for_dom` right after we navigate to a page that executes AJAX queries on load.

Combining Techniques
--------------------

With enough attention we were able to explain and fix most spec failures. When implementing Capybara tests we favor explicit waits and use the combination of the two wait functions above when we just want to generically make sure that everything on the page has loaded and is ready for more action.

Finally, integration tests are essential for continuous deployment. They are very much worth the extra development effort.
