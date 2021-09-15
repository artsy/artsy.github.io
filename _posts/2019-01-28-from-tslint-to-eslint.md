---
layout: epic
title: "From TSLint to ESLint, or How I Learned to Lint GraphQL Code"
date: "2019-01-29"
author: [chris]
categories: [typescript, tslint, eslint, graphql]
series: Omakase
---

At the beginning of January we discovered an interesting note in [TypeScript's roadmap][roadmap] about linting:

> In a survey we ran in VS Code a few months back, the most frequent theme we heard from users was that the linting
> experience left much to be desired. Since part of our team is dedicated to editing experiences in JavaScript, our
> editor team set out to add support for both TSLint and ESLint. However, we noticed that there were a few
> architectural issues with the way TSLint rules operate that impacted performance. Fixing TSLint to operate more
> efficiently would require a different API which would break existing rules (unless an interop API was built like
> what wotan provides).

> Meanwhile, ESLint already has the more-performant architecture we're looking for from a linter. Additionally,
> different communities of users often have lint rules (e.g. rules for React Hooks or Vue) that are built for
> ESLint, but not TSLint.

> Given this, our editor team will be focusing on leveraging ESLint rather than duplicating work. For scenarios
> that ESLint currently doesn't cover (e.g. semantic linting or program-wide linting), we'll be working on sending
> contributions to bring ESLint's TypeScript support to parity with TSLint. As an initial testbed of how this works
> in practice, we'll be switching the TypeScript repository over to using ESLint, and sending any new rules
> upstream.

At Artsy we've been using TSLint for a few years now; it's worked well for us, and we've even written our own
[custom rules](https://github.com/relay-tools/tslint-plugin-relay). However, given the vastness of the JS ecosystem
and how fast it moves, it's easy to recognize this announcement as an exciting moment for tooling simplicity.

<!-- more -->

To give an example, anyone who has built a culture around Airbnb's
[JavaScript style guide](https://github.com/airbnb/javascript) will instantly recognize the conundrum they're in
when migrating to TypeScript:

<img width="100%" alt="a reddit user discovers their linting rules no longer work" src="https://user-images.githubusercontent.com/236943/51884369-d845b380-233b-11e9-9d2f-102cc8a3a78b.png">

This means that teams maintaining legacy JavaScript codebases will no longer have to _also_ maintain
[two][tslint-react] [versions][eslint-react] of often nearly [identical][tslint-prettier]
[rule-sets][eslint-prettier]. All of the aggregate culture that builds up around linting can now be shared in a
forward and backward facing way, making the often-daunting process of migrating a codebase from JavaScript to
TypeScript a much easier sell.

With this in mind we wanted to give the new officially-sanctioned [typescript-eslint][typescript-eslint] project a
spin and document our findings.

### Setup

To get started, install the necessary dependencies:

```sh
$ yarn install -D eslint typescript @typescript-eslint/eslint-plugin
```

Then create a new `.eslintrc.js` and add a bit of setup:

```js
module.exports = {
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  parserOptions: {
    ecmaVersion: 6,
    project: "./tsconfig.json",
    sourceType: "module"
  }
}
```

Note that `parserOptions.project` points to your `tsconfig.json` file:

```json
{
  "compilerOptions": {}
}
```

Next, add a bit of TypeScript to a file

```sh
$ echo "export const foo: any = 'bar'" > index.ts
```

and run the linter:

```sh
$ yarn eslint . --ext .ts,.tsx

~/index.ts
  1:12  warning  Unexpected any. Specify a different type  @typescript-eslint/no-explicit-any

✖ 1 problem (0 errors, 1 warnings)
```

Very nice!

Now lets expand the example a bit and add something more sophisticated, which in Artsy's use-case is commonly
GraphQL:

```sh
$ yarn add -D eslint-plugin-graphql graphql-tag apollo
```

Update `tsconfig.json` and let it know we'll be using `node` for imports:

```json
{
  "compilerOptions": {
    "moduleResolution": "node"
  }
}
```

In `.eslintrc.js` add these rules (while noting the addition of `graphql` to `plugins` and
`graphql/template-strings` under `rules`):

```js
const path = require("path")

module.exports = {
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint", "graphql"],
  extends: ["eslint:recommended", "plugin:@typescript-eslint/recommended"],
  parserOptions: {
    ecmaVersion: 6,
    project: "./tsconfig.json",
    sourceType: "module"
  },
  rules: {
    "graphql/template-strings": [
      "error",
      {
        schemaJsonFilepath: path.resolve(__dirname, "./schema.json"),
        tagName: "graphql"
      }
    ]
  }
}
```

For GraphQL to know what to lint, we'll need a schema. Thankfully the
[Ethiopian Movie Database](https://etmdb.com/graphql) has our back :)

```sh
$ yarn apollo service:download --endpoint https://etmdb.com/graphql
  ✔ Loading Apollo Project
  ✔ Saving schema to schema.json
✨  Done in 2.18s.
```

Back in `index.ts`, add this bit of code:

```js
import graphql from "graphql-tag"

export const MovieQuery = graphql`
  query MoveQuery {
    allCinemaDetails(before: "2017-10-04", after: "2010-01-01") {
      edges {
        nodez {
          slug
          hallName
        }
      }
    }
  }
`
```

And run the linter:

```sh
$ yarn eslint . --ext .ts,.tsx

~/index.ts
  7:9  error  Cannot query field "nodez" on type "CinemaDetailNodeEdge". Did you mean "node"?  graphql/template-strings

✖ 1 problem (1 error, 0 warnings)
```

Ahh yes, I meant [`node`][blackhole].

### Bonus: VSCode Integration

As developers, we like our tools to work for us, and in 2019 the tool that _seems_ to do that best just happens to
be a brilliant open source product from Microsoft. There were a couple unexpected configuration issues when we were
setting this up, but thankfully they're easy fixes.

```sh
$ mkdir .vscode && touch .vscode/settings.json
```

Then add a couple settings:

```json
{
  "editor.formatOnSave": true,
  "eslint.autoFixOnSave": true,
  "eslint.validate": [
    {
      "language": "javascript",
      "autoFix": true
    },
    {
      "language": "javascriptreact",
      "autoFix": true
    },
    {
      "language": "typescript",
      "autoFix": true
    },
    {
      "language": "typescriptreact",
      "autoFix": true
    }
  ],
  "tslint.enable": false
}
```

Format on save, fix on save, _autofix_ on save, tell ESLint to recognize `.ts` (and `.tsx`, for the React folks)
then disable `tslint` so that `eslint` can do its thing:

<img width="698" alt="eslint displaying graphql error in VSCode IDE" src="https://user-images.githubusercontent.com/236943/51884366-d380ff80-233b-11e9-8128-6c39e210dd31.png">

Now ESLint will show you right where your GraphQL error is from within VSCode. Pretty sweet.

Be sure to read [The future of TypeScript on ESLint][ts-on-eslint] for more details.

[roadmap]: https://github.com/Microsoft/TypeScript/issues/29288
[tslint-react]: https://github.com/palantir/tslint-react
[eslint-react]: https://github.com/yannickcr/eslint-plugin-react
[tslint-prettier]: https://github.com/prettier/tslint-plugin-prettier
[eslint-prettier]: https://github.com/prettier/prettier-eslint
[typescript-eslint]: https://github.com/typescript-eslint/typescript-eslint
[blackhole]: https://i.redd.it/tfugj4n3l6ez.png
[ts-on-eslint]: https://eslint.org/blog/2019/01/future-typescript-eslint
