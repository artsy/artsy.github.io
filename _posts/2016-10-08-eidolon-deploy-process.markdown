---
layout: post
title: "The Eidolon Deploy Process"
date: 2016-10-08 12:00
author: ash
categories: [mobile, eidolon]
---

Since we [originally built](http://artsy.github.io/blog/2014/11/13/eidolon-retrospective/) Eidolon – an auction bidding kiosk app – the project has largely remained in maintenance mode. Eidolon was one of the first projects that we used automated deploys for, and the deploy process has remained largely unchanged. I believe this stability of the deploy process is a testament to how well the automated deploys have gone. 

This post is going to detail the mechanics of automated deploys for an enterprise-distributed iOS application, discuss lessons we learned and applied to other projects' deploy processes, and describe some of the changes we'd like to make. Our project is entirely open source, so you can check out any part of the code on your own or [open an issue](https://github.com/artsy/eidolon/issues/new) with questions.

<!-- more -->

## Deploying Eidolon

It's one command on the terminal to deploy Eidolon:

```sh
bundle exec fast lane deploy version:X.Y.Z
```

This command does a lot of things. It uses [Fastlane](https://fastlane.tools), and you can [read the entire script here](https://github.com/artsy/eidolon/blob/a0aad31bccfe2b4abf648fc64892cc165be400b4/fastlane/Fastfile#L40-L131). We're going to go over each part line-by-line. A few notes:

- We run this command locally on a development machine that has the keys installed to sign a deploy.
- Our changelog is formatted in [yaml](https://en.wikipedia.org/wiki/YAML), our script uses this strategically.
- Our deploy script modifies the project's Info.plist version and build number, as well as the changelog.

Let's dive in!

## The Script

The first thing we do is verify that the version number we've been given is in the proper [SemVer](http://semver.org) format.

```rb
version = options[:version]
raise "You must specify a version in A.B.X format to deploy." if version.nil? || version.scan(/\d+\.\d+\.\d+/).length == 0
```

We deploy using Hockey, so make sure that an environment variable with the Hockey API key is set.

```rb
hockey_api_token = ENV['HOCKEY_API_TOKEN']
raise "You must specify a HOCKEY_API_TOKEN environment variable to deploy." if hockey_api_token.nil?
```

We also want to verify that we have valid API keys for analytics, the Artsy API, and a few other services the app uses. This validation only makes sure the keys have been set to non-empty values. And we don't want to accidentally deploy uncommited changes, so we check the git status first.

```rb
verify_pod_keys
ensure_git_status_clean
```

Next we need to set the build number. These need to be unique, and we use the current date. This could be a problem if we need to deploy more than once in a day. It hasn't been a problem yet, though, since we rarely deploy. 

We also want to set the Info.plist's version to the one specified when we run the `fastlane` command.

```rb
build_number = Time.new.strftime("%Y.%m.%d")
increment_build_number build_number: build_number

increment_version_number version_number: version
```

Okay, now it's time to generate markdown release notes from the changelog. Our changelog is in the following format:

```yaml
upcoming:
- Upcoming version bug fix.

releases:
- version: X.Y.Z
  date: Month Day Year
  notes:
  - Previous version bug fix.
```

We want to grab the `upcoming` notes for the changelog, and then move them to the `releases` section. Let's generate the notes first:

```rb
changelog_filename = '../CHANGELOG.yml'
changelog_yaml = YAML.load_file(changelog_filename)
release_notes = changelog_yaml['upcoming'].map{ |note| note.prepend '- ' }.join("\n")
```

Updating the changelog is a little messy. I tried parsing the changelog as yaml, modifying it, and then writing it back as yaml, but kept running into trouble. Instead, I treat it as plain text. We open the changelog, split on `releases:`, prepend the existing releases with a the generated release notes, and write the changelog.

```rb
changelog_contents = File.read(changelog_filename)
existing_releases = changelog_contents.split('releases:').last
this_release = changelog_yaml['upcoming'].map{ |note| note.prepend '  ' }.join("\n")
changelog_contents = <<-EOS
upcoming:
releases:
- version: #{version}
  date: #{Time.new.strftime("%B %d %Y")}
  notes:
#{this_release}
#{existing_releases}
EOS

File.open(changelog_filename, 'w') { |file| file.puts changelog_contents }
```

At this point, we're ready to start the actual deploy process. First we need to download the provisioning profiles, which is only one step with Fastlane:

```rb
sigh
```

Next we build our app using `gym`. We need to use the legacy build API, I can't remember why.

```rb
gym(
  scheme: "Kiosk",
  export_method: 'enterprise',
  use_legacy_build_api: true
)
```

With our build finished, we upload to Hockey.

```rb
hockey(
  api_token: hockey_api_token,
  notes: release_notes
)
```

Okay, our build is deployed. Time to let the team know there's a new version available:

```rb
slack(
  message: "There is a new version of the Kiosk app available. Download it at http://artsy.net/kioskbeta",
  success: true,        # optional, defaults to true
  payload: {            # optional, lets you specify any number of your own Slack attachments
    'Version' => version,
    'What\'s new' => release_notes,
  },
  default_payloads: [],
)
```

`default_payloads` needs to be empty I think, I can't remember why. Seems like "I can't remember why" is a common theme here...

Before committing the changes we've made to the changelog and Info.plist files, we need to clean any build artefacts. This includes the actual binary that was compiled, unit test coverage reports, and downloaded provisioning profiles.

```rb
clean_build_artifacts
```

Finally, we commit, tag the build, and push to GitHub. Fastlane's built-in commands to commit to git reject any changes except to Info.plist files, and we've modified the changelog, so I used `sh` and used git directly.

```rb
sh "git add .. ; git commit -m 'Deploying version #{version}.'"
add_git_tag tag: version
push_to_git_remote
```

And that's it! With one terminal command, we've done all the following:

- Verified version number format.
- Verified the local environment is set up to deploy.
- Verified API keys used by the app aren't empty.
- Incremented the build number and version.
- Updated the changelog.
- Built and signed the app.
- Uploaded the build to Hockey.
- Posted a notification to Slack.
- Tagged the release and pushed to GitHub.

## Lessons Learned

Automating Eidolon deploys was one of the first automated deploys we built on Artsy's iOS team. Now, based on Eidolon's successful deploy process, all our iOS deploys are automated.

We've learned a few lessons.

First, running deploys locally is _so 2015_. Our more modern deploy processes run on continuous integration servers like Circle CI. This poses some problems around securing certificates necessary to deploy, maybe we'll cover that in a future blog post.

We deploy on CI based on pushes to a specific branch, and we run our deploy script only if the unit tests pass. This is a huge incentive to keep CI green.

On other iOS projects, we sometimes deploy more than once a day, so we use `Year.Month.Day.Hour` as the build number format, which is unique enough to do one deploy per hour. This is good enough for now.

One thing I really wish I'd done when I set up automated deploys is to document things a little better. To be honest, that's part of the motivation to write this blog post (better late than never!).

## Conclusion

Overall, automating deploys for Eidolon has been a huge win. The other night, we had an emergency at an auction: the Eidolon app was no longer working and we needed a new deploy.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Guess who’s got two thumbs and forgot that their enterprise distribution certificates expire in September.<br><br>👍this guy👍</p>&mdash; Ash vs NSThread (@ashfurrow) <a href="https://twitter.com/ashfurrow/status/784548214527627266">October 8, 2016</a></blockquote> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

From the time the team let me know about the problem to the time they had a fresh deploy with a new certificate, less than twenty minutes had passed. I issued one command and watched it do all the work for me. If I had to manually follow a set of arcane steps I hadn't done in a long time, our team might not have had the new build in time. 
