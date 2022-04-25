[![Build Status](https://circleci.com/gh/artsy/artsy.github.io.svg?style=svg)](https://circleci.com/gh/artsy/artsy.github.io)

The Artsy OSS page and the blog runs on top of a default jekyll install. If you would like an overview of jekyll,
their [website rocks](http://jekyllrb.com/).

## Setup

```
git clone git@github.com:artsy/artsy.github.io.git
cd artsy.github.io
bundle
bundle exec rake bootstrap
bundle exec rake build
```

### Common issues ⚠️

<details><summary>Issues installing `therubyracer` and/or `v8` dependencies</summary>
Some combination of the following might help resolve issues with installing these dependencies:

- make sure you have a ruby version that works (e.g. 2.7.5)
- Installing `v8` via homebrew: `brew install v8`
- Installing the `libv8` gem using a specific version and v8 flag:
  `gem install libv8 -v '3.16.14.19' -- --with-system-v8`
- Assigning configuration options, as in
  [this comment](https://gist.github.com/fernandoaleman/868b64cd60ab2d51ab24e7bf384da1ca#gistcomment-3114668).

</details>

## License

The code in this repository is released under the MIT license. The contents of the blog itself (ie: the contents of
the `_posts` directory) are released
under +[Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

## Running the OSS Site / Blog locally

Running `rake serve` will _not_ generate category pages. They take a _long_ time to generate. No one wants that
when working on the site.

```
  bundle exec rake serve
```

Categories are generated when the ENV var `PRODUCTION` = `"YES"`.

## Deploying

- Circle automatically deploys to GitHub Pages when new commits are pushed to the `source` branch.
- If you need to trigger a deploy locally, the `rake deploy` command is available.
- See the `Rakefile` for details on how builds/deploys are done.
- Note that the `main` branch does not build on Circle, due to all deploy commits being prefixed with `[skip ci]`.

## Adding an Author

Authors are key-value stored, so you will need to give yourself a key inside [\_config.yml](_config.yml) - for
example:

```yaml
joey:
  name: Joey Aghion
  github: joeyAghion
  twitter: joeyAghion
  site: http://joey.aghion.com
```

Everything but name is optional.

## Authoring an Article

Note: we now have some templates to help get you started writing a blog post. Check out the
[`Post-Templates` directory](Post-Templates).

TLDR _To generate a new post, create a new file in the `_posts` directory. Be sure to add your name as the author
of the post and include several categories to file the post under. Here is a sample header YAML:_

Note: categories are aggregated from the individual posts, so adding one is as easy as adding it to your post!

```yaml
---
layout: post
title: "Responsive Layouts with CSS3"
date: 2012-01-17 11:03
comments: true
author: Matt McNierney
github-url: https://www.github.com/mmcnierney14
twitter-url: http://twitter.com/mmcnierney
blog-url: http://mattmcnierney.wordpress.com
categories: [Design, CSS, HTML5]
---
```

More info can be found in the [Jekyll docs](http://jekyllrb.com/docs/posts/).

When you have authored an article, `git add` and `git commit` it, then push to a named branch with
`git push origin [branch]`, and create a pull request to the `source` branch, it will be deployed to the site by
travis when merged.

## Enabling Comments

Comments for articles are managed with [Issues](https://github.com/artsy/artsy.github.io/issues) in this GitHub
repository.

#### [Create an issue](https://github.com/artsy/artsy.github.io/issues/new) for the article

Quote the opening paragraph(s) of the post as the body of the issue, and name it something like "Comments: My
Fantastic New Post".

#### Add the `Comment Thread` label to the issue

#### Attach the issue to your article

Copy the created issue ID; add it to the frontmatter YAML of your post, as the `comment_id` attribute:

`comment_id: 1234`

## After Deploying an Article

Every article on our blog needs one more thing: a snappy tweet! You can ask Ash or Orta to do this for you, but
you're also welcome to log into the [@ArtsyOpenSource](https://twitter.com/ArtsyOpenSource) twitter account and
tweet yourself (credentials are in the Engineering 1Password vault). Tweets usually follow the following format:

```
[pithy observation] [description of problem] [@ the article author's twitter handle]

📝 [link to blog post]
💻 [link to GitHub repo, if applicable]
📷 [attach a screenshot of the first few paragraphs of the post]
```

We attach screenshots of the post because tweets with images get more traction. But! Images aren't accessible to
screen readers, so make sure to use the twitter.com web interface and add a description to the image when posting:

> Screenshot of the title and first two paragraphs of the linked-to blog post.

You can look at previous tweets from our account to get a feel for these. If you'd like help, just ask in Slack.

## Authoring a Podcast Episode

To add a new episode of the podcast, [configure](https://github.com/aws/aws-sdk-ruby#configuration) your local AWS
environment. The easiest is in environment variables stored in `~/.zshrc` or equivalent.

```
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
```

After you have set up the environment, run the following rake task.

```sh
rake podcast:new_episode /path/to/local/mp3
```

This will add required YAML to `_config.yml`. You'll need to fill in some other fields manually; when finished
it'll look like this:

```yaml
- title: Name of your episode
  date: (generated by Rake task)
  description: A paragraph-long description of the episode.
  podcast_url: (generated by Rake task)
  file_byte_length: (generated by Rake task)
  duration: (generated by Rake task)
```

## About Artsy

<a href="https://www.artsy.net/">
  <img align="left" src="https://avatars2.githubusercontent.com/u/546231?s=200&v=4"/>
</a>

This project is the work of engineers at [Artsy][footer_website], the world's leading and largest online art
marketplace and platform for discovering art. One of our core [Engineering Principles][footer_principles] is being
[Open Source by Default][footer_open] which means we strive to share as many details of our work as possible.

You can learn more about this work from [our blog][footer_blog] and by following [@ArtsyOpenSource][footer_twitter]
or explore our public data by checking out [our API][footer_api]. If you're interested in a career at Artsy, read
through our [job postings][footer_jobs]!

[footer_website]: https://www.artsy.net/
[footer_principles]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md
[footer_open]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#open-source-by-default
[footer_blog]: https://artsy.github.io/
[footer_twitter]: https://twitter.com/ArtsyOpenSource
[footer_api]: https://developers.artsy.net/
[footer_jobs]: https://www.artsy.net/jobs
