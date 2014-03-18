---
layout: post
title: "Presenters and Memoization: Moving Logic out of Templates"
date: 2014-03-18 17:27
comments: true
categories: [Ruby, Rails]
author: Matt Zikherman
github-url: https://github.com/mzikherman
---


When dealing with rendering data for an email, one frequently has to make many database calls to assemble the required data. This can be slow, and depending on how you structure the code that is assembling the data vs rendering the data in a template, it's very easy to be making repeated calls, which can significantly slow down your process. Additionally, whether you are using [Haml](http://haml.info/), [Mustache](http://mustache.github.io/), [Jade](http://jade-lang.com/), or any other templating language, embedding too much logic in the template can making things hard to maintain (especially if some logic lives in the template and some elsewhere in your domain code). Of course some logic in the template (a conditional: should I render this section?, or loops: render this hash of data) is necessary, but I like to keep as much out of there as possible. It's easier to optimize, debug and maintain that logic elsewhere, and also writing complex logic in [Ruby](https://www.ruby-lang.org) is much more fun than in a templating language!

In this article I'll present what I've been doing to keep my templates relatively logic-free, and how I make sure I don't repeat any heavy database calls in assembling my data.

<!-- more -->

## The Setup - Presenters and Memoization

First, I'd like to introduce the Presenter pattern, and how this can help clean up your templates. Consider the following screenshot of a section of a weekly email that we send our users:

![Example of Recently Added Works](/images/2014-03-18-presenters-and-memoization-moving-logic-out-of-templates/recently_added.png)

This section shows works that have been added that week by artists that you follow. That's clearly going to involve some database calls, and potentially heavy ones at that. Now we want to make sure that we only make these calls once (no matter what we wind up doing with the data later), and we also would like to make sure that any code that is making these calls, and potentially munging the data into an easy-to-render format, is done in Ruby (and not in our templates directly).

Let's start by creating a Module to hold the various logic required for this email.

``` ruby
module WeeklyEmail
  class Presenter

    def initialize(user)
      @user = user
    end
  end
end
```

Ok, so far so good. In our mail template rendering/calling code, we can now say:

``` ruby
@presenter = WeeklyEmail::Presenter.new(user)
```

This will allow us to refer to methods in this class in our mail template. So now let's add a method that will query our database and return a list of artists that this user should be notified about:

``` ruby
module WeeklyEmail
  class Presenter

    def initialize(user)
      @user = user
    end

    def recently_added_works
      # Some really heavy database query
    end
  end
end
```

Ok, that was easy. In our HAML template, we can now do:

``` haml
-if @presenter.recently_added_works && @presenter.recently_added_works.any?
  %table{ id: "recently-added-works", cellpadding: "0", cellspacing: "0", style: "border: 0;padding:10px 0px 15px 0px;width:610px" }
    %tr
      %td{ align: "left", valign: "middle", style: 'padding-bottom:15px;border-bottom:1px solid #ccc;', colspan: "3" }
        -@presenter.recently_added_works.each do |artists|
          <!-- markup to render each artist with recently added works -->
```

(As a side note- this is a great opportunity to take the markup for each row in this table and move it into a partial, further cleaning up this layout!)

However, take a look at how many times we've referred to ```@presenter.recently_added_works``` - 3 times already! And we'll most likely refer to it more elsewhere (perhaps when deriving a subject line, or showing a total count somewhere, etc.). Depending on how you've implemented the method ```recently_added_works```, you may be re-querying the database every time it's referred to! Clearly that's a lot of wasted resources. So, let's look at an easy change that will guarantee we only ever perform the work to assemble this data once. We memoize it:

``` ruby
module WeeklyEmail
  class Presenter

    def initialize(user)
      @user = user
    end

    def recently_added_works
      @recently_added_works ||= build_recently_added_works
    end

    private

    def build_recently_added_works
      # Code to do database lookups
    end
  end
end
```

All we do is move the actual code that's doing the heavy lifting into a ```private``` method (for convention, I like to prefix the name with ```build_```), and then the public method that will be referred to multiple times throughout, will call the private method, and will only call it once. We accomplish this by using instance variables, and conditional assignment.


That's it! To summarize, use instance variables in your public methods which is what your templates and other code will use. Those public methods should call private ```build_``` methods which actually do all the heavy lifting. This way, you get to easily move logic away from a template and into its own module, and can guarantee that you're not repeating any long-running database queries or other slow data processing.

Hopefully you've found this a useful pattern to follow, please leave any feedback in the comments and [follow us on Github](https://github.com/artsy)!