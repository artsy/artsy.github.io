---
layout: post_longform
title: Deploying your app on a weekly basis via fastlane + Travis CI
date: 2017-05-10
author: orta
categories: [mobile, ios, emission, fastlane]
---

We have a few apps now, but one of them isn't really used by anyone other than developers. This is [our React Native host app][em_app]. We built our React Native components [as a library][how_emission] to be consumed by our main app, and in the process we have a separate app that just acts as a host for the React Native components. This app is often updated, but never deployed to beta users - where it could be of use.

So I automated it. Using Travis CI and fastlane.

<!-- more -->

Travis CI (and Circle CI) now have the ability to run scheduled runs. This is great for one-off tasks like uploading an app to Apple's Testflight on a weekly basis.

I wanted this to exist outside of our current CI environment for two reasons:

* Our CI is already [using AppHub][pr_deploy] to deploy the JavaScript parts of our React Native on a per-commit basis. It's complicated enough as it is, without adding a lot more process.
* Our CI is currently running on Linux boxes, and so everything is fast and stable. This would force us to use Mac boxes which would have the opposite effect.

The downside is that the process of uploading is not inside the main repo, and can go out of sync. So ideally the new project would be as generic and future-safe as possible.

## Setup

I created a new repo, and added the [usual LICENSE and README][init], then started [working on a PR][pr] that added support for CI to run. Here are the general steps I needed to make work:

* Downloading and setting up the application.
* Ensuring signing will work.
* Creating the build and shipping it to Testflight.
* Notifications that it passed or succeeded.

Finally I needed to document the process, which is what you're reading.

## Downloading and setting up the application

My initial thoughts were to use a submodule, but that option provides little advantage over cloning the repo itself so it's done inline. Our dependencies for the app live in Rubygems (Fastlane/CocoaPods), NPM (React Native) and CocoaPods (Artsy Mobile code), so I use the `before_install` and `before_script` section of the `.travis.yml` to set up our dependencies:

```yml
# Use a Mac build please
language: objective-c

# Ensure our dependency managers are up to date
before_install:
  - brew install yarn
  - gem install bundler
  - bundle update

# Clone emission and setup dependencies
before_script:
  - git clone https://github.com/artsy/emission.git
  - cd emission && yarn install
  - git pull origin fastlane_match 
  - cd Example && pod install
  - cd ../..
```

Note the `- bundle update`. As both CocoaPods and Fastlane are build tools that have to handle ever changing Apple black-boxes, then locking their versions doesn't make much sense over long time periods for somehting like this. In this case, both of the apps will always be at the latest stable release.

## Ensuring signing will work.

This one is a bit tricker, luckily I've already set up one of our apps to use [fastlane match][] and I can re-use that infrastructure. As it is a closed repo, Travis did not have access to clone the repo. I fixed this by creating an access token for a user with read-only access to our match-codesigning repo, then exposed this as a private environment variable in CI which the Matchfile uses. E.g.

```ruby
git_url "https://#{ENV['GITHUB_SUBMODULES_USER']}@github.com/artsy/mobile_fastlane_match"

# Instead of 
# git_url "https://github.com/artsy/mobile_fastlane_match"
```

That's what's great about building a DSL that which sits above a real programming language, you give users a lot of flexibility. I added a two fastlane lanes for code signing:

```ruby
# In case you need to update the signing profiles for this app
lane :update_signing do
  match(type: 'appstore')
end

# Used by CI, will not sneakily update (the CI only has read-only access to the repo anyway)
lane :setup_signing do
  match(type: 'appstore', readonly: true)
end
```

## Creating the build and shipping it to Testflight

This is handled by [fastlane gym][gym], again, I made a separate fastlane lane so it could be tested independently.

```ruby
# You can run `bundle exec fastlane build` to test the build process locally.
lane :build do
  gym workspace: 'emission/Example/Emission.xcworkspace',
      configuration: 'Deploy',
      scheme: 'Emission',
      clean: true
end
```

It uses a scheme for deploys, which prioritises using AppHub over a local React Native server. Gym handles a lot of CLI ugliness for us, and works well.

Sending the app to Testflight involves a little bit of work:

```ruby
# Get the last 10 lines of the CHANGELOG for Testflight
changelog = 'emission/CHANGELOG.md'
upcoming_release_notes = File.read(changelog).lines[0...12].join("\n")

# Log into iTunes connect, get the latest version of the app we shipped, and how many builds we've sent too
Spaceship::Tunes.login(ENV['FASTLANE_USERNAME'], ENV['FASTLANE_PASSWORD'])
app = Spaceship::Tunes::Application.find('net.artsy.Emission')
latest_version = app.build_trains.keys.sort.last
train = app.build_trains[latest_version]
build_version = train.builds.count + 1
```

