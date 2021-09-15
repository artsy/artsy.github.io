---
layout: post
title: "Delaying CarrierWave Image Processing"
date: 2012-01-31 08:31
comments: true
categories: [CarrierWave, Image Processing]
author: db
---
We do a lot of image processing at Artsy. We have tens of thousands of beautiful original high resolution images from our partners and treat them with care. The files mostly come from professional art photographers, include embedded color profiles and other complicated features that make image processing a big deal.

Once uploaded, these images are converted to JPG, resized into many versions and often resampled. We are using [CarrierWave](https://github.com/jnicklas/carrierwave) for this process - our typical image uploader starts like a usual CarrierWave implementation with a few additional features.

<!-- more -->

* Fallback to a well-known image when an image is missing
* Support for a local development environment, S3 and CloudFront
* Image versioning: replaced images get a new path to bust CloudFront caching

Here's the complete source.

``` ruby app/models/image_uploader.rb
    class ImageUploader < CarrierWave::Uploader::Base

      include CarrierWave::RMagick

      # default url for a missing image
      def default_url
        "/assets/images/shared/missing_image.png"
      end

      # a local path for development environments w/o S3 or CloudFront
      def local_path
        (ENV['CLOUDFRONT_URL'] || ENV['S3_BUCKET']) ? "" : "local/"
      end

      # complete url to an image version
      def image_url_format_string
        "#{self.class.image_url_prefix}/#{self.class.store_path_base(self.model)}:version.jpg"
      end

      # a whitelist for uploading
      def extension_white_list
        %w(jpg jpeg png gif tif tiff bmp)
      end

      # alternate temporary location for Heroku
      def cache_dir
        "#{Rails.root.to_s}/tmp/uploads"
      end

      # relative path for saving a file
      def store_path(for_file = filename)
        "#{local_path}#{self.class.store_path_base(self.model)}#{(version_name || :original).to_s}.jpg"
      end

      # normalized file name for an image converted to JPG
      def filename
        super != nil ? super.split('.').first + '.jpg' : super
      end

      # a location that includes a version number
      def self.store_path_base(model)
        class_name = model.class.name.underscore.pluralize
        image_version = (model.image_version || 0) > 0 ? "#{model.image_version}/" : ""
        "#{class_name}/#{model.id.to_s}/#{image_version}"
      end

      # a url prefix depending on environment settings
      def self.image_url_prefix
        if ENV['IMAGES_URL']
          ENV['IMAGES_URL']
        elsif ENV['CLOUDFRONT_URL']
          ENV['CLOUDFRONT_URL']
        elsif ENV['S3_BUCKET']
          "http://#{ENV['S3_BUCKET']}.s3.amazonaws.com"
        else
          "/local"
        end
      end

    end
```

We derive actual uploaders from the `ImageUploader` class.

``` ruby app/models/widget_uploader.rb
    class WidgetUploader < ImageUploader

      process :increment_version

      def increment_version
        return if self.is_processing_delayed?
        self.model.image_version = (self.model.image_version.to_i + 1)
        self.model.image_versions = []
      end

      version :small, if: :is_processing_delayed? do
        process :convert => 'jpg'
        process :resize_to_limit => [200, 200]
        process :quality => 70
      end

      version :square, if: :is_processing_delayed? do
        process :convert => 'jpg'
        process :resize_to_fill => [230, 230]
        process :quality => 90
      end
    end
```

And the uploader is mounted via `mount_uploader`.

``` ruby
    mount_uploader :image,  WidgetUploader, delayed: true
```

You'll notice a few unusual things here. The versions have an `:if` condition and there're mentions of `is_processing_delayed?`. This comes from a small module [@joeyAghion](https://github.com/joeyAghion/) wrote called `DelayedImageProcessing`. It's a much more evolved version designed on top of [my earlier idea](http://code.dblock.org/carrierwave-delayjob-processing-of-selected-versions) of delaying some image processing for background jobs.

The reason we want to delay image processing is because it takes a long time. The Heroku HTTP request limit is only 30 seconds, so image upload would regularly timeout. And some of the large images can take up to ten minutes to process - we don't want the user to wait that long.

To use, you will add some code in `config/initializers/carrierwave.rb` and add `DelayedImageProcessing` into `lib`.

* [lib/delayed_image_processing.rb](https://gist.github.com/1710609#file_delayed_image_processing.rb)
* [config/initializers/carrierwave.rb](https://gist.github.com/1710609#file_carrierwave.rb)

The code above works with Mongoid. You will have to do some work to make this work with other storage.
