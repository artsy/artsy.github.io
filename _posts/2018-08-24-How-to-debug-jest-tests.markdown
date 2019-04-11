---
layout: epic
title: "How To Debug Jest Tests"
date: 2018-08-24
author: anson
categories: [Node.js, Jest, testing, tooling]
series: Omakase
---

Hey there! My name is Anson and I work on the Platform team at Artsy. Recently, we faced an issue where a certain
[Enzyme](https://github.com/airbnb/enzyme) test we wrote using mock tracking was failing, but we couldn't figure
out why. Luckily, with some help from [Orta](/author/orta) and some clever thinking, we figured out what was going
on.

<!-- more -->

We thought it was an issue with the mock testing library we had written. We tried to fix the problem by sprinkling
`console.log` calls throughout the test, but it was still hard to figure out what was going on, especially without
knowing how to peek into the properties of certain objects.

Instead, [Orta](/author/orta) suggested we used the Chrome Node DevTools. Since the Enzyme test is run via
`yarn jest`, yarn is acting as a frontend for running the Enzyme test with Node. This means that we can use the
Chrome Node DevTools as a debugger to run the Enzyme test. This was super useful since the one thing we needed was
to be able to peek inside certain objects to see what they looked like and how they were failing. It was a much
faster, more methodical way to approach debugging this test. Here are the steps we took:

- First, insert a new line in your test where you think it might be failing and type `debugger`. This will serve as
  a break point for the debugger to stop at.
- Open up Chrome and type in the address bar : `chrome://inspect`
- Click on "Open dedicated DevTools for Node"
- In your terminal, instead of typing `yarn jest <path_to_test>`, type this:

```bash
node --inspect node_modules/.bin/jest --runInBand <path_to_test>
```

Or you can add it to your `package.json` as a script:

```diff
  {
    "scripts" : {
+    "test:debug": "node --inspect node_modules/.bin/jest --runInBand",
    }
  }
```

Which you can then run as `yarn test:debug <path_to_test>`.

Voila! Your test should now be running in the Chrome debugger. And you get your handy console to poke around all
sorts of stuff!

You also have the option of using this with Jest's `--watch` mode in order easily re-run tests, after changes to
app or test code.

```bash
node --inspect node_modules/.bin/jest --watch --runInBand <path_to_test>
```

Now simply hit Enter in the terminal running your Jest process anytime you want to re-run your currently selected
specs. You'll be dropped right back into the Chrome debugger.

You might be wondering how this fixed our tests. Well, turns out that we missed a `jest.unmock()` call at the top
of the test file. _Facepalm._ To prevent this from biting other developers in the future, [Orta](/author/orta)
whipped up a [pull request](https://github.com/artsy/reaction/pull/1174) to add a rule in our TypeScript linter,
check it out!

Either way, in the future, this will probably be my first step in debugging non-obvious issues in tests, if only to
eliminate possible sources of the issues. I'm glad I was able to learn with [Orta](/author/orta) about a methodical
way to debug test failures. Hope this helps, and happy hacking!
