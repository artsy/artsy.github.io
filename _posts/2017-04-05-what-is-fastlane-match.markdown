---
layout: post
title: "What is fastlane match?"
date: 2017-04-05 12:17
author: orta
categories: [mobile, ios, energy, fastlane]
---

Like anyone working on a non-trivial app in the iOS world who values their time, we use fastlane. [fastlane][] is a suite
of tools that makes it much simpler to automate the very manual processes provided by Apple for deployment.

We've adopted it in a relatively piece-meal manner in different projects, converting custom in-house code to something 
provided by the gem.  Over time we found what pieces of the suite work for us. [I've adopted another today][pr]: [match][].

match automates setting up your iOS projects for code signing. One of the most arduous orthogonal tasks which every dev team learns and then forgets.

In using match, we have given away a bit of control with code signing, and so this post is going to dig into; what we used 
to have, and how it works now with match instead.

<!-- more -->

When match came out, I knew this was a 🌟 idea.

* Automatically generate the right certificates and keys for your different apps and environments.
* Take all your developer certificates and keys, move them to a central place accessible via private git repos.
* Encrypt all your certs and keys, the team just needs to share one password.
* Migrate all of those keys on both the developer's and CI's computers.

You can now have a consistent signing setup between how you work, and how your CI runs. After understanding this, I migrated
Artsy's app store apps to deploy via [Circle CI]. We initially gave match a shot, but ended up having issues with supporting 
multiple apps. So, I replicated the core ideas in match into our Fastfile. It looked like this:

```ruby
lane :setup_for_app_store do
  app_name = "eigen"
  signing_root = "signing"

  `git clone https://github.com/artsy/mobile_code_signing.git #{signing_root}`

  # prints out the codesigning identities
  system "security find-identity -v -p codesigning"

  # Install the iOS distribution certificate, -A
  system "security import #{signing_root}/ios_distribution.cer  -k ~/Library/Keychains/login.keychain -A"

  # Move our provisioning profile in
  profile_path = File.expand_path("~") + "/Library/MobileDevice/Provisioning Profiles/"
  destination = profile_path + "/" + app_name + ".mobileprovision"
  profile = Dir.glob(signing_root + "/profiles/" + app_name + "/*").first

  # Ensure folder exists
  unless File.directory?(profile_path)
    FileUtils.mkdir_p(profile_path)
  end

  # Migrate it in
  FileUtils.copy profile, destination
  puts "Installed Profile"

  # Install the key
  key = Dir.glob(signing_root + "/keys/" + app_name + "/*").first
  system "security import #{key} -k ~/Library/Keychains/login.keychain -P #{ENV['MATCH_PASSWORD']}  -A "

  # prints out the codesigning identities
  system "security find-identity -v -p codesigning"

  # Clean-up
  `rm -rf #{signing_root}`
end
```

Pretty neat, huh? It handles the centralization and migration of certificates. The trade-off against match is:

* We continue to maintain our own certificates, keys and provisioning profiles.
* There is no easy way to update these.
* There is tooling which makes it easy to see the state of all the code signing process.

A year later, on a project which gets no-where near as much developer attention, I discovered that we had got multiple 
parts of the certs, keys and profiles wrong when updating our central repo. So, for [this project][folio], I have switched to use match.

--- 

# So how does it work now?

First, I ran `bundle exec fastlane appstore` and `bundle exec fastlane dev`.

This creates the certificates, keys and profiles on iTunes connect and gives you output similar to this:

```sh

+-----------------------+------------------------------------------------+
|                        Summary for match 2.25.0                        |
+-----------------------+------------------------------------------------+
| readonly              | true                                           |
| git_url               | https://github.com/artsy/mobile_fastlane_match |
| type                  | appstore                                       |
| git_branch            | master                                         |
| app_identifier        | sy.art.folio                                   |
| username              | it@artsymail.com                               |
| keychain_name         | login.keychain                                 |
| team_id               | 23KMWZ572J                                     |
| team_name             | Art.sy Inc.                                    |
| verbose               | false                                          |
| force                 | false                                          |
| skip_confirmation     | false                                          |
| shallow_clone         | false                                          |
| force_for_new_devices | false                                          |
| skip_docs             | false                                          |
| platform              | ios                                            |
+-----------------------+------------------------------------------------+

[17:03:52]: Cloning remote git repo...
[17:03:54]: 🔓  Successfully decrypted certificates repo
[17:03:54]: Installing certificate...

+-------------------+-----------------------------------------------+
|                       Installed Certificate                       |
+-------------------+-----------------------------------------------+
| User ID           | 23KMWZ572J                                    |
| Common Name       | iPhone Distribution: Art.sy Inc. (23KMWZ572J) |
| Organisation Unit | 23KMWZ572J                                    |
| Organisation      | Art.sy Inc.                                   |
| Country           | US                                            |
| Start Datetime    | Apr  4 13:59:06 2017 GMT                      |
| End Datetime      | Apr  4 13:59:06 2018 GMT                      |
+-------------------+-----------------------------------------------+

[17:03:56]: Installing provisioning profile...

+---------------------+-----------------------------------------+-------------------------------------------------------------------------------------------------------------+
|                                                                       Installed Provisioning Profile                                                                        |
+---------------------+-----------------------------------------+-------------------------------------------------------------------------------------------------------------+
| Parameter           | Environment Variable                    | Value                                                                                                       |
+---------------------+-----------------------------------------+-------------------------------------------------------------------------------------------------------------+
| App Identifier      |                                         | sy.art.folio                                                                                                |
| Type                |                                         | appstore                                                                                                    |
| Platform            |                                         | ios                                                                                                         |
| Profile UUID        | sigh_sy.art.folio_appstore              | b045df0f-a691-4b7a-ac34-8349a3684030                                                                        |
| Profile Name        | sigh_sy.art.folio_appstore_profile-name | match AppStore sy.art.folio                                                                                 |
| Profile Path        | sigh_sy.art.folio_appstore_profile-path | /Users/orta/Library/MobileDevice/Provisioning Profiles/b045df0f-a691-4b7a-ac34-8349a3684030.mobileprovision |
| Development Team ID | sigh_sy.art.folio_appstore_team-id      | 23KMWZ572J                                                                                                  |
+---------------------+-----------------------------------------+-------------------------------------------------------------------------------------------------------------+

[17:03:56]: All required keys, certificates and provisioning profiles are installed 🙌
```

Which at a glimpse gives a lot of the most useful information about how all the pieces come together. The new repo looks like this:

```sh
$ tree mobile_fastlane_match

├── README.md
├── certs
│   ├── development
│   │   ├── P4K6FACAUD.cer
│   │   └── P4K6FACAUD.p12
│   └── distribution
│       ├── N5BMJ28RQ2.cer
│       └── N5BMJ28RQ2.p12
├── match_version.txt
└── profiles
    ├── appstore
    │   └── AppStore_sy.art.folio.mobileprovision
    └── development
        └── Development_sy.art.folio.mobileprovision

```

## So, what is Match doing here?

1. match creates a new key (the `*.p12`) - normally you would generate one of these through Keychain, and the entire team would 
   to share this. We keep ours in team [1Password][]. It needs to be used consistently when request certificates from Apple 
   though the "Request a Certificate from a Certificate Authority" part of getting your certs set up.

2. Using [cert][]: match will use this key [to create a signing request][signing] for you.

3. Using [cert][]: match will generate a certificate for [development or distribution][certs] for you.

4. Using [cert][]: match will [generate a Provisioning Profile][prov] using your certificate and data pulled from your Xcode Project. 
   In my case, for development and distribution.
  
   These profiles are tied directly to one app and the certificate in step 3. For development, all devices in the dev center are also added.

5. These files are then installed in their various methods.

6. These files are then moved into your git repo, a commit is made for you, then pushed and the repo is removed from your computer.

This process is nice, because this ^ is a lot of work. I only had to run a command. 

It would take at about 30 minutes to do this if I knew exactly what I wanted through the web interface + Keychain. 

We currently need to do this for every app. This works fine for the app where we are deploying multiple betas a month, 
but for one when we're deploying _maybe_ a beta once a month or two (_eek! sorry..._) then it feels like every time you've come
back to do some work, the world has shifted a bit.

We do lose the fact that we know someone has specifically set everything up to work right at some point, but given how 
Xcode updates, [WWDR updates][wwdr] and certificate expirations tend to crop up - it can be frustrating to maintain.

So would I move [Eigen][] to match? Maybe, next time something breaks. Till then I think new apps, and less-often updated 
apps should use match.


[Fastlane]: https://fastlane.tools
[match]: https://github.com/fastlane/fastlane/tree/master/match
[First Build]: https://circleci.com/gh/artsy/energy/294
[pr]: https://github.com/artsy/energy/pull/266
[Circle CI]: https://circleci.com
[folio]: http://folio.artsy.net
[cert]: https://github.com/fastlane/fastlane/tree/master/cert
[signing]: https://github.com/fastlane/fastlane/blob/14dea61e4c81bf9be13bb86c09aa225c6e572618/cert/lib/cert/runner.rb#L141
[certs]: https://github.com/fastlane/fastlane/blob/14dea61e4c81bf9be13bb86c09aa225c6e572618/cert/lib/cert/runner.rb#L79
[prov]: https://github.com/fastlane/fastlane/blob/14dea61e4c81bf9be13bb86c09aa225c6e572618/match/lib/match/runner.rb#L133
[1password]: http://1password.com
[wwdr]: http://stackoverflow.com/questions/4057241/iphone-what-is-a-wwdr-intermediate-certificate
[Eigen]: https://github.com/artsy/eigen
