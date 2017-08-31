---
layout: epic
title: Deploying your app on a weekly basis via fastlane + Travis CI
date: 2017-07-31
author: orta
categories: [mobile, ios, emission, fastlane]
css: fastlane
---

We have a few apps now, but one of them isn't really used by anyone other than developers. This is [our React Native host app][em_app]. We built our React Native components [as a library][how_emission] to be consumed by our other apps. Our development environment for these components is a unique app that acts as a host for the React Native components. It's effectively a long tableview.

This app is often updated for developers, but never deployed to beta users inside Artsy. So I automated it. Using Travis CI and fastlane. This post covers how I got that set up.

<!-- more -->

<center>
  <img src="/images/fastlane-weekly/screenshot.png" width=300>
</center>

As the JavaScript is continuously deployed, the native side of the app rarely gets a deploy. In order to ensure an up-to-date version of the app, I used the [scheduler][schedule] now available in Travis CI, and Circle CI. This is a perfect use-case for one-off tasks like uploading an app to Apple's Testflight on a weekly basis.

I wanted this to exist outside of our current CI environment for two reasons:

* Our CI is already [using AppHub][pr_deploy] to deploy the JavaScript parts of our React Native on a per-commit basis. It's complicated enough as it is, without adding a lot more process.
* Our CI is currently running on Linux boxes, and so everything is fast and stable. Deploying using the main repo would force us to use macOS which would slow down our processes.

The downside of this choice is that the process of uploading is not inside the main repo, and can go out of sync with the main app.

## Setup

I created a new repo, and added the [usual LICENSE and README][init], then started [working on a PR][pr] that added the initial support for CI to run. Here are the general steps I needed to make work:

* Downloading and setting up the application.
* Ensuring signing will work.
* Creating the build and shipping it to Testflight.
* Notifications that it passed or succeeded.

Finally I needed to document the process, which is what you're reading.

## Downloading and setting up the application

My initial thoughts were to use a submodule, but that option provides little advantage over cloning the repo itself so it's done inline. Our dependencies for the app live in Rubygems (fastlane/CocoaPods), NPM (React Native) and CocoaPods (Artsy Mobile code), so I use the `before_install` and `before_script` section of the `.travis.yml` to set up our dependencies:

```yml
# Use a Mac build please
language: objective-c
osx_image: xcode8.2

# Ensure that fastlane is at the latest version
before_install:
- bundle update

# Let fastlane set up the other dependency managers
before_script:
- bundle exec fastlane setup

# Separate fastlane lanes so that they can be individually
# tested one by one during development
script:
- bundle exec fastlane validate_env_vars
- bundle exec fastlane ci_deploy
```

Note the `- bundle update`. As fastlane works against unofficial iTunes connect which is always changing, it's safer to always use the most recent release. 

## Ensuring signing will work.

This one is a bit tricker, luckily I've already set up one of our apps to use [fastlane match][] and I can re-use that infrastructure. As it is a private repo, Travis did not have access to clone the repo. I fixed this by creating an access token for a user with read-only access to our match-codesigning repo, then exposed this as a private environment variable in CI which the Matchfile uses. E.g.

```ruby
git_url "https://#{ENV['GITHUB_SUBMODULES_USER']}@github.com/artsy/mobile_fastlane_match"

# Instead of 
# git_url "https://github.com/artsy/mobile_fastlane_match"
```

This is one of the highlights on fastlane's choice in building a DSL that which sits above a real programming language, you give users a lot of flexibility.

Next up, I added a fastlane lane for code signing, and keychain setup. This just calls two setup functions.

```ruby
lane :setup_signing do
  setup_travis

  match(type: 'appstore')
end
```

## Creating the build and shipping it to Testflight

This is handled by [fastlane gym][gym] at the start of the main lane.

