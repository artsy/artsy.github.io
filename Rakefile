#!/usr/bin/env rake

require 'ruby/openai'

desc 'Initial setup'
task :bootstrap do
  puts 'Installing Bundle...'
  puts `bundle install --without distribution`
end

desc 'Builds the site locally'
task :build do
  puts 'Building site.'
  sh 'PRODUCTION="YES" bundle exec jekyll build --destination _gh-pages'
end

namespace :podcast do
  desc 'Adds a new '
  task :new_episode do
    require 'mp3info'
    require 'pathname'
    require 'aws-sdk-s3'

    mp3_path = ARGV.last
    file_name = File.basename(mp3_path)

    abort 'Please specify a path to the MP3.' if mp3_path.nil?
    abort 'Please use a filename without spaces.' if file_name.include?(' ')

    duration = ''
    Mp3Info.open(mp3_path) do |mp3|
      duration = Time.at(mp3.length).utc.strftime("%H:%M:%S")
    end
    filesize = File.stat(mp3_path).size

    puts 'Uploading episode to S3 bucket.'
    s3 = Aws::S3::Resource.new(region: 'us-east-1')
    s3_upload = s3.bucket('artsy-engineering-podcast').object(file_name)
    abort "Upload failed." unless s3_upload.upload_file(mp3_path)
    puts 'Upload completed.'

    output = <<-EOS
    - title: ""
      date: "#{Time.new.to_s}"
      description: ""
      url: "#{s3_upload.public_url}"
      file_byte_length: "#{filesize}"
      duration: "#{duration}"
      credits: ""
      links:
        - title: "links are optional"
          url: "https://TODO"
        - title: "please remove the links property if there are none"
          url: "https://TODO"
EOS

    File.open('_config.yml', 'a') do |file|
      file.write(output)
    end

    puts 'Updated _config.yml with new episode. Please configure.'
    sh 'open _config.yml'
  end
end

# Deprecated, but leaving shortcut in because I'm sure Orta, at least, has this
# in his muscle-memory.
task :init => :bootstrap

namespace :serve do
  def run_server(extra_flags = "")
    jekyll = Process.spawn('PRODUCTION="NO" bundle exec jekyll serve --watch --port 4000 ' + extra_flags)
    trap("INT") {
      Process.kill(9, jekyll) rescue Errno::ESRCH
      exit 0
    }
    Process.wait(jekyll)
  end

  desc 'Runs a local server *with* draft posts and watches for changes'
  task :drafts do
    puts 'Starting the server locally on http://localhost:4000'
    run_server '--drafts'
  end

  desc 'Runs a local server *without* draft posts and watches for changes'
  task :published do
    puts 'Starting the server locally on http://localhost:4000'
    run_server
  end
end

desc 'Runs a local server with draft posts and watches for changes'
task :serve => 'serve:drafts'

desc 'Deploy the site to the gh_pages branch and push'
task :deploy do
  FileUtils.rm_rf '_gh-pages'
  puts 'Cloning main branch...'
  puts `git clone https://github.com/artsy/artsy.github.io.git _gh-pages`
  Dir.chdir('_gh-pages') do
    puts `git checkout main`
  end

  Dir.chdir('_gh-pages') do
    puts 'Pulling changes from server.'
    puts `git reset --hard`
    puts `git clean -xdf`
    puts `git checkout main`
    puts `git pull origin main`
  end

  Rake::Task['build'].invoke

  Dir.chdir('_gh-pages') do
    puts 'Pulling changes from server.'
    puts `git checkout main`
    puts `git pull origin main`

    puts 'Creating a commit for the deploy.'
    puts `git add --all`
    puts `git commit -m "[skip ci] Deploy"`

    puts 'Pushing to github.'
    puts `git push`
  end
end

desc 'Defaults to serve:drafts'
task :default => 'serve:drafts'

