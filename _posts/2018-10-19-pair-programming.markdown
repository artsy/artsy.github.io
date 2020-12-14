---
layout: epic
title: "The Hows and Whys of Pair Programming"
date: 2018-10-19
author: [yuki, orta]
categories: [pairing, culture]
---

_Why pair program? As new engineers join Artsy, we've been experimenting with different programming cultures - Yuki
came from Pivotal Labs where they have a strong pair programming culture and introduced it at Artsy - it's been
about a year and a half and we're all really loving the changes he's introduced._

_I asked Yuki if he'd pair program with me on a blog, post on Pair Programming, and this is it. He's going to
dive into what pair programming is, why you should do it, what are good mental models to think about, the techniques
you can use to make it work, what hardware you might need and how Yuki persuaded so many of us to start doing it
more often._

&mdash; Orta

<!-- more -->

## Why pair program?

The idea of pair programming came from a very popular book called [Extreme Programming Explained: Embrace
Change][extreme-explained]. Code review has been a good practice in software development for decades. Many organizations have
adopted it, but XP (Extreme Programming) literally takes this **more extremely** - what if the engineer sitting next
to you is reviewing your code as soon as you write it? This requires two engineers to simultaneously pay attention
to the code that's being written, discuss implementation details, and sometimes socialize. That's how pair
programming was born.

Pair programming seems as easy as it sounds, and to some extent that's true. However, with just a few key points
you'll be able to make your pairing session much more valuable.

To think about when pairing is most valuable, let's think about code review first. Modern software organizations
have implemented a process where engineers send pull requests to get reviews on GitHub (or whatever tool your
organization uses for reviewing code). This is a very powerful process, but most of us have probably experienced a
situation where a pull request with [a very simple change created a very long discussion][simple_changes]. Sometimes
that's because of your lack of context in the work you are doing. Sometimes it's because you are working on a
system you are unfamiliar with. Your co-worker left a lot of comments on your pull request, and you had to push a lot
of extra commits, or even re-wrote the entire pull request. That's when pairing becomes very valuable to your team.

Another good example is on-boarding new hires. Coming from an agile consultancy and a photo-product company, I was
nowhere close to an Art expert when I joined Artsy. This was the time I wanted to question not just technical
questions, but also very basic questions about art. How do people find and purchase artworks? Who actually sells
artworks? What is an art fair? And auctions? [Christina Thompson][christina-thompson], on the other hand, has been at 
Artsy for more than two years. She also has strong experience in agile software development and practices, including 
pair-programming. Naturally, we started pairing to familiarize myself both with the code base and basic knowledge 
about Art on my first week at Artsy.

### When not to pair program?

This post is about pair-programming, so why even talk about when not to pair-program? Well, while it’s a powerful tool,
it's not a silver bullet we can utilize to solve all software problems. As we all deal with complex, long-standing
pull requests, there are also simple changes that don't require a lot of discussions. Occasionally, your pull request
is very long because of a great number of deprecated method names. Sometimes, you and your pair both feel stuck because
none of you have context or knowledge about what you are addressing. Whenever you are not feeling as productive as you
think you should be, then you don’t have to pair. Sometimes it may make sense for two of you to do research
individually and check in later to share findings and learnings. In an occasional case, even swapping a pair is also a
good way to make the entire team more productive.

So what is the key point that makes a pair-programming session successful? I believe pair-programming works best when
there is a fair amount of knowledge gap between two people. One is coding and teaching simultaneously, and the
other is reviewing and learning simultaneously. Here the crucial part is _teaching_. It is easy, especially for more
seasoned developers, to ignore the opportunity to share thoughts and knowledge with new hires, losing productivity
they could've gained by pairing. Joining a new company is always scary, and pair-programming with a new hire will
reduce a lot of "I wasn't sure about X" moments new hires might have encountered. At the same time, as mentioned above,
pair-programming is not a silver bullet. It is important to be able to use pair-programming as a tool in your toolbox
to solve a particular issue in your engineering team.

## What You'll Need to Pair Program

The minimum you need is a computer and the ability to communicate, but let's look at what an optimal pair
programming setup looks like.

### Offline

If you and the other engineer are in the same physical space, then you should aim to have:

- One computer set up as a workstation.
- Two sets of keyboards, mice and monitors attached.
- A spare computer for researching on the side.

This gives you the ability to iterate and switch responsibilities at the speed of thought. If you have the resources
and space, then setting up a place where any 2 engineers can drop a laptop down and be productive instantly will
reduce a lot of the setup friction.

### Remote

