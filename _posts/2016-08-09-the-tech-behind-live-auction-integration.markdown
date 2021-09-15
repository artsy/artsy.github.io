---
layout: post
title: "The Tech Behind Live Auction Integration"
date: 2016-08-09 11:30
comments: true
author: alan
categories: [engineering, architecture, auctions, javascript, react, redux, scala, akka, swift, launch, lifecycle]
series: Artsy Tech Stack
---

In late June, the [Artsy auctions](https://www.artsy.net/auctions/) team launched our Live Auction Integration (LAI) product. It allows people to participate online in live sales held at auction houses [that partner with Artsy](https://www.artsy.net/auction-partnerships). It was a big project, begun in December, involving both brand new software and extensive integration work with the rest of our systems. This is the first in what will be a series of blog posts discussing the engineering work we did to get a complex product from inception to launch in such a brief time window, with a go-live deadline set in stone weeks in advance. In this, I’ll dig into what we shipped on a high level, as well as some of the overarching technical decisions.

<!-- more -->

LAI raised challenges that were novel to our engineering team. The product is a real-time experience from the perspectives of the bidder and the auction house. Producing that experience requires a complex human + computer system. There are two main flows of information: from auction house to bidder, and vice versa. These are mediated by our systems and staff as follows:

- As bids occur in the auction house sale room, an Artsy operator working on-site inputs that activity into a web interface so that online participants can keep track of what’s happening.
- As online participants place bids, our system records those as “prospective bids”, and an Artsy bidding clerk on site at the auction house bids on their behalf in the auction house. As those bids are recognized, they are reflected back to all participants, through the prior flow.

To make this easier to visualize:

![Artsy Live Auction Integration Flow](/images/2016-08-09-the-tech-behind-live-auction-integration/Artsy Live Auction Integration flow.png)

This needs to happen in a tight loop to allow online bidders to be competitive with those in the room and via auction house phone clerks. The architecture and UX of the LAI product were optimized for that goal. In addition, we built the system to integrate with live events hosted by our partners. As the events are outside our direct control, there are many, many ways things can deviate from this idealized flow. We had to carefully account for these situations.

Where possible, we leveraged our existing auctions technology. But we took the opportunity to upgrade that technology in some places and chose new approaches in others. Meanwhile, we were running the busiest Artsy auction season to date, and we had to ensure that we weren’t disrupting our existing stack. Below, I discuss the pieces of the end-to-end product.

# The Live user experience

When the live auction actually begins, participants and Artsy staff interact with the system with front-end software developed from scratch. Web users (desktop and mobile) and staff use a new, dedicated Artsy Live web application, which is implemented in a project we call Prediction. iOS Artsy App users can also participate with newly developed UX within that app.

## The web app: Prediction

Our bidder and operator web interfaces are implemented in an application we call Prediction, a [universal](https://medium.com/@mjackson/universal-javascript-4761051b7ae9#.ev1yd3juy) [React](https://facebook.github.io/react/)+[Redux](http://redux.js.org/) JavaScript app, served from an [Express](http://expressjs.com/) server. Using React allowed us to completely share our view layer code for pre-rendering in the server and making updates in the client.

![Prediction Bidder UI](/images/2016-08-09-the-tech-behind-live-auction-integration/Prediction Bidder Screenshot.png)

Keeping our state management and transition code organized with Redux allowed us to achieve a massive amount of reuse of model and controller code between our web interfaces. To solve Redux's [async](http://stackoverflow.com/q/34570758/807674) and [data conveyance](http://stackoverflow.com/q/34299460/807674) “problems", we built an integration layer for React and Redux called [React Redux Controller](https://github.com/artsy/react-redux-controller).

![Prediction Operator UI](/images/2016-08-09-the-tech-behind-live-auction-integration/Prediction Operator Screenshot.png)

We found the React+Redux approach to model-view-controller app development to be a major win in what it gave us for maintainability, code reuse, easy testability, and the ability to reason about our code.

## The iOS native app: Eigen

For users of the Artsy iOS app, known to our engineering team as [Eigen](https://github.com/artsy/eigen), a touch-optimized LAI experience was coded in Swift. It shares the same app with existing Objective-C code as well as [React Native](https://facebook.github.io/react-native/) code used for other aspects of the iOS experience. We considered using React Native for this, but we decided to go with more familiar technology to contain the risk.

![Eigen Bidder UI](/images/2016-08-09-the-tech-behind-live-auction-integration/Eigen Bidder Screenshot.png)

Both of these applications interact with our central Artsy back-end service to pull in artist, artwork, and sale metadata when the user enters the auction. These queries are mediated by a [GraphQL](http://graphql.org/) middleware service we call [Metaphysics](https://github.com/artsy/metaphysics) (also discussed [here](/blog/2016/06/19/graphql-for-mobile/)), which vastly simplified the fetching process in the front-end services. But from that point forward, the apps interact with a brand new auction state management system over a bidirectional [WebSocket](https://en.wikipedia.org/wiki/WebSocket) API for live updating.

# The auction state management service: Causality

The other recently launched piece of software delivered for LAI was a new auction state management system we call Causality. It processes bids and other auction events, computes the derived state of a sale, and hosts the bidirectional WebSocket API.

Causality was developed in Scala, using the [Akka](http://doc.akka.io/docs/akka/current/intro/what-is-akka.html) technology suite for distributed computing. At its core is an append-only storage engine, based on [Akka Persistence](http://doc.akka.io/docs/akka/current/scala/persistence.html), with a small library we developed called [Atomic Store](https://github.com/artsy/atomic-store) that allowed us to achieve strict consistency, at the cost of maximal throughput -- a trade-off that is explored in the readme of that project.

Lastly, Causality has an [Akka HTTP](http://doc.akka.io/docs/akka/current/scala/http/introduction.html)-based API layer, with a WebSocket server implemented using [Akka Streams](http://doc.akka.io/docs/akka/current/scala/stream/stream-introduction.html). Asynchronous updates generated in the event processing logic are published across the cluster using [Akka Distributed Pub/Sub](http://doc.akka.io/docs/akka/current/scala/distributed-pub-sub.html), and they are merged into the WebSocket outflow.

# Pre-bidding, tooling, and other concerns

In addition to accepting bids placed during a live sale, we also allow users to place bids before the event begins. In practice, this is almost the same workflow as our existing timed auction experience. For this reason, we chose to leverage all of our existing technology. The work of preparing our preexisting tech for LAI involved widespread modifications to our front-end UI, messaging services, admin tooling, and monitoring to make them appropriate for a live sale, as well as a reliable handoff of responsibility from these preexisting front- and back-end services to the new ones at the time the sale goes live.

We relied on our automated test suites, as well as thorough manual testing by the entire Artsy auctions team, to ensure that this handoff functioned smoothly under various circumstances. We will eventually eliminate this duplication. But this will require delicate refactoring of our preexisting tooling, which we will take on, even as we execute a fall auction season significantly busier than the last.

# Reflection

In the process of architecting our LAI product, we had to make some tough decisions in the face of new challenges. Chief among these were the decisions on where on the spectrum of bleeding-edge technology versus tried-and-true choices to land, for many of our subcomponents. Bleeding-edge tech often offers more elegant and performant solutions, but at the cost of learning curve and risk of immaturity. We also had to carefully prioritize functionality. Choosing wisely throughout the process was critical to shipping on time. The rationale behind these decisions and their outcomes will be the result of future pieces.

To close, I want to express huge thanks to the auctions product & engineering team for putting in long hours to design, implement, and troubleshoot the software; the auctions arts team for providing the domain knowledge and operational feedback; and our broader Artsy engineering team, at least half of whom directly contributed code to this effort.
