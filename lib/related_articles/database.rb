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
              properties: [
                {
                  name: "title",
                  dataType: [ "string" ],
                  description: "The title of the post"
                },
                {
                  name: "path",
                  dataType: [ "string" ],
                  description: "The relative path to the post"
                },
                {
                  name: "date",
                  dataType: [ "date" ],
                  description: "The date of the post"
                },
              ],
              # Possible values: 'text2vec-cohere', 'text2vec-openai', 'text2vec-huggingface', 'text2vec-transformers', 'text2vec-contextionary', 'img2vec-neural', 'multi2vec-clip', 'ref2vec-centroid'
              vectorizer: "text2vec-openai"
            )
        end
    end
end