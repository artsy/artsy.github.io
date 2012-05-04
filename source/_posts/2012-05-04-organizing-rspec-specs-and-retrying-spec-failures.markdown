---
layout: post
title: Organizing RSpec Specs and Retyring Spec Failures
date: 2012-05-04 12:00
comments: true
categories: [RSpec, Testing]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---
Having over 3700 RSpec tests in a single project can quickly become difficult to manage. Lets organize them into suites. And while we got pretty good at making our Capybara integration tests more reliable, they continue relying on timeouts - we'll put together a system to retry failed tests. Because a spec that fails twice in a row is definitely not a fluke!

Create a new Rake file in `lib/tasks/test_suites.rake` and declare an array of test suites.

``` ruby lib/tasks/test_suites.rake
  SPEC_SUITES = [
    { :id => :models, :pattern => "spec/models/**/*_spec.rb" },
    { :id => :controllers, :pattern => "spec/controllers/**/*_spec.rb" },
    { :id => :views, :pattern => "spec/views/**/*_spec.rb" }
  ]
```
<!-- more -->
`RSpec::Core` contains a module called `RakeTask` that will programmatically create Rake tasks for you.

``` ruby lib/tasks/test_suites.rake
require 'rspec/core/rake_task'

namespace :test
  namespace :suite
    RSpec::Core::RakeTask.new("#{suite[:id]}:run") do |t|
      t.pattern = suite[:pattern]
      t.verbose = false
      t.fail_on_error = false
    end
  end
end
```

Run `rake -T` to ensure that the suites have been generated. To execute a suite, `rake test:suite:models:run`.

``` bash
rake spec:suite:models:run
rake spec:suite:controllers:run
rake spec:suite:views:run
```

Retrying failed specs has been a long requested feature in RSpec (see [#456](https://github.com/rspec/rspec-core/issues/456)). A viable approach has been finally suggested and implemented in [#596](https://github.com/rspec/rspec-core/pull/596). While I am afraid it's not going to make it as a whole, several pieces have already been merged that make retrying specs feasible outside of RSpec.

* A fix for incorrect parsing input files specified via `-O`. [#610](https://github.com/rspec/rspec-core/pull/610)
* A fix for making the -e option cumulative. [#614](https://github.com/rspec/rspec-core/pull/614)

Both will appear in the 2.11.0 version of RSpec.

The first piece is a logger that can output spec failures into a file. Lets create it in `spec/support/formatters/failures_formatter.rb` call that file `rspec.failures`.

