## Setup

```
  git clone git@github.com:artsy/artsy.github.com.git
  cd artsy.github.com
  rake bootstrap
```
## New Post

Go into `_posts` and make a new file.

## Running the OSS Site / Blog

Running `rake serve` will _not_ generate category pages. They take a _long_ time to generate. No one wants that when working on the site.

```
  rake serve
```

Categories are generated when the ENV var `PRODUCTION` = `"YES"`.

## Deploying

```
  rake deploy
```
