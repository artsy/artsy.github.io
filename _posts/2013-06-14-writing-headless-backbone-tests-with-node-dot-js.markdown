---
layout: post
title: "Writing Headless Backbone Tests With Node.js"
date: 2013-06-14 17:48
comments: true
categories: [Javascript, Backbone.js, Node.js, testing]
author: craig
---

## TL;DR

Write fast, headless, tests for Backbone using Node.js. See this project as an example  [https://github.com/craigspaeth/backbone-headless-testing](https://github.com/craigspaeth/backbone-headless-testing).

## A Brief History

Artsy is mostly a thick client [Backbone](http://backbonejs.org/) app that sits on [Rails](http://rubyonrails.org/) and largely depends on [Capybara](http://jnicklas.github.io/capybara/) ([Selenium](http://docs.seleniumhq.org/) backed bot that clicks around Firefox) for testing it's javascript. This leads to some seriously brittle and slow integration tests. [Despite being able to wrangle Capybara](http://artsy.github.io/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/) to do most of our client-side testing, we knew there must be a better way.

When building a CMS app for our gallery partners to manage their Artsy inventory, we built a new Backbone app on top of [node.js](http://nodejs.org/). The result was a headless test suite that runs around 60 times faster.

Let's take a look at how it's done.

<!-- more -->

## Setting Up The Environment

The trick to testing client-side code in node.js is creating an environment that mimics the browser. [Jsdom](https://github.com/tmpvar/jsdom) does just that by bringing a pure javascript implementation of the DOM to node.js.

``` javascript
jsdom.env({
  html: "<html><body></body></html>",
  done: function(errs, window) {
    global.window = window;
    // ...
    callback();
  }
});
```

At this point we've globally exposed the `window` object of our jsdom browser. However the DOM isn't the only global dependency in most of our client-side code. We'll also need to expose our common libraries like Backbone, Underscore, and jQuery.

``` javascript
global.window = window;
global.Backbone = require('../app/javascripts/vendor/backbone.js');
global.Underscore = require('../app/javascripts/vendor/underscore.js');
global.jQuery = require('../app/javascripts/vendor/jQuery.js');
```

We can simply require Backbone, Underscore, and jQuery like any node module because they follow [CommonJS](http://wiki.CommonJS.org/wiki/Modules/1.1.1) convention. However not all libraries are CommonJS compatible, and in this case you might have to expose their attachment to `window`.

``` javascript
global.window = window;
require('../app/javascripts/vendor/zepto.js');
global.Zepto = window.Zepto;
```

Finally you probably have a namespace like `App` which your components attach to.

``` javascript
global.window = window;
// Libraries
global.Backbone = require('../app/javascripts/vendor/backbone.js');
global.Underscore = require('../app/javascripts/vendor/underscore.js');
global.jQuery = require('../app/javascripts/vendor/jQuery.js');
// Namespace
global.App = {};
// We're ready to test some Backbone components
```

Try to keep global dependencies to a minimum. This reduces setup/teardown, increases modularity, and makes it easier to test your code.

For example, instead of attaching a view to `App` it might be better to pass that view in to the options of another so you can call `this.options.header.doSomething()`.

## Unit Testing Models

Because all good javascript guides are based off Todo apps, let's pretend we're testing a Todo model.

``` javascript
App.Todo = Backbone.Models.extend({

  urlRoot: '/api/todo',

  complete: function() {
    var self = this;
    $.ajax({
      url: '/api/todos/' + this.get('id') + '/complete',
      type: 'PUT',
      success: function() { self.set({ completed: true }); }
    });
  }
});
```

Let's test that `#complete` makes the proper API PUT and `completed` is updated to true. After we setup our jsdom environment we need to stub `$.ajax` using [sinon](http://sinonjs.org/docs/#stubs) as we won't be sending XHRs in node.

``` javascript
before(function(done) {
  jsdom.env({
    html: "<html><body></body></html>",
    done: function(errs, window) {
      global.$ = require('../../app/javascripts/vendor/jquery.js');
      //...
    }
  });
});

beforeEach(function(done) {
  ajaxStub = sinon.stub($, 'ajax');
  todo = new App.Todo({ title: 'Feed the cat', id: 'feed-the-cat' });
});
```

Now we can simply assert that `$.ajax` was called with the right params and completed changed.

``` javascript
it('PUTs to the API', function() {
  todo.complete();
  $.ajax.args[0][0].type.should.equal('PUT');
  $.ajax.args[0][0].url.should
    .equal('/api/todos/feed-the-cat/complete');
});

it('updates the item to be completed', function() {
  todo.set('completed', false);
  $.ajax.args[0][0].success();
  todo.get('completed').should.equal(true);
});
```

## Unit Testing Views

Models are easy to unit test because they're mostly self-contained javascript. However a Backbone view might expect some server-side rendered HTML, use client-side templates, communicate to other views, and so on. This makes it harder to test but manageable given our set up.

Let's pretend we have a view that renders our todo list inside a server-side rendered element, and uses a client-side template to fill in the actual list items.

Our DOM might look something like this:

``` html
<div id='todos'>
  <h1>Things I need to do today</h1>
  <ul class='todos-list'></ul>
</div>
```

and our view might look something like this:

``` javascript
App.TodosListView = Backbone.View.extend({

  el: '#todos',

  template: JST['todos/list_items'],

  initialize: function() {
    this.collection.bind('add remove', this.render);
  },

  render: function() {
    this.$('.todos-list')
      .html(this.template({ todos: this.collection.models }));
  }
})
```

We can render the server-side `#todos` element by compiling the express view into html and injecting it straight in jsdom with our globally exposed jQuery.

``` javascript
filename = path.resolve(__dirname, '../app/views/index.jade');
template = fs.readFileSync(filename).toString();
html = jade.compile(template, { filename: filename })();
$('html').html(html);
```

Next we need to expose our client-side templates. In this case I'm assuming client-side templates are pre-compiled into functions namespaced under a global JST object like in the [Rail's asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html) (if you're looking for a node.js tool [nap](https://github.com/craigspaeth/nap) is what Artsy uses).

We need to mimic what the JST functions are expecting so that when calling `JST['foo/bar']({ foo: 'some-data' })` we get back a string of html.

``` javascript
global.JST = {};
var filename = path.resolve(
  __dirname,
  '../app/javascripts/templates/todos/list.jade'
);
JST['todos/list'] = jade.compile(
  fs.readFileSync(filename).toString(),
  { filename: filename }
);
```

With our server-side HTML injected and our client-side templates ready to use, all that's needed is to require any other dependent Backbone components. This boilerplate can get pretty repetitive and would be good to wrap up into a helper.

``` javascript
var clientenv = require('../helpers/clientenv');

before(function(done) {
  clientenv.setup(function() {
    global.App.Todo = require('../app/javascripts/models/todo.js');
    global.App.Todos = require('../app/javascripts/collections/todos.js');
    done();
  });
});

beforeEach(function(done) {
  var templateFilename = path.resolve(
        __dirname,
        '../../views/index.jade'
      ),
      html = require('jade').compile(
        fs.readFileSync(templateFilename).toString(),
        { filename: templateFilename }
      )();
  $('html').html(html);
  view = new App.TodosListView();
  done();
});

it('renders items as they are added', function() {
  view.collection.add([
    new App.Todo({ title: 'clean the kitchen' })
  ]);
  view.$el.html().should.include('clean the kitchen');
});
```

With a little bit more work, testing views in node can be almost as easy as testing models.

## Integration Tests

Although I encourage writing way more unit test coverage as they're faster and less brittle, it is necessary to have integration tests to cover longer scenarios. At Artsy we use some tricks to make integration testing less painful.

### Stubbing the API Layer

In Artsy's case we're consuming a JSON API service that already has ample test coverage, so it makes sense to cut off integration at this point and stub our API responses.

To do this we can conditionally check which environment we're running in and swap out the API to use a real API or an [express](http://expressjs.com/) app serving a stubbed API.

``` javascript
if(app.get('env') == 'test') {
  app.set('api url', 'http://localhost:5000');
  // Create a mock api server in your test helpers
  // and run it on 5000 in a before block
} else {
  app.set('api url', 'http://api.my-app.com');
}
// Bootstrap in your server-side view so the client app
// knows where to point
app.locals.API_URL_ROOT = app.get('api url');
```

If our API was hosted on the same server as our client app, or we're proxying API calls because of lack of [CORS](http://en.wikipedia.org/wiki/Cross-Origin_Resource_Sharing) support, this could be as easy as swapping out middleware.

``` javascript
if(app.get('env') == 'test') {
  app.use('/api', require('./test/helpers/mock_api'));
} else {
  app.use('/api', require('./routes/api'));
}
```

This speeds up integration tests and simplifies the stack by not populating a database or booting an API server.

### Headless Integration Tests with Zombie.js

Selenium has to actually boot up Firefox and poll the UI to wait for things to appear. This disconnect means extra seconds of "wait_util we're sure" time.  [Zombie.js](http://zombie.labnotes.org/) is backed by our friend jsdom and alleviates these issues by giving us a fast headless browser that we can programmatically access.

Of course the caveat to headless testing is that you can't visually see how a test is actually failing. Using `{ debug: true }` in your options will spit every Zombie action to stdout. In most cases this is enough, but sometimes you need to go a step further and actually visualize what the test is doing.

A trick we use is to write tests using the browser's `jQuery`. This is more familiar than Zombie's DSL and lets you copy and paste test code directly in your browser's console to see if it's actually doing what you want.

.e.g

``` javascript
Browser.visit('http://localhost:5000', function(err, browser) {
  var $ = browser.window.$;

  // From here we can run `NODE_ENV=test node app.js` and copy
  // this code right into our browser's console.
  $('#add-todo').val('Foo').change();
  });
}
```

## Conclusion

Using these techniques has greatly increased productivity and developer happiness for testing client-side code. For an example implementation of this see [https://github.com/craigspaeth/backbone-headless-testing](https://github.com/craigspaeth/backbone-headless-testing).

Looking forward, testing client-side code can be made even better by using a package manager that adds require functionality like [browserify](https://github.com/substack/node-browserify), [component](https://github.com/component/component), or [require.js](http://requirejs.org/). But I've gone far enough for now, maybe in another blog post (leave a comment if you're interested).
