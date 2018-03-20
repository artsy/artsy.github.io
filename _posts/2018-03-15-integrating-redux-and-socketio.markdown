---
layout: post_longform
title: "Integrating Redux and Socket.io"
date: 2018-03-15
categories: [Technology, positron, javascript]
author: [luc]
---

On the engineering team at Artsy, we've built a CMS for both internal and external editors to write and publish articles. We have a team of (x) in-house editors creating new content on a daily basis. As multiple people would use the app simultaneously, something became apparent. Editors would unintentionally go and override each other’s work because there was no way to tell if another editor was currently editing an article. As a workaround, our editors are forced to edit drafts in another editor such as google docs andonly copy their work over once ready. This makes for a lackluster collaborative experience.

So we decided to implement locking mechanism that would make our editors more confident in our CMS by insuring only one editor can edit an article at any given time. I was tasked with coming up with an elegant technical solution for this feature. Here's the approach I took.

<!-- more -->

In order to fix that problem, we decided to build an article locking mechanism so only one of the editors on the team can start editing at once. One of the requirements for this new feature was for our editors to see when someone else started editing without refreshing the page. In order to fulfill this, we needed to implement a system to push events from the server to clients.

Based on the requirements presented, I looked at potential solutions for this. Right away, the HTML5 WebSocket API seemed to be the perfect solution to keep all clients synced in realtime, however a few issues arose. For one, many proxies and firewalls block WebSocket connections so it's not always an available option for clients. That's where socket.io comes in.
Socket.io, a battle tested library for two-way real time communication channel helps mitigate those problems. First socket.io establishes a long-polling HTTP connection, and in parallel it tries to upgrade to WebSocket.

By the time this project was proposed, we had already started the process of converting the app from using Backbone + jade to a modern javascript stack. Using React for UI components and Redux for managing app state. So naturally one of the goals was to leverage redux to manage state for this feature. If you've probably at least heard of Redux, as it's emerged to be the industry standard way implementing one-way data flow. If you’re familiar with the redux architecture you know it comprises a single source of truth for state known as the store. Actions, action creators, reducers. (You can read this excellent [intro to redux](https://www.smashingmagazine.com/2016/06/an-introduction-to-redux/) blog post to familiarize yourself with the topic if you aren't).

 So how do we go about integrating socket.io in the react/redux architecture we just designed. I thought the 

![/images/2018-03-15-integrating-redux-and-socketio/example.gif](/images/2018-03-15-integrating-redux-and-socketio/example.gif)

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
// actions.js
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

And on the receiving end, we simply add a reducer to process the event from the action payload which we can then return a new state from.

```javascript
//reducers.js
import { data as sd } from 'sharify'
import { actions } from 'client/actions/editActions'

export const initialState = {
  articles: sd.ARTICLES,
  articlesInSession: sd.ARTICLES_IN_SESSION || {}
}

export function articlesReducer (state = initialState, action) {
  switch (action.type) {
    ...
    case actions.START_EDITING_ARTICLE: {
      const session = action.payload

      return u({
        articlesInSession: {
          [session.article]: session
        }
      }, state)
    }
    ...
  }
}
```

After setting it up, all we needed to do is wrap action creators with `emitAction`, add a `key` property to the action object and we can decide to either process actions
 on the backend or proxy them to other clients. The remainder of the server implementation and the [server handlers](https://github.com/artsy/positron/blob/master/client/apps/websocket/index.js) is available to inspect [here](https://github.com/artsy/positron) in our github repo. Which has instructions on how to run.

## Future improvements

There's an opportunity to extract this module for other projects and apps, also adding more helpers for handling events in other clients.

## Useful links

- [Redux](https://redux.js.org/)
- [Socket.io](https://socket.io/docs/)
