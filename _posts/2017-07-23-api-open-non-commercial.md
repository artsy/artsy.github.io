---
layout: epic
title: Artsy API Ready for Production Non-Commercial Use
date: 2017-07-23
categories: [API, Open-Source]
author: orta
---

About 3 years ago, dB. announced that Artsy [had a public API](/blog/2014/09/12/designing-the-public-artsy-api/). 

> The Artsy API currently provides access to images of historic artwork and related information on [artsy.net](https://artsy.net) for educational and other non-commercial purposes. You can try it for playing, testing, and learning, but not yet for production. The scope of the API will expand in the future as it gains some traction.

We've wrapped up some legal work around the developer API terms and services, [the PR is here](https://github.com/artsy/doppler/pull/119) and I'm happy to announce that the API is ready for non-commercial production use.

The **TDLR** [Terms and Conditions](https://developers.artsy.net/terms) today for using the Artsy API is:

* Non-commercial use only.
* You only get access to public-domain artworks.

The API:

* Is a [Hypermedia](https://robots.thoughtbot.com/writing-a-hypermedia-api-client-in-ruby) API.
* Covers [Artists][a], [Artworks][aw], [Genes][g], [Shows][s], [Partners][p] and [more][m].

If you have a great idea for an app that can use public-domain data, then the Artsy API is the right place to look: [https://developers.artsy.net][d].

[a]: https://developers.artsy.net/docs/artists
[aw]: https://developers.artsy.net/docs/artworks
[g]: https://developers.artsy.net/docs/genes
[s]: https://developers.artsy.net/docs/shows
[p]: https://developers.artsy.net/docs/partners
[m]: https://developers.artsy.net/docs/
[d]: https://developers.artsy.net/
