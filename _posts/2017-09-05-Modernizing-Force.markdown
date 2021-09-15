---
layout: epic
title: Modernizing Force
comments: true
comment_id: 385
date: 2017-09-05
categories: [force, reaction, emission, javascript, typescript, react, babel, styled-components, artsy/express-reloadable, artsy/stitch]
author: chris
---

[Force](https://github.com/artsy/force) is Artsy's main website, [artsy.net](https://www.artsy.net). In the three years since it was [open-sourced](http://artsy.github.io/blog/2014/09/05/we-open-sourced-our-isomorphic-javascript-website/), it has provided a solid foundation to build features on top of without a lot of the costs associated with growth. It is an early example of Isomorphic ("universal") JavaScript, built on top of Express, Backbone, CoffeeScript, Stylus and Jade. It is also highly modular, adopting patterns laid down by its parent project,  [Ezel](https://github.com/artsy/ezel).

When first developed these technologies made a lot of sense; CoffeeScript fixed many of the problems with JavaScript pre-ES6, and Jade / Stylus made working with HTML / CSS much more elegant. As time progressed and new technologies became a thing these solutions starting feeling more burdensome to continue building features with and many of our developers longed to start using next-generation tools like React.

<!-- more -->

Looking at output from `cloc`, the question is "But how?"

```js
[artsy/force] $ cloc desktop mobile

--------------------------------------------------------
Language                     files                  code
--------------------------------------------------------
CoffeeScript                  1828                 81569
CSS                              9                 76632
Stylus                         577                 32324
JavaScript                     274                 18310
JSON                            30                  6145
Markdown                        41                  1097
HTML                             3                    25
XML                              3                    24
--------------------------------------------------------
SUM:                          2765                216126
--------------------------------------------------------

```

216k+ LOC, spread across multiple languages and formats. Given finite resources and a small team rebuilds can be difficult to execute, and so we had to figure out a way to marry the old with the new while also maintaining backwards compatibility / interoperability. Out of this exercise came a few patterns, libraries and projects that I would like to describe in an effort to help those caught in similar situations.

## Step 1: Get Your House (aka Compiler) in Order

[Babel](https://babeljs.io/) has been around for a while, but lately their team has been putting effort into making it as easy as possible to use. By dropping a [.babelrc](https://github.com/artsy/force/blob/master/.babelrc) file into the root of your project, server and client-side JavaScript can share the same configuration, including [module resolution](https://github.com/tleunen/babel-plugin-module-resolver) (aka, no more `../../../`).

A simplified example:

```json
// .babelrc

{
  "presets": ["es2015", "react", "stage-3"],
  "plugins": [
    ["module-resolver", {
      "root": ["./"]
    }]
  ]
}
```

```js
// index.js

require('coffee-script/register')
require('babel-core/register')

// Start the app
require('./boot')

```
On the client, we use [Browserify](http://browserify.org/) with [Coffeeify](https://github.com/substack/coffeeify) and [Babelify](https://github.com/babel/babelify):

```json
// package.json

{
  "scripts": {
    "assets": "browserify -t babelify -t coffeeify -o bundle.js",
    "start": "yarn assets && node index.js"
  }
}
```
And then boot it up:
```sh
$ yarn start
```

By adding just a few lines, our existing CoffeeScript pipeline was augmented to support modern JavaScript on both the server and the client, with code that can be shared between.

## Step 2: Tune-up Iteration Time
<a name="iteration-time"></a>

A question that every developer should ask of their stack is:

> "How long does it take for me to make a change and see that change reflected in a running process?"

Does your code take one second to compile, or ten? When writing a back-end service, does your server [automatically restart](https://github.com/remy/nodemon) after you make a change, or do you need to `ctrl+c` (stop it) and then restart manually?

For those of us working in Force, the bottleneck typically involved making changes to back-end code. Due to how we organize our sub-apps, client-side code compilation -- after the server heats up -- is pretty much instant, but that heat-up time can often take a while depending on which app we're working on. So even with a "restart on code change" setup that listens for updates it still felt terribly slow, and this iteration time would often discourage developers from touching certain areas of the codebase. We needed something better!

Enter Webpack and React, which helped popularize the concept of HMR, or "Hot Module Replacement".

From the Webpack docs:
> "Hot Module Replacement (HMR) exchanges, adds, or removes modules while an application is running, without a full reload."

That's more like it! But is there anything similar for the server given we don't use Webpack? This was the question [@alloy](https://github.com/alloy), one of our Engineering Leads, asked himself while researching various setups that ultimately led to [Reaction](https://github.com/artsy/reaction), and for which he found an answer to in Glen Mailer's excellent [ultimate-hot-reloading-example](https://github.com/glenjamin/ultimate-hot-reloading-example). Digging into the code, [this little snippet](https://github.com/glenjamin/ultimate-hot-reloading-example/blob/master/server.js#L38-L45) jumped out:

```js
watcher.on('ready', function() {
  watcher.on('all', function() {
    console.log("Clearing /server/ module cache from server");
    Object.keys(require.cache).forEach(function(id) {
      if (/[\/\\]server[\/\\]/.test(id)) delete require.cache[id];
    });
  });
});
```

The code seemed simple enough -- on change, iterate through Node.js's internal require cache, look for the changed module, and clear it out. When the module is `require`'d at a later point it will be like it was required for the first time, effectively hot-swapping out the code.

With this knowledge we wrapped a modified version of this snippet into [@artsy/express-reloadable](https://github.com/artsy/express-reloadable), a small utility package meant to be used with Express.

Here's a full example:

```js
import express from 'express'
import { createReloadable, isDevelopment } from '@artsy/express-reloadable'

const app = express()

if (isDevelopment) {

  // Pass in app and current `require` context
  const reloadAndMount = createReloadable(app, require)

  // Note that if you need to mount an app at a particular root (`/api`), pass
  // in `mountPoint` as an option.
  app.use('/api', reloadAndMount(path.resolve(__dirname, 'api'), {
    mountPoint: '/api'
  }))

  // Otherwise, just pass in the path to the express app and everything is taken care of
  reloadAndMount(path.resolve(__dirname, 'client'))
} else {
  app.use('/api', require('./api')
  app.use(require('./client')
}

app.listen(3000, () => {
  console.log(`Listening on port 3000`)
})
```

In Force, we mounted this library [at the root](https://github.com/artsy/force/blob/master/lib/setup.js#L205), allowing us to make changes anywhere within our numerous sub-apps and with a fresh page reload instantly see those changes reflected without a restart. This approach also works great with API servers, as this implementation from Artsy's [editorial app Positron](https://github.com/artsy/positron/blob/master/boot.js#L34) shows. Like magic, it "just works". Why isn't this trick more widely used and known?

## Step 3: The View Layer, or: How I Stopped Worrying and Learned to Love Legacy UI

This one was a bit tricky to solve, but ultimately ended up being fairly straightforward and conceptually simple. In Force, we've got dozens of apps built on top of hundreds of components supported by thousands of tests stretched across desktop and mobile. From the perspective of sheer code volume these things aren't going anywhere any time soon. On top of that, our view templates are built using Jade (now known as [Pug](https://pugjs.org)), which supports an interesting form of inheritance known as [blocks](https://pugjs.org/language/inheritance.html). What this means in practice is our UI has been extended in a variety of complex ways making alternative view engines difficult on the surface to interpolate.

What to do? It's 2017 and the era of handlebars templates bound to Backbone MVC views is over. We want [React](https://facebook.github.io/react/)! We want [Styled Components](https://www.styled-components.com/)! And when those tools are surpassed by the Next Big Thing we want that too! But we also want our existing CoffeeScript and Jade and old-school `Backbone.View`s as well.

Thinking through this problem, [@artsy/stitch](https://github.com/artsy/stitch) was born.

Stitch helps your Template and Component dependencies peacefully co-exist. You feed it a layout and some data and out pops a string of compiled html that can be passed down to the client. "Blocks" can be added that represent portions of UI, injected by key. It aims for maximum flexibility: templating engines supported by [consolidate](https://github.com/tj/consolidate.js) can be installed and custom rendering engines [can be swapped out or extended](https://github.com/artsy/stitch#custom-renderers). With very little setup it unlocks UI configurations that have been lost to time.

A basic example:

{% raw %}
```html
<div>
  {{title}}
</div>
```
{% endraw %}
```js
const html = await renderLayout({
  layout: 'templates/layout.handlebars',
  data: {
    title: 'Hello!'
  }
})

console.log(html)

// => Outputs:
/*
<div>
  Hello!
</div>
*/
```

By adding "blocks" you can begin assembling (or adapting to) more complex layouts. Blocks represent either a path to a template or a component (with "component" meaning a React or [React-like](https://preactjs.com) function / class component):

{% raw %}
```html
// templates/layout.handlebars

<html>
  <head>
    <title>
      {{title}}
    </title>
  </head>
  <body
    {{{body}}}
  </body>
</html>
```
{% endraw %}

```js
// index.js

const html = await renderLayout({
  layout: 'templates/layout.handlebars',
  data: {
    title: 'Hello World!',
  },
  blocks: {
    body: (props) => {
      return (
        <h1>
          {props.title}
        </h1>
      )
    }
  }
})

console.log(html)

// => Outputs:
/*
<html>
  <head>
    <title>Hello World!</title>
  </head>
  <body>
    <h1>
      Hello World!
    </h1>
  </body>
</html>
*/
```

In Force, we're using this pattern to incrementally migrate portions of our app over to React, by taking existing block-based Jade layouts and injecting `ReactDOM.renderToString` output into them, and then rendering the layout into an HTML string that is passed down from the server and rehydrated on the client, isomorphically.

Our existing Backbone views take advantage of the `templates` key:

```js
// server.js

import LoginApp from 'apps/login/LoginApp'
import { Provider } from 'react-redux'
import { StaticRouter } from 'react-router'

const html = await renderLayout({
  layout: 'templates/layout.handlebars',
  data: {
    title: 'Login / Sign-up',
  },
  templates: {
    login: 'templates/login.jade'
  },
  blocks: {
    app: (props) => (
      <Provider store={store}>
        <StaticRouter>
          <LoginApp {...props} />
        </StaticRouter>
      </Provider>
    )
  }
})

res.send(html)
```

Similar to blocks, templates located in this object are pre-compiled and available to your components as `props.templates`.

Once the html has been sent over the wire, we mount it like so:

```js
// client.js

import LoginApp from 'apps/login/LoginApp'

React.render(
  <LoginApp {...window.__BOOTSTRAP__} /> // Data passed down from `data` key
)
```

```js
// apps/login/LoginApp.js

import React from 'react'
import Login from 'apps/login/Login'

export default function LoginApp (props) {
  const {
    templates: {
      login
    }
  } = props

  return (
    <Login
      template={login}
    />
  )
}
```

During the server-side render phase existing template code will be rendered with the component, and once the component is mounted on the client `componentDidMount` will fire and the Backbone view instantiated:

{% raw %}
```js
// apps/login/Login.js

import React, { Component } from 'react'
import LoginBackboneView from 'apps/login/views/LoginView'

export default class Login extends Component {
  componentDidMount () {
    this.loginView = new LoginBackboneView()
    this.loginView.render()
  }

  componentWillUnmount () {
    this.loginView.remove()
  }

  render () {
    return (
      <div>
        <div dangerouslySetInnerHtml={{
          __html: this.props.template
        }}>
      </div>
    )
  }
}
```
{% endraw %}

All of the possibilities that Stitch provides are too numerous to go over here, but check out the [documentation](https://github.com/artsy/stitch#usage) and [example apps](https://github.com/artsy/stitch/tree/master/examples) for more complete usage. While new, this pattern has worked quite well for us and has allowed Force to evolve alongside existing code with very little friction.

## Moving Forward

A common thread that connects [Force](https://github.com/artsy/force) to [Eigen](https://github.com/artsy/eigen) (Artsy's mobile app) is an understanding that while grand re-writes will gladly remove technical debt, technical debt is not our issue. A lot of the patterns we've laid down within our apps still work for us, and many of our implementations remain sufficient to the task. What we needed was an environment where _incremental revolution_ was possible, where old ideas could merge with new and evolve. In terms of Eigen, we felt the best way forward was the adoption of [React Native](https://facebook.github.io/react-native/) -- and [Emission](https://github.com/artsy/emission) was born. Likewise, for our web and web-based mobile apps, [Reaction](https://github.com/artsy/reaction) is serving a similar role. Both of these projects are built with [TypeScript](https://www.typescriptlang.org/), and both rely heavily on functionality that our [GraphQL](http://graphql.org/) interface [Metaphysics](https://github.com/artsy/metaphysics) provides. But crucially, these projects _augment_ our existing infrastructure; they don't replace it. They fit in with existing ideas, tools and processes that have facilitated Artsy's growth, including highly-specific domain knowledge that our engineers have built up over time.

In conclusion, I hope this post has provided a bit of a window into some of our processes here at Artsy for those facing similar challenges. If you want to take a deeper dive, check out the links below:

- [express-reloadable](https://github.com/artsy/express-reloadable)
- [stitch](https://github.com/artsy/stitch)
- [reaction](https://github.com/artsy/reaction)
- [emission](https://github.com/artsy/emission)
