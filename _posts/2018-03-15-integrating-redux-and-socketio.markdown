---
layout: post_longform
title: "Integrating Redux and Socket.io"
date: 2018-03-15
categories: [Technology, positron, javascript]
author: [luc]
---

On the engineering team at Artsy, we've built a CMS for both internal and external editors to write and publish articles. We have about (x) editors internally writing new content on a regular basis. One of the issues we've been facing a problem with our article editor tool. Our users would go and override each other’s work without knowing because we've had no system in place to tell if someone else was currently editing the current article. To keep that from occurring, their workflow would involve editing a draft in another editor such as google docs and once their article is ready, copy it over to our writer app. The goal of this project was to implement locking mechanism to only allow one editor per article. I had to come up with an elegant technical implementation for this problem. Here's how I went about it.

<!-- more -->

In order to fix that problem, we decided to build a article lock mechanism so only one editor can enter at once. One of the requirements for this new feature was for our editors to see when other editors are using the app without refreshing the page. In order to fulfill this requirement we needed a two-communication data channel.
Based on the requirements presented, we looked at potential solutions for this. Right away, we jumped to using HTML5 web sockets API to allow us pushing editing events via the backend to all other clients. However a few architecture decisions needed to be made.
The team was already in the process of converting the app from using Backbone to a modern javascript stack: React for UI components, redux for managing app state. So whatever solution I came up with, one goal was to have it play nicely with redux. If you’re familiar with the redux architecture you know it comprises a single source of truth for state known as the store. Actions, action creators, reducers.

## Solution

![/images/2018-03-15-integrating-redux-and-socketio/example.gif](/images/2018-03-15-integrating-redux-and-socketio/example.gif)

Redux emerged as the industry standard way implementing one-way data flow into your app, taking actions (events).

For server/client, I ended up using socket.io, a battle tested library for two-way real time communication channel. At that point, we were facing another challenge, how do we integrate socket.io in the react/redux architecture we just designed. also written in javascript for backend and clients combine the two. All that’s left to do is to integrate the two libraries.

Here's a simplified version of the helper function.

```javascript
// From client
import io from 'socket.io-client'
import { messageTypes } from './messageTypes'

let socket = io(rootURL)

// Helper to emit a redux action to our websocket server
const emitAction = (actionCreator) => {
  return (...args) => {
    // This return the action object which gets sent to our backend
    // server via the socket connection
    const result = actionCreator.apply(this, args)
    socket.emit(result.key, {
      ...result.payload,
      type: result.type
    })
    return result
  }
}
```

Here's an example of how it's being used to wrap a typical redux action creator. All that's needed is to wrap the function as shown in the following example.

```javascript
import keyMirror from 'client/lib/keyMirror'
import { emitAction } from 'client/apps/websocket/client'
import { messageTypes } from 'client/apps/websocket/messageTypes'

export const actions = keyMirror(
  ...
  'START_EDITING_ARTICLE',
  'STOP_EDITING_ARTICLE',
  ...
)

export const startEditingArticle = emitAction((data) => {
  return {
    type: actions.START_EDITING_ARTICLE,
    key: messageTypes.userStartedEditing,
    payload: {
      timestamp: new Date().toISOString(),
      ...data
    }
  }
})

...
```

We set up a two communication channel using websockets to implement a locking mechanism for editing articles. We also implemented the UI to show an indication that an article is locked on the homepage and prevents user from clicking on a locked article.

How do we handle clients that don’t have native websocket support, or in cases your nodes sit behind a load balancer.

There are many use cases for this, any real-time client heavy applications. This event broadcast system can be used in any applications built with redux. 

Socket.io is a real-time engine that enables bidirectional event-based communication. The support broadcasting came about as we were working on an editor feature for our clients. We came to realize multiple editors could go in to an article and edit it at the same time.

## Future improvements