```ruby
# The main job for fastlane in this repo, you can run this on your computer
# You can run it via `bundle exec fastlane ship`
lane :ship do
  # We were having issues with building an a few folders deep.
  # The /Pods bit is because we can rely on it being there, see
  # this link: https://docs.fastlane.tools/advanced/#directory-behavior
  #
  Dir.chdir('../emission/Example/Pods') do
    gym workspace: 'Emission.xcworkspace',
        configuration: 'Deploy',
        scheme: 'Emission'
  end

  # [...]
end
```

It uses a scheme for deploys, which prioritises using AppHub over a local React Native server. Gym handles a lot of CLI ugliness for us, and works well.

Sending the app to Testflight involves a a few lines:

```ruby
# Get the last 10 lines of the CHANGELOG for Testflight
changelog = '../emission/CHANGELOG.md'
upcoming_release_notes = File.read(changelog).split("\n### ").first

# Ship to testflight
pilot(changelog: upcoming_release_notes)
```

This lets the deploy process figure out what the latest release version is, and how many builds have shipped for that version. Then those can be used to set the build version and create a tag associated with it.

[fastlane pilot][] is used to send off the compiled build to Testflight.

## Keeping track of deploys

I don't know when we'll need it today, but it's always good to be able to go back and see what code lines up to every release. To do this I have a few lines of Ruby that creates a tag inside the original Emission repo.

```ruby
# Do a tag, we use a http git remote so we can have push access
# as the default remote for travis is read-only. This needs to be
# inside the emission repo, instead of our own.
Dir.chdir('../emission/Example/') do
  tag = "deploy-#{latest_version}-#{build_version}"
  add_git_tag(key: tag)

  if ENV['GITHUB_SUBMODULES_USER']
    writable_remote = "https://#{ENV['GITHUB_SUBMODULES_USER']}@github.com/artsy/emission.git"
    sh "git remote add http #{writable_remote}"
  else
    sh 'git remote add http https://github.com/artsy/emission.git'
  end
  push_git_tags(remote: 'http')
end
```

## Notifications that it passed or succeeded.

This was easy, I created a new slack inbound web-hook and added that as an environment variable. Then when a build passes we post a notification that there is a new version for everyone in Slack, if the lane fails then it will also post to slack. To ensure we keep on top of it, during development this was commented out.

```ruby
# If the weekly task fails, then ship a message
error do |_, exception|
   slack message: "Error Deploying Emission: #{exception}",
         success: false,
         payload: { Output: exception.error_info.to_s }
end
```

That wraps up setting up the CI. Once you've confirmed everything has worked, you can add the scheduler inside Travis and expect to see a slack notification in a week.

By the end of the process, our `Fastfile` looked like:

