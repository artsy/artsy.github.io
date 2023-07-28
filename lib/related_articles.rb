require_relative './related_articles/database'

module RelatedArticles
    def self.client
        @client ||= Weaviate::Client.new(
            url: ENV['WEAVIATE_URL']
        )
    end
end
