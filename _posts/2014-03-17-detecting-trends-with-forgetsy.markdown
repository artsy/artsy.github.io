---
layout: post
title: "Detecting trends using Forgetsy"
date: 2014-03-17 11:32
comments: true
categories: [Ruby,Data,Redis]
author: anil
---

![Armory Trending Screen](/images/2014-03-17-detecting-trends-with-forgetsy/monolith.jpg)

As part of our partnership with [The New York Armory Show](https://www.thearmoryshow.com/) this year, we installed a number of terminals throughout the fair. These screens used our own real-time data to display an ever shifting set of trending artworks, artists, and booths, to the attendees.

Out of this work, we've open-sourced [Forgetsy](https://github.com/cavvia/forgetsy), a lightweight Ruby trending library. Put simply, Forgetsy implements data structures that forget. Loosely based on Bit.ly's [Forget Table](http://word.bitly.com/post/41284219720/forget-table) concept, Forgetsy uses decaying counters to track temporal trends in categorical distributions.

<!-- more -->

## Anatomy of a Trend

To clarify the term 'trend', let's take this graph of cumulative artist searches over time as an example.

![Artist Search Graphs](/images/2014-03-17-detecting-trends-with-forgetsy/searches.png)

On the left-hand side, we see a steepening gradient (denoted by the dashed lines) for Banksy during his residency in New York (Oct 2013), but in contrast a linear rise in searches for Warhol over the same period. We define a 'trend' as this rise in the _rate_ of observations of a particular event over a time period, which we'll call τ.

In Forgetsy, trends are encapsulated by a construct named _delta_. A _delta_ consists of two sets of counters, each of which implements [exponential decay](https://en.wikipedia.org/wiki/Exponential_decay) of the following form.

![Exponential Decay](http://latex.codecogs.com/gif.latex?X_t_1%3DX_t_0%5Ctimes%7Be%5E%7B-%5Clambda%5Ctimes%7Bt%7D%7D%7D)

Where the inverse of the decay rate (λ) is the lifetime of an observation in the set, τ. By normalising one set by a set with half the decay rate (or double the lifetime), we obtain a trending score for each category in a distribution. This score expresses the change in the rate of observations of a category over the lifetime of the set, as a proportion in the range [0,1].

Forgetsy removes the need for manually sliding time windows or explicitly maintaining rolling counts, as observations naturally decay away over time. It's designed for heavy writes and sparse reads, as it implements decay at read time. Each set is implemented as a [redis](http://redis.io/) sorted set, and keys are scrubbed when a count is decayed to near zero, providing storage efficiency.

As a result, Forgetsy handles distributions with up to around 10<sup>6</sup> active categories, receiving hundreds of writes per second, without much fuss.

## Usage

Take a social network in which users can follow each other. You want to track trending users. You construct a delta with a one week lifetime, to capture trends in your follows data over one week periods:

``` ruby
follows_delta = Forgetsy::Delta.create('user_follows', t: 1.week)
```

The delta consists of two sets of counters indexed by category identifiers. In this example, the identifiers will be user ids. One set decays over the mean lifetime specified by τ, and another set decays over double the lifetime.

You can now add observations to the delta, in the form of follow events. Each time a user follows another, you increment the followed user id. You can also do this retrospectively:

``` ruby
follows_delta.incr('UserFoo', date: 2.weeks.ago)
follows_delta.incr('UserBar', date: 10.days.ago)
follows_delta.incr('UserBar', date: 1.week.ago)
...
```

Providing an explicit date is useful if you are processing data asynchronously. You can also use the `incr_by` option to increment a counter in batches. You can now consult your follows delta to find your top trending users:

``` ruby
puts follows_delta.fetch
```

Will print:

``` ruby
{ 'UserFoo' => 0.789, 'UserBar' => 0.367 }
```

Each user is given a dimensionless score in the range [0,1] corresponding to the normalised follows delta over the time period. This expresses the proportion of follows gained by the user over the last week compared to double that lifetime.

Optionally fetch the top _n_ users, or an individual user's trending score:

``` ruby
follows_delta.fetch(n: 20)
follows_delta.fetch(bin: 'UserFoo')
```

For more information on usage, check out the [github project](https://github.com/cavvia/forgetsy) page.

## In the Wild

In practice, we use linear, weighted combinations of deltas to produce trending scores for any given domain, such as artists. Forgetsy doesn't provide a server, but we send events to an rpc service that updates the deltas in a streamed manner. These events might include artist follows, artwork favorites, auction lot sales or individual page views.

One requirement we have is lifetime flexibility. Forgetsy lets us stipulate the trending period τ on a delta by delta basis. This allows us to lower the lifetime significantly in a fair context, in which we track trends over just a few hours, contrasted with a general art market context, in which we're interested in trends over weeks and months.

In summary, the delta structures provided by Forgetsy provide you with a simple, scalable, transparent base for a trending algorithm that can be tuned to suit the specific dynamics of the domain in question.
