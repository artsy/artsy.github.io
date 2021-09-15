---
layout: post
title: 'Beyond Heroku: "Satellite" Delayed Job Workers on EC2'
date: 2012-01-31 11:45
comments: true
categories: [Heroku, EC2, Fog, Chef]
author: joey
---

[TL;DR: To supplement Heroku-managed app servers, we launched custom EC2 instances to host Delayed Job worker processes. See the [satellite_setup github repo](https://github.com/joeyAghion/satellite_setup) for rake tasks and Chef recipes that make it easy.]

[Artsy](http://artsy.net) engineers are big users and abusers of [Heroku](http://heroku.com). It's a neat abstraction of server resources, so we were conflicted when parts of our application started to bump into Heroku's limitations. While we weren't eager to start managing additional infrastructure, we found that--with a few good tools--we could migrate some components away from Heroku without fragmenting the codebase or over-complicating our development environments.

There are a number of reasons your app might need to go beyond Heroku. It might rely on a locally installed tool (not possible on Heroku's locked-down servers), or require heavy file-system usage (limited to `tmp/` and `log/`, and not permanent or shared). In our case, the culprit was Heroku's 512 MB RAM limit--reasonable for most web processes, but quickly exceeded by the image-processing tasks of our [delayed_job](https://github.com/collectiveidea/delayed_job) workers. We considered building a specialized image-processing service, but decided instead to supplement our web apps with a custom [EC2](http://aws.amazon.com/ec2/) instance dedicated to processing background tasks. We call these servers "satellites."

We'll walk through the pertinent sections here, but you can find Rake tasks that correspond with these scripts, plus all of the necessary cookbooks, in the [satellite_setup github repo](https://github.com/joeyAghion/satellite_setup). Now, on to the code!

First, generate a key-pair from [Amazon's AWS Management Console](https://console.aws.amazon.com/ec2/home?#s=KeyPairs). Then we'll use [Fog](http://fog.io) to spawn the EC2 instance.

``` ruby
require 'fog'

# Update these values according to your environment...
S3_ACCESS_KEY_ID = 'XXXXXXXXXXXXXXXXXXXX'
S3_SECRET_ACCESS_KEY = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
KEY_NAME = 'satellite_keypair'
KEY_PATH = "#{ENV['HOME']}/.ssh/#{KEY_NAME}.pem"
IMAGE_ID = 'ami-c162a9a8'  # 64-bit Ubuntu 11.10
FLAVOR_ID = 'm1.large'

connection = Fog::Compute.new(provider: 'AWS',
  aws_access_key_id: S3_ACCESS_KEY_ID,
  aws_secret_access_key: S3_SECRET_ACCESS_KEY)

server = connection.servers.bootstrap(
  key_name: KEY_NAME,
  private_key_path: KEY_PATH,
  image_id: IMAGE_ID,
  flavor_id: FLAVOR_ID)
```

Next, we'll do some basic server prep and install our preferred Ruby version.<!-- more --> We'll again use Fog, this time to SSH into the new instance and run the following commands:

``` ruby
[ %{sudo sh -c "grep '^[^#].*us-east-1\.ec2' /etc/apt/sources.list | sed 's/us-east-1\.ec2/us/g' > /etc/apt/sources.list.d/better.list"},
  %{sudo apt-get update; sudo apt-get install -y make gcc rsync curl zlib1g-dev libssl-dev libreadline-dev libreadline5},
  %{mkdir -p /tmp/bootstrap},
  %{cd /tmp/bootstrap && curl -L 'ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz' | tar xvzf - && cd ruby-1.9.2-p290 && ./configure && make && sudo make install},
  %{cd /tmp/bootstrap && curl -L 'http://production.cf.rubygems.org/rubygems/rubygems-1.6.2.tgz' | tar xvzf - && cd rubygems* && sudo ruby setup.rb --no-ri --no-rdoc},
  %{sudo gem install rdoc chef ohai --no-ri --no-rdoc --source http://gems.rubyforge.org}
].each do |command|
  server.ssh command
end
```

The first command replaces some broken links in the AMI's `/etc/apt/sources.list`, so that the later package installation commands have a chance. We then install a few necessary packages, download and install Ruby 1.9.2 from source, and install RubyGems. Finally, we install [Chef](http://www.opscode.com/chef/) so we can let `chef-solo` drive the remainder of the configuration (and manage it going forward).

Chef deserves a few blog posts of its own, but know that it provides a platform-independent DSL for specifying an environment's configuration. [Opscode](http://www.opscode.com) supplies a deep set of related tools, but for our purposes, `chef-solo`--which applies a local set of configuration "cookbooks" to an individual server--will be plenty. These lines copy our local cookbooks folder (originally in `config/satellite`) up to a temporary location on the server, then execute the `chef-solo` command via SSH:

``` ruby
system "rsync -rlP --rsh=\"ssh -i #{KEY_PATH}\" --delete --exclude '.*' ./config/satellite ubuntu@#{server.dns_name}:/tmp/chef/"
server.ssh "cd /tmp/chef/satellite; RAILS_ENV=staging sudo -H -E chef-solo -c solo.rb -j configure.json -l info"
```

The first file referenced in that command simply declares where cookbooks will be found. In our case, they're stored alongside `solo.rb` in the temporary directory.

```ruby config/satellite/solo.rb
cookbook_path File.expand_path(File.join(File.dirname(__FILE__), "cookbooks"))
```

The next file, `configure.json`, specifies that Chef should apply the `configure` recipe found in the `example_app` cookbook.

```javascript config/satellite/configure.json
{"recipes": ["example_app::configure"]}
```

Finally, let's look at the `example_app::configure` recipe. First it will make sure necessary packages and gems are installed. These, of course, might be different for your app.

```ruby config/satellite/cookbooks/example_app/recipes/configure.rb
[ 'build-essential',
  'binutils-doc',
  'autoconf',
  'flex',
  'bison',
  'openssl',
  'libreadline5',
  'libreadline-dev',
  'git-core',
  'zlib1g',
  'zlib1g-dev',
  'libssl-dev',
  'libxml2-dev',
  'autoconf',
  'libxslt-dev',
  'imagemagick',
  'libmagick9-dev'
].each do |pkg|
  package(pkg)
end

gem_package 'bundler' do
  version '1.0.10'
end
```

Next, it will ensure that a user and group (named for `example_app`) are created and configured:

``` ruby config/satellite/cookbooks/example_app/recipes/configure.rb (cont'd)
group 'example_app'

user 'example_app' do
  gid 'example_app'
  home '/home/example_app'
  shell '/bin/bash'
  supports :manage_home => true
end

directory '/home/example_app/.ssh' do
  owner 'example_app'
  group 'example_app'
  mode 0700
end

# Ensure example_app can sudo
cookbook_file '/etc/sudoers.d/example_app' do
  mode 0440
end

[ 'authorized_keys',  # place the keys you want to authorize for SSH in this file
  'id_dsa',  # a new private key file, authorized to pull from your git repo
   'config'  # avoid prompt when pulling from github
].each do |config_file|
  cookbook_file "/home/example_app/.ssh/#{config_file}" do
    owner 'example_app'
    group 'example_app'
    mode 0600
  end
end

# Allow other developers to SSH as primary ubuntu account as well.
cookbook_file "/home/ubuntu/.ssh/authorized_keys" do
  owner 'ubuntu'
  group 'ubuntu'
  mode 0600
end
```

Next, it creates supporting directories.

``` ruby config/satellite/cookbooks/example_app/recipes/configure.rb (cont'd)
[ '/app',
  '/app/example_app',
  '/app/example_app/shared',
  '/app/example_app/shared/log',
  '/app/example_app/shared/pids',
  '/app/example_app/shared/config'
].each do |dir|
  directory dir do
    owner 'example_app'
    group 'example_app'
    mode 0755
  end
end
```

We rely heavily on the [New Relic](http://newrelic.com/) plug-in, and want to enable it in our custom environment as well. Heroku usually takes care of injecting a `newrelic.yml` configuration file into our app servers, so we'll have to replicate that in our custom environment. Depending on what plug-ins you've enabled (e.g., [Sendgrid](http://sendgrid.com)), you might need to replicate other configuration files or initializers.

``` ruby config/satellite/cookbooks/example_app/recipes/configure.rb (cont'd)
cookbook_file "/app/example_app/shared/config/newrelic.yml" do
  owner 'example_app'
  group 'example_app'
  mode 0755
end
```

[Monit](http://mmonit.com/monit/) is a great tool for starting, managing, and monitoring long-running processes. It can be configured with all sorts of thresholds and alerting. (We've included only a simple configuration in the [github repo](https://github.com/joeyAghion/satellite_setup) for now.) Let's include the `monit` recipe, to ensure that monit is installed and running, and then add the necessary configuration for monit to start and monitor our delayed_job worker process.

``` ruby config/satellite/cookbooks/example_app/recipes/configure.rb (cont'd)
include_recipe 'monit'
monitrc 'delayed_job', {}, :immediately
```

To keep disk space from becoming a problem, we'll automatically rotate all of the logs in our app's shared `log/` directory.

``` ruby config/satellite/cookbooks/example_app/recipes/configure.rb (cont'd)
logrotate_app "example_app" do
  path "/app/example_app/shared/log/*.log"
  frequency "daily"
  rotate 30
end

include_recipe 'example_app::deploy'
```

That last line loads up the neighboring `deploy.rb` recipe, which is responsible for checking out the appropriate version of the codebase to the server and [re]starting the delayed_job worker:

```ruby config/satellite/cookbooks/example_app/deploy.rb
deploy "/app/example_app" do

  repo "git@github.com:my_org/example_app.git"  # update this!
  branch node['rails_env']  # assumes a branch named for this RAILS_ENV (e.g., staging, production)
  shallow_clone true
  environment node['rails_env']
  symlinks 'pids' => 'tmp/pids', 'log' => 'log', 'config/newrelic.yml' => 'config/newrelic.yml'
  before_restart do
    current_release = release_path
    execute("bundle install --without development test") do
      cwd current_release
      user 'example_app'
      group 'example_app'
      environment 'HOME' => '/home/example_app'
    end
  end
  restart_command { execute "monit restart delayed_job" }
  user 'example_app'
  group 'example_app'

end
```

The `deploy` Chef command creates a new timestamped directory under `/app/example_app/releases` and cleans up any older release directories, leaving the most recent 5 (much in the style of [Capistrano](https://github.com/capistrano/capistrano)). It also symlinks necessary directories and files and restarts the delayed_job worker.

Did you notice how we ensure that Heroku and the satellite use the same version of the codebase? We've formalized `staging` and `production` branches and update them with the commits we intend to deploy. Of course, we can't simply `git push heroku master` anymore. Instead, we push to the appropriate branch, then push that to heroku and re-run the satellite's `deploy` recipe. Here, we've wrapped the process up into a single `deploy:[staging|production]` rake task. (The precise branches might vary depending on your development workflow.)

``` ruby lib/tasks/deploy.rake
namespace :deploy do
  desc 'Merge master into a staging branch and deploy it to example_app-staging.'
  task :staging => 'git:tag:staging' do
    puts `git push git@heroku.com:example_app-staging.git origin/staging:master`
    ENV['RAILS_ENV'] = 'staging'
    task('satellite:deploy').invoke
  end

  desc 'Merge staging into a production branch and deploy it to example_app-production.'
  task :production => 'git:tag:production' do
    puts `git push git@heroku.com:example_app-production.git origin/production:master`
    ENV['RAILS_ENV'] = 'production'
    task('satellite:deploy').invoke
  end
end

namespace :git do
  task :tag, [:from, :to] => :confirm_clean do |t, args|
    raise "Must specify 'from' and 'to' branches" unless args[:from] && args[:to]
    `git fetch`
    `git branch -f #{args[:to]} origin/#{args[:to]}`
    `git checkout #{args[:to]}`
    `git reset --hard origin/#{args[:from]}`
    puts "Updating #{args[:to]} with these commits:"
    puts `git log origin/#{args[:to]}..#{args[:to]} --format=format:"%h  %s  (%an)"`
    `git push -f origin #{args[:to]}`
    `git checkout master`
    `git branch -D #{args[:to]}`
  end

  task :confirm_clean do
    raise "Must have clean working directory" unless `git status` =~ /working directory clean/
  end

  namespace :tag do
    task :staging do
      task('git:tag').invoke('master',  'staging')
    end
    task :production do
      task('git:tag').invoke('staging', 'production')
    end
  end
end
```

Our satellite requires access to some of the same environment variables as our Heroku web apps (such as a database host or mail server credentials). To keep these synchronized, we rely on a `config/heroku.yml` file. (This duplication is an obvious hazard and deserves improvement, but we've actually found it convenient to have these locally for easy access from Rake tasks, etc.)

In the [satellite_setup](https://github.com/joeyAghion/satellite_setup) github repo, we've simplified this set-up into a few tasks that we use on an ongoing basis:
``` bash
$ rake satellite:spawn RAILS_ENV=staging
$ rake satellite:configure RAILS_ENV=staging
$ rake satellite:info RAILS_ENV=staging
	1 satellite server(s)
		state: running (1)
			i-f4583196	staging	ec2-170-179-113-159.compute-1.amazonaws.com	2012-01-03 14:48:11 UTC
$ rake satellite:deploy RAILS_ENV=staging
$ rake satellite:destroy RAILS_ENV=staging
```

This arrangement has worked for us so far. Satellite servers cost a little more, but can benefit from arbitrary customization and are served out of the same data-centers as our Heroku-based web apps and S3 storage. Since the same app is running transparently in 2 different environments, our developers' workflow has hardly needed modification. In fact, the portability enforced by Heroku's design (elaborated in [The Twelve-Factor App](http://12factor.net)) made this transition relatively straightforward.

Some worthy enhancements might be:

* Improving monitoring and notifications
* Extending the recipes to manage multiple parallel workers
* Using Chef attributes to replace uses of `example_app` with a parameter
* Cleaning up the duplication of Heroku configuration values in `heroku.yml`
