---
layout: post
title: "Splitting up a large test suite"
date: 2015-09-24 22:13
comments: true
author: joey
categories: [Ruby, testing, Continuous Integration, Rspec]
---

A while back, we wrote about [How to Run RSpec Test Suites in Parallel with Jenkins CI Build Flow](/blog/2012/10/09/how-to-run-rspec-test-suites-in-parallel-with-jenkins-ci-build-flow/). A version of that still handles our largest test suite, but over time the initial division of specs became unbalanced. We ended up with some tasks that took twice as long as others. Even worse, in an attempt to rebalance task times, we ended up with awkward file patterns like `'spec/api/**/[a-m]*_spec.rb'`.

To keep our parallel spec tasks approximately equal in size and to support arbitrary concurrency, we've added a new `spec:sliced` task:

<!-- more -->

```ruby
namespace :spec do
  task :set_up_spec_files do
    spec_files = Dir['spec/**/*_spec.rb']
    @spec_file_digests = Hash[spec_files.map { |f| [f, Zlib.crc32(f)] }]
  end

  RSpec::Core::RakeTask.new(:sliced, [:index, :concurrency] => :set_up_spec_files) do |t, args|
    index = args[:index].to_i
    concurrency = args[:concurrency].to_i
    t.pattern = @spec_file_digests.select { |f, d| d % concurrency == index }.keys
  end
end
```

As you can see, the `set_up_spec_files` helper task builds a hash of spec file paths and corresponding checksums. When we invoke the `sliced` task with `index` and `concurrency` values (e.g., `0` and `5`), only the spec files with checksums equal to `0` when mod-ed by `5` are run. Thus, the Jenkins build flow would look like:

```java
parallel (
  {build("master-ci-task", tasks: "spec:sliced[0,5]")},
  {build("master-ci-task", tasks: "spec:sliced[1,5]")},
  {build("master-ci-task", tasks: "spec:sliced[2,5]")},
  {build("master-ci-task", tasks: "spec:sliced[3,5]")},
  {build("master-ci-task", tasks: "spec:sliced[4,5]")}
)
build("master-ci-succeeded")
```

Now, spec times _might_ continue to be unbalanced despite files being split up approximately evenly. (For a more thorough approach based on recording spec times, see [knapsack](https://github.com/ArturT/knapsack).) However, this little bit of randomness was a big improvement over our previous approach, and promises to scale in a uniform manner.
