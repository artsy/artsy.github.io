# Title: A source breaking Image tag for Jekyll
# Authors: Orta Therox
# Description: Easily output longer images
#
# Syntax {% expanded_img [class name(s)] [http[s]:/]/path/to/image [http[s]:/]/link/for/image [width [height]] [title text | "title text" ["alt text"]] %}
#
# Examples:
# {% expanded_img /images/ninja.png Ninja Attack! %}
# {% expanded_img left half http://site.com/images/ninja.png Ninja Attack! %}
# {% expanded_img left half http://site.com/images/ninja.png 150 150 "Ninja Attack!" "Ninja in attack posture" %}
#
# Output:
# <img src="/images/ninja.png">
# <img class="left half" src="http://site.com/images/ninja.png" title="Ninja Attack!" alt="Ninja Attack!">
# <img class="left half" src="http://site.com/images/ninja.png" width="150" height="150" title="Ninja Attack!" alt="Ninja in attack posture">
#

module Jekyll

  class ExpandedImageTag < Liquid::Tag
    @expanded_img = nil
    @link = nil

    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'src', 'width', 'height', 'title']

      if markup =~ /(?<class>[^(http|\/images)]\S.*\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<link>(?:https?:\/\/|\/|\S+\/)\S+))?(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @expanded_img = attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
        @link = $~['link'].strip if $~['link']

        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @expanded_img['title']
          @expanded_img['title']  = title
          @expanded_img['alt']    = alt
        else
          @expanded_img['alt']    = @expanded_img['title'].gsub!(/"/, '&#34;') if @expanded_img['title']
        end
        @expanded_img['class'].gsub!(/"/, '') if @expanded_img['class']
      end
      super
    end

    def render(context)
      if @expanded_img
        # .entry-content .content-container
        "</div></div>" \
        "<a href='#{@link or @expanded_img["src"]}'><img #{@expanded_img.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}></a>" \
        "<div class='meta-container'><header>&nbsp;</header></div><div class='date-container'>&nbsp;</div><div class='content-container'><div class='entry-content'>" \
      else
        "Error processing input, expected syntax: {% expanded_img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end
end

Liquid::Template.register_tag('expanded_img', Jekyll::ExpandedImageTag)
