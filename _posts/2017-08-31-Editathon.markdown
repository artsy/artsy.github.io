---
layout: epic
title: Art + Feminism and Artsy Wikipedia/Wikidata Editathon
date: 2017-08-31
categories: [writing, culture, workshop]
css: editathon
author: [orta, roop]
---

Artsy has always had a focus on Art meets Science, and we [hosted a meet-up in July][meetup-msg] that really hits on both. We had a collection of Artsy Staff, members of [Art + Feminism][afem] NYC, the [CocoaPods Peer Lab][peer-lab], [New York Arts Practicum][nyap] and volunteers from [Wikimedia NYC][wikinyc] all helping out.

We came with two aims:

* Help anyone interested in contributing to Wikipedia get started.
* Use [The Art Genome Project][tagp](TAGP) to improve Wikidata entries for women Artists.

I helped out with the second part, and the rest of this post will be about the lessons learned during this [editathon][].

<!-- more -->

# What is Wikidata?

Everyone knows Wikipedia, but fewer people know about [Wikidata][]. We learned about it in the process of helping set up this meetup. Wikidata is a structured document store for generic items. The lexicon of keys that can go into a document are handled by community consensus.

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

    // This is used in our example below
    "P27": [
      {
        "id": "Q463639$5B578566-EEC7-45F9-9007-612E98CA2D59",
        "mainsnak": {
          "datatype": "wikibase-item",
          "datavalue": {
            "type": "wikibase-entityid",
            "value": {
              "entity-type": "item",
              "id": "Q30",
              "numeric-id": 30
            }
          },
          "property": "P27",
          "snaktype": "value"
        },
        "rank": "normal",
        "type": "statement"
      }
    ],
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

The database is created with the the notion of "[semantic triples][triple]", which was new to us.
The idea being that each `Item` (corresponding to a Q id (`Q463639`)) has a bunch of associated `Statements` via `Properties` in the form:

> subject — predicate — object

Which means…

> `<this thing>` `<has some relationship to>` `<that thing>`

For example…

> `Q463639` `P27` `Q30`

In plain English…

> **Ana Mendietta** has a **country of citizenship** which is **United States of America**

In essence, a Wikidata `Item` is just some structured data around a big bag of triples, like the above.

# Artsy + Wikidata

Lucky for this editathon, both [Artsy Artist ID][artist-id], and [TAGP ID][tagp-id] were already inside the Wikidata controlled vocabulary of `Properties`. This mean we could think about how to connect items rather than how we can pitch that is worth connecting them at all.

We used Wikipedia to keep track of all [the useful links][dash] to share among contributors. 

As the majority of us were new to the Wikidata, we scoped our projects to "get something small done." We ended up with three projects on the Wikidata side:

* Edit some wikidata items manually to understand the process.
* Understand QuickStatements in order to do mass-updates of Wikidata items from Artsy data.
* Explore using pywikibot to ensure that updated Artsy details can be kept in sync with Wikidata.

# Outcomes

We got some changes to Wikidata. 🎉.

In preparing for this we also generated some data on Artists:

* [Artsy Female and Nonbinary Emerging Artists][f_nb]
* [Artsy Female and Nonbinary Artists with "Feminist Art" and "Contemporary Feminist" Genes][f_nb_genes]

These were generated back in July, so if you're looking for up-to-date data, we recommend using the [Artsy Developer API][dev].

# Updating Wikidata with data from Artsy

After spending some time familiarizing ourselves with the process of manually creating and editing Items, we moved onto some basic [QuickStatement][qs] updates. QuickStatments are a simple text based interface for updating multiple items and properties at once.

We ended up writing what would be the script for a single data item based on hardcoded values:

```sh
# COMPACT VERSION -- see below for annotated version
CREATE
LAST  Len  "Amina Benbouchta"
LAST  Den  "Moroccan contemporary artist"
LAST  P2042  "amina-benbouchta"
LAST  P106  Q483501  S2042  "amina-benbouchta"
LAST  P106  Q1281618  S2042  "amina-benbouchta"
LAST  P21  Q6581072  S2042  "amina-benbouchta"
LAST  P27  Q1028  S2042  "amina-benbouchta"
LAST  P569  +1963-01-01T00:00:00Z/9  S2042  "amina-benbouchta"

# ANNOTATED VERSION

# create new Item
CREATE

# add a label in English to the last created item
LAST  Len  "Amina Benbouchta"

# add a description in English
LAST  Den  "Moroccan contemporary artist"

# add an Artsy Artist ID
LAST  P2042  "amina-benbouchta"

# add occupation (e.g. artist: Q483501, painter: Q1028181, sculptor: Q1281618, photographer: Q33231)
# and source these statements to Artsy (source 2042)
LAST  P106  Q483501  S2042  "amina-benbouchta"
LAST  P106  Q1281618  S2042  "amina-benbouchta"

# add sex or gender (e.g. female: Q6581072; nonbinary: not in Wikidata yet)
LAST  P21  Q6581072  S2042  "amina-benbouchta"

# add country of citizenship (e.g. USA: Q30, Morocco: Q1028)
LAST  P27  Q1028  S2042  "amina-benbouchta"

# add birthdate (precision: /9=year /10=month /11=day)
LAST  P569  +1963-01-01T00:00:00Z/9  S2042  "amina-benbouchta"
```

