---
layout: epic
title: "What is TypeScript?"
date: "2019-04-05"
author: [orta]
categories: [community, javascript, roads and bridges, typescript]
series: Omakase
---

TypeScript is a language from Microsoft which builds on JavaScript. This post is a non-technical overview of what
JavaScript is, how TypeScript extends JavaScript and why we choose to adopt TypeScript at Artsy.

<!-- more -->

## What is JavaScript?

First up, you can't describe TypeScript without talking about JavaScript. To create a website (and a bunch of other
types of things) you work in three languages: HTML, CSS and JavaScript (JS). Broadly speaking: HTML defines the
content that will appear on the page, CSS defines the visual style of the page, and JS defines the interactive
behaviours of the page.

We describe having these sets of skills as being a "front-end" developer. You have to understand those three
languages to present anything inside a web browser like Safari, Firefox or Chrome. So, given how popular the web
is, there is a massive demand for people who are good at using these three languages.

There is also the set of skills for the "back-end" developers, which are to create computer services that
communicate either to a web browser (by passing it HTML/CSS/JS) or to another service (by sending a raw data.) You
don't need to use HTML, CSS or JS to write this type of code, but it's usually an end-product of your work. We
mostly build our back-ends in Ruby or JavaScript at Artsy.

### What do Programming Languages do?

Programming languages are an interesting problem to solve. People read code many, many multiples of times more than
they write it - so developers create languages which are good at solving particular problems with a small amount of
code. Here's an example using JavaScript:

```js
var name = "Danger"
console.log("Hello, " + name)
```

