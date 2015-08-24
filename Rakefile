#!/usr/bin/env rake

desc 'Initial setup'
task :bootstrap do
  puts 'Installing Bundle...'
  puts `bundle install`
end

desc 'Builds the site locally'
task :build do
  puts 'Building site.'
  puts `PRODUCTION="YES" bundle exec jekyll build -d _gh-pages`
end

# Deprecated, but leaving shortcut in because I'm sure Orta, at least, has this
# in his muscle-memory.
task :init => :bootstrap

namespace :serve do
  desc 'Runs a local server *with* draft posts and watches for changes'
  task :drafts do
    puts 'Starting the server locally on http://localhost:4000'
    sh 'PRODUCTION="NO" bundle exec jekyll serve --watch --drafts --port 4000'
  end

  desc 'Runs a local server *without* draft posts and watches for changes'
  task :published do
    puts 'Starting the server locally on http://localhost:4000'
    sh 'PRODUCTION="NO" bundle exec jekyll serve --watch --port 4000'
  end
end

desc 'Runs a local server with draft posts and watches for changes'
task :serve => 'serve:drafts'

desc 'Deploy the site to the gh_pages branch and push'
task :deploy do
  FileUtils.rm_rf '_gh-pages'
  puts 'Cloning master branch...'
  url = `git ls-remote --get-url origin`
  puts `git clone #{url.strip} _gh-pages`
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

  desc 'Run on Travis only; deploys the site when built on the master branch'
  task :travis do
    branch = ENV['TRAVIS_BRANCH'] # Ensure this command is only run on Travis.
    pull_request = ENV['TRAVIS_PULL_REQUEST'] #Ensure this command is only not run on pull requests

    abort 'Must be run on Travis' unless branch

    if pull_request != 'false'
      puts 'Skipping deploy for pull request; can only be deployed from master branch.'
      exit 0
    end

    if branch != 'master'
      puts "Skipping deploy for #{ branch }; can only be deployed from master branch."
      exit 0
    end

    Rake::Task['deploy'].invoke
  end
end

desc 'Defaults to serve:drafts'
task :default => 'serve:drafts'
