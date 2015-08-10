# Custom filters for Octopress

require './_plugins/backtick_code_block'
require './_plugins/raw'
require 'octopress-hooks'

class MySiteHook < Octopress::Hooks::Post
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
