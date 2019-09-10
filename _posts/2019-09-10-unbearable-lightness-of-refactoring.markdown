---
layout: epic
title: "Unbearable Lightness of Refactoring"
date: "2019-09-10"
author: [ashkan]
categories: [refactoring, community, culture]
comment_id: 522
---

As engineers we are constantly in the process of building new features and improve our existing ones. Nowadays, with the help of tools and processes like code reviews one could argue the quality of the codes being written has risen. At Artsy a pull request normally has one Assignee and possibly one or more Reviewers, so why we still do lot of refactoring?

> There is no means of testing which decision is better, because there is no basis for comparison. We live everything as it comes, without warning, like an actor going on cold. And what can life be worth if the first rehearsal for life is life itself?

― Milan Kundera, [The Unbearable Lightness of Being](https://en.wikipedia.org/wiki/The_Unbearable_Lightness_of_Being)

Part of me wants to end this blogpost by Kundra’s quote, but for now lets get deeper.

<!-- more -->

## "The Refactor"
Recently we've started adding SCA (Strong Customer Authentication) support to one of our services. This service is relatively young in our stack and very well revieiwed. While the original code and approach looked nice and simple, as this service naturally grew and we started adding more logic to it, things got more and more complicated. During SCA support efforts, we realized its time to refactor. The code I was trying to refactor was less than a year old and originally written, well... by me!

Should I be worried? embarrased? well, not really. As engineers when we build things we tend to look at current state of affairs, we attempt to predict the future as much as possible but future is always changing, moving. SCA feature we were about to add to our existing logic wasn't a requirement a year ago, a year ago I did not know what SCA is, im still not 100% sure but thats the beauty of our job. So first thing, never be embarrased about refactoring, you are still sane and just excerising a healthy engineering practice.

Back to refactoring, we ended up having some discussions about how to improve are already complicated logic in a way that easily supports future updates. We started by looking at our existing logic, trying to separate different steps that an order has to go through to fully get submitted and try to simplify it. We went through pros and cons of each approach. While pretty much all of our solutions would have some cons, we managed to find our best option and started refactoring. We basically went from:

```ruby
order.submit! do
  order.line_items.each { |li| li.update!(commission_fee_cents: li.current_commission_fee_cents) }
  totals = BuyOrderTotals.new(order)
  order.update!(
   # set totals
  )
  order_processor.hold!
  raise Errors::InsufficientInventoryError if order_processor.failed_inventory?
  # in case of failed transaction, we need to rollback this block,
  # but still need to add transaction, so we raise an ActiveRecord::Rollback
  raise ActiveRecord::Rollback if order_processor.failed_payment? || order_processor.requires_action?

  order.update!(
    # set payment
  )
  order.transactions << order_processor.transaction
  PostTransactionNotificationJob.perform_later(order_processor.transaction.id, user_id)
  raise Errors::FailedTransactionError.new(:charge_authorization_failed, order_processor.transaction) if order_processor.failed_payment?
  if order_processor.requires_action?
    # because of an issue with `ActiveRecord::Rollback` we have to force a reload here
    # rollback does not clean the model and calling update on it will raise error
    order.reload.update!(external_charge_id: order_processor.transaction.external_id)
    Exchange.dogstatsd.increment '******'
    raise Errors::PaymentRequiresActionError, order_processor.action_data
  end
end
```

to

```ruby
order_processor = OrderProcessor.new(order, user_id)
raise Errors::ValidationError, order_processor.validation_error unless order_processor.valid?

order_processor.advance_state(:submit!)
unless order_processor.deduct_inventory
  order_processor.revert!
  raise Errors::InsufficientInventoryError
end

order_processor.set_totals!
order_processor.hold
order_processor.store_transaction

if order_processor.failed_payment?
  order_processor.revert!
  raise Errors::FailedTransactionError.new(:charge_authorization_failed, order_processor.transaction)
elsif order_processor.requires_action?
  order_processor.revert!
  Exchange.dogstatsd.increment '******'
  raise Errors::PaymentRequiresActionError, order_processor.action_data
end
order_processor.on_success
```
Well, this at least is lot more readable.

Next question is how to get this to production, we tried to isolate this specific refacotring by:

* Open a PR that only focuses on our refactoring
* Make sure in the PR above we don't touch any API level tests and make sure all these tests still pass. This would give us more confident that we are not impacting our exsiting clients.
* Review and merge refactoring PR and test on staging.
* Deploy everything in current pipeline to isolate the refactor deploy.
* Deploy the refactoring PR to production.

## How Did It Go?

This plan worked for us, for the most part. We ended up rollback the Deploy since we found a bug in production in a non-API part of our app. We eventually fixed that bug and got the fix to production in follow up deploys. Off of this issue we learned that even if we already have tests written in different layers of our app, we still need to verify them and make sure they cover all cases. Basically we relied too much on existing tests which is not always a good decision.

## Our learnings
- Don't be afraid of refactors. They are natural and one of the healthy engineering tools and practices.
- Isolate the refactor PRs to pure refactor related changes and avoid change business logic. Business logic changes can always be follow up PRs.
- Don't only rely on existing tests. Refactoring is great opportunity to review and verify your tests. Verify them and make sure they cover all scenarios.

Curious about the PR? At Artsy we beleive in Open Source By Default, so checkout the [PR](https://github.com/artsy/exchange/pull/475/files)
