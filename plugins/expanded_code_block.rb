# Title: Simple Code Blocks for Jekyll
# Author: Orta Therox
# Description: Will wrap a normal code block with expandsions for breaking out of the layout.
#
# Syntax:
# {% expanded_codeblock [title] [url] [link text] %}
# code snippet
# {% endexpanded_codeblock %}
#
# For syntax highlighting, put a file extension somewhere in the title. examples:
# {% expanded_codeblock file.sh %}
# code snippet
# {% endexpanded_codeblock %}
#
# {% expanded_codeblock Time to be Awesome! (awesome.rb) %}
# code snippet
# {% endexpanded_codeblock %}
#
# Example:
#
# {% expanded_codeblock Got pain? painreleif.sh http://site.com/painreleief.sh Download it! %}
# $ rm -rf ~/PAIN
# {% endexpanded_codeblock %}
#
# Output:
#
# <figure class='code'>
# <figcaption><span>Got pain? painrelief.sh</span> <a href="http://site.com/painrelief.sh">Download it!</a>
# <div class="highlight"><pre><code class="sh">
# -- nicely escaped highlighted code --
# </code></pre></div>
# </figure>
#
# Example 2 (no syntax highlighting):
#
# {% expanded_codeblock %}
# <sarcasm>Ooooh, sarcasm... How original!</sarcasm>
# {% endexpanded_codeblock %}
#
# <figure class='code'>
# <pre><code>&lt;sarcasm> Ooooh, sarcasm... How original!&lt;/sarcasm></code></pre>
# </figure>
#
require './plugins/pygments_code'
require './plugins/raw'

module Jekyll

  class ExpandedCodeBlock < Liquid::Block
    include HighlightCode
    include TemplateWrapper
    CaptionUrlTitle = /(\S[\S\s]*)\s+(https?:\/\/)(\S+)\s+(.+)/i
    CaptionUrl = /(\S[\S\s]*)\s+(https?:\/\/)(\S+)/i
    Caption = /(\S[\S\s]*)/
    def initialize(tag_name, markup, tokens)
      @title = nil
      @caption = nil
      @filetype = nil
      @highlight = true
      if markup =~ /\s*lang:(\w+)/i
        @filetype = $1
        markup = markup.sub(/lang:\w+/i,'')
      end
      if markup =~ CaptionUrlTitle
        @file = $1
        @caption = "<figcaption><span>#{$1}</span><a href='#{$2 + $3}'>#{$4}</a></figcaption>"
      elsif markup =~ CaptionUrl
        @file = $1
        @caption = "<figcaption><span>#{$1}</span><a href='#{$2 + $3}'>link</a></figcaption>"
      elsif markup =~ Caption
        @file = $1
        @caption = "<figcaption><span>#{$1}</span></figcaption>\n"
      end
      if @file =~ /\S[\S\s]*\w+\.(\w+)/ && @filetype.nil?
        @filetype = $1
      end
      super
    end

    def render(context)
      output = super
      code = super.join
      source = "<figure class='code'>"
      source += @caption if @caption
      if @filetype
        source += " #{highlight(code, @filetype)}</figure>"
      else
        source += "#{tableize_code(code.lstrip.rstrip.gsub(/</,'&lt;'))}</figure>"
      end
      source = "</div></div>" + source + "<div class='meta-container'><header>&nbsp;</header></div><div class='date-container'>&nbsp;</div><div class='content-container'><div class='entry-content'>"
      source = safe_wrap(source)
      source = context['pygments_prefix'] + source if context['pygments_prefix']
      source = source + context['pygments_suffix'] if context['pygments_suffix']
      source
    end
  end
end

Liquid::Template.register_tag('expanded_codeblock', Jekyll::ExpandedCodeBlock)
