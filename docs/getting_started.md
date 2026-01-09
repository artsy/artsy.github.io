# Getting Started

## Setup

```
git clone git@github.com:artsy/artsy.github.io.git
cd artsy.github.io
bundle
bundle exec rake bootstrap
bundle exec rake build
```

<details>
<summary>Common Issues</summary>

### Issues installing `therubyracer` and/or `v8` dependencies

Some combination of the following might help:

- Make sure you have a ruby version that works (e.g. 2.7.5)
- Installing `v8` via homebrew: `brew install v8`
- Installing the `libv8` gem using a specific version and v8 flag:
  `gem install libv8 -v '3.16.14.19' -- --with-system-v8`
- Assigning configuration options, as in
  [this comment](https://gist.github.com/fernandoaleman/868b64cd60ab2d51ab24e7bf384da1ca#gistcomment-3114668).

</details>

## Running Locally

Running `rake serve` will _not_ generate category pages. They take a _long_ time to generate.

```
bundle exec rake serve
```

Categories are generated when the ENV var `PRODUCTION` = `"YES"`.

## Deploying

- Circle automatically deploys to GitHub Pages when new commits are pushed to the `source` branch.
- If you need to trigger a deploy locally, the `rake deploy` command is available.
- See the `Rakefile` for details on how builds/deploys are done.
- Note that the `main` branch does not build on Circle, due to all deploy commits being prefixed with `[skip ci]`.