```ruby
# This is documented in the Artsy Blog: 
# http://artsy.github.io/blog/2017/07/31/fastlane-travis-weekly-deploys/
lane :setup do
  Dir.chdir('..') do
    sh 'rm -rf emission' if Dir.exist? 'Emission'
    sh 'git clone https://github.com/artsy/emission.git'
    Dir.chdir('emission') do
      sh '. ~/.nvm/nvm.sh && nvm use && npm install yarn --global && yarn install'
    end

    Dir.chdir('emission/Example') do
      sh 'pod repo update'
      sh 'pod install'
    end
    stamp_plist
  end
end

# Lets the CI run a bunch of jobs, and share ENV vars between them
lane :ci_deploy do
  setup_signing
  stamp_plist
  ship
end

# The main job for fastlane in this repo, you can run this on your computer
# You can run it via `bundle exec fastlane ship`
lane :ship do
  # We were having issues with building an a few folders deep.
  # The /Pods bit is because we can rely on it being there, see
  # this link: https://docs.fastlane.tools/advanced/#directory-behavior
  #
  Dir.chdir('../emission/Example/Pods') do
    gym(workspace: 'Emission.xcworkspace',
        configuration: 'Deploy',
        scheme: 'Emission')
  end

  # Get the last 10 lines of the CHANGELOG for Testflight
  changelog = '../emission/CHANGELOG.md'
  upcoming_release_notes = File.read(changelog).split("\n### ").first

  # Ship to testflight
  pilot(changelog: upcoming_release_notes)

  # Log into iTunes connect, get the latest version of the app we shipped, and how many builds we've sent
  Spaceship::Tunes.login(ENV['FASTLANE_USERNAME'], ENV['FASTLANE_PASSWORD'])
  app = Spaceship::Tunes::Application.find('net.artsy.Emission')
  latest_version = app.build_trains.keys.sort.last
  train = app.build_trains[latest_version]
  build_version = train.builds.count + 1

  # Do a tag, we use a http git remote so we can have push access
  # as the default remote for travis is read-only. This needs to be
  # inside the emission repo, instead of our own.
  Dir.chdir('../emission/Example/') do
    tag = "deploy-#{latest_version}-#{build_version}"
    add_git_tag(key: tag)

    if ENV['GITHUB_SUBMODULES_USER']
      writable_remote = "https://#{ENV['GITHUB_SUBMODULES_USER']}@github.com/artsy/emission.git"
      sh "git remote add http #{writable_remote}"
    else
      sh 'git remote add http https://github.com/artsy/emission.git'
    end

    push_git_tags(remote: 'http')
  end

  slack message: 'There is a new Emission beta available on Testflight.',
        payload: {
          'Version' => latest_version,
          "What's new" => upcoming_release_notes
        },
        default_payloads: []
end

# In case you need to update the signing profiles for this app
lane :update_signing do
  match(type: 'appstore')
end

# Used by CI, will not sneakily update (the CI only has read-only access to the repo anyway)
lane :setup_signing do
  setup_travis
  match(type: 'appstore')
end

# Minor plist modifications
lane :stamp_plist do
  plist = 'emission/Example/Emission/Info.plist'

  # Increment build number to current date
  build_number = Time.new.strftime('%Y.%m.%d.%H')
  `/usr/libexec/PlistBuddy -c "Set CFBundleVersion #{build_number}" "#{plist}"`
end

# Mainly so we don't forget to include these vars in the future
lane :validate_env_vars do
  unless ENV['FASTLANE_USERNAME'] && ENV['FASTLANE_PASSWORD'] && ENV['MATCH_PASSWORD']
    raise 'You need to set FASTLANE_USERNAME, FASTLANE_PASSWORD and MATCH_PASSWORD in your environment'
  end

  unless ENV['SLACK_URL']
    raise "You need to set SLACK_URL (#{ENV['SLACK_URL']}) in your environment."
  end
end

# If the weekly task fails, then ship a message, a success would also send
error do |_, exception|
  slack(message: "Error Deploying Emission: #{exception}",
        success: false,
        payload: { Output: exception.error_info.to_s })
end
```

Automatically deploying is a good pattern for encouraging more deploys of an app which has only been deployed once. It's a pattern we could also move to in some of our other apps too, if it feels good. If you're interested in if something has changed since this post was authored, the repo is here: https://github.com/artsy/emission-nebula so you can read out the Fastfile and we'll answer questions you have inside GitHub issues on it.

The most annoying part about building deployment changes are that an iteration takes ~20 minutes, so make sure you also have another (easily interrupted) task to do at the same time. 

The second most annoying is that it took months to eventually get this right - so I owe Felix Krause a big thanks for sitting down and pairing with me, we figuring out that `xcodebuild` can create empty archive issues when you run projects that have the xcproject/xcworkspace a few levels deep.

[em_app]: https://github.com/artsy/emission/tree/master/Example
[how_emission]: /blog/2016/08/24/On-Emission/
[pr_deploy]: https://github.com/artsy/emission/pull/263
[init]: https://github.com/artsy/emission-nebula/commit/4d18a11629e097c71b9a375465c754abf45f62d6
[pr]: https://github.com/artsy/emission-nebula/pull/1
[fastlane match]: /blog/2017/04/05/what-is-fastlane-match/
[gym]: https://github.com/fastlane/fastlane/tree/master/gym
[fastlane pilot]: https://github.com/fastlane/fastlane/tree/master/pilot
[schedule]: https://docs.travis-ci.com/user/cron-jobs/
