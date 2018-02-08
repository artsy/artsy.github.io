---
layout: epic
title: "Apogee: Doing More with Less"
date: 2018-02-02
categories: [rails]
author: [ash]
series: Apogee
---

> Apogee: the point in the orbit of two objects at which they are furthest apart.

In 2017, the Artsy Auctions Operations team coordinated and ran 190+ sales on our platform. This year, our ambitions are set even higher. But scaling up the number of sales we run will require scaling up our tools and processes, too. This post describes Apogee, a tool I built to help us scale our businesses processes. I never thought I would be so excited to build a spreadsheet plugin, but I honestly had a blast. So let's dive in!

<!-- more -->

Running a sale on Artsy is no small feat. I mean, after all the contract negotiations you might think things get easier, but that's just the beginning of the work. All our auction partners have data in their own CMS systems, and they're all formatted slightly differently. We need to get the information for each lot in a sale into Artsy's CMS, and so a few years ago we built a batch-import app in Rails to do this (closed source, sorry). It works well, but expects data in a specific format.

A lot of work is done by our Ops team to reformat spreadsheets they get from our partners to match the structure our batch import tool expects. All of our partners have different formats, and sales can include hundreds of lots. The reformatting process can take one person over a day, for large sales.

Wouldn't it be cool to build some kind of server to bridge the gulf between Artsy's database and our partner's myriad systems?

No, actually, it wouldn't. It would be a tremendous amount of work, from our side and from theirs. Back to the drawing board.

In January, Ops arranged a meeting between us engineers and an auction partner. Ideally, a solution to _our_ problem would also make our partners' lives easier, since exporting data from their systems is sometimes as arduous as importing it into ours. [Skinner][] was kind enough to walk us through their export process and provide us with some representative data.

Perfect, now we have a starting point.

---

> If you're not familiar the 80/20 rule says, ‘Do a job until it's 80% done and then quit’.
> —[@searls][searls]

The team's early brainstorming to the Ops import workflow was hampered by a kind of perfectionism. We evaluated, but decided against solutions because they didn't address all the edge cases. It finally clicked, for me anyway, when I realized that our tool didn't need to bridge the gulf between two _systems_, but between two _workflows_.

And it didn't need to be perfect, not at all. Even an 80% reduction in the amount of time spent wrangling spreadsheet data would translate to _hours_ of time saved, per sale. That is, if we could find a way to make it ridiculously easy to add parsers for new partners.

We built a quick prototype – less than two days work – to pull out data from Skinner's spreadsheets and format it into the structure that's easiest to import into Artsy. The prototype itself was a [Google Sheets Add-on][add-on]. There will be a follow-up post describing the technical evolution of this tool, but the important thing to note here is that we engineers had to go to where our Ops team already was. Previous discussions around improving Ops' import workflows were centred around building entirely new workflows instead of improving the existing, functional workflows.

The prototype was tested in production with two large sales Skinner and Artsy were running together. Parsing out _just_ the dimensions of the lots, for _just_ one of the sales, saved an hour of Ops' time. Clearly, there was promise in this tool.

Next steps were all technical, and we'll get into details in the next post, but building Apogee actually involved developing two pieces of technology: a Rails server, and an Add-on client. Because a tool to parse data from various partners necessarily contains those partners' data formats, we decided not to open source Apogee. That's okay – we practice [open source _by default_][ossbd], not _by demand_.

## Apogee Server

It's difficult to discuss the server without first talking about the Add-on, so in short: Add-ons are difficult to maintain, to collaborate on, to unit test, and so on. So we decided early to build a very thin Add-on client and move all the heavy lifting to a backend server that we could develop within our existing technical framework. Our goal was to build an Add-on that needed to be updated less frequently than support for new partners was added.

We needed a server. Most of this server's job was going to be running regular expressions, and Ruby's regex features are still a step above Node's. It's critical that writing new parsers be _ridiculously_ easy to write (and test!). That factored in a lot of technical decisions, which we'll discuss in more detail in the next Apogee post.

So it's a Ruby server, but which framework?

I thought about using Sinatra, since our server is very simple and Sinatra is a tech I've [used before][aeryn], but after speaking with some colleagues, I decided on using Rails in API-only mode. Sticking to Rails would keep the project in-step with the rest of Artsy's Ruby server code – we don't have any Sinatra apps, but everyone here already knows Rails. Plus, Rails is _very_ boring and – consequently – _very_ stable. I like stability.

Before a few weeks ago, I'd never even run `rails new`. Now, I'm the proud point-person for an entire Rails server. I owe a lot to my colleagues for helping me along the way.

## Apogee Add-on

The Add-on is an interesting piece of code. In addition to the strange environment for building and deploying Add-ons, you also have to deal with a strange runtime. How strange? Well, it's JavaScript, but not as we know it.

Google Docs Add-ons run as [Google Scripts][], which are a more general-purpose cloud computing platform. They [execute a runtime][runtime] based on JavaScript 1.6, which specific features from JavaScripts 1.7 and 1.8 ported in. Similar to the [Danger-JS][] 1.x runtime, there is no event loop. So, things are weird.

Just because we can't fully automate deploys doesn't mean we can't automate _parts_ of the process. Specifically, I built the Add-on using [TypeScript][] which is compiled down to a version of JavaScript that Google Scripts plays nice with. There are even open-source [typings][] available for the Google Scripts API.

---

I learned a lot from building Apogee, from a technical perspective, but the lessons I'm most proud of learning have to do more with business processes. From the general approach of making data imports faster, to the specific programming languages used to build Apogee, all decisions were driven first and foremost by actual business needs (and not technology trends). Apogee is not exciting enough to make the front page of Hacker News, and in a weird way, I'm proud of that.

Artsy Auctions are at an inflection point; we need to scale up the number of auctions we run faster than we scale up the effort spends actually running them. 2018 is going to challenge the Auctions engineering team to help our colleagues accomplish more, while doing less. I'm excited for that challenge.

[Skinner]: https://www.skinnerinc.com
[add-on]: https://developers.google.com/apps-script/add-ons/
[aeryn]: https://github.com/Moya/Aeryn
[Google Scripts]: https://script.google.com
[runtime]: https://developers.google.com/apps-script/guides/services/#basic_javascript_features
[Danger-JS]: http://danger.systems/js/
[TypeScript]: https://www.typescriptlang.org
[typings]: https://www.npmjs.com/package/@types/google-apps-script
[searls]: https://www.youtube.com/watch?v=MSgR-hJjdTo#t=2m36s
[ossbd]: https://ashfurrow.com/blog/open-source-ideology/