namespace :related_articles do
  desc "Vectorizes the posts via OpenAI's embedding API"
  task :vectorize do
    BATCH_SIZE = 20
    CHAR_LIMIT = 32000

    client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

    vectors = {}

    files = Dir.glob('_posts/*.{md,markdown}').sort #.take(10)

    path_from_file = -> (file){ file.sub(/_posts\/(.*)\.(md|markdown)/, '\1').sub(/^(\d{4})-(\d{2})-(\d{2})-/, '\1/\2/\3/') }
    body_from_file = -> (file){ File.read(file).split("---").last }
    title_from_file = -> (file){ File.read(file).split("---")[1].match(/title: (.*)/)[1].gsub(/^["'](.*)["']$/, '\1') }

    batch_index = 0
    total_batches = (files.length.to_f / BATCH_SIZE).ceil

    while (files.length > 0) do
      batch_index += 1
      batch = files.shift(BATCH_SIZE)

      paths = batch.map(&path_from_file)
      bodies = batch.map(&body_from_file)
      titles = batch.map(&title_from_file)

      texts = titles.zip(bodies).map{ |title, body| [title, body].join.slice(0, CHAR_LIMIT) }
      dates = paths.map{ |p| Date.parse(p.split("/").first(3).join("-")) }

      response = client.embeddings(
        parameters: {
          model: "text-embedding-ada-002",
          input: texts
        }
      )

      puts "#{batch_index} / #{total_batches} / #{bodies.map(&:length)}"

      begin
        embeddings = response["data"].map{ |obj| obj["embedding"] }

        if (embeddings.length != paths.length)
          raise "Mismatch between paths and embeddings!"
        end

        paths.zip(embeddings, titles, dates).each do |path, embedding, title, date|
          vectors[path] = {
            path: path,
            title: title,
            date: date,
            vector: embedding
          }
        end
      rescue => e
        pp response
        pp e
      end
    end

    data = vectors #.transform_values{ |v| v.length }

    File.open("./vectors.json", "w") do |f|
      f.write(JSON.pretty_generate(data))
    end
  end

  desc "Ingest the vectors into local Weaviate"
  task :ingest do
    client = Weaviate::Client.new

    schema = {
      class: "Post",
      description: "An Artsy blog post",

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
      ]
    }

    pp client.delete_schema("Post")
    pp client.create_schema(schema)

    vectors = JSON.parse(File.read("./vectors.json"))
    objects = vectors.map do |path, attrs|
      {
        class: "Post",
        properties: {
            path: attrs["path"],
            title: attrs["title"],
            date: [attrs["date"], "00:00:00Z"].join("T")
        },
        vector: attrs["vector"]
      }
    end

    BATCH_SIZE = 20
    batch_index = 0
    total_batches = (objects.length.to_f / BATCH_SIZE).ceil

    while (objects.length > 0) do
      batch_index += 1
      batch = objects.shift(BATCH_SIZE)

    #   payload = { objects: ≈ }
    #   cmd = "echo '#{payload.to_json}' | http post http://localhost:8080/v1/batch/objects"
    #   system cmd

      pp client.batch_create_objects(batch)
      pp batch.length
    end
  end

  desc "Cluster the posts"
  task :cluster do
    client = Weaviate::Client.new
    vectors = JSON.parse(File.read("./vectors.json"))
    output = {}
    vectors.each do |path, attrs|
      puts path
      neighbors = client.near(vector: attrs["vector"], certainty: 0.91, limit: 3)["data"]["Get"]["Post"]
      neighbors.reject!{ |n| n["path"] == path } # remove current post from list of neighbors
      related_articles = neighbors.map do |neighbor|
        {
          "path": neighbor["path"],
          "title": neighbor["title"],
          "certainty": neighbor["_additional"]["certainty"],
        }
      end
      output[path] = related_articles
    end

    File.open("./related-articles.json", "w") do |f|
      f.write(JSON.pretty_generate(output))
    end
  end

  task :client do
    client = Weaviate::Client.new

    schema = {
      class: "Post",
      description: "An Artsy blog post",

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
      ]
    }

    vectors = JSON.parse(File.read("./vectors.json"))
    length = vectors.to_a.length
    r = rand(length)

    attrs = vectors.to_a[r].last

    # pp client.delete_schema("Post")
    # pp client.create_schema(schema)
    # pp client.schema
    # pp client.batch_create_objects([])
    pp attrs.values_at("title", "date", "path")
    pp client.near(vector: attrs["vector"], certainty: 0.92, limit: 3)
  end
end

module Weaviate
  class Client
    def initialize(url = "http://localhost:8080/v1")
      @url = url
    end

    def schema
      HTTParty.get(api("/schema"))
    end

    def create_schema(schema)
      HTTParty.post(api("/schema"), body: schema.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    def delete_schema(name)
      HTTParty.delete(api("/schema/#{name}"))
    end

    def batch_create_objects(batch)
      HTTParty.post(api("/batch/objects"), body: { objects: batch }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    def near(vector:, certainty: 0.90, limit: 5)
      gql = <<~GQL
        query Near($vector: [Float]!, $certainty: Float!) {
          Get {
            Post(
              limit: #{limit}
              sort: [{path: ["date"], order: desc}]
              nearVector: {vector: $vector, certainty: $certainty}
            ) {
              title
              path
              date
              _additional {
                certainty
              }
            }
          }
        }
      GQL

      body = {
        query: gql,
        variables: {
          vector: vector,
          certainty: certainty
        }
      }

      HTTParty.post(api("/graphql"), body: body.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    private

    def api(path)
      @url + path
    end
  end
end
