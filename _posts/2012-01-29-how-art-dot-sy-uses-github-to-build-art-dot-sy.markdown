---
layout: post
title: "How Artsy Uses Github to Build Artsy"
date: 2012-01-29 14:26
comments: true
categories: [Tools, Github]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---
[Zach Holman](http://zachholman.com/) gave a good talk on [How Github uses Github to build Github](http://zachholman.com/talk/how-github-uses-github-to-build-github) at Rubyconf. It was great to hear how similar our own processes are at Artsy, with a few notable differences.

Artsy engineers store almost everything on Github. We use Github Wikis, but don't use Github Issues much. We work in 3-week sprints with [Pivotal Tracker](http://pivotaltracker.com/) instead. This blog is on Github. And, of course, we have our own Hubot which feeds funny animated GIFs after each successful deploy to our IRC channel.

The most interesting part for me was around these two slides.

![/images/2012-01-29-how-art-dot-sy-uses-github-to-build-art-dot-sy/github-pull.png](Github Pull)
![/images/2012-01-29-how-art-dot-sy-uses-github-to-build-art-dot-sy/github-fork.png](Github Fork)

Zach emphasized that you don't need forks to make pull requests. While technically true, I find forks particularly useful to keep things clean.

At Artsy we use personal forks to work on features, create topical branches and make pull requests into the master from there. This is the workflow of the vast majority of open-source projects too. Now, Zach is right, you don't want to create any second class developers - our entire team has write access to the master. We use pull requests from forks to do peer code reviews, even for trivial things. I would typically make a pull request including the person I'd like to code review my changes in the title. Here's an example.

![/images/2012-01-29-how-art-dot-sy-uses-github-to-build-art-dot-sy/github-pull-request.png](Targeted Pull Request)

(Notice the use of hash rocket. Zach, Ruby has transcended our lives too.)

Working on forks keeps developer branches away from "master". The main repository only has three branches: "master", "staging" and "production" and each developer can make up whatever branching strategy they like in individual forks.

Code reviews have nothing to do with hierarchy or organization, any developer will code review any other developer's work. We tend to avoid using the same person for two subsequent code reviews to prevent excessive buddying. Zach called his pull requests "collective experiments" - a place for active discussions, rejections and praise. I really like that. Each of my rejected pull requests has been a great learning experience.