By the end of the day we were able to enter basic biographical facts from Artsy's CSVs into Wikidata in one fell swoop, by batching up several QuickStatement instructions. In the future, we could write an "Artsy data to QuickStatement" script to handle larger imports.

One of the interesting aspects of looking through the data is that our Artists had a more nuanced set of gender identities than is currently available inside Wikidata's database. We found that we didn't have enough time to address this, but as Wikidata is an on-going project, anyone can add this in the future. If you're looking for a good first foray into Wikidata - this will improve the foundations for everyone.


# Using pywikibot to update Wikidata 

We created a [PAWS][] Python script that would take metadata from the CSVs Artsy provided on Genes and added that data to existing Wikidata documents. You can get our bot [on GitHub][bot]. 

Most of the work is inside a Jupyter Notebook, which you can get a full preview of [on GitHub][jn]

<img src="/images/editathon/jupyternotebook.png">

We loved the idea of having code showing the incremental process as it's being eval'd. We got the bot to a point where it could edit a Wikidata item based on it data exported from Artsy.

We plan to keep an eye on future efforts to coordinate Wikidata bot development, such as [WikidataIntegrator][wikidata-integrator]

# Upcoming ideas

We discussed what Artsy can do next, we have an idea of how we can connect our data to confirmed data on Wikidata by keeping the Wikidata QID inside our databases too. This means that we can safely keep that up to date.

We would love to do this again, it was exciting to have the project introduced to us - and we really get what they're trying to do. We want to host another, and you should come if you're in NYC!

If you're interested in exploring the Artsy Genome database, we recently updated [The Art Genome Project's Genes and Definitions][TAGP] with all of our genes as a CSV under [CC-A][cca]. We'd love to know if you find any interesting uses.

[meetup-msg]: https://www.meetup.com/CocoaPods-NYC/messages/boards/thread/50940969
[afem]: http://www.artandfeminism.org
[tagp]: https://www.artsy.net/categories
[am]: https://www.artsy.net/artist/ana-mendieta
[ana-json]: https://www.wikidata.org/wiki/Special:EntityData/Q463639.json
[editathon]: https://en.wikipedia.org/wiki/Edit-a-thon
[artist-id]: https://www.wikidata.org/wiki/Property:P2042
[tagp-id]: https://www.wikidata.org/wiki/Property:P2411
[Wikidata]: https://www.wikidata.org/wiki/Wikidata:Main_Page
[dash]: https://en.wikipedia.org/wiki/Wikipedia:Meetup/NYC/Artsy_ArtAndFeminism
[peer-lab]: /blog/2015/08/10/peer-lab/
[nyap]: http://www.artspracticum.org
[qs]: https://tools.wmflabs.org/wikidata-todo/quick_statements.php
[jn]: https://github.com/orta/artsy-wikidata-bot/blob/master/Artsy%2BGenes%2Bto%2BWikiData.ipynb
[PAWS]: https://www.wikidata.org/wiki/Wikidata:Pywikibot_-_Python_3_Tutorial
[bot]: https://github.com/orta/artsy-wikidata-bot
[TAGP]: https://github.com/artsy/the-art-genome-project
[cca]: https://creativecommons.org/licenses/by/4.0/
[triple]: https://en.wikipedia.org/wiki/Semantic_triple
[f_nb]: https://docs.google.com/spreadsheets/d/1bjIKKSHOxR2fJvLgf6yOwuDr3Iqo85hYMDMr4lL7Pxg/edit?usp=sharing
[f_nb_genes]: https://docs.google.com/spreadsheets/d/1G_wCTrP4WzouxfmZdKzqcIKghJDJdiFrv4xQURxrsbI/edit?usp=sharing
[dev]: https://developers.artsy.net/
[wikidata-integrator]: https://github.com/SuLab/WikidataIntegrator
[wikinyc]: https://nyc.wikimedia.org/
