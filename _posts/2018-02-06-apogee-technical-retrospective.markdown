---
layout: epic
title: "Apogee Technical Retrospective"
date: 2018-02-06
categories: [rails, ruby, typescript]
author: [ash]
series: Apogee
---

We've previously covered [what Apogee is][overview] and [how it's deployed][deploys], so all that's left to cover is the technology used to build it. As a refresher: Apogee is a Google Sheets Add-on we built to help our Auctions Ops team transform the data given to us by our partners into a format that our CMS can understand. This process, done manually up until now, takes a long time and is a perfect candidate for automation.

Apogee had some really interesting technical challenges that I enjoyed solving, and I'm excited to share some lessons I learned. So let's dive in!

<!-- more -->

We built a prototype as a "pure" Add-on, written only inside Google's sandbox, but that approach wouldn't work for us in production: the Add-on environment was just too difficult to work with. Google expects you to write Add-ons in their in-browser [Script Editor][scripts] and – while whether or not that editor is _good_ is a matter of preference – the environment isn't suited for collaborating or unit testing. Additionally, we could not get Add-on deploys automated, so we'd like to minimize how often we _have_ to deploy.

So we split things up. Instead of building all Apogee's logic into an Add-on, we decided to build two pieces: a very thin Add-on and a Rails server with all the real logic.

(Because Apogee necessarily includes information about how our partners format their data, we decided not to open source it. Data formats are _probably_ not sensitive, but that's a judgement best left up to our partners.)

## Apogee Add-on

The Add-on we built is very simple, by design. Our goal was to make an Add-on that was flexible enough such that we would need to deploy it less frequently than adding new parsers.

Add-on responsibilities include:

- fetching the available parsers from the server.
- setting up an Add-on user interface (a menu of partners, each with available parsers).
- responding to invocations from that interface. 

Based on the parser selected by the user, Apogee gathers the required data from the current spreadsheet, sends it to the server for processing, and appends the results to the sheet. Pretty straightforward, you'd think.

Unfortunately, Google Add-ons are a bit... strange. The Add-on itself is executed in Google's datacentres (not the user's browser) and is written in [JavaScript 1.6-ish][version]. Specifically, it runs with JavaScript 1.6, plus some features from 1.7, plus some other features from 1.8, and also ["Google Advanced Services"][gas]. The execution environment also lacks an event loop, which makes sense from Google's perspective (their servers need to know if a script execution has completed) but is still a bit unusual.

Rather than deal with a weird version of JavaScript, we decided to write the Add-on in [TypeScript][] and compile down to something Google can execute. We also found [open source typings][typings] for the Google APIs, which helped a lot. Google also provides access to certain whitelisted libraries, including [Lodash][], which is handy.

Add-ons also have a somewhat complex permissions and authentication model. The [documentation][] provided is a great illustration of why _complete_ documentation is not necessarily _effective_ documentation. If you already understand what you're doing, the docs are a good reference, but I found them difficult to learn from. I really like [this explanation][docs] of how to structure documentation like unit tests.

Permissions vary wildly depending on the execution context. For example, the `onOpen` callback is able to make network requests when the script is run as an attachment to a spreadsheet, but not when deployed. This makes it difficult to populate our menu UI, which is based off an API response. I learned to not have confidence everything was working until I saw it work end-to-end.

One other peculiarity of Google's API is how UI callbacks work. You could create a menu for your Add-on with the following code:

```js
SpreadsheetApp.getUi()
  .createAddonMenu()
  .addItem('Do something', 'doSomething')
  .addToUi()
  
function doSomething() {
}
```

You'll notice that the callback function is specified by a _string_ representing a function name (and not as a function itself, which would be more idiomatic). So, for every menu item, there must exist a corresponding function in the global scope with a corresponding name. Sadly, no parameters are passed to these callbacks, so it's impossible for a function to determine which menu item it was invoked by. Therefore, every menu item _must_ have exactly _one_ corresponding function. That presents a problem for an Add-on with a dynamic menu.

The Add-on isn't executed in a browser; we're running on Google's datacentres so let's just brute-force this. Our menu is a list of partner names, which is itself a submenu of parsers specific to that partner. That means that each menu item (and corresponding callback) can be indexed by two integers: a partner index and a operation index. So now we have a way to map from our user interface to a specific operation to perform inside _one_ common menu handler.

Let's take a look at the actual code.

