# Title: Youtube Plugin
# Authors: Orta Therox
# Description: Outputs a Youtube link with breaking HTML
#
# Syntax {% youtube NErVWhEzIBM %}

module Jekyll

  class YoutubeTag < Liquid::Tag
    @id = nil

    def initialize(tag_name, id, others)
      @id = id
      super
    end

    def render(context)
      if @id
        # .entry-content .content-container
        "</div></div>" \
        "<iframe width='100%' height='600' src='https://www.youtube.com/embed/#{@id}' frameborder='0' allowfullscreen></iframe>" \
        "<div class='meta-container'><header>&nbsp;</header></div><div class='content-container'><div class='entry-content'>" \
      else
        "Error processing input, expected syntax: {% youtube [id] %}"
      end
    end
  end
end

Liquid::Template.register_tag('youtube', Jekyll::YoutubeTag)
