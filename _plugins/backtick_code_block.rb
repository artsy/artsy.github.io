require './_plugins/pygments_code'
# require './_plugins/raw'

module BacktickCodeBlock
  AllOptions = %r{([^\s]+)\s+(.+?)\s+(https?://\S+|/\S+)\s*(.+)?}i
  LangCaption = /([^\s]+)\s*(.+)?/i
  def self.render_code_block(input)
    @options = nil
    @caption = nil
    @lang = nil
    @url = nil
    @title = nil
    input.gsub(/^`{3} *([^\n]+)?\n(.+?)\n`{3}/m) do
      @options = Regexp.last_match(1) || ''
      str = Regexp.last_match(2)

      if @options =~ AllOptions
        @lang = Regexp.last_match(1)
        @caption = "<figcaption><span>#{Regexp.last_match(2)}</span><a href='#{Regexp.last_match(3)}'>#{Regexp.last_match(4) || 'link'}</a></figcaption>"
      elsif @options =~ LangCaption
        @lang = Regexp.last_match(1)
        @caption = "<figcaption><span>#{Regexp.last_match(2)}</span></figcaption>"
      end

      str = str.gsub(/^( {4}|\t)/, '') if str.match(/\A( {4}|\t)/)
      if @lang.nil? || @lang == 'plain'
        code = HighlightCode.tableize_code(str.gsub('<', '&lt;').gsub('>', '&gt;'))
        "<figure class='code'>#{@caption}#{code}</figure>"
      elsif @lang.include? '-raw'
        raw = "``` #{@options.sub('-raw', '')}\n"
        raw += str
        raw += "\n```\n"
      else
        code = HighlightCode.highlight(str, @lang)
        "<figure class='code'>#{@caption}#{code}</figure>"
      end
    end
  end
end
