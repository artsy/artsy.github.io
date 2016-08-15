# encoding: utf-8
#

module Jekyll

  # The SeriesIndex class creates a single series page for all their posts.
  class SeriesIndex < Page

    # Initializes a new SeriesIndex.
    #
    #  +base+       is the String path to the <source>.
    #  +series_dir+ is the String path between <source> and the series folder.
    #  +series+     is the series currently being processed.
    #  +posts+      posts in the series.
    def initialize(site, base, series_dir, series, posts, authors)
      @site = site
      @base = base
      @dir  = series_dir
      @name = 'index.html'
      process(@name)

      # Read the YAML data from the layout page.
      read_yaml(File.join(base, '_layouts'), 'series_index.html')
      data['series'] = series
      data['posts'] = posts
      data['authors'] = authors

      # Set the title for this page.
      title_prefix             = 'Series: '
      self.data['title']       = "#{title_prefix}#{series}"

      # Set the meta-description for this page.
      meta_description_prefix  = 'series: '
      self.data['description'] = "#{meta_description_prefix}#{series}"
    end
  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  class Site

    attr_accessor :series_posts

    # Creates an instance of SeriesIndex for each series page, renders it, and
    # writes the output to a file.
    #
    #  +series_prefix+ is the String path to the series folder.
    #  +series+     is the series currently being processed.
    def write_series_index(series_prefix, series, posts, authors)
      index = SeriesIndex.new(self, source, series_prefix, series, posts, authors)
      index.render(layouts, site_payload)
      index.write(dest)

      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      pages << index
    end

    # Loops through the list of series pages and processes each one.
    def write_series_indexes
      series_posts = {}

      series = posts.flat_map { |p| p.data["series"] }.compact.uniq
      series.each do |name|
        safe_name = name.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase
        path = File.join("series", safe_name)
        this_series_posts = posts.select { |p| p.data["series"] == name }
        series_posts[name] = this_series_posts

        authors =  this_series_posts.map { |p| p.data["author"] }.flatten.uniq.map { |key| self.config['authors'][key] }
        write_series_index(path, name, series_posts, authors)
      end
    end

  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the series pages.
  class GenerateSeries < Generator
    safe true
    priority :low

    def generate(site)
      site.write_series_indexes if ENV["PRODUCTION"] == "YES"
    end
  end


  # Adds some extra filters used during the series creation process.
  module Filters

    # # Outputs a list of seriess as comma-separated <a> links. This is used
    # # to output the series list for each post on a series page.
    # #
    # #  +seriess+ is the list of seriess to format.
    # #
    # # Returns string
    # #
    # def series_link(series)
    #   dir = @context.registers[:site].config['series_dir']
    #   "<a class='series' href='/#{dir}/#{series.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase}/'>#{item}</a>"
    # end

    # # Outputs the post.date as formatted html, with hooks for CSS styling.
    # #
    # #  +date+ is the date object to format as HTML.
    # #
    # # Returns string
    # def date_to_html_string(date)
    #   result = '<span class="month">' + date.strftime('%b').upcase + '</span> '
    #   result += date.strftime('<span class="day">%d</span> ')
    #   result += date.strftime('<span class="year">%Y</span> ')
    #   result
    # end

  end

end
