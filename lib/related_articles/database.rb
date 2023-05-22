module RelatedArticles
  module Database
    def self.prepare
      client = RelatedArticles.client

      # Delete old index
      unless "Not Found" == client.schema.get(class_name: 'EngineeringBlogPost')
        client.schema.delete(class_name: 'EngineeringBlogPost')
      end

      # Create new index
      pp client.schema.create(
        class_name: "EngineeringBlogPost",
        description: "An Artsy engineering blog post",
        module_config: { "text2vec-openai": {vectorizeClassName: false} },
        properties: [
          # properties to vectorize
          {
            name: "title",
            dataType: [ "string" ],
            description: "The title of the post",
            "moduleConfig": { "text2vec-openai": { "skip": false } }
          },
          {
            name: "body",
            dataType: [ "string" ],
            description: "The plaintext body of the post",
            "moduleConfig": { "text2vec-openai": { "skip": false } }
          },
          # properties to skip for vectorizing
          {
            name: "path",
            dataType: [ "string" ],
            description: "The relative path to the post",
            "moduleConfig": { "text2vec-openai": { "skip": true } }
          },
          {
            name: "date",
            dataType: [ "date" ],
            description: "The date of the post",
            "moduleConfig": { "text2vec-openai": { "skip": true } }
          },
        ],
        # Possible values: 'text2vec-cohere', 'text2vec-openai', 'text2vec-huggingface', 'text2vec-transformers', 'text2vec-contextionary', 'img2vec-neural', 'multi2vec-clip', 'ref2vec-centroid'
        vectorizer: "text2vec-openai"
      )
    end

    def self.insert
      client = RelatedArticles.client
      all_articles = ArticleIterator.new

      all_articles.each_batch do |articles|
        print "." * articles.length

        objects = articles.map do |article|
          {
            class: "EngineeringBlogPost",
            properties: {
              title: article[:title],
              body: article[:body],
              path: article[:path],
              date: article[:date].rfc3339,
            }            
          }
        end
        client.objects.batch_create(objects: objects)
      end
      puts
    end
  end
end