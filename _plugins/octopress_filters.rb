# Custom filters taken from Octopress

require './_plugins/backtick_code_block'
require './_plugins/raw'
require 'octopress-hooks'

class ArtsyBlogHooks < Octopress::Hooks::Post
  def pre_render(page)
    if page.ext.match('html|textile|markdown|md|haml|slim|xml')
      input = BacktickCodeBlock::render_code_block(page.content)
      page.content = input.gsub /(<figure.+?>.+?<\/figure>)/m do
        TemplateWrapper::safe_wrap($1)
      end
    end
  end

  def post_render(page)
    if page.ext.match('html|textile|markdown|md|haml|slim|xml')
      page.output = TemplateWrapper::unwrap(page.output)
    end
  end
end

class SVGTag < Liquid::Tag
  def render(context)
    File.read context["project"]["svg"]
  end
end

Liquid::Template.register_tag('svg_for_project', SVGTag)

SITE_ROOT = File.expand_path('..', __FILE__ + "/..") + "/"

class RawFileTwo < Liquid::Tag
  def initialize(tag_name, path, tokens)
     super
     @path = path
  end

  def render(*)
    file = SITE_ROOT + @path
    puts file
    File.read file
  end
end

Liquid::Template.register_tag('raw_filer', RawFileTwo)
