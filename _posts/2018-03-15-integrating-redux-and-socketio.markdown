---
layout: post_longform
title: "Integrating Redux and Socket.io"
date: 2018-03-15
categories: [Technology, positron, javascript]
author: [luc]
---

On the engineering team at Artsy, we've built a CMS for both internal and external editors to write and publish articles. We have about (x) editors internally writing new content on a regular basis. One of the issues we've been facing a problem with our article editor tool. Our users would go and override each other’s work without knowing because we've had no system in place to tell if someone else was currently editing the current article.

To keep that from occurring, their workflow would involve editing a draft in another editor such as google docs and once their article is ready, copy it over to our writer app. The goal of this project was to implement locking mechanism to only allow one editor per article. I had to come up with an elegant technical implementation for this problem. Here's how I went about it.

<!-- more -->

In order to fix that problem, we decided to build an article locking mechanism so only one of the editors on the team can start editing at once. One of the requirements for this new feature was for our editors to see when someone else started editing without refreshing the page. In order to fulfill this, we needed to implement a system to push events from the server to clients.

Based on the requirements presented, I looked at potential solutions for this. Right away, the HTML5 WebSocket API seemed to be the perfect solution to keep all clients synced in realtime, however a few issues arose. For one, many proxies and firewalls block WebSocket connections so it's not always an available option for clients.

At that point, we had already started the process of converting the app from using Backbone + jade to a modern javascript stack. Using React for UI components and Redux for managing app state. So whatever solution I came up with, it had to play well with redux. Redux emerged as the industry standard way implementing one-way data flow into your app, taking actions (events).  If you’re familiar with the redux architecture you know it comprises a single source of truth for state known as the store. Actions, action creators, reducers. (You can read this excellent [intro to react]() blog post to familiarize yourself with the topic if you aren't).

![/images/2018-03-15-integrating-redux-and-socketio/example.gif](/images/2018-03-15-integrating-redux-and-socketio/example.gif)

For server/client, I ended up using socket.io, a battle tested library for two-way real time communication channel. At that point, we were facing another challenge, how do we integrate socket.io in the react/redux architecture we just designed. also written in javascript for backend and clients combine the two. All that’s left to do is to integrate the two libraries.

Here's a simplified version of the helper function that I wrote to broadcast redux actions over the socket to other connected clients via our backend service.

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

After setting it up, all we needed to do is wrap action creators with `emitAction`, add a `key` property to the action object and we can decide to either process actions
 on the backend or proxy them to other clients. The remainder of the server implementation and the (server handlers)[] is available to inspect [here]() in our github repo. Which has instructions on how to run.

## Future improvements

There's an opportunity to extract this module for other projects and apps, also adding more helpers for handling events in other clients.

## Useful links

- [Redux]()
- [Socket.io](https://socket.io/)
