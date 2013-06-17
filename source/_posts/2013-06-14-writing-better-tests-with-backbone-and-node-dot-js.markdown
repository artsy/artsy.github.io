---
layout: post
title: "Writing Better Tests With Backbone and Node.js"
date: 2013-06-14 17:48
comments: true
categories: [Javascript, Backbone.js, Node.js]
---

# Outline
* Brief History
* Setting up an environment for unit tests
  * Node, Express, mocha, sinon, should
  * Use jsdom to create a browser environment in the server
  * Expose App namespace and expose other window objects (Backbone, jQuery, Underscore)
  * See the reason why minimum global dependencies are a good thing
* Simple unit test on a model
  * Create a Todo model with complete method
  * Stub ajax
  * Assert on ajax args
* View Tests
  * Todo list item view
  * Render your templates into jsdom
  * Expose any client-side templates globally
  * Require any other dependencies like App.Todos
* Integration Tests
  * Conditionally start your app server & expose it for testing on different port
  * Swap your API routes for a stubbed API to keep DB clean and fast
  * Use zombie to visit your app server running in test mode
  * Spy on ajax
* Final notes
  * See it in action https://github.com/craigspaeth/backbone-headless-testing
  * use browserify/require/component/bower to bring modularity and package management to the client for even easier testing

## TL;DR

