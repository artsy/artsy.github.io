---
layout: post
title: "Generating Notifications and Personalized Emails Efficiently"
date: 2014-04-24 16:00
comments: true
categories: [Ruby, Email, CSS, HTML]
author: matt
---

We recently launched a new personalized email here at [Artsy](https://artsy.net) that features content that a given user might find interesting. The goal of this post is to describe how we built a backend system that efficiently generates these e-mails for all our users. I'll talk about the first, naive implementation that had performance problems right away, and how the second implementation (currently in production) solved those issues, and whose behavior at scale is well-defined and understood. I won't go into the details of the design and layout of the mail itself and how we render the content - there are several earlier blog posts that deal with those: [Presenters and Memoization](http://artsy.github.io/blog/2014/03/18/presenters-and-memoization-moving-logic-out-of-templates/), [Pinterest-style Layouts](http://artsy.github.io/blog/2014/03/17/ruby-helper-to-group-artworks-into-a-pinterest-style-layout-for-email/) and [Email Layouts and Responsiveness](http://artsy.github.io/blog/2014/03/17/some-tips-for-email-layout-and-responsiveness/).

![Personalized Email Example](/images/2014-04-24-generating-notifications-and-personalized-emails-efficiently/percy_example.png)

<!-- more -->

### Deciding What Content to Include

First, we had to decide what types of personalized content we wanted to feature in our mails. Users can follow artists and galleries, and so this seemed like a great place to start. We'd like to let you know about new artworks that have been uploaded by artists that you follow, as well as new shows that have been added by galleries you follow, or that are exhibiting artists you follow. Since we have location data for our galleries and our users (accomplished thru an onboarding flow, or thru geo-locating their IP address), we also want to include new shows that are opening near you. Additionally, we have a recommendations engine that recommends artworks to users based on their preferences and activity on the site, and we'd like to show some of the latest and best of such recommendations.

### Initial Implementation Ideas

My first thought was to have an observer (really just some ```after_save``` callbacks) that will wait for data to get into a state where a user can be validly notified, and in a background task write these notifications to interested users. Here's how the base setup of our ```Notification``` model looked:

``` ruby
class Notification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :notifiable, polymorphic: true, inverse_of: :notifications
end
```

It's a simple join of the user and the ```notifiable``` (the object/action that a user is being notified about).

Then, a specific notification (such as one for published artworks by artists you follow) can inherit from this and look like:

``` ruby
class PublishedArtworkNotification < Notification
  def self.notify!(artwork_id)
    user_ids = FollowArtist.where(artist: artwork.artist).pluck("user_id")
    user_ids.each_slice(100) do |uids|
      PublishedArtworkNotification.delay(queue: :any, priority: 6).create_for_users(artwork_id, uids)
    end
  end

  def self.create_for_users(artwork, uids)
    uids.each do |uid|
      PublishedArtworkNotification.create!(user_id: uid, notifiable_id: artwork_id, notifiable_type: 'Artwork')
    end
  end
end
```

Then, the ```after_save``` hook on an ```Artwork``` model is:

``` ruby
def delay_notify
  PublishedArtworkNotification.delay(queue: :any).notify!(self.id) if self.published_changed? && self.published
end
```

So, when an artwork is published, we run ```notify!``` in the background for the respective notification. That method will pull all interested users (via following the artist), and then spawn off more background processes to write the notifications in batches of 100. We batched these writes to avoid any one background process taking too long (an artist such as [Andy Warhol](https://artsy.net/artist/andy-warhol) has around twelve thousand followers currently), and also ran them at a lower priority to avoid blocking other jobs in our queue.

The other types of notifications were all implemented similarly (via an observer on the model, and a specific ```Notification``` class inheriting from the base class). We also added some other logic into the base ```Notification``` class such as some uniqueness constraints, as well as an ability to mark notifications as 'sent' or 'invalid'. However, we ran into serious performance/scaling issues fairly quickly, and had to re-implement this scheme.

### Performance Bottlenecks

All of these records were being written to one collection in [MongoDB](https://www.mongodb.org/), and the size of this collection grew quite rapidly. It's size almost immediately dwarfed the size of any of our other collections, and the number of records quickly reached into the tens of millions. This led to problems: writing new notifications started to crawl to a standstill. We had several indices on this collection to aid in querying, and these made the insertion of new notifications very non-performant, and also started to affect overall database performance. Querying against this collection degraded quickly and started to similarly affect database performance. Archiving old records also proved next to impossible. We couldn't simply drop the entire collection, but had to prune records. This similarly was totally non-performant and was adversely affecting database and site performance. We needed to come up with a new implementation for ```Notification```, and addressing these issues was essential.

### Resolving Performance Bottlenecks

So, we decided on a scheme where each day would result in a new ```Notifications``` collection (name keyed on the date), named ```notifications_20140101```, ```notifications_20140102```, etc. Each of these collections would have an ```_id``` field that corresponds to a user_id, and an ```events``` array (or 'stack' if you will) that records the id's of notified objects, as well as the type of notification. An example of a record in that collection is:

``` json
{"_id"=>"5106b619f56337db300001f8",
 "events"=>[{"t"=>"NearbyShow", "o"=>"533998b1c9dc24c371000041"},
            {"t"=>"NearbyShow", "o"=>"5345774cc9dc246d580003d0"},
            {"t"=>"NearbyShow", "o"=>"5335af4fa09a67145300028c"},
            {"t"=>"NearbyShow", "o"=>"533f1174a09a67298900007b"},
            {"t"=>"ArtworkPublished", "o"=>"5334647b139b2165160000d8"}]
}
```

So, here we see all of my notifications for April 22, 2014. On that day, I was notified about 4 shows opening near my location, and one artwork added by an artist I follow. Incidentally, that artwork was a piece by [Rob Wynne](https://artsy.net/artist/rob-wynne) entitled [You're Dreaming](https://artsy.net/artwork/rob-wynne-youre-dreaming). The show notifications were for NYC-area shows opening at [Klein Sun Gallery](https://artsy.net/klein-sun-gallery), [Garis & Hahn](https://artsy.net/garis-and-hahn), [Miyako Yoshinaga Gallery](https://artsy.net/miyako-yoshinaga-gallery) and [DODGEgallery](https://artsy.net/dodgegallery).

A couple of nice things about this implementation is it limits the size of a collection: any one day's collection will scale directly with the number of users, which seems reasonable. Our earlier implementation scaled with the product of the number of users and amount of content on Artsy, which is clearly problematic. Also, archiving old notifications is as simple as dropping a particular day's collection, which is very performant. However, querying and assembling these notifications is a bit trickier than in the naive implementation, as well as marking which events have already been sent to a user, so as to avoid duplicating any content in between mailings.

Let's see how we rewrite the notification generation in this scheme:

``` ruby
module NotificationService

  def self.notify_many!(user_ids, object_id, type)
    events = events_from(object_id, type)
    user_ids.each do |user_id|
      notify_with_events(user_id, events)
    end
  end

  private

  def self.notify_with_events(user_id, events)
    collection.find(_id: user_id).upsert('$push' => { events: { '$each' => events } })
  end

  def self.events_from(object_ids, type)
    Array(object_ids).map do |object_id|
      {
        't' => type,
        'o' => object_id
      }
    end
  end

  # collection storing notifications for the given day
  def self.collection(date = Date.today)
    Mongoid.default_session.with(safe: false)[collection_name(date)]
  end

  def self.collection_name(date)
    "notifications_#{date.to_s(:number)}"
  end

end
```

Here's how the ```after_save``` callback looks now:

``` ruby
def notify_published
  NotificationService.notify_many!(user_ids, self, 'ArtworkPublished') if self.published_changed? && self.published
end
```

Let's take a look at what's going on here. When an artwork is published, we call ```notify_many!``` in the ```NotificationService``` module. That will determine the correct collection (keyed by the date) using the ```collection``` and ```collection_name``` helpers. We build our events stack with the ```events_from``` helper, and then do an ```upsert``` with a ```$push``` to either insert or update that user's events for that day. Due to the fast performance of this scheme, we also no longer have to batch notification creation. As a sample benchmark, writing this type of notification to our [Warhol](https://artsy.net/artist/andy-warhol) followers takes under 15 seconds.

Ok, so we seem to have solved some of our issues: namely writing and archiving notifications is performant, and we understand the behavior of these collections as the number of users and content on the site grows. Now let's look at how we can query against this scheme in an efficient manner, and also how we can mark events as 'seen' to avoid emailing out duplicates.

### Marking Notifications as Flushed and Retrieving Notifications

We decided to push a ```flushed``` event onto the user's stack after we send out notifications, and analogously, when we are querying a user's notifications, we want to throw away notifications that occur before a ```flushed``` event. Here's that method, in our ```NotificationService``` module:

``` ruby
# Mark all events until this point "seen." Pushes a {flushed: <id>}
# hash on to events array.
def self.flush!(user_id, since = Date.today - 7.days)
  flushed = { 'flushed' => Moped::BSON::ObjectId.new }
  collections_since(since).each do |coll|
    coll.find(_id: user_id).update('$push' => { events: flushed })
  end
  flushed  # return "id" of flushed marker, in case useful later
end

private

def self.collections_since(date)
  (date..Date.today).map { |d| collection(d) }
end
```

Pretty simple. We push the appropriate event onto every collection that was under consideration via the ```collections_since``` helper. When we send out a personalized email we accumulate the last 7 day's worth of activity for you, and so after we generate/send a mail for a user, we can simply say ```NotificationService.flush!(user)```. Here's how that day's notifications for me looks after the ```flushed``` event:

``` json
  {"_id"=>"5106b619f56337db300001f8",
   "events"=>[{"t"=>"NearbyShow", "o"=>"5338504e139b21f2a9000362"},
              {"t"=>"FollowedArtistShow", "o"=>"533ddba3a09a6764f60006b6"}, {"t"=>"NearbyShow", "o"=>"533ddba3a09a6764f60006b6"},
              {"flushed"=>"5352b346b504f5f3690002fe"}]
  }
```

For the last piece of the puzzle, let's look at how we query against this scheme and compile together all notifications that are applicable for a given user:

``` ruby
module NotificationService
  NOTIFICATION_TYPES = {
    'FollowedArtistShow' => PartnerShow,
    'FollowedPartnerShow' => PartnerShow,
    'NearbyShow' => PartnerShow,
    'ArtworkPublished' => Artwork,
    'ArtworkSuggested' => Artwork
  }

  class Notification < Struct.new(:type, :object_id)
    def object
      @object ||= NOTIFICATION_TYPES[type].find(object_id)
    end

    def applicable?
      object.try(:notifiable?) || false
    end
  end

# Return applicable notifications for user since given date.
def self.get(user_id, since = Date.today - 7.days)
  collections_since(since)
    .map { |coll| coll.find(_id: user_id).one }.compact
    .flat_map { |doc| doc['events'].slice_before { |ev| ev['flushed'] }.to_a.last }
    .reject { |ev| ev['flushed'] }.uniq
    .map { |ev| Notification.new(ev['t'], ev['o']) }.select(&:applicable?)
end
```

We introduce a lite-weight ```Notification``` class that will load the object, as well as perform an additional check. We use the previously introduced ```collections_since``` helper to retrieve all the notification collections under consideration. We query each and build up an array of all events from a user's stack. We remove events that occurred prior to a ```flushed``` event in a given collection and the ```flushed``` events themselves. Then we actually load all the objects and return the ones that are still ```applicable?```. That final ```applicable?``` check is to allow us to filter out content at run-time that is no longer valid. For example, if an artwork is published and the correct event is written out to users, but before the user can be notified the artwork is unpublished, this can serve as a run-time check to not include that work. ```def notifiable?``` can thus be implemented in the ```Artwork``` model like so:

``` ruby
def notifiable?
  published?
end
```

And...that's basically it! Throughout the week as partners are uploading their shows/fair booths/artworks, these records are being opportunistically written to that day's notification collection, in a performant and scalable fashion. Then when we want to send you a personalized email, we pull all your appropriate notifications via the ```get``` routine in our ```NotificationService```, and primarily using the technique described in [Presenters and Memoization](http://artsy.github.io/blog/2014/03/18/presenters-and-memoization-moving-logic-out-of-templates/) we make sure we cache/memoize all such data. Using the tips in [Pinterest-style Layouts](http://artsy.github.io/blog/2014/03/17/ruby-helper-to-group-artworks-into-a-pinterest-style-layout-for-email/) and [Email Layouts and Responsiveness](http://artsy.github.io/blog/2014/03/17/some-tips-for-email-layout-and-responsiveness/) we can render this content and support various devices/email clients. We parallelize and batch the generation/sending of our e-mails as well. This whole system, from notification generation to actually emailing users, is running successfully and smoothly in production.

### Next Steps

I think this type of infrastructure can easily be adapted to serve as a feed on a front-end or other client app. An API to serve up these notifications (AKA feed items) can be built and different feed items can then be rendered or aggregated at load-time. Simple client-side polling can even be set up to alert a user if something has happened that interests them _while_ they're browsing! I think push notifications and other messaging can be handled by this system as well.

I'd love to hear any feedback and thoughts, and hopefully you've found this post informative and interesting. Please leave any feedback in the comments and [follow us on Github](https://github.com/artsy)!
