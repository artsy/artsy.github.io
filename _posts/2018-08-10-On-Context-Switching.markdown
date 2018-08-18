---
layout: epic
title: "Context Switching"
date: 2018-08-10
author: [orta]
categories: [tooling, danger, shortcuts, concepts]
comment_id: 474
css: context
---

Programming generally requires getting into a good [flow state][flow] and working on a tricky problem for some time.
In the last 2 years, most of my work at Artsy (and in the OSS world) has been less about longer-term building of
hard things, but working on many smaller tasks across a lot of different areas.

Somehow, during this period I managed to end up in the top of "most active" [GitHub members][active], I feel like a
lot of this is due to doing [Open Source by Default][ossd] at Artsy and second to being good at context switching. I
want to try and talk though some of my techniques for handling context switching, as well as a bit of philosophy
around adopting and owning your tools.

<!-- more -->

## Shallow and Wide Work

I want to encourage as many people as possible to work on fun, deep-flow projects at Artsy. One of the most
successful ways of achieving this, that I've found, is to spend most of my time working on shallower tasks. An
example from my last few weeks is hiring. The communication aspects require dozens of emails and internal updates
that can't be scheduled into safe blocks. _([Totally related BTW, we're hiring][hiring].)_

For programming work I have a few techniques for trying to accomplish a lot of shallow tasks across many repos.

Start off by making yourself accountable to someone. For my OSS, this tends to either be [setting expectations][exp]
in README or using [a VISION][vision] file. For Artsy work we have product managers and engineers who own the
projects I'm contributing to. For this blog post, it's my [buddy Chris][chris].

I would then strive to get _anything_ out, this could be a work-in-progress PR or via declaratively via
[README-driven-development][rdd]. Part of this is because you might end up being dragged off into something else,
and another is that you're less likely to grok the domain better than your reviewers. Whilst not every change is an
improvement, every improvement adds up - even in small increments.

One way to instantly get rich domain knowledge is by pairing with someone who is more involved. This is a perfect
way to understand how decisions were made and provides great insight into how someone works on a project. While
pairing, you might also find additional ways to improve the daily workflow for someone else too!

Trying to have a shallow and wide understanding of many systems means accepting that you can't know the finer
details about how everything works. You want to know when really big interesting things are happening, but most work
should be iterative and less relevant to external folk like you.

With this in mind you can change your perspective to aim for having overviews on many things, but not get bogged
down in the useful discussion.

Techniques for this are:

- Making a custom stream of updates and not being too concerned about reading every single one of them. For Artsy,
  with many contributors and contexts - I create slack channels like: `#front-end-ios-notifs`,
  `#front-end-web-notifs`, `#orta-misc-notifs` and business specific ones like `#consignments-notifs` that contain
  PR or Issue information creation from GitHub but nothing with more details. I do the same but smaller for Danger
  and CocoaPods.

- I set [Slack keywords][keywords] to key GitHub repo names, or internal facing app names that I care about. This
  means I don't have to monitor every channel.

* I don't read my email. All 13,489 of them right now. I read the subjects and decide if it's worth reading. Every
  few months I declare inbox zero so others are less distracted by the number.

The tricky thing with this sort of work is trying not to be a blocker for someone else. A lot of this is about being
cautious about what you strive to help with, and about finding ways to boost others asynchronously. Am I good at
this? Sometimes. It's easier in OSS thanks to the the limited liability clauses, but in work-work that can be hard.

When my contributions are larger and I know the domain well, for example in a front-end JavaScript project, I am
willing to take longer than I'd like to ensure that it is reference level quality. A recent example came up in a
retrospective last month when an engineering team at Artsy said that one of [my projects][consign] was a key
reference for testing and React Native form handling for them. Pulling off this can definitely take longer than
expected, but if you're not going to be the one maintaining it then holding yourself to a higher standard is worth
it.

## Deep Automation

