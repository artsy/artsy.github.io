---
layout: post
sharing: false
title: "Using CocoaPods Caching with Travis CI"
date: 2014-08-08 11:46
categories: [iOS, Continuous Integration, Travis, Testing]
author: orta
---

As [Ash said earlier](http://artsy.github.io/blog/2014/08/07/taking-a-snapshot-with-second-curtain/) we like using Continuous Integration. Today I spent a large amount of time migrating us to use the new CocoaPods caching system in Travis CI. To make up for my lost time I'm passing on what I've learned and also showing how we do CI at Artsy with Objective-C apps. If you're interested in how we do it in Swift, you can just check [Eidolon](https://github.com/artsy/eidolon).

<!-- more -->

First and foremost, this only works if you are paying for Travis CI.

Travis CI recently merged in support for [Caching of CocoaPods](http://docs.travis-ci.com/user/caching/) - this is great! By using this, we've reduced our build times from an average of about 10 minutes, to about 7 minutes. It works by using your `Podfile.lock` as a key to cache your `Pods` directory, if the lock hasn't changed then there's no need to update the Cache and so `pod install` is not called on your project. This caused me an issue as the `[Project].xcworkspace` file that CocoaPods generates was not in source control, and the app wouldn't build. Useful note, if you're using [development pods](http://guides.cocoapods.org/syntax/podfile.html#pod) in your build you probably shouldn't use this as your Pods directory can get out of sync with the cached version.

We use a [Makefile](https://github.com/artsy/eidolon/blob/master/Makefile) to separate the tasks required to build, test and deploy an app. The general structure of our Makefile is:

| Action        | Reason |
| ------------- | ------ |
| Constants | A collection of constants that get resued by different make tasks. |
| CI Tasks | Separate commands necessary for running Xcode projects from the terminal. |
| Actions | Commands that manipulate your project state, or maintainance commands. |
| Deployment | Commands to get your app ready for the App Store, or Hockey. |

If you don't know the syntax for Make, essentially if it's on the same line you're either setting constants or calling other make commands. If it's on a separate line then you are running a shell command.

This is the [Artsy Folio](http://orta.io/#folio-header-unit) Makefile in full:

``` make
# Constants

WORKSPACE = Artsy Folio.xcworkspace
XCPROJECT = Artsy\ Folio.xcodeproj
SCHEME = ArtsyFolio
CONFIGURATION = Beta
APP_PLIST = Info.plist
PLIST_BUDDY = /usr/libexec/PlistBuddy
TARGETED_DEVICE_FAMILY = \"1,2\"

BUNDLE_VERSION = $(shell $(PLIST_BUDDY) -c "Print CFBundleVersion" $(APP_PLIST))
GIT_COMMIT = $(shell git log -n1 --format='%h')
ALPHA_VERSION = $(BUNDLE_VERSION)-$(BUILD_NUMBER)-$(GIT_COMMIT)

GIT_COMMIT_REV = $(shell git log -n1 --format='%h')
GIT_COMMIT_SHA = $(shell git log -n1 --format='%H')
GIT_REMOTE_ORIGIN_URL = $(shell git config --get remote.origin.url)

DATE_MONTH = $(shell date "+%e %h")
DATE_VERSION = $(shell date "+%Y.%m.%d")

CHANGELOG = CHANGELOG.md
CHANGELOG_SHORT = CHANGELOG_SHORT.md

IPA = ArtsyFolio.ipa
DSYM = ArtsyFolio.app.dSYM.zip

# Phony tasks are tasks that could potentially have a file with the same name in the current folder
.PHONY: build clean test ci

# CI Tasks

ci: CONFIGURATION = Debug
ci: pods build

build:
	set -o pipefail && xcodebuild -workspace "$(WORKSPACE)" -scheme "$(SCHEME)" -sdk iphonesimulator -destination 'name=iPad Retina' build | xcpretty -c

clean:
	xctool -workspace "$(WORKSPACE)" -scheme "$(SCHEME)" -configuration "$(CONFIGURATION)" clean

test:
	set -o pipefail && xcodebuild -workspace "$(WORKSPACE)" -scheme "$(SCHEME)" -configuration Debug test -sdk iphonesimulator -destination 'name=iPad Retina' | second_curtain | xcpretty -c --test

lint:
	bundle exec fui --path Classes find

	bundle exec obcd --path Classes find HeaderStyle
	bundle exec obcd --path "ArtsyFolio Tests" find HeaderStyle

# Actions

ipa:
	$(PLIST_BUDDY) -c "Set CFBundleDisplayName $(BUNDLE_NAME)" $(APP_PLIST)
	$(PLIST_BUDDY) -c "Set CFBundleVersion $(DATE_VERSION)" $(APP_PLIST)
	ipa build --scheme $(SCHEME) --configuration $(CONFIGURATION) -t

alpha_version:
	$(PLIST_BUDDY) -c "Set CFBundleVersion $(ALPHA_VERSION)" $(APP_PLIST)

change_version_to_date:
	$(PLIST_BUDDY) -c "Set CFBundleVersion $(DATE_VERSION)" $(APP_PLIST)

set_git_properties:
	$(PLIST_BUDDY) -c "Set GITCommitRev $(GIT_COMMIT_REV)" $(APP_PLIST)
	$(PLIST_BUDDY) -c "Set GITCommitSha $(GIT_COMMIT_SHA)" $(APP_PLIST)
	$(PLIST_BUDDY) -c "Set GITRemoteOriginURL $(GIT_REMOTE_ORIGIN_URL)" $(APP_PLIST)

pods: remove_debug_pods
pods:
	rm -rf Pods
	bundle install
	bundle exec pod install

remove_debug_pods:
	perl -pi -w -e "s{pod 'Reveal-iOS-SDK'}{}g" Podfile

update_bundle_version:
	@printf 'What is the new human-readable release version? '; \
		read HUMAN_VERSION; \
		$(PLIST_BUDDY) -c "Set CFBundleShortVersionString $$HUMAN_VERSION" $(APP_PLIST)

mogenerate:
	@printf 'What is the new Core Data version? '; \
		read CORE_DATA_VERSION; \
		mogenerator -m "Resources/CoreData/ArtsyPartner.xcdatamodeld/ArtsyFolio v$$CORE_DATA_VERSION.xcdatamodel/" --base-class ARManagedObject --template-path config/mogenerator/artsy --machine-dir Classes/Models/Generated/ --human-dir /tmp/ --template-var arc=true

# Deployment

deploy: ipa distribute

alpha: BUNDLE_NAME = 'Folio α'
alpha: NOTIFY = 0
alpha: alpha_version deploy

appstore: BUNDLE_NAME = 'Artsy Folio'
appstore: TARGETED_DEVICE_FAMILY = 2
appstore: remove_debug_pods update_bundle_version set_git_properties change_version_to_date

next: TARGETED_DEVICE_FAMILY = \"1,2\"
next: update_bundle_version set_git_properties change_version_to_date

distribute:
  cat $(CHANGELOG) | head -n 50 | awk '{ print } END { print "..." }' > $(CHANGELOG_SHORT)
  curl \
   -F status=2 \
   -F notify=$(NOTIFY) \
   -F "notes=<$(CHANGELOG_SHORT)" \
   -F notes_type=1 \
   -F ipa=@$(IPA) \
   -F dsym=@$(DSYM) \
   -H 'X-HockeyAppToken: $(HOCKEYAPP_TOKEN)' \
   https://rink.hockeyapp.net/api/2/apps/upload \
   | grep -v "errors"

```

That gives you a sense of the commands that you can run from the terminal in our projects, next we need to look at the `.travis.yml` file.

``` make
language: objective-c
cache:
  - bundler
  - cocoapods

env:
  - UPLOAD_IOS_SNAPSHOT_BUCKET_NAME=eigen-ci UPLOAD_IOS_SNAPSHOT_BUCKET_PR...

before_install:
  - 'echo ''gem: --no-ri --no-rdoc'' > ~/.gemrc'
  - cp .netrc ~
  - chmod 600 .netrc
  - pod repo add artsy https://github.com/artsy/Specs.git

before_script:
  - gem install second_curtain
  - make ci

script:
  - make test
  - make lint

```

This is nice and simple. It was built to use multiple travis build steps. This makes the CI output a lot more readable as an end user. Travis will by default collapse the shell output for different build stages leaving only the `script` stage defaulting to being exposed. Here is an example of what you see on a failing test:

<center>
<img src="/images/2014-08-08-CocoaPods-Caching/failing_travis_screenshot.png" alt='Travis CI Failure'>
</center>

We use a gem with a binary in [second_curtain](https://github.com/AshFurrow/second_curtain/), and this came with bundler caching issues in Travis. The solution was to ignore bundler and run `gem install second_curtain` each time. To increase the speed we also ensured that documentation is not being generated. If you are interested in what's going on with the `.netrc`, read my blog post on [Artsy's first Closed Source Pod](http://artsy.github.io/blog/2014/06/20/artsys-first-closed-source-pod/).

We will continue pushing the state of the art in iOS deployment, in building our own tools and using everything available to increase developer happiness. If you're into this we're always looking to hire people with a good open source track record or street smarts. Here's [the jobs page](https://artsy.net/job/mobile-engineer).
