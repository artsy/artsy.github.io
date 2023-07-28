require 'date'

class ArticleIterator
    BATCH_SIZE = 20

    def initialize
        @files = Dir.glob('_posts/*.{md,markdown}').sort #.take(20)
        @batch_index = 0
        @total_batches = (@files.length.to_f / BATCH_SIZE).ceil
    end

    def each_batch
        while (@files.length > 0) do
            @batch_index += 1
            files = @files.shift(BATCH_SIZE)

            batch = files.map do |file|
                {
                    path: get_path(file),
                    title: get_title(file),
                    date: get_date(file),
                    body: get_body(file)
                }
            end
            yield batch
        end
    end

    def get_path(file)
        file.sub(/_posts\/(.*)\.(md|markdown)/, '\1').sub(/^(\d{4})-(\d{2})-(\d{2})-/, '\1/\2/\3/')
    end

    def get_title(file)
        File.read(file).split("---")[1].match(/title: (.*)/)[1].gsub(/^["'](.*)["']$/, '\1')
    end

    def get_body(file)
        File.read(file).split("---").last
    end

    def get_date(file)
        Date.parse(get_path(file).split("/").first(3).join("-"))
    end
end