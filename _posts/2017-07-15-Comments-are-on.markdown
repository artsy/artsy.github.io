---
layout: epic
title: Using GitHub Issues for Blog Comments
date: 2017-07-15
categories: [javascript, github, blogging]
author: orta
comment_id: 364
---

I've worked on a few large-scale OSS projects, and I believe that people find it easier to just leave a comment and rely on a contributor to explain a problem rather than consulting the documentation. I consider doing everything you can to make people find their own answers a strong part of [defensive open source][def-oss].

I have an even lower tolerance for comments on posts I write. Once I started using this blog, I added the ability to turn off comments per-post and haven't allowed comments on any posts I've written.

I'm willing to give it another shot though, and so I got around to creating a simple system for allowing opt-in comments on posts using GitHub Issues. The rest of this post will be about how you can do it also, and a bit about why I think GitHub Issues are a happy medium for the comments.

<!-- more -->

<div><div class="comment"><div class="comment-header"><a class="comment-username" href="https://github.com/orta"><img src="https://avatars6.githubusercontent.com/u/49038?v=4" alt="" width="40" height="40">orta</a> commented <a class="comment-date" href="https://github.com/artsy/artsy.github.io/issues/355#issuecomment-313158506">2 days ago</a></div><div class="comment-body"><p>Comments can be worth a shot.</p>
<p>With a static site it can be a bit tricky, but with some JavaScript and a node server thinking than  <g-emoji alias="+1" fallback-src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f44d.png" ios-version="6.0">👍</g-emoji>.</p></div></div></div>

# Getting set up

The general concept is that you have some JavaScript in your page which requests a list of comments from GitHub. These are available as a JSON API, you can grab that then style the results. Sounds easy right?

Turns out to be a bit more complicated. GitHub's API has rate-limits for IP addresses, and they're reasonably low. So, you'll want to use authenticated requests, but you don't really want to include your access tokens inside the JavaScript on your blog.

I've worked around this with a project called [gh-commentify][], a node app whose job is to wrap your comment API requests with an access token. You can create your own instance on heroku using [this link][]. It get's scoped to a single org/user, so you can avoid others using your heroku instance.

From there you need to be able to declare in a post what issue it is hooked up to. This blog uses Jekyll, which has [YAML Front Matter][yaml-fm] on posts. So, I edited our post templates to detect for a key `comment_id`.

From there you need to grab the comments JSON, and move them into the DOM.

I based my work on these two posts:

* [GitHub hosted comments for GitHub hosted blogs][gh-2011]
* [Replacing Disqus with Github Comments][gh-2017]

However this version is more reliable (GitHub authenticated requests) and has fewer dependencies (no jQuery for example).

{% raw %}
```html
{% if page.comment_id %}
  <article class='post'>
    {% include gh_comments.html %}
  </article>
{% endif %}
```
{% endraw %}

This then imports the required JavaScript into the page. It feels a lot like this;

{% raw %}

```javascript
var writeToComment = function(element, html) {
  var element = document.createElement(element)
  element.innerHTML = html
  document.getElementById("comments").appendChild(element)
}

var loadComments = function(data) {
  writeToComment("h2", "Comments")
  
  for (var i = 0; i < data.length; i++) {
    var commentHTML = [...]
    writeToComment("div", commentHTML)
  }

  var callToAction = [...]
  writeToComment("div", callToAction)
}

var writeFirstComment = function() {
  var callToAction = [...]
  writeToComment("div", callToAction)
}

// This is mostly there now: http://caniuse.com/#feat=fetch
if (window.fetch) {
  var url =
    "https://artsy-blog-gh-commentify.herokuapp.com/repos/artsy/artsy.github.io/issues/{{ page.comment_id }}/comments"

  window
    .fetch(url, { Accept: "application/vnd.github.v3.html+json" })
    .then(function(response) {
      return response.json()
    })
    .then(function(json) {
      if(json.length) {
        loadComments(json)
      } else {
        writeFirstComment()
      }
    })
}
```
{% endraw %}

No-one is going to award this JavaScript with a prize for elegance, but it works just fine. That's basically it, you can edit the DOM however you want.

The full PR for these changes is here: [artsy.github.io#363][pr] - and you can see the current [HTML/JS here][current].

# Why GitHub?

It's easier for you to keep track of the conversations, you're likely already having a lot of conversations in a place like GitHub. This means you can use the same flow and tools as your daily job, not relying on a third party service's emails.

You have good admin tools: you can edit comments, block and report problematic users. These are tools that you have for all repos.

People will be using their developer accounts, which I'd like to hope they will take pride in. You're probably more likely to get high quality responses. The lack of threading is a bit of a shame in this context, but we've lived with it in GitHub Issues for this long, so I'm OK with this.

This setup makes it trivial to drop comments from the blog anytime, and you still have all the comments around in a constructive way after. We don't have to 

So: low maintenance, data isn't silo-ed and it's more likely to result in positive interactions.

[def-oss]: /blog/2016/07/03/handling-big-projects/
[gh-commentify]: https://github.com/orta/gh-commentify
[this link]: https://heroku.com/deploy?template=https://github.com/orta/gh-commentify
[yaml-fm]: https://jekyllrb.com/docs/frontmatter/
[gh-2011]: http://ivanzuzak.info/2011/02/18/github-hosted-comments-for-github-hosted-blogs.html
[gh-2017]: http://donw.io/post/github-comments/
[current]: https://github.com/artsy/artsy.github.io/blob/source/_includes/gh_comments.html
[pr]: https://github.com/artsy/artsy.github.io/pull/363