The minimum you would need in this case is a video chat system like Skype, Google Hangouts or Slack Calls. Given
that all of these support screen sharing too, then you can easily replicate two people sitting next to each other
with one computer.

It's worth noting that remote pairing requires stable internet, and with high bandwidth. We've both had situations
in the past where we've had to abort pairing sessions due to internet un-reliability.

In the past, we used to use ScreenHero a lot, because of it's great support for multiple mice and keyboards, but 
[ScreenHero was bought by slack][sh] and those feature aren't available for everyone. 

A lot of our pairing is done via the built-in Slack screen sharing. There's a newcomer to the scene though! 

[VS Code's LiveShare][ls] gives you the ability to share an IDE: it can handle voice
chat, sharing server ports and sharing terminal sessions with a very  minimal amount of setup.

We wrote the initial draft of this post in-person, in an Artsy meeting room writing and talking in real-time. 
If you've not seen Live Share, we posted a video of a [workshop we ran][ls-yt] at Artsy on YouTube.

### Attribution

One way to encourage pair programming is by providing insight to others about when you're working as a pair. A great
technique for this is to use [`git-duet`][git-duet]. Git Duet is a tool which extends git to make it easy to share
attribution among contributors. It does this by having a central list of people' emails, you set up a pairing
session, then use `git duet-commit` to replace `git commit` and the attribution shared.

You can get started with:

```sh
$ brew tap git-duet/tap
$ brew install git-duet
```

You'll then need to set up a `~/.git-authors` file which is a map of people's names to emails:

```yml
pairs:
  ot: Orta Therox; orta
  af: Ash Furrow; ash
  md: Matt Dole;
email:
  domain: artsymail.com
email_addresses:
  md: mdole7@gmail.com
```

The format for each pair is `[tag]: [Name]; [email-prefix]`. This works in combination with the `email:domain` as
the default email address host for someone. So it would infer that Ash Furrow's email is `ash@artsymail.com`.
If they've not set up that email yet, then you can use `email_addresses:` to provide overrides.

Now your config is set up, you can start using it. In your terminal you can use `git duet ot af` to start a session
with Orta and Ash.

```sh
~/d/p/a/j/a/metaphysics  $ git duet ot af

GIT_AUTHOR_NAME='Orta Therox'
GIT_AUTHOR_EMAIL='orta@artsymail.com'
GIT_COMMITTER_NAME='Ash Furrow'
GIT_COMMITTER_EMAIL='ash@artsymail.com'
```

Now you just have to remember to use `git duet-commit` instead of `git commit` for our work. If you forget, you can
use `git duet-commit --amend` to overwrite the last commit with a duet commit instead.

## Where to go from here?

Pair-programming is a fantastic way to collaborate. If your organization hasn't incorporated it yet, I would highly recommend doing so. At Artsy, we've been experimenting with pair-programming for quite a long time, but this is only the start. We haven't figured out the form of pair-programming that works best for us, and it'll probably never end (and it's a good thing). There are also a lot more to think about that didn't get into this blog post, such as mental model one should have while pairing and techniques that keep you focused. We will re-visit once we gain more feedback and iterate on our pairing process.

If you're looking to find more resources on pair programming

- Joe Moore's [Remote Pair Programming][rpp] is a great place to start. He's been working at Pivotal Labs for over a decade.
- Tuple’s [Pair Programming Guide][ppg] is a good work in progress at centralizing a lot of information.

[christina-thompson]: https://medium.com/artsy-blog/what-it-feels-like-to-work-in-a-supportive-environment-for-female-engineers-3c994a001007
[extreme-explained]: https://www.goodreads.com/book/show/67833.Extreme_Programming_Explained
[sh]: https://slack.com/screenhero
[ls]: https://visualstudio.microsoft.com/services/live-share
[ls-yt]: https://twitter.com/ArtsyOpenSource/status/1034555778210910209
[rpp]: http://remotepairprogramming.com/
[git-duet]: https://github.com/git-duet/git-duet/
[simple_changes]: https://github.com/artsy/reaction/pull/1114#discussion_r209354107
[ppg]: https://tuple.app/pair-programming-guide/

<!-- 
Notes:

- http://www.extremeprogramming.org/rules/pair.html -->

<!-- Appendix
  - Ways in which you can encourage more pairing?
  - Techniques for introducing it into your team
  - Good resources? Further reading
  - Do we do it as much as we'd want?
  - Mental model
    - Remind your pair of what to work on
    - Speak up while pairing
    - Take breaks often
    - Show appreciation
  - Techniques
    - driver and navigator
    - ping-pong pairing
  - What companies provides a good best examples?
-->
