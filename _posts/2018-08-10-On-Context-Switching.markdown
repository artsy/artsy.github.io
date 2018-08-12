---
layout: epic
title: "Context Switching"
date: 2018-08-10
author: [orta]
categories: [danger, shortcuts, concepts]
---

Programming generally requires getting into a good [flow state][flow] and working on a tricky problem for some time.
In the last few years, most of my work at Artsy (and in the OSS world) has been less about longer-term building hard
things, but working on many smaller tasks across a lot of different contexts.

Somehow, I managed to end up in the top of "most active" [GitHub members][active], I feel like a lot of this is due
to doing [Open Source by Default][ossd] at Artsy and second to being good at context switching. I want to try talk
though some of my techniques to handling context switching as well as a bit of philosophy around adopting and owning
your tools.

<!-- more -->

## Shallow and Wide Work

I want to allow as many people as possible to be doing fun deep flow work at Artsy. One of the most successful ways
of achieving this I've found is to spend most of my time working on shallower tasks. A contemporary from my last few
weeks is hiring, the communication aspects requires dozens of emails and internal updates that can't be scheduled
into safe blocks. _([Totally related BTW, we're hiring][hiring].)_

For programming work I have a few techniques for trying to accomplish a lot of shallow tasks across many repos.

Start off by making yourself accountable to someone. For my OSS, this tends to either be [setting expectations][exp]
in README or using [a VISION][vision] file. When it's at Artsy, we have product managers and engineers who own the
projects I'm contributing to. For this blog post, it's my [buddy Chris][chris].

I would then strive to get _anything_ out, this could be a work-in-progress PR or via
[README-driven-development][rdd]. Part of this is because you might end up dragged off into something else very
quickly, and the other is that you're less likely to know everything about the domain in which you're working. I
like to think of it as _any improvement is an improvement_.

One way to get rich domain knowledge is by pairing with someone who is more involved, this is a perfect way to
understand how decisions were made and provides a great insight into how someone works on a project. In pairing, you
might find additional ways to improve the daily workflow for someone else too!

Trying to have a shallow and wide understanding of many systems means accepting that you can't know the finest
details about how everything works. You want to know when really big interesting things are happening, but most work
should be iterative and less relevant to external folk. One technique I use for keeping track of these kind of
changes is for making my own streams of updates and not being too fussy about seeing them all. For my GitHub
organisations this means making a slack channel that gets updates for PRs and releases. You can see many overviews,
but not get bogged down in the useful discussion.

A tricky thing with this sort of work is trying not to be a blocker for someone else. A lot of this is about being
cautious about what you strive to help with, and about finding ways to boost others asynchronously. Am I good at
this? Sometimes. It's easier in OSS thanks to the the limited liability clauses, but in work-work that can be hard.

When my contributions are larger, and I know the domain well for example in a front-end JavaScript project. I am
willing to take longer than I'd like to ensure it's best-practices at the company for the rest of the codebase. A
recent example came up in a retrospective last month when an engineering team at Artsy said that one of [my
projects][consign] was a key reference for testing and React Native form handling for them. Pulling off this can
definitely take longer than expected, but if you're not going to be the one maintaining it then holding yourself to
a higher standard is worth it.

## Deep Automation

Remove as much ambiguity as possible for discussion. Tools like [prettier][] really help focus code review away from
the petty formatting issues. Linters like tslint, eslint and rubocop remove remove another series of discussion
points. When you find yourself surprised by a cultural rule for a codebase, add [a danger][danger] rule so you and
others have it codified. Use tools like [husky][] and [lint-staged][] to get that feedback when you're still in a
development context. Danger can even run as a [git-hook/husky task][danger-local] too, so that feedback can be
_blazing_ too.

You can automate via tools, sure, but you can also encourage independent work via documentation. If something is
confusing enough that, as an outsider, you don't get it without asking, you should start adding documentation. I
can't tell you what that looks like because it's different per-project, but at least try make it so you the next
person doesn't need to ask.

I strive to use my time on the project to encourage more consolidation, in the case of front-end that's moving
closer to [the Artsy omakase][oma]. In the case of servers that could be encouraging new APIs to use GraphQL, or to
adopt some of our newer ideas about schema management.

## Impact per Keystroke

I'm a firm believer in customizing your environment. Does that suck for pair programming? Yes. Can we deal with it?
Yes. I'm gonna make assumptions you're on a Mac. An out of the box Mac comes with some solid developer tools, and
Apple are good at [taking][sherlock] some of the communities good ideas and giving it to everyone.

But there's definitely space for independent apps. Here's the genre of things you should be running and have deeply
committed to memory, the bold one are what I use.

- Window management: [**Moom**](https://manytricks.com/moom/), [Magnet](http://magnet.crowdcafe.com),
  [Spectacles](https://www.spectacleapp.com), [Divvy](http://mizage.com/divvy/)
- Effective Keyboard Shortcuts: [**Shortcat**](https://shortcatapp.com), [Keytty](https://keytty.com),
  [Vimium](https://vimium.github.io)/[**Vimari**](https://github.com/guyht/vimari)
- Clipboard Manager: [**Alfred**](https://www.alfredapp.com), [Pastebot](https://tapbots.com/pastebot/),
  [Keyboard Meastro](http://www.keyboardmaestro.com/main/)
- Recently changed files: [**Fresh**](http://www.ironicsoftware.com/fresh/),
  [**Alfred**](http://www.ironicsoftware.com/fresh/)
- Text Snippets: [*Al*fred\*\*](https://www.alfredapp.com), macOS System Settings
- Terminal: [**iTerm 2**](https://iterm2.com), [Hyper](https://hyper.is)
- Learning Keyboard Shortcuts: [**CheatSheet**](https://www.mediaatelier.com/CheatSheet/)
- Shell: [Oh my ZSH](https://github.com/robbyrussell/oh-my-zsh), **[Fish](http://fishshell.com) +
  [Fisherman](https://fisherman.github.io)**
- _Simple_ note-taking: [**nvalt**](http://brettterpstra.com/projects/nvalt/),
  [**Things**](https://culturedcode.com/things/), Notes.app, [Evernote](https://evernote.com)

Use native apps by default, they are better for your time. Native apps will usually conform to the [Human Interface
Guidelines][hig], which means logical shortcuts and great accessibility support. This is good because tools like
[Shortcat](https://shortcatapp.com) rely on that.

Electron-y apps made the most sense when there is a big
[user-land](https://unix.stackexchange.com/questions/137820/whats-the-difference-of-the-userland-vs-the-kernel)
customization scene. So, basically if there's a community around extending the app ([Hyper](https://hyper.is) is a
reasonable example, [Visual Studio Code](https://code.visualstudio.com) is the best example) then Elecron apps make
sense.

Some highlights for non-native apps are [Mailplane](https://mailplaneapp.com) and
[Visual Studio Code](https://code.visualstudio.com).

Every second you're at a computer you should be feeling like it's 1-2-3 hotkeys away from whatever you want to do.
For example:

- Your terminal should be a [single keypress away](https://www.youtube.com/watch?v=ETskRNFeuGM)
- [Learn the keys for OS X](https://github.com/orta/keyboard_shortcuts#using-a-mac) so you can jump/delete words
- [Resize/move windows with modal commands](https://www.youtube.com/watch?v=4CRbJwOctMo)
- [Making a new Jira ticket with a hotkey](https://www.neat.io/bee/)
- [Open any recent file per-app](/images/context-switching/sketch.mov)

App wise there's always more all of us can do, but constant improvement is key to getting there.

I think it's worth stressing here that I believe in paying for my tools. I want to support independent devs, and my
time is worth orders of magnitude more than the cost of entry for this software. There may be similar versions of
what I noted above for free, they could be open source too - but I'd rather have more people working on our tools
full-time than people doing it in their spare-time.

## Regular Re-tooling

Take the time every few years to re-think your previous decisions, I try to start from scratch every 2-3 years, I'm
writing this on a MacBook that's a week old and I've still not installed something form all of the above categories.
Re-evaluate your software priorities as your personal/professional responsibilities change.

## Tool Up

[ENDING TBD]

[active]: https://gist.github.com/paulmillr/2657075
[flow]: https://en.wikipedia.org/wiki/Flow_(psychology)
[ossd]: http://artsy.github.io/series/open-source-by-default/
[hiring]: https://www.artsy.net/jobs#engineering
[exp]: https://github.com/orta/cocoapods-fix-react-native#contributing-back
[vision]: https://github.com/danger/danger-js/blob/master/VISION.md#danger-for-js
[rdd]: https://tom.preston-werner.com/2010/08/23/readme-driven-development.html
[chris]: http://artsy.github.io/author/chris/
[consign]: https://github.com/artsy/emission/tree/master/src/lib/Components/Consignments
[prettier]: https://prettier.io
[danger]: https://danger.systems
[husky]: https://github.com/typicode/husky
[lint-staged]: https://github.com/okonet/lint-staged
[danger-local]: http://danger.systems/js/tutorials/fast-feedback.html
[oma]: https://www.youtube.com/watch?v=1Z3loALSVQM
[sherlock]: http://artsy.github.io/blog/2017/02/05/Retrospective-Swift-at-Artsy/#Developer.Experience
[hig]: https://developer.apple.com/design/human-interface-guidelines/macos/overview/themes/
