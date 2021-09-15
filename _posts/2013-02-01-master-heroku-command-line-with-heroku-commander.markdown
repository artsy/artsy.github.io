---
layout: post
title: Master the Heroku CLI with Heroku Commander
date: 2013-02-01 21:21
comments: true
categories: [Heroku, Shell, Rake]
author: db
---

<img src="/images/2013-02-01-master-heroku-command-line-with-heroku-commander/heroku-commander.png">

Heroku users frequently run the **heroku** command-line tool that ships with the [Heroku Toolbelt](https://toolbelt.heroku.com/). It has two very convenient features: it will remember API credentials and default to the "heroku" GIT remote to figure out the application to connect to. Neither of these features are available in the Heroku client API, so it's not unusual to find developers invoke the Heroku CLI from Rake tasks and other automation scripts.

There're several problems with using the Heroku CLI for automation:

1. The exit code from `heroku run` is not the exit code from the process being run on Heroku. See [#186](https://github.com/heroku/heroku/issues/186).
2. Gathering console output from `heroku run:detached` requires an external `heroku logs --tail` process that will never finish.

The [heroku-commander](https://github.com/dblock/heroku-commander) gem wraps execution of the Heroku CLI to overcome these common limitations.

<!-- more -->

### Heroku Configuration

```ruby
commander = Heroku::Commander.new
# a hash of all settings for your default heroku app
commander.config
```

Notice that unlike `Heroku::Client.new`, this doesn't require your e-mail or API key. It will invoke `heroku config -s`.

You can specify an application name, too.

```ruby
commander = Heroku::Commander.new({ :app => "heroku-commander" })
# a hash of all settings for the heroku-commander application
commander.config
```

### Run Commands on Heroku

```ruby
commander = Heroku::Commander.new
# returns all output lines
# eg. [ "Linux 2.6.32-348-ec2 #54-Ubuntu SMP x86_64 GNU" ]
commander.run "uname -a"
```

This calls `(heroku run 2>&1 uname -a; echo rc=\\$?)`, parses output for the final exit code line and raises an exception if the run's result code wasn't zero. In other words, if the command fails, an error is raised, which makes this suitable for Rake tasks.

You can also read output line-by-line.

```ruby
commander.run "ls -1" do |line|
  # each line from the output of ls -1
end
```

### Detach Commands on Heroku

```ruby
commander = Heroku::Commander.new
commander.run("ls -R", { :detached => true }) do |line|
  # each line from the output of ls -r -1
end
```

This calls `(heroku detached:run ls -r -1 2>&1; echo rc=\\$?)`, parses the output for a Heroku process ID, spawns a `heroku logs --tail -p pid` and monitors the log output until it reports process completion. It will also parse output for the final exit code and raise an exception if the run's result code wasn't zero.

### More Examples

There're more working examples [here](https://github.com/dblock/heroku-commander/tree/master/examples).
