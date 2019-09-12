---
layout: epic
title: "Unbearable Lightness of Refactoring"
date: "2019-09-10"
author: [ashkan]
categories: [refactoring, community, culture]
comment_id: 588
---

As engineers we are constantly in the process of building new features and improving our existing ones. Nowadays, with the help of tools and processes like code reviews one could argue the quality of the code being written has risen. At Artsy a pull request normally has one Assignee and possibly one or more Reviewers, so why do we still do a lot of refactoring?

> There is no means of testing which decision is better, because there is no basis for comparison. We live everything as it comes, without warning, like an actor going on cold. And what can life be worth if the first rehearsal for life is life itself?
>
>― Milan Kundera, [The Unbearable Lightness of Being](https://en.wikipedia.org/wiki/The_Unbearable_Lightness_of_Being)

Part of me wants to end this blogpost by Kundra’s quote, but for now let's get deeper.

<!-- more -->

## "The Refactor"
Recently we've started adding [Strong Customer Authentication (SCA)](https://stripe.com/docs/strong-customer-authentication) support to one of our services. This service is relatively young in our stack and very well-reviewed. While the original code and approach looked nice and simple, as this service naturally grew and we started adding more logic to it, things got more and more complicated. During SCA support efforts, we realized it's time to refactor. The code I was trying to refactor was less than a year old and [originally written, well... by me](https://twitter.com/davidwalshblog/status/953663412013293569)!

Should I be worried? Embarrassed? Well, not really. As engineers, when we build things we tend to look at current state of affairs, and we attempt to predict the future as much as possible. But the future is always changing, moving. SCA feature we were about to add to our existing logic weren't a requirement a year ago (a year ago I didn't know what SCA was). So first thing, **never be embarrassed about refactoring**, because the thing you're working on is often entirely unknown and you can't expect to get something unknown totally right the first time around. Looked at it in this light, refactoring is healthy.

### Lets Get More Specific

Back to our SCA change, we ended up having some discussions about how to improve our already complicated logic in a way that easily supports future updates. We started by trying to separate the different steps that an order has to go through to fully get submitted and try to simplify it, weighing the pros and cons of each approach. While pretty much all of our solutions would have some disadvantages, we managed to find our best option and started refactoring. Without getting too technical, lets look at the actual change.

```ruby
## before refactor
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

In the original solution, we wrapped all of our changes in a database transaction within `order.submit!` to have a lock on that record. This was all good since we would ensure data integrity provided by database transaction. This way we ensure updates to `order` and `line_items` happen only in case of success. A failure in this block would rollback all changes which is good 👍

But things got complicated once some of the changes in the block _should_ have been preserved, even in case of rollback. Specifically we want to make sure a `transaction` is stored on the `order` if it payment fails or requires action.
We found out that we can use `raise ActiveRecord::Rollback` which is a specific exception in Rails that only bubbles up in the surrounding transaction and does not get thrown outside of the block. This already makes things super complicated.

In order to make our code less complicated, we did a few things:

* We delegated more responsibility to a service class,`OrderProcessor`.
* Instead of wrapping all code in one transaction, we now optimistically `submit` the order at the beginning and in case anything went wrong, we revert the changes.

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
Well, this at least is a lot more readable.


### Get The Change to Production

The next question is how to get this to production. We tried to isolate this specific refactoring by:

* Open a PR that only focuses on our refactoring
* Make sure in the PR above we don't touch any API level tests and make sure all these tests still pass. This would give us more confidence that we are not impacting our existing clients.
* Review and merge refactoring PR and test on staging.
* Deploy everything in current pipeline to isolate the refactor deploy.
* Deploy the refactoring PR to production.

## How Did It Go?

This plan worked for us, for the most part. We ended up having to rollback the deploy since we found a bug in a non-API part of our app. From this we learned that even if we already have tests written in different layers of our app, we still need to verify them and make sure they cover all cases. Relying too much on existing tests can often lead to trouble -- verify!

## Our learnings
- Don't be afraid of refactors. They are natural and a healthy engineering tool / practice.
- Ensure that refactor PR's only include refactor-related changes. It's often tempting to fix other things along the way, but those fixes can take place in follow-up PRs.
- Don't rely only on existing tests. Refactoring is a great opportunity to review and verify your tests. Verify them and make sure they cover all scenarios.

Curious about the PR? At Artsy we believe in [Open Source By Default](https://github.com/artsy/README/blob/master/culture/engineering-principles.md#open-source-by-default), so check out the code [here](https://github.com/artsy/exchange/pull/475/files).
