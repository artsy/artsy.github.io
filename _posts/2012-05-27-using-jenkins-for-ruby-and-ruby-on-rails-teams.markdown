---
layout: post
title: Using Jenkins for Ruby and Ruby-on-Rails Teams
date: 2012-05-27 08:15
comments: true
categories: [Jenkins, Automation, Testing]
author: db
---
The [Jenkins CI](http://jenkins-ci.org) project has grown tremendously in the past few months. There're now hundreds of plugins and an amazing engaged community. Artsy is a happy user and proud contributor to this effort with the essential [jenkins-ansicolor plugin](https://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin), eliminating boring console output since 2011.

We are a continuous integration, deployment and devops shop and have been using Jenkins for over a year now. We've shared our experience at the [Jenkins User Conference 2012](http://www.cloudbees.com/juc2012.cb) in [a presentation](http://www.slideshare.net/dblockdotorg/graduating-to-jenkins-ci-for-rubyonrails-teams). This blog post is an overview of how to get started with Jenkins for Ruby(-on-Rails) teams.

![/images/2012-05-27-using-jenkins-for-ruby-on-rails-teams/jenkins.png](Artsy Jenkins CI)

<!-- more -->

When Artsy had only three engineers, we hesitated to deploy Jenkins. The CI server was written in Java (i.e. wasn't written in Ruby). We feared introducing excessive infrastructure too early. In retrospect, we were not in the business of building CI infrastructure, so not using Jenkins was a mistake. Since we adopted it, Jenkins has been operating painlessly and scaled nicely as our needs continued to grow.

Today, we run a single virtual server on [Linode](http://www.linode.com) as our master Jenkins and have 8 Linode slaves. These are all $19 per month plans. Our usage is variable: few builds in the middle of the night and a very high number of builds during the day, so we're planning on trying to build a Jenkins-slave on-demand system on AWS eventually.

Setting up a Jenkins master is straightforward.

``` bash
useradd -m jenkins -p [password] -s /bin/bash
addgroup jenkins sudo
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add –
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo aptitude update
sudo aptitude install jenkins
```

We change Jenkins port in `/etc/default/jenkins`, add the machine to DNS and update the Jenkins URL to an externally visible one in the "Manage Jenkins", "Configure System" menu. We enable and use "Matrix-Based Security" with a single user that all developers share and give the user permission to do everything in the same UI. Finally, we configure the Git Plugin with a global username and e-mail from our shared IT account that has Github access, setup a Github Web Hook and SMTP E-Mail notifications. Restarting Jenkins from the command line with `sudo service jenkins restart` completes the initial setup.

It's also a good idea to setup Jenkins configuration backup with [thinBackup](https://wiki.jenkins-ci.org/display/JENKINS/thinBackup), install [AnsiColor](http://wiki.jenkins-ci.org/display/JENKINS/AnsiColor+Plugin) and, of course, enable [Chuck Norris](http://wiki.hudson-ci.org/display/HUDSON/ChuckNorris+Plugin).

A typical Ruby development environment includes [RVM](https://rvm.io/), a working GIT client and a Github SSH key. We install these under our `jenkins` user manually on the first slave Linode and then clone slaves when we need more. RVM setup includes entries in `~/.bash_profile`, so a Jenkins job for a Ruby project can load that file and execute commands, including `rake`.

``` bash
#!/bin/bash
source ~/.bash_profile
rvm use 1.9.2
gem install bundler
bundle install
bundle exec rake
```

Our default Ruby project Rake task is `test:ci`. We run Jasmine and Capybara tests using a real browser, so we need to redirect all visible output to an X-Windows Virtual Frame Buffer ([XVFB](http://www.xfree86.org/4.0.1/Xvfb.1.html)). This can be done by setting an `ENV` variable inside a Rake task. Our test target also [organizes our tests in suites](http://artsy.github.com/blog/2012/05/15/how-to-organize-over-3000-rspec-specs-and-retry-test-failures/).

``` ruby
namespace :test do
  task :specs, [ :display ] => :environment do |t, args|
   ENV['DISPLAY'] = args[:display] if args[:display]
   Rake::Task['spec:suite:all'].invoke
  end
      
  task :jasmine, [ :display ] => :environment do |t, args|
    ENV['DISPLAY'] = args[:display] if args[:display]
    system!("bundle exec rake jasmine:ci")
  end
    
  task :all, [ :display ] => :environment do |t, args|
    Rake::Task['assets'].invoke
    Rake::Task['test:jasmine'].invoke(args[:display])
    Rake::Task['test:specs'].invoke(args[:display])
  end
      
  task :ci do
    Rake::Task['test:all'].invoke(":99")
  end
      
end
```

A successful CI test run will trigger a deployment to a staging environment on Heroku.

``` ruby
namespace :deploy do
  task :staging => :environment do
    system!("bundle exec heroku maintenance:on --app=app-staging")
    system!("git push git@heroku.com:app-staging.git origin/staging:master")
    system!("bundle exec heroku maintenance:off --app=app-staging")
  end
end
```

You'll notice that we execute system commands with `system!`. Unlike the usual `system` method, our wrapper raises an exception when a command returns a non-zero error code to abort execution.

``` ruby
def system!(cmdline)
  logger.info("[#{Time.now}] #{cmdline}")
  rc = system(cmdline)
  "failed with exit code #{$?.exitstatus}" if (rc.nil? || ! rc || $?.exitstatus != 0)
end
```

Our production deployment task is also a Jenkins job.

``` ruby
namespace :deploy do
  task :production => :environment do
    system!("git push git@heroku.com:app-production.git origin/production:master")
  end
end
```

We don't want any downtime on our production environment, so we don't turn Heroku maintance on. Our staging deployment task also includes copying production data to staging, so we chose to enable maintenance to avoid people hitting the test environment while it's being built and may be in a half-baked state.

Finally, we also run production daily cron-like tasks via Jenkins. It gives us email notifications, console output and the ability to manually trigger them. Centralizing operations in the same environment as CI creates truly continuous integration, deployment and operations.
