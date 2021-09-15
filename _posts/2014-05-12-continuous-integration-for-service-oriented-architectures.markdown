---
layout: post
title: "Continuous integration for service-oriented architectures"
date: 2014-05-12 10:50
comments: true
categories: [Testing, Rspec, Continuous Integration, SOA]
author: joey
---

Whatever you have against monolithic architectures, at least they're easy to test. And when those tests succeed, you can be reasonably confident the live app will work the same way.

Artsy began as one such monolithic app, but we've been refactoring into an ecosystem of related APIs and sites. Today, when you search for ["cultural commentary"](https://artsy.net/gene/cultural-commentary) or visit [Robert Longo](https://artsy.net/artist/robert-longo) on [artsy.net](https://artsy.net), the page is rendered by a web app, sources data from an API, retrieves recommendations from a separate service, tracks trends in another, and records analytics in yet another.

This was a boost for developer productivity and scaling, but eviscerated the value of our tests. We repeatedly encountered bugs that were failings of _the interaction between codebases_ rather than failings of individual ones. Test libraries and tools typically concern themselves with one isolated app. When you have services that consume services that consume services, those isolated tests (with their stubs of everything else) don't necessarily reflect production's reality.

So how should we develop our small, focused apps (or [service-oriented architecture](http://en.wikipedia.org/wiki/Service-oriented_architecture), or [microservices](http://martinfowler.com/articles/microservices.html)...) with confidence? We set out to build a dedicated acceptance test suite that would run tests across multiple services, configuring and integrating them in a way that closely matches the production environment.

<!-- more -->

The code
---

We'll take the simplest example possible of 2 related applications: a trivial Ruby API serving a Node.js-based web app. (You can also go directly to [the source](https://github.com/joeyAghion/multiapp_example-tests).)

[Recent](http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html) [debates](http://blog.8thlight.com/uncle-bob/2014/04/25/MonogamousTDD.html) [aside](https://news.ycombinator.com/item?id=7659251), I like to start with a test:

```ruby
feature "home", js: true do

  scenario "welcomes visitor" do
    visit "/"
    expect(page).to have_content("Browse products")
  end
end
```

We're using the popular [and familiar] [Capybara](https://github.com/jnicklas/capybara) with [RSpec](https://relishapp.com/rspec) and [Selenium](http://docs.seleniumhq.org/). Naturally, our test fails right away:

```bash
$ bundle exec rspec
# ...
     Failure/Error: visit "/"
     Selenium::WebDriver::Error::UnknownError:
       Target URL / is not well-formed.
```

There are a few steps to getting our projects installed and running as part of the test suite. First, we'll add git submodules in the `/api` and `/web` subdirectories that [track the master branch](http://stackoverflow.com/questions/9189575/git-submodule-tracking-latest) of each project.

```bash
git submodule add -b master git@github.com:joeyAghion/multiapp_example-api.git api
git submodule add -b master git@github.com:joeyAghion/multiapp_example-web.git web
```

Next, create Rake tasks to install prerequisites for each project.

```ruby
# Rakefile
require 'childprocess'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :ci => ['checkout', 'install', 'spec']

task :checkout do
  sh %{git submodule update --remote --init} do |ok, res|
    raise "Submodule update failed with status #{res.exitstatus}" unless ok
  end
end

task :install => ['api:install', 'web:install']

namespace :api do
  task :install do
    Bundler.with_clean_env do
      proc = ChildProcess.build('bundle', 'install')
      proc.io.inherit!
      proc.cwd = './api'
      proc.start
      proc.wait
      raise "bundle install exited with status #{proc.exit_code}" unless proc.exit_code == 0
    end
  end
end

namespace :web do
  task :install do
    proc = ChildProcess.build('npm', 'install')
    proc.io.inherit!
    proc.cwd = './web'
    proc.start
    proc.wait
    raise "npm install existed with status #{proc.exit_code}" unless proc.exit_code == 0
  end
end
```

The new `checkout` and `install` tasks make sure we have the latest code and all prerequisites installed. Note how we use `Bundler.with_clean_env` to isolate the API (which has its own Gemfile and bundler environment) from the test suite.

Now that the API and web apps are set up, we'll use RSpec's `before(:suite)` and `after(:suite)` hooks to start and stop them around each test run.

```ruby
# spec/spec_helper.rb
require 'capybara/rspec'
require 'childprocess'

API_PORT = 7000
WEB_PORT = 7001

Capybara.configure do |config|
  config.current_driver = :selenium
  config.run_server = false
  config.app_host = "http://localhost:#{WEB_PORT}"
end

RSpec.configure do |config|
  # ...
  config.before(:suite) do
    start_api
    start_web
  end

  config.after(:suite) do
    stop_api
    stop_web
  end
end

def start_api
  $stderr.puts "Starting API..."
  Bundler.with_clean_env do
    $api = ChildProcess.build('bundle', 'exec', 'ruby', 'app.rb')
    $api.cwd = './api'
    $api.io.inherit!
    $api.environment['PORT'] = API_PORT
    $api.start
    $stderr.puts "Waiting for API to start listening..."
    sleep(1) while !listening_on?(API_PORT) && $api.alive?
  end
end

def stop_api
  $stderr.puts "Stopping API..."
  $api.stop
end

def start_web
  $stderr.puts "Starting web..."
  $web = ChildProcess.build('node', 'app.js')
  $web.cwd = './web'
  $web.io.inherit!
  $web.environment['API_URL'] = "http://localhost:#{API_PORT}"
  $web.environment['PORT'] = WEB_PORT
  $web.start
  $stderr.puts "Waiting for web to start listening..."
  sleep(1) while !listening_on?(WEB_PORT) && $web.alive?
end

def stop_web
  $stderr.puts "Stopping web..."
  $web.stop
end

def listening_on?(port)
  system("netstat -an | grep #{port} | grep LISTEN")
end
```

Running `rake spec` now starts up and waits for both apps, runs our test, and...

```
Starting API...
Waiting for API to start listening...
# ...
Starting web...
Waiting for web to start listening...
# ...
home
  welcomes visitor
Stopping API...
# ...
Stopping web...

Finished in 4.67 seconds
1 example, 0 failures
```

Success!

Well, sort of. Our test of the home page doesn't even depend on both systems. Let's try a more meaningful test, listing products from the API.

```ruby
feature "shop", js: true do

  scenario "list widgets" do
    visit "/"
    click_link "Browse products"
    expect(page).to have_content("Foo Widget")
  end
end
```

Will it work?

```bash
Failures:

  1) shop list widgets
     Failure/Error: expect(page).to have_content("Foo Widget")
       expected to find text "Foo Widget" in ""
     # ./spec/shop_spec.rb:8:in `block (2 levels) in <top (required)>'
```

The web app isn't authenticated to use the API! This brings up a more general question:

How to bootstrap test data
---

Most testing frameworks offer fixtures or direct access to the database. Because the API runs in a separate process, things are a little more difficult. We opt for 1 of 2 approaches, depending on the context:

* **Insert data directly into the API's database.** We tend to do this only as a last resort, because tests would presume knowledge of the API's implementation.
* **Perform test set-up via the API.** Slightly nicer, and closer to real-life clients. (However, the API must be fairly complete.)

In practice, we "cheat" and use direct database-insertion to initially bootstrap an API client application, then perform further test set-up through the API. You should choose what's most convenient.

Our simple example will register the web application as an API client, then pass a key via basic authentication. We'll have to modify the `start_web` helper:

```ruby
def start_web
  $stderr.puts "Starting web..."
  $web = ChildProcess.build('node', 'app.js')
  $web.cwd = './web'
  $web.io.inherit!
  $api_base_url = "http://#{api_client['key']}:@localhost:#{API_PORT}"
  $web.environment['API_URL'] = $api_base_url
  $web.environment['PORT'] = WEB_PORT
  $web.start
  $stderr.puts "Waiting for web to start listening..."
  sleep(1) while !listening_on?(WEB_PORT) && $web.alive?
end

def api_client
  $api_client ||= begin
    response = Net::HTTP.post_form(URI("http://localhost:#{API_PORT}/api/clients"), {})
    JSON.parse(response.body)
  end
end
```

And the test will need to set up the data it expects to find listed:

```ruby
feature "shop", js: true do

  scenario "list widgets" do
    create_widget(name: 'Foo Widget', price_cents: 100_00)
    visit "/"
    click_link "Browse products"
    expect(page).to have_content("Foo Widget")
  end
end

# spec/spec_helper.rb
def create_widget(params = {})
  Net::HTTP.post_form(URI("#{$api_base_url}/api/widgets"), params)
end
```

Lo and behold, our entire "suite" now passes:

```bash
2 examples, 0 failures
```

This basic structure has accommodated dozens of test scenarios. We've extended it with database- and cache-clearing between tests, and organized helpers into modules under `spec/support`. The suite is built nightly against the latest versions of our codebases, and has caught a few significant bugs.

A caveat: with so many layers and dependencies involved, there are often spurious failures. We've picked up a few practices that help:

* [Automatic retries](http://artsy.github.io/blog/2012/05/15/how-to-organize-over-3000-rspec-specs-and-retry-test-failures/)
* [Quarantine for problematic tests](http://artsy.github.io/blog/2014/01/30/isolating-spurious-and-nondeterministic-tests/)
* [Failure screenshots](https://github.com/mattheworiordan/capybara-screenshot)

You can [grab the example code](https://github.com/joeyAghion/multiapp_example-tests). And make sure to let us know in the comments how _you_ approach testing across applications.