The first line makes a variable (a kind of box you can keep things in) and then the second line outputs text to the
console (think DOS, or the terminal) `"Hello, Danger"`. JavaScript is designed to work as a scripting language,
which means the code starts at the top of the file and then goes through line by line. To provide some contrast,
here is the [same behavior](https://repl.it/repls/VioletredGlisteningInfo) in Java, which is built with different
language constraints:

```java
class Main {
  public static void main(String[] args) {
    String name = "Danger";
    System.out.println("Hello, " + name);
  }
}
```

> Note: if you find the naming of Java and JavaScript confusing, it is (they are two completely separate
> programming languages, no link at all.) JavaScript was [named that way][js-hist] because Java was looking to be
> really the next hot language (it did turn out that way for a decade or two, but now JavaScript is usually the
> first language people have heard of.)

Aside from having a lot more lines, the Java version comes with a lot of words that aren't necessarily about
telling the computer exactly what to do, e.g. `class Main {`, `public static void main(String[] args) {`, `}` and
`}` again. It also has semi-colons at the end of some lines. Java is aimed at building different things from
JavaScript, and these extra bits of code make sense within the constraints of building a Java app.

To get to my main point though, there is one standout line I'd like us to compare:

```
// JavaScript
var name = "Danger"
// Java
String name = "Danger";
```

Both of these lines declare variables called `name` which contain the value `"Danger"`.

In JavaScript you use the abbreviation `var` to declare a variable. Meanwhile, in Java you need to say _what kind
of data_ the variable contains. In this case the variable contains a `String`. (A string is a programming term for
a collection of characters. They `"look like this"`. This [5m video](https://www.youtube.com/watch?v=czTWbdwbt7E)
is a good primer if you want to learn more.)

Both of these variables contain a string, but the difference is that in Java the variable can _only_ ever contain a
_string_, because that's what we said when we created the variable. In JS the variable can change to be _anything_,
like a number, or a list of dates.

To illustrate:

```js
// Before in JS
var name = "Danger"
// Also OK
var name = 1
var name = false
var name = ["2018-02-03", "2019-01-12"]

// Before in Java
String name = "Danger";
// Not OK, the code wouldn't be accepted by Java
String name = 1;
String name = false
String name = new String[]{"2018-02-03", "2019-01-12"};
```

These trade-offs make sense in the context for which these languages were built back in 1995. JavaScript was
originally designed to be a small programming language which handled simple interactions on websites. Java on the
other hand was built specifically to make big apps which could run on any computer. Their needs had different
scales, so the language required programmers write different types of code.

Java required programmers to be more explicit with the values of their variables because the programs they expected
people to build were more complex. While JavaScript opted for ease of reading, and aimed to do less.

### What is TypeScript?

TypeScript is a programming language - it contains all of JavaScript, and then a bit more. Using our example above,
let's compare the scripts for "Hello, Danger" in JavaScript vs TypeScript:

```js
// JavaScript
var name = "Danger"
console.log("Hello, " + name)

// TypeScript
var name = "Danger"
console.log("Hello, " + name)

// Yep, you're not missing something, there's no difference
```

Due to TypeScript's aim to only _extend_ JavaScript, your normal JavaScript code should work fine with TypeScript.
The things TypeScript adds to JavaScript are intended to help you be more explicit about what kinds of data are
used in your code, a bit like Java.

```diff
- var name = "Danger"
+ var name: string = "Danger"
console.log("Hello, " + danger)
```

This extra `: string` allow the reader to be certain that `name` will only be a string. Annotating your variables
also gives TypeScript the chance to verify this for you. This is _very_ useful because keeping track of changes
like the type of value in a variable seems easy when it's one or two, but once it starts hitting the hundreds,
that's a lot to keep track of. Types help programmers be more confident about their code because types catch
mistakes.

Simply speaking, we call these annotations "Types". Hence the name <i>Type</i>Script. The tag-line for TypeScript
is "JavaScript which scales" which is a statement that these extra type annotations allows you to work on bigger
projects. This is because you can verify up-front how correct your code is. This means you have less need to
understand how every change affects the rest of the program.

In the 90s, and maybe until a 5-10 years ago the trade-off for not having types in your JavaScript application was
fine because the size and complexities of the programs being built were constrained to just the front-end of
websites. Today though, JavaScript is being used everywhere:

- Apps like Slack, or Spotify for your computer are built in mostly JavaScript
- Some iOS apps, including Artsy's are mostly JavaScript
- The back-end and front-end of Artsy.net are JavaScript

These are all considerably more complicated to build and understand, adding types drastically reduces the
complexity of making improvements to those programs.

### Why does Artsy use TypeScript?

Artsy definitely isn't the size of Microsoft! Artsy is about 30 engineers, and Microsoft are about 60,000. However,
some of our problems are the same. Developers at Artsy build apps which are made up of thousands of files. A change
to one individual file can affect the behaviour of any number of other files, like throwing a pebble into a pond
and causing ripples to spread out to the bank.

Typically, the need to ensure there are no bugs is less of a problem for people building websites. Websites are
easy to make changes to, because if you change the site - everyone gets the update instantly. We also build our iOS
app with JavaScript, but a change to our app requires Apple to review the changes and for users to download the new
version from the App Store.

This means that the iOS team needs to have more checks that everything is OK before shipping the app to the world.
Using TypeScript gives our team the ability to feel good that the changes we have made are only the changes we
want.

TypeScript isn't the only programming language to tackle the problem of making JavaScript code safer, but it's the
one with the biggest community, allows people to re-use their JavaScript knowledge, can be added in small steps,
and has really good tools to help developers work faster.

These qualities made it worth adding an extra tool to our developers' toolbelt, and we're not the only ones because
TypeScript is growing to be [one of the most popular programming languages in the world][wired] with almost 6
million downloads a week.

[intro_peril]: /blog/2017/09/04/Introducing-Peril/
[peril_readme]: https://github.com/artsy/README/blob/master/culture/peril.md
[settings-contrib]: https://github.com/artsy/peril-settings/graphs/contributors
[peril]: https://github.com/danger/peril
[wired]: https://www.wired.com/story/typescript-microsoft-javascript-alternative-most-popular
[js-hist]: https://medium.com/@benastontweet/lesson-1a-the-history-of-javascript-8c1ce3bffb17
