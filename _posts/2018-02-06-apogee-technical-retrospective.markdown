---
layout: epic
title: "Apogee Technical Retrospective"
date: 2018-02-06
categories: [rails, ruby, typescript]
author: [ash]
series: Apogee
---

<!--

# Outline

- Intro
	- Explanation about why this is interesting
	- Link to previous posts
	- Explanation about closed source
	- Top-level business requirements of Apogee
	- Decision to split Apogee into two pieces
		- Google expects you to write your Add-on in the Google Scripts in-browser editor, which is not very good
		- Google Scripts are bad at collaborating with
		- Google Scripts can't be unit tested
		- Since we can't fully automate deploys, let's just try to minimize how frequently we _have_ to deploy
- Add-on
	- Overview of the function of the Add-on
	- Strange Add-on language (JavaScript 1.6, plus some of 1.7 and 1.8) and runtime (no event loop)
	- At least there's Lodash.
	- Oh wait, there's TypeScript!
	- UICallback limitation
		- 163kB Functions.gs file
		- runs in Google data centre, not in-browser so ¯\_(ツ)_/¯
	- Strange Add-on permission model 
		- execution differs between deploy installs and testing against a sheet
		- Workaround: triggers to get new UI JSON
- Server
	- Requirements, how they differed from typical Rails app
	- Structure of parsers, runtime reflection, tokens
		- Why? Avoids having to keep a manually updated list.
	- Metaprogramming abstractions
		- Adding parser classes to modules programmatically
		- Adding AllParser class to modules
	- Unit testing
- Authentication options
	- Whitelist request IPs
	- Basic Auth
	- Shared secret
	- OAuth with Artsy by user during Add-on installation
	- Something custom, or a combination of any of these
	- We're not saying what we settled on not in a concern for our security, but in a concern for yours. You should do your own thing.
- Conclusion

-->

<!-- more -->