```ts
interface Operation {
  name: string
  columns: string[]
  token: string
}

interface Partner {
  name: string
  operations: Operation[]
}

// Sets up the Add-on menu and submenus.
function setupAddon(ui: Partner[]) {
  // Reduce the ui to a list of submenus.
  const addOnMenu = ui.reduce((menu, partner, partnerIndex) => {
    // Reduce the operations list to a list of menu items.
    return menu.addSubMenu(partner.operations.reduce((memo, operation, operationIndex) => {
      return memo.addItem(operation.name, `partner${partnerIndex}Operation${operationIndex}`)
    }, SpreadsheetApp.getUi().createMenu(partner.name)))
  }, SpreadsheetApp.getUi().createAddonMenu())
  // Add the generated menu to the Add-on UI.
  addOnMenu.addToUi()
}
```

Each menu has a callback function named something like `partnerXOperationY`. Then we just generated a few thousand functions that match that format and call a shared handler _with_ `X` and `Y` as parameters. The generated code looks like this:

```js
function partner0Operation0() {
    sharedHandler(0, 0);
}
function partner0Operation1() {
    sharedHandler(0, 1);
}
function partner0Operation2() {
    sharedHandler(0, 2);
}

function sharedHandler(partnerIndex, operationIndex) {
    // TODO: Look up the appropriate parser to use.
}
```

It's not elegant, but it works. Actually, I think it does have a certain elegance, given the constraints it has to operate within.

So that's it! The rest of the challenges were just weird permissions issues or config problems, but the Add-on was pretty easy to build. The file generated by the TypeScript compiler is only 166 lines long, and the file with all our menu callbacks is "only" 8000 lines long. Next, let's talk about the server.

## Apogee Server

So, Rails' philosophy is "[convention over configuration][coc]", which is pretty great as long as you know the conventions. I'd never run `rails new` before. Also, that philosophy works best when you're building _conventional_ apps. Because Apogee is a bit unconventional, I was going to write Apogee in Sinatra before my colleague suggested I use Rails in [API-only mode][api] instead. It seemed a bit overkill, but I also didn't want to pass up the chance to finally learn Rails.

The server has two endpoints:

- `/ui` provides a list of partners and their respective parsers.
- `/columns` accepts spreadsheet columns and returns processed data (cell contents and a background colour to indicate our confidence in parsed results).

We needed a way for the server to specify all its operations in a way that they could be invoked through the second endpoint. We decided to use a token-based approach: each parser has a token that can be used to invoke the parser later on. This dovetails with how I structured the parsers, too.

Each partner is defined by a submodule within the `Apogee::Parser` module, and each parser is defined by a class within that partner module. Let's take a look at some code.

```rb
module Apogee
  module Parser
    module Skinner
      extend Apogee::BaseParser
      
      class DimensionsParser
        # Name to show in Add-on UI.
        def self.menu_name
          "Parse dimensions from Description column"
        end

        # Columns required by the `/columns` endpoint.
        def self.column_names
          %w[Description]
        end
        
        # Parse the columns, called from the `/columns` endpoint.
        def self.parse(columns)
          # TODO: parse the columns.
        end
      end
    end
  end
end
```

Each class within a partner is expected to have those three class methods.

So now that we have a defined structure for our parsers, we can use Ruby reflection to collect a list of partner modules:

```rb
Parser.constants
  .select { |c| Parser.const_get(c).is_a? Module }
  .map do |c|
    {
      name: c,
      operations: Parser.const_get(c).public_parsers
    }
end
```

Each module also has a `public_parsers` function (inherited from `Apogee::BaseParser`) which also uses reflection:

```rb
def public_parsers
  constants
    .select { |c| const_get(c).is_a? Class }
    .map { |c| const_get(c) }
    .map do |klass|
      {
        klass: klass.to_s,
        name: klass.menu_name,
        columns: klass.column_names,
        token: Digest::SHA256.base64digest(klass.to_s)
      }
    end
end
```

This code collects all the Ruby classes inside a module into a data structure that can be consumed by the Apogee Add-on through the `/ui` endpoint. As a bonus, the tokens are generated from the SHA256 hash of the fully-qualified parser class names. And we also avoid having to maintain a separate list of parsers that I would inevitably forget to update. Win-win.

All that's left to do is to lookup a parser class from a token. This is as easy as finding the class with the matching token and calling its `parse` function.

```rb
parser = partners
  .map { |p| p[:operations] }
  .flatten
  .find { |op| op[:token] == token }
Object.const_get(parser[:klass]).parse(columns)
```

Neat!

