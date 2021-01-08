#!/usr/bin/env rake

desc 'Initial setup'
task :bootstrap do
  puts 'Installing Bundle...'
  puts `bundle install --without distribution`
end

desc 'Builds the site locally'
task :build do
  puts 'Building site.'
  sh 'PRODUCTION="YES" jekyll build --destination _gh-pages'
  sh 'PRODUCTION="YES" jekyll build --destination _gh-pages'
end

namespace :podcast do
  desc 'Adds a new '
  task :new_episode do
    require 'mp3info'
    require 'pathname'
    require 'aws-sdk'

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
  puts 'Cloning master branch...'
  puts `git clone https://github.com/artsy/artsy.github.io.git _gh-pages`
  Dir.chdir('_gh-pages') do
    puts `git checkout master`
  end

  Dir.chdir('_gh-pages') do
    puts 'Pulling changes from server.'
    puts `git reset --hard`
    puts `git clean -xdf`
    puts `git checkout master`
    puts `git pull origin master`
  end

  Rake::Task['build'].invoke

  Dir.chdir('_gh-pages') do
    puts 'Pulling changes from server.'
    puts `git checkout master`
    puts `git pull origin master`

    puts 'Creating a commit for the deploy.'

    puts `git ls-files --deleted -z | xargs -0 git rm;`
    puts `git add .`
    puts `git commit -m "Deploy"`

    puts 'Pushing to github.'
    puts `git push --quiet > /dev/null 2>&1`
  end
end

namespace :deploy do

  namespace :travis do
    task :checks do
      branch = ENV['TRAVIS_BRANCH'] # Ensure this command is only run on Travis.
      abort 'Must be run on Travis.' unless branch
      abort "Skipping deploy for non-source branch #{branch}." if branch != 'source'

      pull_request = ENV['TRAVIS_PULL_REQUEST'] #Ensure this command is only not run on pull requests
      abort 'Skipping deploy from pull request.' if pull_request != 'false'
    end

    task :github_setup do
      puts `git config --global user.email #{ENV['GIT_EMAIL']}`
      puts `git config --global user.name #{ENV['GIT_NAME']}`
      File.open("#{ENV['HOME']}/.netrc", 'w') { |f| f.write("machine github.com login #{ENV['GH_TOKEN']}") }
      puts `chmod 600 ~/.netrc`
    end
  end

  desc 'Run on Travis only; deploys the site when built on the source branch'
  task :travis => ['deploy:travis:checks', 'deploy:travis:github_setup', :deploy]
end

desc 'Defaults to serve:drafts'
task :default => 'serve:drafts'
