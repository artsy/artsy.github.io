# Custom filters taken from Octopress

require './_plugins/backtick_code_block'
# require './_plugins/raw'
require 'octopress-hooks'

class ArtsyBlogHooks < Octopress::Hooks::Post
  def pre_render(page)
    if page.ext.match('html|textile|markdown|md|haml|slim|xml')
      input = BacktickCodeBlock.render_code_block(page.content)
      page.content = input.gsub(%r{(<figure.+?>.+?</figure>)}m) do
        TemplateWrapper.safe_wrap(Regexp.last_match(1))
      end
    end
  end

  def post_render(page)
    page.output = TemplateWrapper.unwrap(page.output) if page.ext.match('html|textile|markdown|md|haml|slim|xml')
  end
end

class SVGTag < Liquid::Tag
  def render(context)
    File.read context['project']['svg']
  end
end

Liquid::Template.register_tag('svg_for_project', SVGTag)
