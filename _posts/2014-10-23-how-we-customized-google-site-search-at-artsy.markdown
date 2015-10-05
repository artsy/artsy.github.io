---
layout: post
title: "How we customized Google Site Search at Artsy"
date: 2014-10-23 14:47
comments: true
author: brennan
categories: [Search]
---

This post is about how, in a week, we switched from Solr to [Google Site Search](https://support.google.com/customsearch/answer/72326?hl=en) and customized it into a fast, [beautiful search service](https://artsy.net/search?q=banksy). Search is a difficult problem -- a really difficult problem. For small companies and startups, the common solution to search is to launch a custom search service based on [Solr](http://lucene.apache.org/solr/) or [Elastic Search](http://www.elasticsearch.org/). While these services are very appropriate for private data, we think Google Site Search should be considered in addition to these services for a public website. It is often not considered because users search on a dedicated site with different intent than they search Google. We found that while this may be true, it is not necessarily a good reason to roll your own search service for your public site.

![Search for photography on artsy](/images/2014-10-23-how-we-customized-google-site-search-at-artsy/photography-site-search.jpg)

<!-- more -->

## Why Google Site search?

While rolling your own search service has the benefits of infinite customizability, it also takes a great deal of time and effort to build and maintain. Generic services such as Google Site Search, not only may solve your user's search needs, but get benefits from their general purpose. Those benefits are difficult to recreate with a site-specific search app with limited content. Google, with its limitless search data, has a sophisticated understanding of user intent and relevance that is difficult to create without significant engineering effort. On Artsy, Google understands that 'koons' refers to 'Jeff Koons' and is not a misspelling of 'deKooning'. It indexes long form content such as user generated posts, and yet knows that 'andy' refers to 'Andy Warhol' and not the user 'Andy' who has never posted. Without knowing the number of inbound link to these pages, it would be difficult to rank our search results so effectively.

Before looking at Google Site Search, we made many valiant attempts at the great search problem. First, we implemented [full text search in Mongo](https://github.com/artsy/mongoid_fulltext) (before it had full-text search). Eventually that became too slow and we transitioned to use Solr which we tweaked for 3 years. Importantly, we still use Solr for our autocomplete and all admin applications. When trying to deliver a great search results page, we found it difficult to properly weigh results across our many entities. The easiest solution we could find was Google Site Search which allows you to remove Google branding, customize weigh results and access their [JSON api](https://developers.google.com/custom-search/json-api/v1/overview). While that may seem perfect and done, it took us about a week of tweaking to get the most out of the GSS API and turn it into an Artsy branded experience.

## Will Google Site Search work for me?

There are many deal-breaker level tradeoffs to consider when evaluating GSS. But in the end, it works well for Artsy and is so easy to setup and maintain that those tradeoffs may be worth it for you as well. We encountered three big issues when trying to implement GSS.

1.  You can no longer have admin only or user specific search results since you just get back public search results.
2.  Updates to search results take around a week or two.
3.  The ranking logic is magical and non-inspectable or modifiable.

It is important to remember that Google doesn't understand your business. It just wants to provide relevant results to people who come to Google, but people likely come to your site for a different reason. Google's pagerank considers the entire internet of links towards you. This causes some results that are really good globally to be bad for a site specific search. For example, at Artsy, our highest value pages are Artist pages which convert best for our key metrics. Our editorial pages, while nice are our lowest value pages and convert poorly. Google tends to highlight the editorial pages which have many inbound links. We have hacked around this by bumping up artist pages in results but it isn't ideal. Sometimes this works out favorably such as in the Banksy result below (one of our top searches). While SOLR give us artists who may be a misspelling of 'Banksy', GSS gives preferable result set with a mix of editorial content about Banksy and related categories.

![Search for Banksy on artsy](/images/2014-10-23-how-we-customized-google-site-search-at-artsy/banksy-site-search.jpg)

## Getting the most out of Google Site Search

First, make sure Google indexes your site. Google Site Search merely searches Google's index of your public site. This may highlight issues with indexing that you may want to fix such as improving page titles, descriptions or adding helpful meta information.

### Google Site Search JSON API

The most important next step is to use the [JSON API](https://developers.google.com/custom-search/json-api/v1/overview) instead of letting Google render the results for you. GSS looks like Google Search (with some theming options). Google-style UI in your site is both conceptually and visually jarring to your users. Your designer may eventually want to move some things around so you might as well just start by rendering the results yourself.

In addition to these visual issues, GSS displays your page title, description and image intended for search engine result pages. This information should be changed to be more appropriate to people who are already on your site. See below where we compare a customized Google Site Search page with our own rendered version. We make the results more appropriate to Artsy by changing the order of results, cleaning up page titles and using visual layout.

![Customized Google Site Search at Artsy](/images/2014-10-23-how-we-customized-google-site-search-at-artsy/google-site-search.jpg)

### Custom Metatags

The GSS JSON API is not your custom API with a connection to your database but you can make it work like one. You no longer get back nicely structured data allowing you to know if the entity is say, an artist or an artwork. You just get back urls and their meta tags. The key to getting good data out of the GSS API is to use a custom Facebook [Open Graph](http://ogp.me/) implementation (custom og:type) and other custom meta tags.

Note how Banksy appears in a different layout from Articles above. For artist pages, we use a custom OG type called 'artsyinc:artist' which tell us which layout to use when displaying the result. We then include additional data like "og:nationality", "og:birthyear" etc if we need extra information. In addition to improving our layout, this makes Artsy more semantic.

### Evaluating Search Changes

In addition to doing internal testing and sending to friends, we used [usertesting.org](https://usertesting.org) to get a wider spectrum of users. This proved valuable just to see how real people phrase queries. For us, an art site, queries differ between art specialists and people new to art. Being able to see both gave us insights such as making search results more visual than textual.

## In Conclusion

Overall we were surprised at how well Google Site Search worked for us, a specialized art site. Given our level of customization it is impossible tell that we use it. We will see how well GSS plays out long term but so far, we have improved the search experience on Artsy while making it more semantic in the process. I only wish we had considered GSS a valid option earlier.

If you would like to try out Artsy's public search API, we have a public version [here](https://developers.artsy.net/docs/search). It uses the [google_custom_search_api](https://github.com/wiseleyb/google_custom_search_api) gem which makes GSS trivial to integrate into a Ruby app.
