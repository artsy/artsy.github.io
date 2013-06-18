---
layout: post
title: "Writing Better Tests With Backbone and Node.js"
date: 2013-06-14 17:48
comments: true
categories: [Javascript, Backbone.js, Node.js]
---

## TL;DR

Write fast, headless, tests for Backbone using Node.js. See this project as an example  [https://github.com/craigspaeth/backbone-headless-testing](https://github.com/craigspaeth/backbone-headless-testing).

## A Brief History

If you've been keeping up with this blog you may have figured out that Artsy is a thick client [Backbone](http://backbonejs.org/) app sitting on top of [Rails](http://rubyonrails.org/) and consuming a [Grape](https://github.com/intridea/grape) API. Getting to this point was certainly no breeze and involved many growing pains, one of the biggest being testing our thick-client Backbone app in a thick-server ruby framework.

To this day we mostly have adopted a large integration suite using [Capybara](http://jnicklas.github.io/capybara/) and a smaller set of unit tests with [Jasmine](http://pivotal.github.io/jasmine/). Unfortunately depending on a large integration suite that has a bot clicking around an actual browser leads to some seriously slow and brittle tests that aren't all that easy to integrate with CI. Even so, [we've been able to wrangle Capybara](http://artsy.github.io/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/) to do most of our client-side testing.

When building a CMS app for our gallery partners to manage their own Artsy inventory, we got a chance to test a similar Backbone app, but this time backed by [node.js](http://nodejs.org/). The result was a headless test suite that runs around 60 times faster, focusing on more unit test coverage.

Lets take a look at how it's done.

<!-- more -->

## Unit Tests

The trick to running headless unit tests on your client-side javascript code is creating an environment that mimics the browser. Luckily node.js has the perfect project for this called [jsdom](https://github.com/tmpvar/jsdom). This amazing project brings a pure javascript implementation of the DOM right to your node.js console.

The model layer of Backbone can work on the server without the DOM, but this will make it much easier to use libraries and test view code that expects a browser API to be available.

``` javascript
var jsdom = require('jsdom');

jsdom.env({
  html: "<html><body></body></html>",
  done: function(errs, window) {
    global.window = window;
    // ... 
    callback();
  }
});
```

At this point we've globally exposed the `window` of our fake browser environment which is the first step to getting client-side code to work on the server. However our client-side code isn't only assuming we have access to the DOM but probably a list of global libraries.

Without a module system on the client (like [browserify](https://github.com/substack/node-browserify) or [require.js](http://requirejs.org/)) we'll have to globally expose these other libraries as well. In any backbone app we we'll want to expose Backbone, Underscore, and jQuery.

``` javascript
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
```

As you can see above Backbone, Underscore, and jQuery are wrapped in [CommonJS](http://wiki.CommonJS.org/wiki/Modules/1.1.1) modules (same modules definition node uses). This allows us to simply require them just like any other node module. However not all libraries are CommonJS compatible and in this case you might have to expose their attachment to `window`.

``` javascript
done: function(errs, window) {
  global.window = window;
  require('../public/javascripts/vendor/zepto.js');
  global.Zepto = window.Zepto;
  //...
}
```

Finally you probably have a namespace like `App` which your components will expect when required.

``` javascript
done: function(errs, window) {
  global.window = window;
  //...
  global.App = {};
  // We're ready to require some Backbone components
}
```

As you can see keeping global dependencies to a minimum will not only reduce this boilerplate and make it easier to test your code, but also increase the quality of your code by ensuring modularity. For instance, instead of using `App.header.doSomething()` it might be better to pass that in to the initialize options so you can call `this.options.header.doSomething()`.

**NOTE**: It's best to run these unit tests in their own process such as `make test-unit` as polluting the global scope will likely cause unforeseen consequences on other test code.

## Let's Unit Test a Model

Example time! Because all good javascript guides are based off Todo apps, let's pretend we're testing a Todo model.

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
```

Great! Now that we've used [sinon.js](http://sinonjs.org/docs/#stubs) to stub ajax into `ajaxStub` we can simply start asserting our model change and ajax calls.

``` javascript app/test/javascripts/models/todo.js
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
```

In practicality one would probably build their API so they could simply `todo.save({ completed: true })` but hopefully this is a useful example.

# Let's Unit Test a View

Model tests are fairly straight forward. By their nature models mostly self contained javascript code with little dependencies. Things get a little bit more complicated as you have to integrate more parts. A Backbone view might expect some server-side rendered HTML to exist, use client-side templates, depend on model/collection classes, communicate to other views, and have interactions like animation that's not meant to happen headlessly. This makes it harder to write unit tests for, but manageable given our set up.

Lets pretend we have a list view that renders our todo list. It'll expect there to be a `#todos` element in the DOM that looks something like this.

``` html
<div id='todos'>
<h1>Things I need to do today</h1>
<ul class='todos-list'></ul>
<input class='add-todo'>
</div>
```

Our view will render a list of todos inside `ul.todos-list` using a JST and binding to a collection's events.

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
    this.$('.todos-list').html(this.template({ todos: this.collection.models }));
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

To begin unit testing this inside node we'll first need to make sure the '#todos' element is rendered inside jsdom since the view expects it to be rendered server-side. Since jQuery is globally exposed and pointing to jsdom's `window` we can simply compile the express view into html and render it directly with good ol' `$('html').html`.

``` javascript
var filename = path.resolve(__dirname, '../app/views/index.jade'),
    html = require('jade').compile(
      fs.readFileSync(filename).toString(),
      { filename: filename }
    )();
$('html').html(html);
```

Now that we've got our server-side DOM rendered we'll need to make sure our client-side template is available as well. In this case I'm assuming client-side templates are compiled into functions name-spaced under a global JST object like in the [Rail's asset pipeline](http://guides.rubyonrails.org/asset_pipeline.html), or in the Artsy CMS's case,  [nap](https://github.com/craigspaeth/nap). We'll want to mimic what the client JST functions are expecting so that when we call `JST['foo/bar']({ foo: 'some-data' })` we'll get back a string of html. In this example we're using jade, but you can imagine how this might be configured with another templating language.

``` javascript
var jade = require('jade');

global.JST = {};
var filename = path.resolve(__dirname, '../public/javascripts/templates/todos/list.jade');
JST['todos/list'] = jade.compile(fs.readFileSync(filename).toString(),
  { filename: filename}
);
```

With those out of the way we just need to require whatever other model classes like `App.Todo` the view depends on. Lets pretend we wrapped all of this globally exposing dependencies into a test helper called `clientenv` and write a view test.

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

As you can see testing views requires a little more setup, but with a little extra work you can unit test your views like any other piece of javascript code.

## Integration Tests

Although I encourage writing way more unit test coverage, it's still necessary to have a smaller set of integration tests that will actually cover user scenarios like "I log in, open this dialog, and it submits my request info.". You can imagine the steps involved in setting this scenario up. You would need to run your app server, setup a test database, fill in some fixture data including a user with password, fire up a browser, and click through some user actions.

Depending on so many variables and setup is what makes integration tests so brittle and slow. In the case of our CMS we were able alleviate the pain of certain steps.

### Stubbing the API Layer

In our case we're consuming a JSON API service. It makes sense to cut off integration at this point and stub our API responses because we already have a large test suite covering our API ensuring if given the right request it'll save the data correctly.

To do this we can conditionally check which environment we're running in and swap out the API to use a real API or our [express app](http://expressjs.com/) stubbing API routes.

``` javascript
if(app.get('env') == 'test') {
  app.set('api url', 'http://localhost:5000);
  // Create a mock api server in your test helpers and run it on 5000 in a before block
} else {
  app.set('api url', 'http://api.my-app.com');
}
// Bootstrap in your server-side view so the client app knows where to point
app.locals.API_URL_ROOT = app.get('api url');
```

``` javascript public/javascripts/models/todo.js
App.Todos = Backbone.Collection.extend({
  
  model: App.Todo,
  
  url: API_URL_ROOT + '/api/todos' 
});
```

If our API was hosted on the same server as our client app, or we had to proxy API calls because of lack of [CORS](http://en.wikipedia.org/wiki/Cross-Origin_Resource_Sharing) support, this could be as easy as swapping out the API as middleware.

``` javascript app.js
if(app.get('env') == 'test') {
  app.use('/api', require('./test/helpers/mock_api'));
} else {
  app.use('/api', require('./routes/api'));
}
```

This not only removes the need to boot up an API server and database, but it also speeds up integration tests by not having to populate a test database and wait on disk read or latency.

### Headless Integration Tests with [Zombie.js](http://zombie.labnotes.org/)

Another reason integration tests are brittle and slow is the use of an actual browser. Selenium has to run firefox and actually render UI that it interacts with. This in combination with techniques like polling for elements to visually appear can mean you end up waiting extra seconds to be sure that there wasn't a hiccup between the UI rendering/animation and the test assertion. Zombie is backed by [jsdom](https://github.com/tmpvar/jsdom), which means it runs entirely inside our node.js process. This simplifies testing, stubbing, and debugging as you can programmatically access the browser's environment right inside your tests.

The caveat to headless testing of course is that you can't visually see how a test is actually failing.

Using `{ debug: true }` in your options will spit out every Zombie action to stdout. In most cases this is enough, but sometimes you need to go a step further and actually visualize what the test is doing.

With Zombie you can use `browser.viewInBrowser()` to open up the page in an actual browser, but waiting for a test to run and debug back and forth can be kind of slow and annoying. A trick we use is to write tests using the browser's `jQuery`. This is not only more familiar than Zombie's DSL but  you can also copy and paste test code directly in your browser's console to see if it's actually doing what you want.

.e.g

``` javascript
it('Adds the todo, renders the todos, and crosses it out when done', function(done) {
  Browser.visit('http://localhost:5000', function(err, browser) {
    $ = browser.window.$;
    $('#add-todo').val('Foo').change();
    browser.wait(function() {
      $('#todos li').length.should.be.above(2);
      $('#todos li:last-child .complete-todo').click();
      $('#todos li:last-child').hasClass('completed').should.be.ok
      done()
    });
  });
```

## Conclusion

Using these techniques has greatly increased productivity and developer happiness for testing client-side javascript code. For an example implementation of this see https://github.com/craigspaeth/backbone-headless-testing.

Looking towards the future, this can be made even easier by using a client-side package manager that adds require functionality to your client-side code like [browserify](https://github.com/substack/node-browserify), [component](https://github.com/component/component), or [require.js](http://requirejs.org/). This will mostly remove the  boilerplate of exposing dependencies globally and better modularize your code in general. But that could be worth it's own blog post.