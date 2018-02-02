---
layout: epic
title: Getting Closer In Apogee
date: 2018-02-02
categories: [rails]
author: [ash]
series: Apogee
---

> Apogee: the point in the orbit of two objects at which they are furthest from each other.

In 2017, the Artsy Auctions Operations team coordinated 190+ sales on our platform. This year, we're even more ambitious. But scaling up the number of sales we run will require scaling up our tools and processes, too.

<!-- more -->

Running a sale on Artsy is no small feat. I mean, after all the contract negotiations you might think things get easier, but that's just the beginning of the work. All our auction partners have data in their own CMS systems, and they're all formatted slightly differently. We need to get the information for each lot in a sale into Artsy's CMS, and so a few years ago we built a batch-import app in Rails to do this (closed source, sorry). It works well, but expects data in a certain format. A lot of work is done by our Ops team to take the spreadsheets they get from our partners and reformatting the data to match the structure our batch import tool expects. All of our partners have different formats, and sales can include hundreds of lots.

Wouldn't it be cool to build some kind of web app to bridge the gulf between Artsy's system and our partner's myriad systems?

No, actually, it wouldn't. It would be a tremendous amount of work, from our side and from our partners. Back to the drawing board.

In January, a few of us engineers met with Ops and an auction partner to discuss this problem. [Skinner][] was kind enough to walk us through their export process and give us some representative data. Perfect, now we have a starting point.

We built a quick prototype – less than two days work – to pull out data from Skinner's spreadsheets and format it into the format easiest for our Ops team to work with. The tool itself was a [Google Sheets Add-on][add-on]. There will be a follow-up post describing the technical evolution of this tool, but the important thing is that our engineering team went to where our Ops team already was. Previous discussions around improving Ops' workflow were centred around building new systems, instead of building tools that fit into our existing, functional workflows.

The prototype was used with three sales Skinner and Artsy were running together. Parsing out the dimensions of the lots, for just a single sale, saved an hour of Ops' time. Clearly, there was promise in this tool.

// TODO: Describe, in general terms, the development process. Discuss: Add-on runtime weirdness, high-level tech stack decisions, and showing off the prototype.

[Skinner]: https://www.skinnerinc.com
[add-on]: https://developers.google.com/apps-script/add-ons/
