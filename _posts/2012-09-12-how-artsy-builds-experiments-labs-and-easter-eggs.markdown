---
layout: post
title: How Artsy Builds Labs, Experiments and Easter Eggs
date: 2012-09-12 21:21
comments: true
categories: [Fun, Experiments, Programming]
author: db
---
At Artsy Engineering we encourage a culture of experimentation with something called *labs*.

A new feature released into production is usually only turned on for a handful of users. We get feedback from our own team and a tiny group of early adopters, iterate, fix bugs, toss failed experiments and work on promoting complete, well behaved features to all users. The labs infrastructure gives us a chance to sleep on an idea and polish details. It also allows us to make progress continuously and flip a switch on the very last day.

My favorite labs features push our collective imagination and give birth to productive brainstorms around coffee at a popular startup hangout around the corner from our Manhattan office. But the team's favorite labs are, by far, those that ship as easter eggs. These are fun and sometimes useful features that don't make much business sense. So, before I explain our rudimentary labs system, I want to invite you to our easter egg hunt. Check out [https://artsy.net/humans.txt](https://artsy.net/humans.txt) for instructions.

<!-- more -->

Our labs infrastructure is rather straightforward. A lab feature data model is pretty boring, with the exception of a `created_by` field. Each such lab feature belongs to an engineer and you have to nurture your feature and fight for it to meet the production bar!

``` ruby app/models/lab_feature.rb
class LabFeature
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :created_by
end
```

You can enable and disable a lab feature for a given user.

``` ruby app/models/user.rb
class User
  references_and_referenced_in_many :lab_features

  def enable_lab_feature!(feature)
    lab_features.push(feature) unless lab_features.member?(feature)
    save!
  end

  def disable_lab_feature!(feature)
    lab_features.delete(feature)
    save!
  end

  def lab_feature_enabled?(feature)
    lab_features.member?(feature)
  end
end
```

In Ruby, we check whether the user has a lab with `lab_feature_enabled?`. In JavaScript, we return the lab features in a Backbone.js collection and check for the same.

``` coffeescript app/coffeescripts/models/user.coffee
class App.Models.CurrentUser extends Backbone.Model

  hasLabFeature: (feature_name) ->
    $.inArray(feature_name, @get('lab_features')) >= 0

```

We also have a bit of UI and an API to let you turn a lab feature on and off when you're part of our labs program. The program itself is also a lab feature!

Lab features can be retired after the code is promoted to all users or deleted.

``` ruby app/models/lab_feature.rb
class LabFeature
  def retire!
    User.all.each do |u|
      u.disable_lab_feature!(self)
    end
    destroy
  end
end
```

This "system" is super simple. I encourage you to think more in terms of experiments or labs - it helped us foster a culture of innovation, tremendously reduced risk of catastrophic failures, and, because anyone can push anything into labs at any time, removed the unnecessary discussions around whether an idea is worthy of an implementation at all.
