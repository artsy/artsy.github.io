---
layout: post
title: Programmer Misconceptions about Art
date: 2018-04-18
author: ash
categories: [best practices, data, programming]
---

Our mission at Artsy has been to make a world where everyone is moved by art every day, and at a high level, the way that our engineering team supports that mission is through building software. We have built systems and databases and user interfaces that represent different facets of the art world, and throughout our work, we have... made some mistakes.

That's okay! Programmers make mistakes all the time. There is [a large list of blog posts][falsehoods] describing various programmer misconceptions, from subjects you might expect would be simple to model in computers, like units of measurement and time, to subjects that are based more in the human condition, like postal addresses and marriage.

In the interest of openness and sharing what we've learned, the Artsy Engineering team has come up with the following list of misconceptions programmers believe about art. Thank you to everyone at Artsy who contributed to this list.

<!-- more -->

- All artworks have an artist (some artworks are attributed to "cultural makers", others have a manufacturer).
- All artworks have exactly one artist (some artworks are collaborations).
- All artworks are unique (there are editions, reproductions, and series of works, and modeling the relationships between them all is nontrivial).
- All lots in an art auction are artworks (some lots are "experiential", like a visit to an artist's studio).
- Only rich people buy art.
- Only rich people can afford to buy art, and everyone else just buys posters of "real" art.
- All artworks have a title (some are untitled).
- "Untitled" signifies an artwork has no title (some artworks are titled "Untitled").
- All artwork titles can fit inside 512 characters (not true, [here is a counterexample][counter]).
- An artwork is associated with a natural, canonical category.
- An artwork belongs to only one gallery/collector/auction house at a time (provenance of artworks is complicated, and there is no canonical source of truth).
- Art should always be rendered at its maximum size (there are complex business constraints and art world norms that need to be considered).
- People buy art mostly for its visual qualities (most people buy art because of a story, because they understand what the artwork is trying to say, or because they simply can't stop thinking about it).
- People don't buy art from JPEGs (in fact, people buy art that hasn't even been created yet).
- "My kid can paint that" ([but did they?][tweet]).
- The art market needs technology because it's inefficient (the art market needs technology because technology can help expand the entire art world).
- Intermediaries in the art market are bad (eg. galleries: they enable artists to make works for years before they sell anything, they are the enabler, not the obstacle).
- There is one "art world" (there are thousands of galleries around the world, specializing in everything from contemporary jewelry and emerging conceptual art to Chinese scroll painting and regional landscapes).
- Your opinion on art doesn't matter, the industry will independently determine value of an artwork (everyone has opinions, your appreciation of art is _all_ about _you_).
- The art world is hermetic and isn't relevant to my life (in fact the arts contribute billions of dollars to the economy, employ thousands of people, have a ripple effect on urban life, and are often a major source of inspiration for the TV, movies, and books we all consume on a daily basis).
- Gallerists are fancy people in a luxury business, living fancy lives (in fact, the average salary for a gallery owner is way lower than you think).
- Art and engineering are orthogonal (nope, just look at us!).

Do you have expertise in an area programmers often get wrong? Write a blog post and add it to [the list of misconceptions][falsehoods]!

[falsehoods]: https://github.com/kdeldycke/awesome-falsehood
[counter]: https://www.artsy.net/artwork/matt-goerzen-sockpuppet-theatre-representing-the-techniques-tools-and-environments-whereby-hackers-and-other-info-warriors-might-seek-to-parse-through-elsewhere-distorted-informational-domains-to-make-sense-of-them-and-also-possibly-to-acquire-by-illicit-or-clever-means-good-information-that-can-then-be-communicated-in-a-way-that-sheds-light-on-deceptions-but-can-also-be-difficult-to-evaluate-on-their-own-terms-due-to-the-elite-requisites-of-interpreting-such-knowledge-or-more-generalized-uncertaintities-regarding
[tweet]: https://twitter.com/ashfurrow/status/707273704640798720
