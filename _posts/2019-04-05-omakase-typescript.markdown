---
layout: epic
title: "What is TypeScript?"
date: "2019-05-05"
author: [orta]
categories: [community, javascript, roads and bridges, typescript]
---

TypeScript is a language which builds on JavaScript. This post is a non-technical overview of what JavaScript is,
how TypeScript extends it and why we choose to adopt it at Artsy.

<!-- more -->

## What is JavaScript?

First up, you can't describe TypeScript without talking about JavaScript. To create a website (and a bunch of other
types of things) you work in three languages: HTML, CSS and JavaScript (JS). The first two languages about
presenting the look and feel of the website, and JavaScript allows you to edit what it shows and make it
interactive.

We describe having these sets of skills as being a "front-end" developer. You have to understand those three
languages to present anything inside a web browser like Safari, Firefox or Chrome. So, given how popular the web
is, there is a massive demand for people who are good at using these three languages.

There is also the set of skills for the "back-end" developers, which are to create computer servers which
communicate either to a web browser (by passing it HTML/CSS/JS) or to another computer server (by sending a kind of
JavaScript.) You don't need to use HTML, CSS or JS to write this type of code, but it's usually an end-product of
your work. We mostly build our back-ends in Ruby or JavaScript at Artsy.

### What do Programming Languages do?

Programming languages are an interesting problem to solve. People read code many, many multiples of times more than
they write it - so developers create languages which are good at solving particular problems in a terse amount of
code. Here's an example using JavaScript:

```js
var name = "Danger"
console.log("Hello, " + danger)
```

The first line makes a variable (something you can store something in) and then the seconds outputs text out to the
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

> Note: if you find the naming of Java and JavaScript confusing (it is) - that's because when JavaScript as being
> created, Java was looking to be really the next hot language to work with (it did turn out that way for a few
> decades, but now JavaScript is usually the first language people have heard of.)

Aside from having a lot more lines, the Java version comes with a lot of words that aren't necessarily about
telling the computer exactly what to do, e.g. `class Main {`, `public static void main(String[] args) {`, `}` and
`}` again. It also has semi-colons at the end of some line. Java is aimed at building different things, and these
extras to the code sense within the constraints of building a Java app.

To get to my main point though, there is one standout line I'd like us to compare:

```
// JavaScript
var name = "Danger"
// Java
String name = "Danger";
```

Both of these lines set a variable to a be "Danger" as a string (a collection of characters, which in programming
we call a string (this [5m video](https://www.youtube.com/watch?v=czTWbdwbt7E) is a good primer)) - in JS you write
`var` which tells the next word after that is the name of the variable. However in Java, the first thing you write
is `String` instead.

There are many values which can go into a variable, and `var` accepts all of them in JS. In Java though, we have to
say upfront what can be inside that variable, which is only strings, so:

```js
// Before in JS
var name = "Danger"
// Also OK
var name = 1
var name = false
var name = { first: "Danger", last: "McMaslen" }

// Before in Java
String name = "Danger";
// Not OK, the code wouldn't be accepted by Java
String name = 1;

// This example isn't quite what you'd write, but it shows the difference well
Map<String, String> person = new HashMap<String, String>();
person.put("first", "Danger");
person.put("last", "McMaslen");
String name = person;
```

These trade-offs make sense in the context for which these languages were built. JavaScript was **originally**
designed in a a short time, to specifically do a small amount of things. Java on the other hand was built
specifically to make very, very large amounts of easy to read with - which means sometimes you have to do more
writing/reading chores. It's an implicit vs explicit thing.

### What is TypeScript?

TypeScript is a programming language - it contains all of JavaScript, and then a bit more. So in our case above,
lets compare the scripts for "Hello, Danger" in JavaScript vs TypeScript:

```js
// JavaScript
var name = "Danger"
console.log("Hello, " + danger)

// TypeScript
var name = "Danger"
console.log("Hello, " + danger)

// Yep, you're not missing something, there's no difference
```

Due to TypeScript aiming to only _extend_ JavaScript, your normal JavaScript code should work fine with TypeScript.
The parts of the JavaScript language which TypeScript extends are specifically about trying to make it easier to be
more explicit in your code.

```diff
- var name = "Danger"
+ var name: string = "Danger"
console.log("Hello, " + danger)
```

This allows the reader to be certain that `name` will only be a string. Annotating your variables also allows
TypeScript to check this for you.

Simply speaking, we call these annotation "Types" and this is the "Type" in TypeScript. The tag-line for TypeScript
is "JavaScript which scales" which is a statement that these extra type annotations allows you to work on bigger
projects. This is because you can verify how correct your code is, and as many people read and write it then you
don't need to fit it all in your head.

TypeScript extends JavaScript more, but this is the core concept - and that's enough for now.

### Why does Artsy use TypeScript?

Artsy definitely isn't the size of Microsoft! Artsy is about 30 engineers, and Microsoft are about 60,000. However,
some of our problems are the same. The "front end" developers at Artsy build apps which are thousands of files big.
Any single change to one file, could affect any other file. A good way to think about this is how in a story,
changing a conversation earlier can trigger a butterfly effect of changes later down the line.

Typically, the need to ensure all your changes do what you want is less of a problem for people building websites.
Websites are easy to make changes to, because if you change the site - everyone gets the update instantly. However,
we also build our iOS app with JavaScript, and a change to the app requires Apple to review the changes and for
someone to download the new version from the App Store.

This means that the iOS team needs to have more checks that everything is OK before shipping the app to the world.
Using TypeScript gives our team the ability to feel good that the changes we have made are only the changes we
want.

TypeScript isn't the only programming language to tackle the problem of making JavaScript code safer, but it's the
one with the biggest community, allows people to re-use their JavaScript knowledge and has a really good
programmers text editor.

These qualities made it worth adding an extra tool to our developer's toolbelt, and we're not the only ones because
TypeScript is growing to be [one of the most popular programming languages in the world][wired].

[intro_peril]: /blog/2017/09/04/Introducing-Peril/
[peril_readme]: https://github.com/artsy/README/blob/master/culture/peril.md
[settings-contrib]: https://github.com/artsy/peril-settings/graphs/contributors
[peril]: https://github.com/danger/peril
[wired]: https://www.wired.com/story/typescript-microsoft-javascript-alternative-most-popular
