---
layout: post
title: "Babel 7 + TypeScript"
date: 2017-11-27 14:18
comments: true
author: chris
github-url: https://www.github.com/damassi
twitter-url: http://twitter.com/damassi
categories: [Babel, TypeScript]
---

At Artsy we <3 [TypeScript](https://www.typescriptlang.org/). We use it with React Native via [Emission](https://github.com/artsy/emission) and on the web via [Reaction](https://github.com/artsy/reaction). Increasingly we've been using it for other internal projects, too. Until recently, however, existing projects built on top of Babel had to implement convoluted tooling pipelines in order to work with the TypeScript compiler, increasing friction in an already complex landscape. Thankfully, those days [are over](https://github.com/babel/babel/tree/master/packages/babel-preset-typescript). Read on for an example project, as well as some advice on how to avoid common pitfalls when working with the new beta version of Babel 7.

<!-- more -->

Babel configurations can be complicated. They take time to set up and maintain and can often contain some pretty [far-out features](https://github.com/kentcdodds/babel-macros) that make interop with other environments difficult. That's why we were elated when [this PR](https://github.com/babel/babylon/pull/523) appeared in the wild from [@andy-ms](https://github.com/andy-ms), a developer on the TypeScript team, announcing a new parser for Babylon. [@babel/preset-typescript](https://github.com/babel/babel/tree/master/packages/babel-preset-typescript) arrived soon after and we felt it was finally time to give it a try. There was a catch, however: TypeScript support only works with Babel 7+!

**TLDR; Check out https://github.com/damassi/babel-7-typescript-example for a fully working project that includes React, Jest and Enzyme.**

And with that, here's list of setup issues we faced in no specific order:

### 1) New @babel Namespace

One of the first things Babel 7 users will notice is the package ecosystem now exists as a [monorepo](https://github.com/babel/babel/tree/master/packages) and all NPM modules are namespaced behind the `@babel` org address. Packages that used to be installed via

```sh
yarn add -D \
  babel-core \
  babel-preset-react \
  babel-preset-stage-3
  ...
```
are now installed via
```sh
yarn add -D \
  @babel/core \
  @babel/preset-react \
  @babel/preset-stage-3
  ...
```
which immediately creates upgrade conflicts between libraries that use Babel 6 and Babel 7. For example, `babel-jest` internally points to `babel-core` which supports a [version range between 6 and 7](https://github.com/facebook/jest/blob/master/packages/babel-jest/package.json#L19) -- but! -- `babel-core` is now `@babel/core` so this breaks.

This wasn't immediately apparent at the time, and so we would often find errors like

```sh
Error: Could not find preset "@babel/env" relative to directory
```

These errors appeared ambiguous because the folder structure was correct and commands like `yarn list @babel/preset-env` yielded expected results:

```sh
└─ @babel/preset-env@7.0.0-beta.32
✨  Done in 0.58s.
```

Why was the package not found? Digging deeper, it seemed like Babel 6 was still being used somewhere. Running `yarn list babel-core` revealed the culprit:

```sh
└─ babel-core@6.25.0
✨  Done in 0.58s.
```

Thankfully, [babel-bridge](https://github.com/babel/babel-bridge) exists to "bridge" the gap, but one can see how complications can and will arise. Further, not all packages have implemented this fix and so we had to rely on `yarn`'s new [selective dependency resolution](https://yarnpkg.com/lang/en/docs/selective-version-resolutions/) feature which overrides child dependency versions with a fixed number set directly in `package.json`:

```json
"resolutions": {
  "babel-core": "^7.0.0-bridge.0"
},
```

With this in place many of our errors disappeared and packages like `jest` now worked like a charm.

### 2) Missing ES2015 Features

Another error we faced early on surrounded language features that worked with Babel _or_ TypeScript, but not with Babel _and_ TypeScript. For example, take an existing Babel project that points to `index.js` as an entrypoint, configure it to support TypeScript via Babel 7, and then run it:

```json
"scripts": {
  "start": "babel-node index.js"
}
```
```js
// index.js
require('@babel/register', {
  extensions: ['.js', '.jsx', '.ts', '.tsx']
})
require('app/server.ts')
```
```typescript
// app/server.ts
console.log('hi!')
```

Running

```sh
yarn start
$ babel-node index.js

hi!
✨  Done in 1.88s.
```

Everything seems to be working; our `.js` entrypoint is configured to support `.ts` extensions and we kick off the boot process.

Let's now try to import a file from within `app/server.ts`:

```typescript
import path from 'path'
console.log(`Hello ${path.resolve(process.cwd())}!`)
```

```sh
yarn start
$ yarn run v1.3.2
$ babel-node index.js
sites/src/index.tsx:1
(function (exports, require, module, __filename, __dirname) { import path from 'path'
                                                              ^^^^^^

SyntaxError: Unexpected token import
```

Maybe my `tsconfig.json` file is misconfigured?

```json
{
  "compilerOptions": {
    "module": "es2015",
    ...
  }
}
```

Nope, all good. How about my `.babelrc`?

```json
{
  "presets": [
    ["@babel/env", {
      "targets": {
        "browsers": ["last 2 versions"]
      }
    }],
    "@babel/stage-3",
    "@babel/react",
    "@babel/typescript"
  ]
}
```

We're using [`@babel/preset-env`](https://github.com/babel/babel/tree/master/packages/babel-preset-env) which handles selecting the JS features we need, so thats not it. And anyways, doesn't TypeScript support `ES2015` modules right out of the box?

Continuing, how about specifying the extension list directly in `package.json`:

```json
"start": "babel-node --extensions '.ts,.tsx' index.js"
```

Still no go :(

Last try: Create a new entrypoint file that uses a `.ts` extension and then use _that_ to boot the rest of the app:

```json
"start": "babel-node --extensions '.ts,.tsx' index.ts"
```
```typescript
// index.ts
import './app/server'
```
```sh
yarn start
$ yarn run v1.3.2
$ babel-node index.js
Hello /sites!
```

Once this change was in place, we could ditch `@babel/register` and instead rely on the `--extensions` configuration from `package.json`.

**NOTE:** If you're using [`babel-plugin-module-resolver`](https://github.com/tleunen/babel-plugin-module-resolver) to support absolute path imports make sure to update the `extensions` [option](https://github.com/tleunen/babel-plugin-module-resolver#options) with `.ts` and `.tsx`.

### 3) Type-Checking

Lastly, since Babel 7 is now responsible for compiling our TypeScript files we no longer need to rely on TypeScript's own `tsc` compiler to output JavaScript and instead just use it to type-check our code. Again, in `package.json`:

```
"typecheck": "tsc"
```

This reads in settings located in `tsconfig.json`:
```json
{
  "compilerOptions": {
    "allowJs": true,
    "allowSyntheticDefaultImports": true,
    "baseUrl": "./src",
    "jsx": "react",
    "module": "es2015",
    "noEmit": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "pretty": true,
    "rootDirs": [
      "./src"
    ],
    "sourceMap": true
  }
}
```

Notice the `noEmit` flag? That tells `tsc` not to output any JS and instead only check for correctness.

While this seemed to be all that was needed, running `yarn typecheck` would throw an error:

```
$ yarn typecheck
yarn run v1.3.2
$ tsc

node_modules/@types/jest/index.d.ts(1053,34): error TS2304: Cannot find name 'Set'.

1053         onRunComplete?(contexts: Set<Context>, results: AggregatedResult): Maybe<Promise<void>>;
                                      ~~~

error Command failed with exit code 1.
```

Why is it TypeChecking my `node_modules` folder when `rootDirs` is set to `src`? It looks like we missed a TypeScript setting:

```json
{
  "compilerOptions": {
    ...
    "skipLibCheck": true
  }
}
```

With that last missing piece everything now works:

```sh
yarn typecheck -w
yarn run v1.3.2
$ tsc -w

src/index.tsx(5,7): error TS2451: Cannot redeclare block-scoped variable 'test'.

5 const test = (foo: string) => foo
        ~~~~

src/index.tsx(6,6): error TS2345: Argument of type '2' is not assignable to parameter of type 'string'.

6 test(2)
       ~
```

Proper type-checking, but compilation handled by Babel 😎.

References:
- https://github.com/damassi/babel-7-typescript-example
- https://github.com/babel/babel/tree/master/packages/babel-preset-typescript
- https://github.com/artsy/emission
- https://github.com/artsy/reaction
