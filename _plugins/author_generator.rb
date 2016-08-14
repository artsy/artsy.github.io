# encoding: utf-8
#

module Jekyll

  # The AuthorIndex class creates a single author page for all their posts.
  class AuthorIndex < Page

    # Initializes a new AuthorIndex.
    #
    #  +base+         is the String path to the <source>.
    #  +author_dir+ is the String path between <source> and the author folder.
    #  +author+     is the author currently being processed.
    def initialize(site, base, author_dir, author)
      @site = site
      @base = base
      @dir  = author_dir
      @name = 'index.html'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'author_index.html')
      self.data['author']      = author
      # Set the title for this page.
      title_prefix             = 'Author: '
      self.data['title']       = "#{title_prefix}#{author}"
      # Set the meta-description for this page.
      meta_description_prefix  = 'author: '
      self.data['description'] = "#{meta_description_prefix}#{author}"
    end

  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  class Site

    def authors
      self.config['authors'].keys
    end

    # Creates an instance of authorIndex for each author page, renders it, and
    # writes the output to a file.
    #
    #  +author_dir+ is the String path to the author folder.
    #  +author+     is the author currently being processed.
    def write_author_index(author_dir, author)
      index = AuthorIndex.new(self, self.source, author_dir, author)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index
    end

    # Loops through the list of author pages and processes each one.
    def write_author_indexes
      if self.layouts.key? 'author_index'
        dir = self.config['author_dir'] || 'author'
        self.authors.each do |author|
          self.config['current_author'] = author
          self.write_author_index(File.join(dir, author.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase), author)
        end

      # Throw an exception if the layout couldn't be found.
      else
        throw "No 'author_index' layout found."
      end
    end

  end


  # Jekyll hook - the generate method is called by jekyll, and generates all of the author pages.
  class GenerateAuthors < Generator
    safe true
    priority :low

    def generate(site)
      if ENV["PRODUCTION"] == "YES"
        site.write_author_indexes
      end
    end

  end


  # Adds some extra filters used during the author creation process.
  module Filters

    # Outputs a list of authors as comma-separated <a> links. This is used
    # to output the author list for each post on a author page.
    #
    #  +authors+ is the list of authors to format.
    #
    # Returns string
    #
    def author_link(author)
      dir = @context.registers[:site].config['author_dir']
      "<a class='author' href='/#{dir}/#{author.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase}/'>#{item}</a>"
    end

    # Outputs the post.date as formatted html, with hooks for CSS styling.
    #
    #  +date+ is the date object to format as HTML.
    #
    # Returns string
    def date_to_html_string(date)
      result = '<span class="month">' + date.strftime('%b').upcase + '</span> '
      result += date.strftime('<span class="day">%d</span> ')
      result += date.strftime('<span class="year">%Y</span> ')
      result
    end

  end

end