This approach is _good_, but strikes me as overly object-oriented. _Most_ of the parsers we're going to write are going to do the same thing: they have the same three methods and the `parse` method is basically just matching each spreadsheet cell against a regular expression. We can make a better abstraction.

Since the parsers are defined by the presence of a class within a partner module, we can use metaprogramming to abstract away all the common pieces and add classes to the module programmatically. The implementation is too in-depth to explain in detail here, but our partner module above could be rewritten to look like the following:


```rb
module Apogee
  module Parser
    module Skinner
      extend Apogee::BaseParser
      
      add_single_column_parser(
        class_name: 'DimensionsParser',
        menu_name: 'Parse dimensions from Description column',
        column_name: 'Description',
        regex: %r{REGEX GOES HERE},
        new_columns: %w[Height Width Depth Unit]
      ) do |match|
        # TODO: Process each cell.
      end
    end
  end
end
```

I created two such methods: one that uses a single regex, and another that uses multiple regexes (for more complex needs). I also wrote a handy `add_all_parser` method which adds a sort of meta-parser, which collates the results from calling `parse` on all the _other_ parsers in that module. Our Ops team just needs to click "Parse everything" and the entire spreadsheet is processed with all the parsers in seconds.

And of course, since all our parsers are just Ruby classes, they were easy to unit test.

I've done metaprogramming in other languages, and it was a lot of fun to use it in Ruby. I ran the code by my colleagues who are more experienced in Ruby than I am, and documented everything thoroughly. It's a real shame the codebase isn't open source, because I'm really proud of the approach and would love to share it with you.

## Apogee Authentication

We needed to make sure that only the Add-on itself was invoking the server's endpoints. Not because the server has sensitive data – Apogee's server has no database and doesn't access any APIs – but just because it's good practice to limit access to services to only who needs them.

We evaluated a bunch of prospective auth strategies, including (but not limited to) the following:

- Whitelist Google datacentre IP addresses, block all others.
- HTTP Basic Auth.
- Shared secret.
- OAuth with Artsy's API, by the user upon Add-on installation.
- Something totally custom, or a combination of any of these.

After thoughtful discussion, we decided on a solution that works for us. I'm not going to specify what we used – not because I'm that concerned about the security, but because each project and team will have their own needs. If you build a server, think carefully about what kind of authentication makes sense for you and your team.

## Conclusion

Apogee was a really fun project. It had a defined scope, so it was a good first Rails project for me to tackle. The Add-on helps my colleagues on the Auctions Ops team do their jobs easier, so it was intrinsically rewarding to build. And it turns out that our Gallery Partnerships team also has to import a lot of partner data into Artsy's CMS, so I'm now exploring ways Apogee can help them, too.

As a closing note, I want to discuss something that's been on my mind lately. I've been developing iOS apps [since 2009][ios post], and have a [very intimate knowledge][books] of Objective-C, Swift, and UIKit. For a long time, I actually avoided learning new languages and frameworks because they intimidated me – starting over in a new framework, from scratch, felt like a step backward.

I think this is a common frame of mind, among iOS developers, among all developers. But now I regret avoiding new technology for so long. The languages and tools that I knew had become part of my identity: I was an "iOS Developer." That identity was a source of strength, but was also a limitation.

Developers solve problems. Sometimes those problems are best solved with iOS apps. And sometimes, they're best solved with spreadsheet plugins. After [realizing][feels] last year that I was limiting myself, I'm still coming to terms with how that impacts my identity. But I'll say this: if _I_ can leave the safety blanket of the iOS world and build something completely new, so can you. Don't let your expertise and experience limit what you think you can build.

[overview]: /blog/2018/02/02/artsy-apogee/
[deploys]: /blog/2018/01/24/kubernetes-and-hokusai/
[scripts]: http://script.google.com
[version]: https://developers.google.com/apps-script/guides/services/#basic_javascript_features
[typings]: https://www.npmjs.com/package/@types/google-apps-script
[Lodash]: https://lodash.com
[documentation]: https://developers.google.com/apps-script/add-ons/lifecycle
[coc]: https://en.wikipedia.org/wiki/Convention_over_configuration
[api]: http://guides.rubyonrails.org/api_app.html
[ios post]: https://ashfurrow.com/blog/5-years-of-ios/
[feels]: https://ashfurrow.com/blog/swift-vs-react-native-feels/
[books]: https://ashfurrow.com/books/
[TypeScript]: https://www.typescriptlang.org
[docs]: https://twitter.com/kosamari/status/852319140060823553
[gas]: https://developers.google.com/apps-script/guides/services/advanced