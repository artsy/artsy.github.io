---
layout: post
title: "CocoaPods-Keys and CI"
date: 2015-01-21 16:43
comments: true
categories: [iOS, mobile]
author: orta
---

We built CocoaPods-Keys as a way to remove API keys and secrets from our source code. We use it to open up our code to the public, without leaking private details. One of the cool things about doing it this way was that we could all use different API keys stashed away in each developers Keychain.

To ensure we could run CI on our apps we came up with two different ways to use keys on CI. This post explains them both.

<!-- more -->

## The easy way.

Depending on your use-case, you may not need to use the keys at all in your testing. This works really well if you're using stubbed network requests. So if you have a keys definition in your [Podfile](https://github.com/artsy/eidolon/blob/9a918108e717a68a45709345f38d55e0eeb1f8b3/Podfile#L4-L21) like this:

```ruby
plugin 'cocoapods-keys', {
  :project => "Eidolon",
  :target => "Kiosk",
  :keys => [
    "ArtsyAPIClientSecret",
    "ArtsyAPIClientKey",
  ]
}
```

Before the CI runs `pod install` you will want ensure you have already set the keys to be dummy data. So in either your `install:` or `before_install:` add commands like the following:

```
	bundle exec pod keys set ArtsyAPIClientSecret "-" Eidolon
	bundle exec pod keys set ArtsyAPIClientKey "-"

```

This will set up the keys beforehand with the right target name.


## The fully featured way

If you need to have full access to an API with secret keys, we recommend using the CI's private environment keys feature. You can see the technique being used here in Eidolon, starting on [line 5](https://github.com/artsy/eidolon/blob/master/.travis.yml#L5) we declare a secure environment key `GITHUB_API_KEY` in that hash. Then it is used on [line 8](https://github.com/artsy/eidolon/blob/aa8e8447f797c483ff72148d124d2930b58a42e7/.travis.yml#L8) to set up our `~/.netrc`.

To get started on Travis CI you will need to install the travis gem, and go through the [Environment Variables](http://docs.travis-ci.com/user/environment-variables/) section of their documentation. Notably the [Secure Variables](http://docs.travis-ci.com/user/environment-variables/#Secure-Variables) section. In a gist, you run `travis encrypt ARTSYAPICLIENTSECRET=super_secret_yo` and it gives you the secure string.

You can then use the new keys in your `before:` section:

```
	bundle exec pod keys set ArtsyAPIClientSecret $ARTSYAPICLIENTSECRET Eidolon
	bundle exec pod keys set ArtsyAPIClientKey $ARTSYAPICLIENTKEY

```

That's a wrap. We don't use the second technique in any OSS repos, though there is talk of doing it on our [Artsy Authentication](https://github.com/artsy/Artsy_Authentication/) pod. So if you're in my future 👋, maybe give that a look over as an example of the latter.
