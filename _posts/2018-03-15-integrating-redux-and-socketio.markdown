---
layout: epic
title: "Integrating Redux and Socket.io"
date: 2018-03-15
categories: [Technology, positron, javascript]
author: [luc]
---

On the engineering team at Artsy, we've built a CMS for both internal and external editors to write and publish [articles](https://www.artsy.net/article/artsy-editorial-brooklyn-born-sisters-diego-rivera-dubbed-the-greatest-living-women-mural-painters). We have a team of a dozen in-house editors creating new content on a daily basis. As many people starting using the app simultaneously, something became apparent. Editors would unintentionally go and override each other’s work because there was no way to tell if someone else was currently editing an article. As a workaround, team members would be forced to edit drafts in another editor such as google docs and copy their work over once ready. This made for a lackluster collaborative experience.

So we decided to implement a system that would make our editors more confident in our CMS by ensuring only one editor could go in and edit an article at any given time. I was tasked with coming up with an elegant technical solution for this feature. Here's the approach I took....

<!-- more -->

We decided to resolve this issue building an article locking mechanism. When an editor would start editing an article, all other users in sessions would be notified. One of the requirements for this new feature was for things needed to update without refreshing the page. In order to fulfill this, we needed to implement a system to push events from the server to clients.

Based on the requirements presented, I looked at potential solutions for this. Right away, the HTML5 WebSocket API seemed like the perfect solution to keep all clients synced in realtime, however a few issues arose. For one, many proxies and firewalls block WebSocket connections, so it's not always an available option for clients. I needed to find another option to mitigate that problem. That's where [socket.io](https://socket.io) comes in.

Socket.io, a battle tested library for creating real-time bidirectional communication channels, helps mitigate those problems. In a gist socket.io initially establishes a long-polling HTTP connection, and in parallel tries to upgrade it to WebSocket.

By the time this project was proposed, we had already started the process of converting the app from using Coffeescript, Backbone + Jade to a modern javascript stack based on ES6, React for UI components and Redux for managing app state. Naturally, one of the goals was to leverage Redux to manage state for this feature. You've probably at least heard of Redux as it has emerged as the industry standard way of implementing one-way data flows in apps. If you're not familiar with Redux and its architecture, here's an excellent [intro to redux](https://www.smashingmagazine.com/2016/06/an-introduction-to-redux/) article to familiarize yourself.

 So how do we go about integrating socket.io in the Redux-based state architecture we just designed. I thought the best would be to change as little as possible to the code structures developers familiar with Redux are already used to. Namely, use standard Redux actions creators and simply use a decorator to enhance them.

![/images/2018-03-15-integrating-redux-and-socketio/example.gif](/images/2018-03-15-integrating-redux-and-socketio/example.gif)

Here's a simplified version of the [function decorator](https://leanpub.com/javascriptallongesix/read#decorators) which broadcasts redux actions via a socket connection to other connected clients.

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

To recap the code above, `emitAction` is a [function decorator](https://leanpub.com/javascriptallongesix/read#decorators) that enhances action creators to dispatch actions via the local store and also broadcast that same action to other connected clients. The following code snippet shows how it's being used to wrap a typical redux action creator.

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

On the receiving end, we simply add a reducer to process the event from the action payload which we can then return a new state from.

```javascript
//reducers.js
import { data as sd } from 'sharify'
import { actions } from 'client/actions/editActions'
import u from 'updeep'

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

We can now use our `emitAction` decorator function to enhance any number of action creators. All that's needed is to add a `key` property to the action object. We can then decide to either process actions
 on a backend service or proxy them directly to other clients. You can find the remainder of the server implementation and our [event handlers](https://github.com/artsy/positron/blob/master/src/client/apps/websocket/index.js) in our [github repo](https://github.com/artsy/positron) along with instructions on how to run the code.

## Future improvements

There's an opportunity to extract this module for reuse in other projects and apps. Another logical improvement to this project would be to implement collaborative editing using this architecture. It would also be nice to include helpers for handling events on backend servers.

## Useful links

- [Redux](https://redux.js.org/)
- [Socket.io](https://socket.io/docs/)
- [Updeep](https://github.com/substantial/updeep)
