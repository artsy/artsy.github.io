---
layout: post
title: 'Using OCR To Fix a Hilarious Bug'
date: 2015-11-05T00:00:00.000Z
comments: false
categories: [Ruby, open source, OSS, debugging]
author: matt
---

For a little while, we would get very strange bug reports. People would complain that artist thumbnails (viewed in several different contexts across the web and our iOS apps) would not be an image of the artist's work, but rather text, which had inexplicably become an actual JPG. This wasn't just text appearing in a `div` that should contain an `img` or something like that, these were actual JPG's that were pictures of text.

We would fix these as they came up, chalking the strangeness up to some relic of an old image processing pipeline, data being migrated, etc.

However, the reports kept coming in. This blog post is about how we diagnosed this actual bug, and how we used a simple Ruby script and OCR to help us detect and fix the existing images.

<!-- more -->

Here's an example of a bug report where the thumbnail for [Marina Abramović](https://www.artsy.net/artist/marina-abramovic-1) became the text of her bio.

![Bad Search](/images/2015-11-12-hilarious-bug/search.png)

Here's one from our [iOS app](https://github.com/artsy/eigen) showing that thumbnails for related artists are set to their bios as well.

![Bad Related Artists](/images/2015-11-12-hilarious-bug/eigen.png)

Weird right? We eventually tracked down what was going on, and it's actually perfectly summarized in [this issue](https://github.com/blueimp/jQuery-File-Upload/pull/3356). When someone copies text from Excel, it also generates an image of that cell or cells, and puts it into the clipboard. We immediately suspected something with `pasteZone`, and the bug was easy to reproduce - have an image in your clipboard and paste anywhere on the page.

We have an admin panel that allows some metadata about an artist to be edited. This includes their bio, as well as a place to upload a representative image as their 'cover thumbnail'.

As the issue describes, we had some text input fields, as well as a file upload form using [Blueimp's jQuery File Upload](https://github.com/blueimp/jQuery-File-Upload). When you don't specify a `pasteZone` it defaults to the entire document. This means that a paste event anywhere on the page will trigger that event.

Our editorial team was using Microsoft Excel and Word to organize some data about the artist, including bios. When ready, a team member would copy and paste the bio into the bio input text field. This would also immediately fire the event for the image upload, which now automagically became an actual picture of the text of the bio. Our API and image processing pipeline would happily accept that, leading to the incredibly bizarre bug reports.

My immediate fix was to specify and scope `pasteZone` (and similarly, `dropZone`) to the element the file upload widget was bound to. That would prevent the problem from happening again. Taking a quick look art some random samples of artists, it looked like potentially thousands of records might have been affected and I became interested in a programmatic way to detect these images. A manual approach would have been very cumbersome.

Since the images were that of text, I decided to use OCR to remove artist thumbnails that it determined had 'too much text'. This may have unset valid covers from artists that use lots of text in their work, such as [Joseph Kosuth](https://www.artsy.net/artist/joseph-kosuth). However, this was safe to do since we have some custom logic to fall back to an image of an iconic artwork by the artist in the case of a missing thumbnail.

To get OCR functionality in Ruby, I decided to use [Tesseract](https://github.com/tesseract-ocr/tesseract), a great OSS library. Once I had it installed, I used a [ruby wrapper](https://github.com/meh/ruby-tesseract-ocr) to make using it easier.

The script eventually turned into something like:

``` ruby
# initialize and configure Tesseract
engine = Tesseract::Engine.new do |config|
  config.language  = :eng
  config.blacklist = '|'
end

# iterate over artists and pull their thumbnails
# given the URL to a publicly accessible image at img

text = engine.text_for(img)
text = text.gsub(/[^a-z ]/i, '').gsub(' ', '')
if text.length > 30
  puts "Found problematic artist #{artist_doc['last']}"
  # ...
end
```

So all we do is find all the text in an image, and then remove any garbage characters or artifacts from the OCR analysis, and then use 30 as an arbitrary cutoff to determine if an image was problematic. If the image had more than 30 characters as detected by the OCR library, we wound up unsetting it from the artist.

The additional logic to set artist covers from their iconic artworks was already in place, and I ran this script in production, identifying and unsetting over 1000 problematic thumbnails. And we haven't gotten any new reports of this bug since then :)