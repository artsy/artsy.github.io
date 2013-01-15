---
layout: post
title: Debugging Bundler Issues on Heroku
date: 2013-12-13 21:21
comments: true
categories: [Heroku,ruby,bundler]
author: Daniel Doubrovkine
github-url: https://www.github.com/dblock
twitter-url: http://twitter.com/dblockdotorg
blog-url: http://code.dblock.org
---

A few days ago we have started seeing the Heroku deployments of one of our applications randomly hang during `bundle install`. The problem became worse with time and we were not able to do a deployment for days.

```
$ git push -f git@heroku.com:application.git FETCH_HEAD:master
-----> Deleting 12 files matching .slugignore patterns.
-----> Ruby/Rails app detected
-----> Using Ruby version: ruby-1.9.3
-----> Installing dependencies using Bundler version 1.3.0.pre.5
       Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin
       Fetching gem metadata from http://rubygems.org/.......
       Fetching gem metadata from http://rubygems.org/..
/app/slug-compiler/lib/utils.rb:66:in `block (2 levels) in spawn': command='/app/slug-compiler/lib/../../tmp/buildpacks/ruby/bin/compile /tmp/build_1p6071sni4hh1 /app/tmp/repo.git/.cache' exit_status=0 out='' at=timeout elapsed=900.1056394577026 (Utils::TimeoutError)
  from /app/slug-compiler/lib/utils.rb:52:in `loop'
  from /app/slug-compiler/lib/utils.rb:52:in `block in spawn'
  from /app/slug-compiler/lib/utils.rb:47:in `popen'
  from /app/slug-compiler/lib/utils.rb:47:in `spawn'
  from /app/slug-compiler/lib/buildpack.rb:37:in `block in compile'
  from /app/slug-compiler/lib/buildpack.rb:35:in `fork'
  from /app/slug-compiler/lib/buildpack.rb:35:in `compile'
  from /app/slug-compiler/lib/slug.rb:497:in `block in run_buildpack'
 !     Heroku push rejected, failed to compile Ruby/rails app
```

Seeing bundler hang on fetching gem metadata from Rubygems, my immediate reaction was to blame the RubyGems Dependency API and attempt the [recommended fix](http://hone.herokuapp.com/bundler%20heroku/2012/10/22/rubygems-and-the-dependency-api.html) of switching to *http://bundler-api.herokuapp.com*. That did not fix the problem.

I could not reproduce the issue on any local environment, including a (what I thought was) a completely clean machine. Naturally, everything pointed at an infrastructure problem with Heroku itself, so I opened a ticket (#72648), [tweeted](https://twitter.com/dblockdotorg/status/290221530892365824) endlessly to Heroku devs, pinged a direct contact at Heroku on Skype and generally annoyed people for 5 straight days. It was a frustrating problem and I was getting very little help.

In the end this turned out to be a [bug in Bundler](https://github.com/carlhuda/bundler/issues/2248). Narrowing it down was reltively easy if you knew where to look.

<!-- more -->

Heroku Slug Compiler
--------------------

Heroku provides small Ubuntu virtual machines on-demand, called "dynos", that look very much like any other Linux box. You can `heroku run bash` and examine the file system of a running dyno. You can delete the bundler cache, rerun `bundle install`, etc. But deployment does not happen in a running dyno - every time you push to Heroku, deployment happens inside a compiler dyno. Heroku attaches the dyno to your slug filesystem (your code), which may include a cache from previous runs. It then executes the code inside [heroku-buildpack-ruby](https://github.com/heroku/heroku-buildpack-ruby), specifically [this code](https://github.com/heroku/heroku-buildpack-ruby/blob/5dbf4c06c765dc832c073fe5be9360533fd1846d/lib/language_pack/ruby.rb#L49).

``` ruby
def compile
  Dir.chdir(build_path)
  remove_vendor_bundle
  install_ruby
  install_jvm
  setup_language_pack_environment
  setup_profiled
  allow_git do
    install_language_pack_gems
    build_bundler
    create_database_yml
    install_binaries
    run_assets_precompile_rake_task
  end
end
```

A lot of these functions call `IO.open` and transmit `$stdout` and `$stderr` back to you. You see everything Heroku sees and while you cannot get access to the compiler dyno, there's really no mystery to this process. Heroku slug compiler will timeout after 15 minutes and produce a stack with `Utils::TimeoutError`. And everything Heroku does should be reproducible locally.

Troubleshooting Bundler
-----------------------

The key to getting the same problem locally was to use the [Bundler Troubleshooting](https://github.com/carlhuda/bundler/blob/master/ISSUES.md) section. I had previously missed one of the steps in cleaning the local Bundler cache.

```
# remove user-specific gems and git repos
rm -rf ~/.bundle/ ~/.gem/bundler/ ~/.gems/cache/bundler/

# remove system-wide git repos and git checkouts
rm -rf $GEM_HOME/bundler/ $GEM_HOME/cache/bundler/

# remove project-specific settings and git repos
rm -rf .bundle/

# remove project-specific cached .gem files
rm -rf vendor/cache/

# remove the saved resolve of the Gemfile
rm -rf Gemfile.lock

# uninstall the rubygems-bundler and open_gem gems
rvm gemset use global # if using rvm
gem uninstall rubygems-bundler open_gem

# try to install one more time
bundle install
```

This hung with my Gemfile the same way as on Heroku.

Bundler Dependency Resolver
---------------------------

So what is bundler doing? It runs the gem dependency resolver, which is described in detail in [Pat Shaughnessy's blog post](http://patshaughnessy.net/2011/9/24/how-does-bundler-bundle). It talks about running `DEBUG_RESOLVER=1 bundle install`, which produced a mountain of output that wasn't very helpful for infinite loop troubleshooting. I made a pull request with a similar `DEBUG_RESOLVER_TREE` in [#2249](https://github.com/carlhuda/bundler/pull/2249), which helped narrow down a [small repro](https://github.com/carlhuda/bundler/issues/2248). With `DEBUG_RESOLVER_TREE` I was also able to work around the bug by moving some gems around `Gemfile` and forcing a specific version of some of the dependencies.

Troubleshooting Tips
--------------------

Next time you have a hang inside `bundle install` on or off Heroku, start with [Bundler Troubleshooting](https://github.com/carlhuda/bundler/blob/master/ISSUES.md).