Remove as much ambiguity as possible for discussion. Project tools like [prettier][] really help focus code review
away from the petty formatting issues. Linters like [tslint][], [eslint][] and [rubocop][] remove another series of
discussion points. When you find yourself surprised by a cultural rule for a codebase, add [a danger][danger] rule
so you and others have it codified. Use tools like [husky][] and [lint-staged][] to get that feedback when you're
still in a development context. Danger can even run as a [git-hook/husky task][danger-local] too, so that feedback
can be _blazing_ too.

You can automate via tools, sure, but you can also encourage independent work via documentation.(TO DO: saves your
time, but isn't "automation") If something is confusing enough that, as an outsider, you don't get it without
asking, you should start adding documentation. I can't tell you what that looks like because it's different
per-project, but at least try to make it so the next person doesn't need to ask.

I strive to use my time on a project to encourage more consolidation, in the case of front-end that's moving closer
to [the Artsy omakase][oma]. In the case of servers that could be encouraging new APIs to use GraphQL, or to adopt
some of our newer ideas about schema management.

## Impact per Keystroke

I'm a firm believer in customising your environment. Does that suck for pair programming? Yes. Can we deal with it?
Yes. I'm gong to assume you're on a Mac. An out of the box Mac comes with some solid developer tools, and Apple are
good at [taking][sherlock] some of the communities good ideas and giving it to everyone.

However, there's definitely space for independent apps. Here's a list of apps broken into genres. You should be
running at least one from each genre, and have it's features deeply committed to memory. The ones in bold are what I
use.

- Window Management: [**Moom**](https://manytricks.com/moom/), [Magnet](http://magnet.crowdcafe.com),
  [Spectacles](https://www.spectacleapp.com), [Divvy](http://mizage.com/divvy/)
- Effective Keyboard Shortcuts: [**Shortcat**](https://shortcatapp.com), [Keytty](https://keytty.com),
  [Vimium](https://vimium.github.io)/[**Vimari**](https://github.com/guyht/vimari)
- Clipboard Manager: [**Alfred**](https://www.alfredapp.com), [Pastebot](https://tapbots.com/pastebot/),
  [Keyboard Meastro](http://www.keyboardmaestro.com/main/)
- Recently changed files: [**Fresh**](http://www.ironicsoftware.com/fresh/),
  [**Alfred**](http://www.ironicsoftware.com/fresh/)
- Text Snippets: [**Alfred**](https://www.alfredapp.com), [TextExpander](https://textexpander.com/), macOS System
  Settings
- Terminal: [**iTerm 2**](https://iterm2.com), [Hyper](https://hyper.is)
- Learning Keyboard Shortcuts: [**CheatSheet**](https://www.mediaatelier.com/CheatSheet/)
- Shell: [Oh my ZSH](https://github.com/robbyrussell/oh-my-zsh), **[Fish](http://fishshell.com) +
  [Fisherman](https://fisherman.github.io)**
- _Simple_ Note Taking: [**nvalt**](http://brettterpstra.com/projects/nvalt/),
  [**Things**](https://culturedcode.com/things/), Notes.app, [Evernote](https://evernote.com)

Use native apps by default, they are better for your time. Native apps will usually conform to the [Human Interface
Guidelines][hig], which means logical shortcuts and great accessibility support. This is good because tools like
[Shortcat](https://shortcatapp.com) rely on that.

Electron-y apps made the most sense when there is a big
[user-land](https://unix.stackexchange.com/questions/137820/whats-the-difference-of-the-userland-vs-the-kernel)
customization scene. So, basically if there's a community around extending the app ([Hyper](https://hyper.is) is a
reasonable example, [Visual Studio Code](https://code.visualstudio.com) and [Atom](https://atom.io) are the best
example) then Electron apps make sense.

Some highlights for non-native apps are [Mailplane](https://mailplaneapp.com) and
[Visual Studio Code](https://code.visualstudio.com).

Every second you're at a computer you should be feeling like it's 1-2-3 hotkeys away from whatever you want to do
next. For example:

- Your terminal should be a [single keypress away](https://www.youtube.com/watch?v=ETskRNFeuGM)
- [Learn the keys for OS X](https://github.com/orta/keyboard_shortcuts#using-a-mac) so you can jump/delete words
- [Resize/move windows with modal commands](https://www.youtube.com/watch?v=4CRbJwOctMo)
- [Making a new Jira ticket with a hotkey](https://www.neat.io/bee/)
- [Open any recent file per-app](/images/context-switching/sketch.mov)
- [Use a shortcut for every Mac app you use regularly](https://krausefx.com/blog/use-custom-shortcuts-for-every-application)

App-wise there's always more all of us can do, but constant improvement is key to getting there.

I think it's worth stressing here that I believe in paying for my tools. I want to support independent devs, and my
time is worth orders of magnitude more than the cost of entry for this software. There may be similar versions of
what I noted above for free, they could be open source too - but I'd rather have more people working on our tools
full-time than people doing it in their spare-time.

## Terminal Context Switching

macOS's UNIX underpinnings mean that a lot of common GUI activities have a CLI counter-part. To handle regular
context switching in the terminal you'll need to customise the shell to give you information as you arrive in a new
context. Things that I find useful in a shell are:

- What folder am I in?
- Is it a git repo?
- What branch am I on, or are there existing changes?
- Did the last command fail?
- Sometimes, what version of node/ruby is setup for this project?

I think it's also really useful to be able to jump between many development folders, you can use
[**z**](https://github.com/rupa/z), [j](https://github.com/wting/autojump) or
[goto](https://github.com/iridakos/goto) for this. Or set up some custom
[aliases](https://shapeshed.com/unix-alias/) for the most common folders.

As you'll be spending a good chunk of time, it's worth feeling comfortable that you know a few of the flags for
`cd`, `ls`, `mkdir`, `rm`, `cat`, `touch` and `grep`. Ideally, you have tab completion set up, and
[natural keybindings](https://stackoverflow.com/questions/6205157/iterm-2-how-to-set-keyboard-shortcuts-to-jump-to-beginning-end-of-line#10485061)
set up in your terminal input.

## Regular Re-tooling

Take the time every few years to re-think your previous decisions, I try to start from scratch every 2-3 years, I'm
writing this on a MacBook that's a week old and I've still not installed something from all of the above categories.
It's a good time to re-evaluate your software priorities as your personal/professional aims/responsibilities change.

A pattern I aim to strive for with tools is:

- Start with overkill to learn what you need.
- Migrate to smaller and simpler once you know what you want.

## Small and Often

It's not a very traditional way to work as a programmer, but it fits my personality type and can really rack up the
commits and contributions across the board. Being able to quickly jump contexts makes a lot more sense in the node
ecosystem - where the boundaries between projects can be as small as per-function.

Working this way can make it really hard to monitor what you've done on a regular basis, a technique I've used to
stay on top of is [git-standup][gs] and a dev folder structure that corresponds to [areas of work][tweet]. For
example, here's what a week roughly looks like on a slow week for Danger/Peril for me:

```sh
~/dev/projects/danger
❯ git standup -m 7 -d 7
/Users/orta/dev/projects/danger/hazmat/peril
c1d6893 - Update danger (2 days ago) <Orta Therox>
/Users/orta/dev/projects/danger/danger-js
a90d74c - Version bump, and peril fix (2 days ago) <Orta Therox>
f4836a1 - Version bump (2 days ago) <Orta Therox>
fbbcc1c - Adds a create/update label function to the github utils func (2 days ago) <Orta Therox>
702e51d - More dep updates (4 days ago) <Orta Therox>
```

Working this way requires trust from others that you're doing things that are valuable, which can be tricky when
your responses to "what did you get up to yesterday" end up being a bit ephemeral. Tools like `git-standup` help on
the code front, and [RescueTime][rt] can help you understand how much time you've spent in greenhouse.

It's your time, you should use it fastly.

Do you have any useful ideas for speeding up context switching? I'm open to improvements.

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
[gs]: https://github.com/kamranahmedse/git-standup
[tweet]: https://twitter.com/orta/status/1028764128310185984
[rt]: https://www.rescuetime.com
[keywords]: https://get.slack.help/hc/en-us/articles/201398467-Set-up-keyword-notifications
[tslint]: https://github.com/palantir/tslint
[eslint]: https://eslint.org
[rubocop]: https://www.github.com/bbatsov/rubocop
