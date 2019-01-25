---
layout: epic
title: "Switch from Capybara Webkit to Chrome"
date: 2018-11-27
author: chungyi
categories: [testing, ci, rspec, rails]
---

Volt is the internal app name of Artsy CMS, and our partners use it to manage their inventory and presence on artsy.net. It's a Rails-based UI app that talks to many API services. We use [RSpec][rspec] extensively to cover controller, model, view, and feature specs. As of Jun. 2018, Volt had 3751 specs and 495 of them were run with JavaScript enabled. It took about 16 mins to run on CircleCI with 6x parallelism.

Capybara-webkit was introduced from the very beginning of Volt for testing JavaScript-enabled specs via headless WebKit browser. It's been providing a lot of confidence for the past 4+ years; however, a few reasons/growing concerns have encouraged us to look for (more modern) alternatives:

<!-- more -->

## The Problem

- The [dependency of a specific versions of Qt][qt-dependency] has been causing frustrations to set it up properly both on engineers' local machines and on CI.
- The roadmap of capybara-webkit development is [unclear][unclear-capybara-webkit-roadmap].
- It's been hard to truly identify the root cause of "flickering" feature specs (i.e. tests that fail intermittently and are hard to reliably reproduce), while retrying tended to resolve it on CI.
- The entire RSpec tests took about 16 mins to complete on CI, with 6 parallelism. The slowness made it unrealistic to run the whole tests locally.

## The Goal

Headless Chrome has gained a lot of attention in the past few years and migrations done by companies such as [GitLab][headless-chrome-migration-gitlab] and [thoughtbot][headless-chrome-migration-thoughtbot] have proven it to be a promising alternative to capybara-webkit. In fact, it's been [officially included in Rails 5.1][rails-5.1-system-tests] for [system tests][rails-system-tests].

The goal of this project is to switch to Headless Chrome and maintain the same feature sets we have now. This includes:

- Making all existing specs pass
- Running in container environments and using Artsy [Hokusai][hokusai]
- Supporting mechanisms to debug specs, e.g. examining browser console logs for JavaScript behavior, taking screenshots on demand and automatically on failure, etc.
- Bonus point to improve the stability of feature specs
- Bonus point to improve the speed of running the entire test suite

## The How

First, we replaced `capybara-webkit` with `selenium-webdriver` and `chromedriver-helper`:

```ruby
gem 'selenium-webdriver'
gem 'chromedriver-helper'
```

[`chromedriver-helper`][chromedriver-helper] was useful to help install [chromedriver][chromedriver] in different environments, e.g. an engineer's local machine, CI, etc.

Second, we registered both `:chrome` and `:headleass_chrome` drivers. By default, it used Headless Chrome as the JavaScript driver, and we could easily switch to Chrome and observe the actual interaction happening in a real browser.

```ruby
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  caps = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs: { browser: 'ALL' })
  opts = Selenium::WebDriver::Chrome::Options.new

  chrome_args = %w[--headless --window-size=1920,1080 --no-sandbox --disable-dev-shm-usage]
  chrome_args.each { |arg| opts.add_argument(arg) }
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: opts, desired_capabilities: caps)
end

Capybara.configure do |config|
  # change this to :chrome to observe tests in a real browser
  config.javascript_driver = :headless_chrome
end
```

We were on Rails v5.0.2 and Capybara v2.18.0 during the migration. We will be able to simplify the configuration by using the default `:selenium_chrome` and `:selenium_chrome_headless` drivers introduced in [Capybara v3.11.1][capybara-default-chrome-drivers]. In addition, Rails v5.1 introduced the new system tests, and it'll be even simpler by using the [`driven_by`][driven-by] method.

## Lessons Learned

Naively switching to Headless Chrome caused about 60 spec failures on my local machine. We simply went through them one by one and fixed them. A big part of failures was due to [capybara-webkit's non-standard driver methods][capybara-webkit-non-standard-driver-methods], such as setting cookies, inspecting console logs, etc., and we just had to migrate to Selenium WebDriver's equivalents.

However, we still observed flickering specs on CI, while the exact failures seemed to be different than previously observed with Capybara Webkit. We will have to investigate further for possible causes. Regarding speed, we didn't see significant improvement after switching to Headless Chrome, as mentioned in GitLab's and others' blog post, too.

## Next Steps

The naive migration to Chrome (and removal of the Qt dependency) already improved the developer experience quite a lot (e.g. no more wrestling with installing Capybara Webkit and Qt 5.5 on every engineer's local machine _and_ CI.) There are many next steps we can keep experimenting with and improving our tests, for example

- Updating Volt to Rails >= 5.1 and switching to system tests
- Investigating the causes of the flickering specs by looking into intermittent failures reported on CI
- Improving speed by using Docker [multi-stage builds][multi-stage-builds], caching, writing the right type and amount of tests, etc.

It's a long journey, and we were all excited about the migration and the new future. We'd love to hear your experience, too!

[qt-dependency]: https://github.com/thoughtbot/capybara-webkit/tree/v1.14.0#qt-dependency-and-installation-issues
[unclear-capybara-webkit-roadmap]: https://github.com/thoughtbot/capybara-webkit/issues/885#issuecomment-193988527
[rspec]: https://github.com/rspec/rspec
[headless-chrome-migration-gitlab]: https://about.gitlab.com/2017/12/19/moving-to-headless-chrome/
[headless-chrome-migration-thoughtbot]: https://robots.thoughtbot.com/headless-feature-specs-with-chrome
[capybara-webkit-non-standard-driver-methods]: https://github.com/thoughtbot/capybara-webkit/tree/v1.14.0#non-standard-driver-methods
[rails-5.1-system-tests]: http://guides.rubyonrails.org/5_1_release_notes.html#system-tests
[rails-system-tests]: https://guides.rubyonrails.org/testing.html#system-testing
[hokusai]: https://github.com/artsy/hokusai
[chromedriver-helper]: https://github.com/flavorjones/chromedriver-helper
[chromedriver]: https://sites.google.com/a/chromium.org/chromedriver/
[capybara-default-chrome-drivers]: https://github.com/teamcapybara/capybara/blob/3.11.1/lib/capybara.rb#L535-L545
[driven-by]: https://api.rubyonrails.org/v5.1.3/classes/ActionDispatch/SystemTestCase.html#method-c-driven_by
[multi-stage-builds]: https://docs.docker.com/develop/develop-images/multistage-build/
