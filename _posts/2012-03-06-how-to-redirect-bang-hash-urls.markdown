---
layout: post
title: How To Redirect Bang Hash Urls
date: 2012-03-06 09:02
comments: true
categories: [Rails, JavaScript]
author: db
---
Sometimes you type a hash-bang URL too fast, bang first.

Consider `https://artsy.net/!#/log_in`. Rails will receive `/!` as the file path, resulting in a 404, File Not Found error. The part of the URL after the hash is a position within the page and is never sent to the web server.

It's actually pretty easy to handle this scenario and redirect to the corresponding hash-bang URL.

The most straightforward way is to create a file called `!.html` in your `public` folder and use JavaScript to rewrite the URL with the bang-hash.

``` html public/!.html
<html>
 <head>
 </head>
 <body>
  Click <a href="#" onclick="return window.redirect();">here</a> if you're not redirected ...
  <script language="javascript">
    window.redirect = function() {
      window.location = '/#!' + window.location.hash.substring(1)
      return false;
    }
    window.redirect();
  </script>
 </body>
</html>
```

You can also do this inside a controller with a view or layout. Start by trapping the URL in your `ApplicationController`.

``` ruby app/controllers/application_controller.rb
if request.env['PATH_INFO'] == '/!'
  render layout: "bang_hash"
  return
end
```

The layout can have the piece of JavaScript that redirects to the corresponding hash-bang URL.

``` ruby app/views/layouts/bang_hash.html.haml
!!!
- ie_tag(:html) do
  %body
    :javascript
      window.location = '/#!' + window.location.hash.substring(1)
```
