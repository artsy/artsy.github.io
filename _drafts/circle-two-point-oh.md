---
layout: post
title: "Upgrading Volt to Circle 2.0"
date: 2017-12-20
comments: true
author: jonallured
categories: [ci]
---
I was really excited about CircleCI 2.0, especially the workflows features. It
seemed to me that with the work they had done here, really complicated builds
would be able to be configured in a way that made more sense than on 1.0. This
was something that was causing me grief on one of our projects, called Volt so I
upgraded to 2.0. It was pretty hard to get green and once we did, we decided to
downgrade back to 1.0. Here's why.

Volt is what we call our app that Partners use to enter information about their
artworks and artists into the Artsy platform. It's a Rails app and has a pretty
big and slow test suite. Over time, we've ended up with a good number of things
that run during CI for this project:

* [Danger][]
* [RuboCop][]
* [Prettier][]
* [Jest tests][Jest]
* [Teaspoon tests][Teaspoon]
* [RSpec tests][RSpec]

[Danger]: http://danger.systems/
[RuboCop]: http://rubocop.readthedocs.io/
[Prettier]: https://prettier.io/
[Jest]: https://facebook.github.io/jest/
[Teaspoon]: https://github.com/jejacks0n/teaspoon
[RSpec]: http://rspec.info/

Some of these things are fast and some are slow. Ok, fine, really only the view
specs are slow - you can run everything else in about BLAH minutes. The view
specs add about BLAH minutes.

My goal was to separate out the fast stuff, run that in parallel and only if all
that passed would I run the view specs. This should get our developers feedback
faster when they've broken something and not waste time running the slowest part
of the CI stack.

Artsy has 7 containers with Circle and Volt takes up 6 of them, so being able to
break apart it's parts into pieces seemed like a good thing for the wider Artsy
engineering organization too - developers working on something else would spend
less time blocked by Volt builds and developers working on Volt shouldn't notice
anything. Foreshadowing!!

Here's the [config][] and here's a pretty picture of what our CircleCI 2.0 builds
looked like:

[config]: https://gist.github.com/jonallured/45032779506138186973af7cb94b5363

![/images/circle-two-oh/volt-circle-two-workflow.png](/images/circle-two-oh/volt-circle-two-workflow.png)

I'm really proud of this - it's cool and it was hard to figure out!

But then we lived with it and noticed something that really slowed us down. Each
rounded rect in that picture is called a job and is scheduled along with
anything else you have going on at Circle. That would often mean that once the
build step was done and the next column of jobs kicked off, then we'd be stuck
waiting for a container. But those are fast jobs, so they would finish pretty
fast. But then again, moving on to the `view_specs` job would be slow because it
wanted 6 containers to run in ~10 minutes.

What this meant was that all told it often took 45 minutes of wall time to
finish one of these builds even though as Circle reports it, they only took like
15 minutes.

We reached out to Circle to explain as best we could our situation but didn't
get a lot of help there. They advised that going back to 1.0 might be wise for
now.
