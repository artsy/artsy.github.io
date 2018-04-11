---
layout: post
title: Programmer Misconceptions about Art
date: 2018-04-10
author: ash
categories: [best practices, data, programming]
---

Our mission at Artsy has been to make art as popular as music, and at a high level, the way that our engineering team supports that mission is through building software. We have built systems and databases and user interfaces that represent different facets of the art world, and throughout our work, we have... made some mistakes.

That's okay! Programmers make mistakes all the time. There is [a large list of blog posts][falsehoods] describing various programmer misconceptions, from subjects you might expect would be simple to model in computers, like units of measurement and time, to subjects that are based more in the human condition, like postal addresses and marriage.

In the interest of openness and sharing what we've learned, the Artsy Engineering team has come up with the following list of misconceptions programmers believe about art.

<!-- more -->

- All artworks have an artist (some artworks are attributed to "cultural makers", others have a manufacturer).
- All artworks have exactly one artist (some artworks are collaborations).
- All artworks are unique (there are editions, reproductions, and series of works, and modeling the relationships between them all is nontrivial).
- All lots in an art auction are artworks (some lots are "experiential", like a visit to an artist's studio).
- Only rich people buy art.
- Only rich people can afford to buy art, and everyone else just buys posters of "real" art.
- All artworks have a title (some are untitled).
- "Untitled" signifies an artwork has no title (some artworks are titled "Untitled").
- An artwork is associated with a natural, canonical category.
- An artwork belongs to only one gallery/collector/auction house at a time (provenance of artworks is complicated, and there is no canonical source of truth).
- Art and engineering are orthogonal (nope, just look at us!).

Do you have expertise in an area programmers often get wrong? Write a blog post and add it to [the list of misconceptions][falsehoods]!

[falsehoods]: https://github.com/kdeldycke/awesome-falsehood