Write fast headless tests for your client-side javascript using Backbone and Node.js. See this project as an example  (https://github.com/craigspaeth/backbone-headless-testing)[https://github.com/craigspaeth/backbone-headless-testing].

## A Brief History

If you've been keeping up with this blog you may have figured out that Artsy is a thick client [Backbone](http://backbonejs.org/) app sitting on top of [Rails](http://rubyonrails.org/) and consuming a [Grape](https://github.com/intridea/grape) API. Getting to this point was certainly no breeze and involved many growing pains, one of the biggest being testing our thick-client Backbone app in a thick-server ruby framework.

To this day we mostly have adopted a large integration suite using [Capybara](http://jnicklas.github.io/capybara/) (a [Selenium](http://docs.seleniumhq.org/) backed DSL) and a smaller set of unit tests with [Jasmine](http://pivotal.github.io/jasmine/) using the [jasmine-rails](https://github.com/searls/jasmine-rails) gem. Unfortunately depending on a large integration suite that has a bot clicking around an actual browser leads to some seriously slow and brittle tests that aren't all that easy to integrate with CI. Even so, [we've been able to wrangle Capybara](http://artsy.github.io/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/) to do most of our UI testing, but there has always been a lurking feeling that there must be a better way.

When faced with building a CMS app for our gallery partners to manage their own Artsy inventory, we got a chance to build and test a similar Backbone app, but this time backed by [node.js](http://nodejs.org/). The result was a headless test suite that runs around 60 times faster, focusing on more unit test coverage.

Lets take a look at how it's done.

## Setting up an environment for unit tests

Lets assume you want to test

The trick to running headless unit tests on your client-side javascript code is creating an environment that mimics the browser without having to actually fire up a browser like Firefox. Luckily node.js has the perfect project for this called [jsdom](https://github.com/tmpvar/jsdom). This amazing project brings a pure javascript implementation of the browser right to your node.js console.

````
npm install jsdom
````

Although parts of Backbone can work on the server without a DOM implementation this will make it much easier to use libraries like jQuery and will be necessary to unit test view code. The next step is to use jsdom to expose a browser environment globally in the way that client-side code expects it.

````
var jsdom = require('jsdom');

jsdom.env({
  html: "<html><body></body></html>",
  done: function(errs, window) {
    global.window = window;
    // ... 
    callback();
  }
});
````

At this point we've globally exposed the `window` of our fake browser environment which is the first step to getting Backbone modules on the server to work. However unfortunately our client-side code isn't only assuming we have access to the DOM but probably a long set of global dependencies.

Without a module system on the client (like browserify or require.js) we can garuntee that we'll want to globally expose a bunch of other libraries. In a backbone app we can assume we'll always want to expose Backbone, Underscore, and jQuery.

````
var jsdom = require('jsdom');

jsdom.env({
  html: "<html><body></body></html>",
  done: function(errs, window) {
    global.window = window;
    global.Backbone = require('../public/javascripts/vendor/backbone.js');
    global.Underscore = require('../public/javascripts/vendor/underscore.js');
    global.jQuery = require('../public/javascripts/vendor/jQuery.js');
    callback();
  }
});
````

As you can see above Backbone, Underscore, and jQuery are wrapped in commonjs definitions (same definition node modules use). This allows us to simply require them just like any other node module.

However not all libraries are, and in this case you might have to expose their attachment to window.

````
done: function(errs, window) {
  global.window = window;
  require('../public/javascripts/vendor/zepto.js');
  global.Zepto = window.Zepto;
  //...
}
````

If the library doesn't have a module definition or explicitly attach to window then you should probably stub it using sinon `global.loadImage = sinon.stub()`. Otherwise you'll be tasked with tampering with the library itself. But hey, we're unit testing here, so it's not important to test the integration of every third party library.

Finally you probably have a namespace like `App` which your components will expect when required.

````
done: function(errs, window) {
  global.window = window;
  //...
  global.App = {};
  // We're ready to require some Backbone components
}
````

As you can see keeping global dependencies to a minimum will not only reduce this boilerplate and make it easier to test your code, but also increase the quality of your code by ensuring modularity.

## Simple unit test on a model

Now that we've exposed a browser-like environment in node.js lets test a Backbone Model. Because all good javascript guides are based off Todo apps, let's pretend we're testing a Todo model.

``` javascript public/javascripts/models/todo.js
App.Todos = Backbone.Collection.extend({
  
  model: App.Todo,
  
  url: '/api/todos' 
  
  complete: function() {
    var self = this;
    $.ajax({
      url: '/api/todos/' + this.get('id') + '/complete',
      type: 'PUT'
    }).then(function() {
      self.set({ completed: true });
    });
  }
});
```

To start, let's write a test for `complete` asserting our API call was made and completed was updated to true. We'll want to setup our browser-like environment in a `before` hook and stub `$.ajax` because we aren't actually going to be making XHR requests in node.

``` javascript app/test/javascripts/models/todo.js
describe('Todos', function() {
  
  var todo, ajaxStub, dfd;
  
  before(function(done) {
    jsdom.env({
      html: "<html><body></body></html>",
      done: function(errs, window) {
        global.window = window;
        global.Backbone = require('../../public/javascripts/vendor/backbone.js');
        global.Backbone.$ = global.$ = require('../../public/javascripts/vendor/jquery.js');
        global._ = require('../../public/javascripts/vendor/underscore.js');
        global.App = {};
        require('../../public/javascripts/models/todo');
        done();
      }
    });
  });
  
  beforeEach(function(done) {
    dfd = $.Deferred();
    todo = new App.Todo({ title: 'Feed the cat', id: 'feed-the-cat' });
    ajaxStub = sinon.stub($, 'ajax');
    ajaxStub.returns(dfd);
  });
  
  afterEach(function(done){
    ajaxStub.restore();
  });
  
  describe('#complete', function() {
    
    it('updates the item to be completed', function() {
      todo.set('completed', false);
      todo.complete();
      dfd.resolve();
      todo.get('completed').should.equal(true);
    });
    
    it('PUTs to the API', function() {
      todo.complete();
      dfd.resolve();
      $.ajax.args[0][0].type.should.equal('PUT');
      $.ajax.args[0][0].url.should.equal('/api/todos/feed-the-cat/complete');
    });
  });
});
```

In practicality one would probably build their API so they could simply `todo.save({ completed: true })` but hopefully this is a useful example.

# View tests

Model tests are fairly straight forward because by their nature they're mostly self contained javascript code. Things get a little bit more complicated as you have to integrate more parts. A Backbone view might expect some server-side rendered HTML to exist, use client-side templates, depend on model/collection classes, communicate to other views like nested child views or global layout views, and have interactions like animation that's not meant to happen headlessly. This makes it harder to write unit tests for, but manageable given our set up.

Lets pretend we have a list view that renders our todo list. It'll expect there to be a `#todos` element in the DOM that looks something like this.

````html
<div id='todos'>
<h1>Things I need to do today</h1>
<ul class='todos-list'></ul>
<input class='add-todo'>
</div>
````

And will render a list of todos inside `ul.todos-list` by using a client-side javascript template and binding to a collection's events.

``` javascript public/javascripts/views/todos/list.js
App.TodosListView = Backbone.View.extend({
  
  el: '#todos',
  
  template: JST['todos/list'],
  
  initialize: function() {
    this.collection = new App.Todos;
    this.collection.bind('add remove', this.render);
    //...
  },
  
  render: function() {
    this.$('.todos-list').html(this.template({ todos: this.collection.models }))
  },
  
  events: {
    'change .add-todo': 'addTodo'
  },
  
  addTodo: function(event) {
    var todo = new App.Todo({ title: $(event.target).val() });
    this.collection.add(todo);
  }
})
```

To begin unit testing this inside node we'll first need to make sure the '#todos' element is rendered inside jsdom. Since `$` is globally exposed and pointing to jsdom's `window` we can simply compile the express view into html and render it directly with good ol' `$('html').html`.

````javascript
var filename = path.resolve(__dirname, '../app/views/index.jade'),
    html = require('jade').compile(
      fs.readFileSync(filename).toString(),
      { filename: filename }
    )();
$('html').html(html);
````

Now that we've got our server-side template rendered in our jsdom environment we'll need to make sure our client-side template is available as well. In this case I'm assuming client-side templates are packaged up into functions name-spaced under a global JST object like in the [Rail's asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html). In our case we use [nap](https://github.com/craigspaeth/nap) to do our asset management, but there are other various options for packaging client-side templates. We'll want to mimic what the client JST functions are expecting so that when we call `JST['foo/bar']({ foo: 'some-data' })` we'll get back a string of html. In this example we're using jade, but you can imagine how this might be configured with another templating language.

````javascript
var jade = require('jade');

global.JST = {};
var filename = path.resolve(__dirname, '../public/javascripts/templates/todos/list.jade');
JST['todos/list'] = jade.compile(fs.readFileSync(filename).toString(),
  { filename: filename}
);
````

With these two dependencies out of the way, now the view only assumes globally available classes like `App.Todo` which we can require after exposing `window`, `Backbone`, `App`, etc. like exampled above in the model test.

Since we'll being doing this fake-browser setup in every unit test we write, lets pretend we wrapped it up into a test helper called `clientenv` and write an example view test.

``` javascript test/unit/views/todos/list.js
var clientenv = require('../helpers/client_env');

describe('TodosListView', function() {
  
  var view;
  
  beforeEach(function(done) {
    clientenv.setup(function() {
      // We now have window, App.Todos, JST, and more available globally
      
      // Compile our server-side template and render it in jsdom
      var templateFilename = path.resolve(__dirname, '../../views/index.jade'),
          html = require('jade').compile(
            fs.readFileSync(templateFilename).toString(),
            { filename: templateFilename }
          )();
      $('html').html(html);
      
      // Require our view
      view = new App.TodosListView();
      done();
    });
  });
  
  afterEach(function(){
    ajaxStub.restore();
  });
  
  describe('#initialize', function() {
    
    it('renders items as they are added', function() {
      view.collection.add([new App.Todo({ title: 'clean the kitchen' })]);
      view.$el.html().should.include('clean the kitchen');
    });
  });
});
```