---
layout: epic
title: Why Projects Need Code Names
date: 2019-05-10
author: [joey]
categories: [engineering, git, github]
---

Before I joined Artsy, I worked at companies where software projects tended to have meaningful, predictable names. If we were building a system for flagging media uploads, it might be called `media-review`. In many cases, our code repositories' names matched the main product's branding or even the company's name. Life was simple and there was no risk of ambiguity.

At Artsy, our systems have peculiar code names like _Gravity_, _Pulse_, and _Vortex_. There's a persistent learning curve as you contribute to different repositories or as new services get created. Numerous times, I've wondered: are code names worth the trouble?

<!-- more -->

![](/images/2019-05-10-why-projects-need-codenames/github_projects.png)

To be clear, _any_ project naming scheme works in small quantities. Personal projects or libraries for public release should probably just be named for clarity and find-ability. Code names start to offer benefits as a team grows and a product evolves over the longer term:

Code names embrace that **we don't necessarily know the fit or scope of a system when it's first conceived**. To _not_ employ code names would require accurately predicting a system's eventual function. A project named `artsy-admin` starts to grate when we make the architectural decision to split apart management utilities or introduce more fine-grained administrative roles. An `artwork-taxonomy` label loses meaning when that system expands to include less structured tags

**Branding shifts, products pivot, and companies merge.** Project code names introduce a level of indirection between what engineers build and the labels, URLs, or brands that end users experience. Over a long enough period, these external or superficial changes _will_ happen and risk introducing confusion or just subtle misalignment between form and function. As with software design in general, abstractions can be a powerful tool to [separate concerns](https://en.wikipedia.org/wiki/Separation_of_concerns). Ask yourself: what code changes might be required if your company were to spin off your product or be merged into an acquirer?

**Language is important**, and not just for communication but for shaping our thoughts and assumptions. We frequently find ourselves debating which system should serve as the authority for a given domain model or where to implement a new feature, and project names that overlap with these topics (e.g., `search`, `images`, `suggestions`) would predispose us to certain decisions. Code names free us to focus on the architectural and organizational merits instead.

We like to **have fun at work** and it's more joyful to proclaim that "Torque is in the wild" than "data-sync has been deployed." Over time these names gain mythologies and personalities within the team and organization.

With this in mind, how should you choose a naming scheme?

## Rules for a project naming scheme

* Avoid implicit value judgments like "new," "next," or "modern." We've all witnessed today's hot project become next year's unloved albatross.
* Choose a code name scheme that isn't directly related to your technology or business. A flower business using flower names is cute, but breaks down when you want to build a feature that _actually_ is about tulips.
* Everyone should be able to participate, so avoid industry lingo or obscure terminology. Funny story: I work at an art start-up but don't know enough artists to name my projects that way. I struggle even more to pronounce the few projects that are.
* There should be lots of choices. You'll regret choosing to name your projects after "decathlon sports" or "days of the week" when your team inevitably transitions to microservices.
* Names should be unique within a company and--ideally--beyond the company's scope. You wouldn't want your `marketing-site` repository to conflict with a contributor's `marketing-site` repository from another organization. Github projects, S3 buckets, Heroku application names, and published libraries all benefit from being globally unique.
* Bonus points for choosing a rich enough scheme that names can subtly relate to each system's function. At Artsy, we use physics terms for code names, so our e-commerce back-end is called [Exchange](https://github.com/artsy/exchange) and a command line utility for developers is called [Momentum](https://github.com/artsy/momentum). A shipping service might be called _Weight_.

Example code name schemes: animals, movies, sea creatures, cartoon/TV characters, woodworking tools, celebrities (but get legal advice before borrowing living individuals' names). [Ubuntu](https://wiki.ubuntu.com/DevelopmentCodeNames) gets extra mileage by combining adjectives with animal names. [Apple](https://en.wikipedia.org/wiki/List_of_Apple_codenames) has used wine, cats, and California geography. [Google](https://en.wikipedia.org/wiki/Android_%28operating_system%29) likes dessert.

## Finally

These days, I've embraced Artsy's use of physics terms for project names. There continues to be some head-scratching as new engineers navigate codebases and encounter these terms or just struggle to identify the system responsible for a given site or feature. (This isn't shocking, since code names were probably adapted from more secretive environments like the military.) As your code names multiply and projects come and go, a glossary becomes essential. I suggest creating a simple document that maps projects' code names to descriptions, URL destinations, hosting environments, and teams.

See also:

* [What's in a Project Name?](https://blog.codinghorror.com/whats-in-a-project-name/)
* [The Developer Obsession With Code Names, 186 Interesting Examples](https://royal.pingdom.com/the-developer-obsession-with-code-names-186-interesting-examples/)
