---
layout: post
title: How to Organize Over 3000 RSpec Specs and Retry Test Failures
date: 2012-05-15 12:00
comments: true
categories: [RSpec, Testing]
author: db
---
Having over three thousand RSpec tests in a single project has become difficult to manage. We chose to organize these into suites, somewhat mimicking our directory structure. And while we succeeded at making our Capybara integration tests more reliable (see [Reliably Testing Asynchronous UI with RSpec and Capybara](/blog/2012/02/03/reliably-testing-asynchronous-ui-w-slash-rspec-and-capybara/)), they continue relying on finicky timeouts. To avoid too many false positives we've put together a system to retry failed tests. We know that a spec that fails twice in a row is definitely not a fluke!

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

Run `rake -T` to ensure that the suites have been generated. To execute a suite, run `rake test:suite:models:run`. Having a test suite will help you separate spec failures and enables other organizations than by directory, potentially allowing you to tag tests across multiple suites.

``` bash
rake spec:suite:models:run
rake spec:suite:controllers:run
rake spec:suite:views:run
```

Retrying failed specs has been a long requested feature in RSpec (see [#456](https://github.com/rspec/rspec-core/issues/456)). A viable approach has been finally implemented by [Matt Mitchell](https://github.com/antifun) in [#596](https://github.com/rspec/rspec-core/pull/596). There're a few issues with that pull request, but two pieces have already been merged that make retrying specs feasible outside of RSpec.

* [#610](https://github.com/rspec/rspec-core/pull/610):
  A fix for incorrect parsing input files specified via `-O`.
* [#614](https://github.com/rspec/rspec-core/pull/614):
  A fix for making the `-e` option cumulative, so that one can pass multiple example names to run.

Both will appear in the 2.11.0 version of RSpec, in the meantime you have to point your `rspec-core` dependency to the latest version on Github.

``` ruby Gemfile
"rspec-core", :git => "https://github.com/rspec/rspec-core.git"
```

Don't forget to run `bundle update rspec-core`.

The strategy to retry failed specs is to output a file that contains a list of failed ones and to feed that file back to RSpec. The former can be accomplished with a custom logger. Create `spec/support/formatters/failures_formatter.rb`.

``` ruby spec/support/formatters/failures_formatter.rb
require 'rspec/core/formatters/base_formatter'

module RSpec
  module Core
    module Formatters
      class FailuresFormatter < BaseFormatter

        # create a file called rspec.failures with a list of failed examples
        def dump_failures
          return if failed_examples.empty?
          f = File.new("rspec.failures", "w+")
          failed_examples.each do |example|
            f.puts retry_command(example)
          end
          f.close
        end

        def retry_command(example)
          example_name = example.full_description.gsub("\"", "\\\"")
          "-e \"#{example_name}\""
        end

      end
    end
  end
end
```

In order to use the formatter, we must tell RSpec to `require` it with `--require` and to use it with `--format`. We don't want to lose our settings in `.rspec` either - all these options can be combined in the Rake task.

``` ruby lib/tasks/test_suites.rake
RSpec::Core::RakeTask.new("#{suite[:id]}:run") do |t|
  t.pattern = suite[:pattern]
  t.verbose = false
  t.fail_on_error = false
  t.spec_opts = [
    "--require", "#{Rails.root}/spec/support/formatters/failures_formatter.rb",
    "--format", "RSpec::Core::Formatters::FailuresFormatter",
    File.read(File.join(Rails.root, ".rspec")).split(/\n+/).map { |l| l.shellsplit }
  ].flatten
end
```

Once a file is generated, we can feed it back to RSpec in another task, called `suite:suite[:id]:retry`.

``` ruby lib/tasks/test_suites.rake
RSpec::Core::RakeTask.new("#{suite[:id]}:retry") do |t|
  t.pattern = suite[:pattern]
  t.verbose = false
  t.fail_on_error = false
  t.spec_opts = [
    "-O", File.join(Rails.root, 'rspec.failures'),
    File.read(File.join(Rails.root, '.rspec')).split(/\n+/).map { |l| l.shellsplit }
  ].flatten
end
```

Finally, lets combine the two tasks and invoke `retry` when the `run` task fails.

``` ruby lib/tasks/test_suites.rake
task "#{suite[:id]}" do
  rspec_failures = File.join(Rails.root, 'rspec.failures')
  FileUtils.rm_f rspec_failures
  Rake::Task["spec:suite:#{suite[:id]}:run"].execute
  unless $?.success?
    puts "[#{Time.now}] Failed, retrying #{File.read(rspec_failures).split(/\n+/).count} failure(s) in spec:suite:#{suite[:id]} ..."
    Rake::Task["spec:suite:#{suite[:id]}:retry"].execute
  end
end
```

A complete version of our `test_suites.rake`, including a `spec:suite:all` task that executes all specs can be found [in this gist](https://gist.github.com/2597305). Our Jenkins CI runs `rake spec:suite:all`, with a much improved weather report since we started using this system.
