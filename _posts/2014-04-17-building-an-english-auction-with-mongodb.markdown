---
layout: post
title: Building an English Auction with MongoDB
date: 2014-04-17 12:21
comments: true
categories: [Ruby,Auctions,Bidding,MongoDB]
author: db
---

Artsy ran several successful auctions over the past few months. The first, [TWO x TWO](https://artsy.net/feature/two-x-two), raised hundreds of thousands of dollars for amfAR (the AIDS Research foundation), and the Dallas Museum of Art. It was followed by [Independent Curators International](https://artsy.net/feature/ici-benefit-auction), at which Artsy launched on-site auction projection screens, which displayed competing bids coming in online from places around the world, like Oslo and Santa Monica, in realtime. Users could place bids on the website, via the iPhone app or with one of the Artsy representatives in the room carrying an iPad.  All the auction lots sold, and Artsy helped ICI to raise 50% more than its target revenue goal. Other, recent Artsy auctions include [Public Art Fund](https://artsy.net/feature/public-art-fund-2014-spring-benefit) and the [Brooklyn Artists Ball](https://artsy.net/feature/brooklyn-artists-ball), benefitting the Brooklyn Museum.

![ICI Auction: Live](/images/2014-04-17-implementing-bidding-in-an-english-auction-with-mongodb/ici-live-auction.jpg)

The domain of auctions is a fascinating one, and includes everything from buying items on eBay to trading livestock and selling investment products on the stock exchange. For those interested in the large spectrum of auctions I highly recommend [Auctions and bidding: A guide for computer
scientists](http://www.sci.brooklyn.cuny.edu/~parsons/projects/mech-design/publications/bluffers-final.pdf) by Simon Parsons (CUNY), Juan A. Rodriguez-Aguilar (CSIC) and Mark Klein (MIT).

At Artsy we implemented a classic English auction with, so called, "book bids". I spent a fair amount of time visiting engineering teams that have built internet auctions, most of which were transactional systems where taking a position on an item involved starting a transaction, running an auction round and committing the changes. In contrast, we chose to deliver a simpler, eventually consistent system on top of MongoDB, in which all data is immutable and where some level of serialization occurs within a single background process.

In this post we'll go over some data modeling and examine the auction engine implementation details.

<!-- more -->

### Data Modeling

In the Artsy platform, an *Auction* is an specialization of a more general concept of a *Sale*. A sale typically has an opening and a closing date, during which bidding or purchases can occur. We create a relationship between an artwork and a sale, which, in the case of an auction, includes the opening bid amount. We store all money in cents, and assume the currency to be USD, making it easy to extend the system for other currencies in the future.

``` ruby
class SaleArtwork
  include Mongoid::Document

  field :opening_bid_cents, type: Integer

  belongs_to :artwork, inverse_of: nil
  belongs_to :sale

  belongs_to :highest_bid, class_name: "Bid", inverse_of: nil

  # Minimum next acceptable bid amount, in cents.
  def minimum_next_bid_cents
    return opening_bid_cents if highest_bid.nil? && opening_bid_cents.present?
    # calculate using a bid incrementing strategy ...
  end
end
```

A user registers to bid and creates a *Bidder* record.

``` ruby
class Bidder
  include Mongoid::Document

  belongs_to :user
  belongs_to :sale

  has_many :positions, class_name: 'BidderPosition', inverse_of: :bidder
end
```

This doesn't just mimic the real world where bidding typically requires registration - the bidder record doesn't belong to the user and contains essential data to identify an individual that is placing a bid. It also solves a very peculiar problem where a user decides to delete their account mid-auction. Finally, a bidder could eventually delegate bidding to an agent through this model's permissions.

A bidder doesn't actually place any bids, but create a *Bidder Position*, which indicates the highest amount they are willing to pay for a given artwork.

``` ruby
class BidderPosition
  include Mongoid::Document

  field :active, type: Boolean, default: true
  field :max_bid_amount_cents, type: Integer

  belongs_to :bidder, class_name: 'Bidder', inverse_of: :positions
  belongs_to :sale_artwork
  has_many :bids, inverse_of: :position

  scope :active, where(active: true).asc(:max_bid_amount_cents)
end
```

This is called a "book bid" - before technology took over the auctions world buyers delegated an agent to bid on their behalf after giving them a maximum amount they were willing to part with. Bidder positions belong to a bidder and to the artwork-to-sale relationship. They cannot be changed - if a user wants to increase his maximum bid, he simply creates a new bidder position.

### Bidding Round

Every time a bidder position is created, a *Bidding Round* is queued for the item being bid on. We can parallelize execution of these by artwork, however all bidding rounds for the same artwork are serialized.

``` ruby
class EnglishAuction
  # Run multiple rounds of bidding for the given lot, to rest. Return number of bids generated.
  def self.run!(sale_artwork)
    return 0 unless sale_artwork.sale && sale_artwork.sale.biddable?

    round = EnglishAuction::Round.new(sale_artwork)
    round.run!

    round.bids_generated.size
  end
end
```

A bidding round iterates over all active bidder positions in ascending order by dollar value, outbids any bidders below the max bid, and places new bids, as necessary. The entire round algorithm is below.

``` ruby
# A bidding round for an English auction.
class Round
  attr_accessor :bids_generated

  # @param sale_artwork A relationship between an artwork and a sale.
  def initialize(sale_artwork)
    @sale_artwork = sale_artwork
    @bids_generated = []
  end

  # Run multiple rounds of bidding, to rest.
  def run!
    while (bids = process_more_bids!).any? do
      @bids_generated += bids
    end
  end

  # Run one round of bidding. Return bids.
  def process_more_bids!
    @sale_artwork.bidder_positions.active.map do |bidder_position|
      process_bidder_position!(bidder_position)
    end.compact
  end

  # Process a single bid position.
  # @returns Generated bid, if any.
  def process_bidder_position!(bidder_position)

    # ignore if current position is highest
    return nil if bidder_position == @sale_artwork.highest_bid.try(:position)

    # ignore if bidder is already highest
    return nil if bidder_position.bidder == @sale_artwork.highest_bid.try(:position).try(:bidder)

    # close if below opening bid
    if bidder_position.max_bid_amount_cents < (@sale_artwork.opening_bid_cents || 1)
      bidder_position.deactivate! "Bid must be greater than the minimum bid of #{@sale_artwork.opening_bid_cents}."
      return nil
    end

    amount_cents = @sale_artwork.minimum_next_bid_cents # opening bid or an increment thereafter

    if bidder_position.max_bid_amount_cents < amount_cents
      highest_bid_amount = @sale_artwork.highest_bid.try(:amount_cents) || 0

      # if max is between current and increment (or if it's at current, but earlier), bid max anyway
      # this means that a bidder who placed an identical max bid earlier becomes the highest bidder
      if bidder_position.max_bid_amount_cents > highest_bid_amount ||
        (bidder_position.max_bid_amount_cents == highest_bid_amount && bidder_position.id < @sale_artwork.highest_bid.position.id)
        amount_cents = bidder_position.max_bid_amount_cents
      else
        # outbid, next bid must be at least amount_cents
        bidder_position.update_attributes! active: false
        return nil
      end
    end

    # place a bid
    bidder_position.bids.create!(attrs).tap do |bid|
      @sale_artwork.update_attributes! highest_bid: bid
    end
  end
end
```

One of the interesting aspects of this system is what happens when two users create two identical bidder positions - the earlier one wins and the later one is outbid. In a transactional system we could produce an error message to the second bidder before the position is even created.

### Bidder Notifications

Notifying upon being "outbid" is straightforward, because a position only enters that state once, but notifying bidders of when they are the current high bidder or when their bid has been increased is trickier. We don't want to generate notifications every time a bid is made (i.e., it's the current high). Rather, we want to allow the round to reach a stable state at which there's only a single active position and then notify the current high and outbid bidders. This happens after each `round.run!`.

### Beyond Bidding

Aside of the bidding implementation we've built a whole software ecosystem around auctions. We developed a backend system to manage these. We put up projection screens at the event that list works being auctioned and flash every time a bid is placed. We register users' credit cards and collect their money.

The software part, however, is definitely dwarfed by the amount of logistics and people involved in making one of those auctions a success. We're only trying to make that a bit more efficient. We'll see you at the upcoming BAM Art Auction, SFMOMA Modern Ball or the Whitney Museum Art Party!
