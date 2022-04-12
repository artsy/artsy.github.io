---
layout: epic
title: "What JavaScript Tests Could Learn From RSpec"
date: 2021-09-10
categories: [testing, rspec, jest]
author: steve-hicks
canonical: https://www.stevenhicks.me/blog/2021/09/what-javascript-tests-could-learn-from-rspec/
comment_id: 701
---

When I started at Artsy a few years ago, I'd never written a line of Ruby. I feel at home with JavaScript — it's
been my buddy since I started my career over 20 years ago. I've written enough tests in JavaScript that I sometimes
feel like I can write them in my sleep (as long as they don't involve async React events 😅).

Most of the code I write at Artsy is still JavaScript, but now I write some Ruby code too, and I've written enough
RSpec tests that I'm starting to form opinions about what I think they should look like.

My most recent work has been JavaScript again. I've been writing Jest tests against one of our React apps. But
rather than reaching for the testing patterns I'd become accustomed to over my years of JavaScripting, I'm finding
that something's missing in my Jest tests! My experiences with RSpec have me longing for two features in Jest:

<!-- more -->

1. `context` blocks
2. `let` blocks

## 1. `context` blocks

A [`context` block](https://relishapp.com/rspec/rspec-core/v/2-11/docs/example-groups/basic-structure-describe-it)
in an RSpec test is, as I understand it, literally the same thing as a `describe` block. Like it's just an alias of
`describe`. What's the point, you ask?

The difference is in, well, context. Well-organized RSpec tests use `describe` to describe what's being
tested...and `context` to describe scenarios of the thing being tested.

For example, if I wanted to test the `multiply` method of a `Calculator` class, I might write some test scenarios
that look like this:

```rb
describe "Calculator" do
  describe ".multiply" do
    context "when the first value is negative" do
      context "when the second value is negative" do
        it "returns a positive number" do
        end
      end
      context "when the second value is positive" do
        it "returns a negative number" do
        end
      end
    end
  end
end
```

See the difference in those test cases between `describe` and `context`? The way I think about it is: if the
statement coming after my `describe`/`context` describes a pre-condition for the test, it's a `context`; otherwise
it's a `describe`.

`context` wouldn't be hard to implement in JavaScript — I'd bet there are test frameworks that have it. It'd just
be an alias of `describe`.

## 2. `let` blocks

[`let` blocks](https://relishapp.com/rspec/rspec-core/v/2-11/docs/helper-methods/let-and-let) are used in an RSpec
test to set things up for your test scenario.

Here's a test for a `Counter` class, verifying that when I call the `increment` method on an instance, its stored
value becomes `1`.

```rb
describe "counter" do

  let(:counter) { Counter.new }

  describe "increment" do
    it "increments by 1" do
      counter.increment

      counter.value.should eq(1)
    end
  end
end
```

If you're new to Ruby, the only line that doesn't translate almost directly to a similar JavaScript expression is
the `let` statement.

The `let` statement in RSpec [creates a method with a specified name, which lazily evaluates to the result of a
block][rspec-let]. In this case, we get a method named `counter`, which is evaluated to a new instance of the
`Counter` class. There are a few important things to note about `let` blocks:

1. They're evaluated lazily (by default). That `counter` doesn't actually get created until I reference it.
2. They're memoized. Wherever I reference `counter` within that `describe "counter"` block, I'm getting the same
   instance. It's initialized to whatever I return inside the `let` block.
3. I can override a `let` block deeper inside the tree of tests, by declaring another `let(:counter)` later. When I
   do this, the closest `let` block in the tree for that thing is the one that gets used.

I don't think it's possible to implement `let` in JavaScript — at least not in the way it exists in RSpec. It
relies on
[Ruby meta-programming to intercept calls to missing methods](https://www.leighhalliday.com/ruby-metaprogramming-method-missing),
which just doesn't exist in JavaScript. The [givens](https://github.com/enova/givens) library does something pretty
close, but it relies on string keys to define things, and there's a bit of extra work when working with TypeScript.

## What's the big deal?

On the surface these two features don't seem like much, but they provide a really powerful framework for organizing
test cases and the associated test setup.

With the `let` blocks being lazily evaluated, and override-able, I can set up data at the exact level of tests that
I need it. When I need to override it for a certain set of tests, I can put another `let` block in that set. In
JavaScript I can define functions to set up my data for me with just the changes I need at each test level, or I
can use `beforeEach` blocks, but all that can get pretty noisy.

And with `context` blocks, I can more clearly lay out the scenarios of my tests. Yes, I _could_ just do this with
more `describe` blocks in JavaScript, but how often have you found JavaScript tests that actually do this? I've
personally seen/written too many tests to count named something like
`it("returns false when the flag is enabled, they're located in the US, but they have brown hair.")`. That's three
scenarios rolled into one test name. It works, but being able to nest different `context` blocks to define my
complex scenarios is much easier to read.

## Examples

Here's an example of some tests I could write in RSpec with `let` and `context`:

```rb
describe "Calculator" do
  let(:calculator) { Calculator.new }

  describe ".multiply" do
    let(:result) { calculator.multiply(first, second) }

    context "when the first value is negative" do
      let(:first) { -1 }

      context "when the second value is negative" do
        let(:second) { -3 }

        it "returns a positive number" do
          result.should eq(3)
        end
      end

      context "when the second value is positive" do
        let(:second) { 3 }

        it "returns a negative number" do
          result.should eq(-3)
        end
      end
    end
  end
end
```

HOW COOL IS THAT! Every `describe`/`context` block has _exactly_ the setup data it needs defined clearly inside it.
And each block has very little noise to distract you.

Here's what I'd do in JavaScript/Jest to accomplish something similar:

```js
describe("Calculator", () => {
  let calculator
  beforeEach(() => { calculator = new Calculator() })

  describe(".multiply", () => {
    let first, second
    function getResult() {
      return calculator.multiply(first, second)
    }

    describe("when the first value is negative", () => {
      beforeEach(() => { first = -1 })

      describe("when the second value is negative", () => {
        beforeEach(() => { second = -3 })

        it("returns a positive number", () => {
          expect(getResult()).toEqual(3)
        })
      })

      describe("when the second value is positive", () => {
        beforeEach(() => { second = 3 })

        it("returns a negative number", () => {
          expect(getResult()).toEqual(-3)
        })
      })
    })
  })
})
```

There's definitely a bit more noise here, especially with the `beforeEach` and `let` statements. It's not a _lot_
more noise, but it is definitely more noise.

In real life I wouldn't expect to find tests like the above JavaScript example. I'd expect to find the tests in
JavaScript looking more like this:

```javascript
describe("Calculator", () => {
  let calculator
  beforeEach(() => { calculator = new Calculator() })

  describe(".multiply", () => {
    it("returns a positive number when the first number is negative and the second number is negative", () => {
      const result = calculator.multiply(-1, -3)

      expect(result).toEqual(3)
    })

    it("returns a negative number when the first number is negative and the second number is positive", () => {
      const result = calculator.multiply(-1, 3)

      expect(result).toEqual(-3)
    })
  })
})
```

You could certainly make the case for this contrived example that _this_ is actually the most readable set of
tests, because there's less code. I would have a hard time arguing. But most real-life tests are more complex than
these examples, with state and side-effects to mock out, and more scenarios and edge cases worth testing. Each test
case here includes multiple conditions, but there are only two permutations represented. Once things get a little
more complicated than these contrived examples, the RSpec tests become the clear winner for me — they're easier to
read and manage, with their `let` and `context` blocks more discretely describing your test scenarios.

You could also argue that the bigger win here would be breaking scenarios into individual `describe` blocks in
JavaScript tests, instead of cramming the entire scenario into one long `it("...")` statement. I wouldn't argue
that either.

## Caveats

The day after I wrote this article, a conversation started in the Artsy slack about how confusing `let` was because
it moved variable initializations far away from where the tests used them.

This makes sense! I think it points to two truths in software development:

### Code readability is subjective

For years I was convinced that practices like small functions or long and descriptive function names were
_objectively_ more readable. I leaned into this, and my code reviews almost always included comments on what I
thought would make the code more readable.

As more people pushed back on my feedback over time, I realized that the feedback I was giving was _subjective_. I
still like code that uses many short functions wired together, but not everyone finds that more readable! I've
stopped giving readability feedback on PRs, unless I can provide nearly-objective facts or scenarios that point to
a readability improvement.

In this article, I find the RSpec `let` examples to be much more readable than the JavaScript examples. But you and
your team might not! Maybe the distance between a `let` block's definition and its method's usage makes it hard for
you to follow the test. That's cool!

### Any cool thing can be abused

Earlier in this article I linked to [an article that describes `let` blocks in more detail][rspec-let]. It includes
[a warning from the actual `let` docs](https://www.rubydoc.info/github/rspec/rspec-core/RSpec%2FCore%2FMemoizedHelpers%2FClassMethods%3Alet):

> Note: `let` can enhance readability when used sparingly (1,2, or maybe 3 declarations) in any given example
> group, but that can quickly degrade with overuse. YMMV.

I've definitely seen code where I had a hard time following a stream of `let` blocks. The RSpec example I gave
above reads nicely to me — but it's probably teetering on the edge of where `let` usage becomes confusing. I'm
guessing I have a slightly higher tolerance for this particular abstraction than my friends who don't like
it...again pointing to readability being subjective.

Having said all that — lately every time I try to write JavaScript tests, I find myself trying (unsuccessfully) to
recreate that RSpec example above. It represents exactly how I want to think about complex test scenarios. Each
level of the tests has exactly the setup that is unique to that level. There's very little distraction or noise at
each `context` and `it`. It totally aligns with
[my desire to minimize irrelevant test setup](https://www.stevenhicks.me/blog/2018/01/chekhovs-gun-and-better-unit-tests/).
I'm in ❤️ ❤️ ❤️ ❤️ ❤️.

> _This post originally appeared on
> [Steve's blog](https://www.stevenhicks.me/blog/2021/09/what-javascript-tests-could-learn-from-rspec/)._

[rspec-let]: https://medium.com/@tomkadwill/all-about-rspec-let-a3b642e08d39
