---
layout: post
title: Generating Automatic Plain Text MIME Parts with Rails ActionMailer
date: 2012-05-16 20:52
comments: true
categories: [Email, Ruby on Rails, ActionMailer]
author: db
---
E-mail is one of the most important ways to engage your users. And every time you touch a user's inbox, it reflects on your brand. But getting email right has become increasing difficult due to the complexities introduced by the thousands of web-based, desktop and mobile mail clients. Email formatting is like the "Hunger Games" where the major players include online services such as GMail, Yahoo, Hotmail or AOL, desktop clients such as Outlook and a myriad mobile devices ranging from iPhone and Android to Blackberry.

To deal with this landscape, the MIME standard allows systems to send e-mail with multiple parts: `plain/text` for business-efficient devices such as the Blackberry, and `text/html` for web-based e-mail readers, such as GMail. Furthermore, `ActionMailer` supports multiple template formats: create an `.html.haml` template along with a `.txt.haml` template to generate both. We also know that `text/plain` email helps deliverability, but we believe a disproportionately small amount of text e-mails are actually read - the vast majority of devices are capable of parsing some HTML.

Is it possible to avoid having to maintain two separate templates without sacrificing deliverability? How can we inject a `text/plain` part into HTML e-mail that is both useful and "free"?

<!--more-->

`ActionMailer::Base` defines an internal method called `collect_responses_and_parts_order` ([#ref](http://apidock.com/rails/ActionMailer/Base/collect_responses_and_parts_order)), which iterates over templates and renders them. Let's override that method and examine the contents of the generated parts.

``` ruby
def collect_responses_and_parts_order(headers)
    responses, parts_order = super(headers)
    [responses, parts_order]
end
```

Each `response` is a MIME part with its boundary and the `parts_order` is the order in which the parts appear in the final e-mail. The [MIME RFC 1341](http://www.ietf.org/rfc/rfc1341.txt) says that the parts must be generated in the increasing order of preference, ie. `text/html` content-type part last, provided you want it to be the preferred format of your email.

We can find whether the generated e-mail contains a `plain/text` part and otherwise generate one.

``` ruby
html_part = responses.detect { |response| response[:content_type] == "text/html" }
text_part = responses.detect { |response| response[:content_type] == "text/plain" }
if html_part && ! text_part
  # generate a text/plain part
end
```

Generating the text part means stripping all HTML with links preserved. [Nokogiri](http://nokogiri.org/) has a very convenient deep `traverse` iterator.

``` ruby
body_parts = []
Nokogiri::HTML(html_part[:body]).traverse do |node|
  if node.text? and ! (content = node.content ? node.content.strip : nil).blank?
    body_parts << content
  elsif node.name == "a" && (href = node.attr("href")) && href.match(/^https?:/)
    body_parts << href
  end
end
```

Once we have all the parts, assemble them, get rid of duplicate text and links, and re-insert into the email as a `text/plain` multipart block.

``` ruby
responses.insert 0, {
  content_type: "text/plain",
  body: body_parts.uniq.join("\n")
}
parts_order.insert 0, "text/plain"
```

This has been extracted into the [actionmailer-text](https://github.com/dblock/actionmailer-text) gem. Include `ActionMailer::Text` in your mailers.
