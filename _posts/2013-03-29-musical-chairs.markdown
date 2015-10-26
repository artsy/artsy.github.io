---
layout: post
title: "Musical Chairs"
date: 2013-03-29 16:38
categories: [iOS, UIKIT, Customisation, mobile]
author: orta
---

 At Artsy we make Artsy Folio. Folio is an awesome portfolio app that shows our gallery and museum partners their artworks in one place, allows them to easily get information about their inventory and to send works by email to their contacts.

Folio has to deal with large multi-gigabyte syncs in order to operate offline. That makes for a great user experience, but for the developer working on the sync, it's not as pleasant. Combined with our use of Core Data, the app’s maturity, and dealing with data store migrations, things can get hairy. We needed a tool that could freeze and restore app data at will, obviating the need for constant syncing and resyncing.

That's why I built [chairs](https://github.com/orta/chairs)...

<!--more-->

Chairs is a gem you can install via `gem install chairs`. It allows you to stash and replace your current iOS simulator application state. It will grab everything related to the app ( including the current `NSUserDefaults`) and store it in a named subfolder in your current working directory. No black magic, just lots of copying files.

The command line interface is based on git, so to bring in the current state you run `chairs pull [name]` and to replace the state you use `chairs push [name]`. The name is just a label so you can remember which version corresponds to that musical chair. You can get a list of these by doing `chairs list`, and delete them with `chairs rm [name]`.

Besides the core functionality, chairs has a little bit of sugar to help you with related tasks. My personal favourite is `chairs open`; this will just open the folder of the most recently used app so you can go and have a snoop around. Amazing for making sure files are where they say they are or for opening your sqlite database in [Base](http://menial.co.uk/base/).

So `gem install chairs` or check out the [README](https://github.com/orta/chairs) for some more information.
