---
layout: epic
title: Art + Feminism and Artsy Wikipedia/Wikidata Editathon
date: 2017-07-06
categories: [Technology, emission, reaction, react-native, react, javascript]
author: orta
---

Artsy has always had a focus on Arts meet Science, and we [hosted a meet-up last weekend][meetup-msg] that really hits on both. We had a collection of Artsy Staff, members of [Art + Feminism][afem] NYC, the CocoaPods Peer Lab and volunteers from Wikimedia all helping.


We came with two aims:

* Help anyone interested in contributing to Wikipedia get started.
* Use [The Art Genome Project][tagp](TAGP) to improve Wikidata entries for female Artists.

I helped out with the second part, and the rest of this post will be about the lessons learned during this [editathon][].

<!-- more -->

# What is Wikidata?

Everyone knows Wikipedia, but less people know about [Wikidata][]. I learned about it in the process of helping set up this meetup. Wikidata is a structured document store for generic items. The lexicon of keys that can go into a document are handled by community consensus.

For example let's take the artist: Ana Mendieta ([artsy.net/artist/ana-mendieta][am]) in (truncated) [JSON representation][ana-json] inside Wikidata:

```json
{

  // General database metadata 
  "pageid": 437301,
  "ns": 0,
  "title": "Q463639",
  "lastrevid": 517662334,
  "modified": "2017-07-11T12:30:29Z",
  "type": "item",
  "id": "Q463639",

  // What is the name of this item in the db, in multiple languages
  "labels": {
    [...]
    "ru": {
      "language": "ru",
      "value": "Мендьета, Ана"
    },
    "en": {
      "language": "en",
      "value": "Ana Mendieta"
    },
    [...]
    "he": {
      "language": "he",
      "value": "אנה מנדייטה"
    },
    [...]
  },

  // How do you describe the item per language
  "descriptions": {
    "es": {
      "language": "es",
      "value": "artista cubanoestadounidense"
    },
    "de": {
      "language": "de",
      "value": "US-amerikanische Perfomancekünstlerin"
    },
    "en": {
      "language": "en",
      "value": "American artist"
    },
   [...]
  },

  // How does this item connect to other parts of the system
  "claims": {
    [...]

    // This is https://www.wikidata.org/wiki/Property:P2042
    // Aka: The Artsy Artist ID
    "P2042": [
      {
        "mainsnak": {
          "snaktype": "value",
          "property": "P2042",
          "datavalue": {

            // The slug on the Artsy app/site
            "value": "ana-mendieta",
            "type": "string"
          },
          "datatype": "external-id"
        },
        "type": "statement",
        "id": "Q463639$67B7BA7A-D008-4EB9-BDE6-909ED82DE72A",
        "rank": "normal"
      }
    ],
    [...]
    "P3630": [
      {
        "mainsnak": {
          "snaktype": "value",
          "property": "P3630",
          "datavalue": {
            "value": "321458",
            "type": "string"
          },
          "datatype": "external-id"
        },
        "type": "statement",
        "id": "Q463639$6D91AE1F-6552-432C-948D-D5CEB834E77C",
        "rank": "normal"
      }
    ]
  },

  // Internal links to this document
  "sitelinks": {
    "cawiki": {
      "site": "cawiki",
      "title": "Ana Mendieta",
      "badges": [],
      "url": "https://ca.wikipedia.org/wiki/Ana_Mendieta"
    },
    "cswiki": {
      "site": "cswiki",
      "title": "Ana Mendieta",
      "badges": [],
      "url": "https://cs.wikipedia.org/wiki/Ana_Mendieta"
    },
    [...]
  }
}
```

Lucky for this editathon, both [Artsy Artist ID][artist-id], and [TAGP ID][tagp-id] were already inside the controlled vocabulary. This mean we could think about how to connect items rather than how we can pitch that is worth connecting them at all.


[meetup-msg]: https://www.meetup.com/CocoaPods-NYC/messages/boards/thread/50940969
[afem]: http://www.artandfeminism.org
[tagp]: https://www.artsy.net/categories
[am]: https://www.artsy.net/artist/ana-mendieta
[ana-json]: https://www.wikidata.org/wiki/Special:EntityData/Q463639.json
[editathon]: https://en.wikipedia.org/wiki/Edit-a-thon
[artist-id]: https://www.wikidata.org/wiki/Property:P2042
[tagp-id]: https://www.wikidata.org/wiki/Property:P2411
[Wikidata]: https://www.wikidata.org/wiki/Wikidata:Main_Page