This lets the deploy process figure out what the latest release version is, and how many builds have shipped for that version. Then those can be used to set the build version and create a tag associated with it.

```ruby
# Ship to testflight
pilot changelog: upcoming_release_notes

# Tag releases
add_git_tag tag: tag
`git remote add http https://#{ENV["GITHUB_SUBMODULES_USER"]}@github.com/artsy/emission.git`
`git push http #{tag}`
```

[fastlane pilot][] is send off the compiled build to Testflight, and then a tag noting the deploy is pushed to the main repo.

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

By the end of the process, this looked like:

```ruby
# The main job for Fastlane in this repo.
lane :ship do
  validate_env_vars
  setup_signing
  stamp_plist

  build

  # Get the last 10 lines of the CHANGELOG for Testflight
  changelog = 'emission/CHANGELOG.md'
  upcoming_release_notes = File.read(changelog).lines[0...12].join("\n")

  # Log into iTunes connect, get the latest version of the app we shipped, and how many builds we've sent too
  Spaceship::Tunes.login(ENV['FASTLANE_USERNAME'], ENV['FASTLANE_PASSWORD'])
  app = Spaceship::Tunes::Application.find('net.artsy.Emission')
  latest_version = app.build_trains.keys.sort.last
  train = app.build_trains[latest_version]
  build_version = train.builds.count + 1

  # Do a tag, we use a http git remote so we can have push access
  # as the default remote for travis is read-only
  tag = "deploy-#{latest_version}-#{build_version}"
  `git tag -d "#{tag}"`

  # Ship to testflight
  pilot changelog: upcoming_release_notes

  # Tag releases
  add_git_tag tag: tag
  `git remote add http https://#{ENV["GITHUB_SUBMODULES_USER"]}@github.com/artsy/emission.git`
  `git push http #{tag}`

  slack message: 'There is a new Emission beta available on Testflight.',
        payload: {
          'Version' => latest_version,
          "What's new" => upcoming_release_notes
        },
        default_payloads: []
end

# A separate build task so you can run `bundle exec fastlane build` to test the
# build process locally.
lane :build do
  gym workspace: 'emission/Example/Emission.xcworkspace',
      configuration: 'Deploy',
      scheme: 'Emission',
      clean: true
end

# In case you need to update the signing profiles for this app
lane :update_signing do
  match(type: 'appstore')
end

# Used by CI, will not sneakily update (the CI only has read-only access to the repo anyway)
lane :setup_signing do
  match(type: 'appstore', readonly: true)
end

# Minor plist modifications
lane :stamp_plist do
  plist = 'emission/Example/Emission/Info.plist'

  # Increment build number to current date
  build_number = Time.new.strftime('%Y.%m.%d.%H')
  `/usr/libexec/PlistBuddy -c "Set CFBundleVersion #{build_number}" "#{plist}"`
end

lane :validate_env_vars do
  unless ENV['FASTLANE_USERNAME'] && ENV['FASTLANE_PASSWORD'] && ENV['MATCH_PASSWORD']
    raise 'You need to set FASTLANE_USERNAME, FASTLANE_PASSWORD and MATCH_PASSWORD in your environment'
  end

  unless ENV['GITHUB_SUBMODULES_USER']
    raise 'You need to set GITHUB_SUBMODULES_USER in your environment'
  end

  unless ENV['SLACK_URL']
    raise "You need to set SLACK_URL (#{ENV['SLACK_URL']}) in your environment."
  end
end

# If the weekly task fails, then ship a message
error do |_, exception|
   slack message: "Error Deploying Emission: #{exception}",
         success: false,
         payload: { Output: exception.error_info.to_s }
end
```

Automatically deploying is a good pattern for encouraging more deploys of an app which has only been deployed once. It's a pattern we could also move to in some of our other apps too, if it feels good. If you're interested in if something has changed since this post was authored, the repo is here: https://github.com/artsy/emission-nebula so you can read out the Fastfile and we'll answer questions you have inside GitHub issues on it.

The most annoying part about building this is that an iteration takes ~20 minutes, so make sure you also have another (easily interrupted) task to do at the same time.

[em_app]: https://github.com/artsy/emission/tree/master/Example
[how_emission]: /blog/2016/08/24/On-Emission/
[pr_deploy]: https://github.com/artsy/emission/pull/263
[init]: https://github.com/artsy/emission-nebula/commit/4d18a11629e097c71b9a375465c754abf45f62d6
[pr]: https://github.com/artsy/emission-nebula/pull/1
[fastlane match]: /blog/2017/04/05/what-is-fastlane-match/
[gym]: https://github.com/fastlane/fastlane/tree/master/gym
[fastlane pilot]: https://github.com/fastlane/fastlane/tree/master/pilot
