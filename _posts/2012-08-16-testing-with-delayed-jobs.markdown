---
layout: post
title: Testing with Delayed Jobs
date: 2012-08-16 21:21
comments: true
categories: [RSpec, Testing, DelayedJob]
author: db
---
A mean bug made it into our production environment. It wasn't caught by our extensive test suite and caused thousands of emails to be sent to a handful of people. The root cause was an unfortunate combination of [Devise](https://github.com/plataformatec/devise), [DelayedJob](https://github.com/collectiveidea/delayed_job) and, of course, our own code. It was an easy fix, but nobody ever wants this to happen again.

tl;dr DelayedJob says it's possible to set `Delayed::Worker.delay_jobs = false` for your tests. Don't do it.

<!-- more -->

Consider the following `User` model that implements various Devise strategies which support some kind of notification.

``` ruby app/models/user.rb
class User
  include Mongoid::Document

  devise :database_authenticatable, :registerable, ...

  field :notified_at, type: DateTime
  after_save :notify!, :if => :notify?

  def notify!
    super
    update_attributes!({ notified_at: Time.now.utc })
  end
end

```
We are overriding a black box `notify!` method and updating an attribute with a timestamp of the last notification.

Let's write a test.

``` ruby spec/models/user_spec.rb
describe User do

  subject { User.new }

  context "notification" do

    it "sends one email" do
      expect {
        subject.notify!
      }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "updates notified_at" do
      expect {
        subject.notify!
      }.to change(subject, :notified_at)
    end

  end

end
```

All green. But once this code hit production, `notify!` was called in an infinite loop. How is that possible?

The call to `notify!` is delayed using DelayedJob in production and is not delayed in test. It does not work under DelayedJob and will create as many delayed notifications as it possibly can until it runs out of stack space.

As a common pattern in Devise, the implementation of `notify!` relies on an instance variable to signal that a notification has been sent. Setting the instance variable avoids sending the notification twice for multiple calls to `save!`. Our `after_save` callback invokes `update_attributes!`, which causes another `notify!` call unless `notify?` returns `false`. In a test, the call to `super` inside `notify!` will execute the notification (setting the instance variable), but will create a delayed job in production (without setting it).

We'll start by bringing our tests closer to a real production environment by leaving `Delayed::Worker.delay_jobs = true` and making sure our problem is reproduced with a spec. We could call `Delayed::Worker.new.work_off` for every test that needs to execute a delayed job, but that would be rather tedious. A better approach may be to register an observer that will execute a delayed job every time one is created. This is similar to a production environment where having enough delayed workers almost guarantees a job is picked up immediately after being scheduled.

``` ruby config/initializers/delayed_job_observer.rb
class DelayedJobObserver < Mongoid::Observer
  observe Delayed::Job

  class << self
    attr_accessor :runs
  end

  def after_create(delayed_job)
    delayed_job.invoke_job
    DelayedJobObserver.runs += 1
  end
end

DelayedJobObserver.runs = 0
```

The complete code, which handles a few more cases, including enabling and disabling the observer, and counting successful runs and errors can be found in [this gist](https://gist.github.com/3370052). Please help us improve it.

We can now test our notification without compromising on the delayed nature of the job and add a test making sure we create a single delayed job from a call to `notify!`.

``` ruby spec/models/user_spec.rb
describe User do

  subject { User.new }

  context "notification" do

    it "creates one delayed job" do
      expect {
        subject.notify!
      }.to change(DelayedJobObserver, :runs).by(1)
    end

  end

end
```

This test will also run for a long time before failing with a stack overflow error. Our fix was not to call `notify!` from an `after_save` callback.

We've suggested that immediate execution using an observer becomes a feature in DelayedJob in [#423](https://github.com/collectiveidea/delayed_job/issues/423). Please add your comments.
