module Jekyll
  class CategoryPageGenerator < Generator
    safe true

    Category = Struct.new(:name, :count, :dir) do
      def to_liquid
        { 'name' => name, 'dir' => dir, 'count' => count }
      end
    end

    def generate(site)
      if site.layouts.key? 'category_index'
        dir = site.config['category_dir'] || 'categories'
        categories = []
        site.categories.each do |category, posts|
          categories << category = Category.new(category, posts.size, category.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase)
          site.pages << CategoryPage.new(site, site.source, File.join(dir, category.dir), category)
          site.pages << CategoryFeedPage.new(site, site.source, File.join(dir, category.dir), category.name)
        end
        site.pages << CategoryListPage.new(site, site.source, dir, categories)
      end
    end
  end

  # A Page subclass used in the `CategoryPageGenerator`
  class CategoryPage < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')
      self.data['category'] = category

      category_title_prefix = site.config['category_title_prefix'] || 'Category: '
      self.data['title'] = "#{category_title_prefix}#{category.name}"
    end
  end

  class CategoryListPage < Page
    def initialize(site, base, dir, categories)
      @site = site
      @base = base
      @dir  = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_list_page.html')
      self.data['title'] = "Categories"
      self.data['categories'] = categories
    end
  end

  # The CategoryFeed class creates an Atom feed for the specified category.
  class CategoryFeedPage < Page
    # Initializes a new CategoryFeed.
    #
    #  +base+         is the String path to the <source>.
    #  +category_dir+ is the String path between <source> and the category folder.
    #  +category+     is the category currently being processed.
    def initialize(site, base, category_dir, category)
      @site = site
      @base = base
      @dir  = category_dir
      @name = 'atom.xml'
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_includes'), 'category_feed.xml')
      self.data['category']    = category
      # Set the title for this page.
      title_prefix             = site.config['category_title_prefix'] || 'Category: '
      self.data['title']       = "#{title_prefix}#{category}"
      # Set the meta-description for this page.
      meta_description_prefix  = site.config['category_meta_description_prefix'] || 'Category: '
      self.data['description'] = "#{meta_description_prefix}#{category}"

      # Set the correct feed URL.
      self.data['feed_url'] = "#{category_dir}/#{name}"
    end

  end

  # Adds some extra filters used during the category creation process.
  module CategoryFilters
    # Outputs a list of categories as comma-separated <a> links. This is used
    # to output the category list for each post on a category page.
    #
    #  +categories+ is the list of categories to format.
    #
    # Returns string
    #
    def category_links(categories)
      dir = @context.registers[:site].config['category_dir']
      categories = categories.sort!.map do |item|
        "<a class='category' href='/#{dir}/#{item.gsub(/_|\P{Word}/, '-').gsub(/-{2,}/, '-').downcase}/'>#{item}</a>"
      end
      categories.join(', ')
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

Liquid::Template.register_filter(Jekyll::CategoryFilters)
