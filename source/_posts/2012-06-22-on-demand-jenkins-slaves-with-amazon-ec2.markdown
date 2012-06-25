---
layout: post
title: "On-Demand Jenkins Slaves with Amazon EC2"
date: 2012-06-22 15:28
comments: true
categories: [Jenkins, Testing, Continuous Integration, EC2]
author: Joey Aghion and Frank Macreery

---
The [Art.sy](http://art.sy) team faithfully uses [Jenkins](http://jenkins-ci.org) for continuous integration. [As we've described before](http://artsy.github.com/blog/2012/05/27/using-jenkins-for-ruby-and-ruby-on-rails-teams/), our Jenkins master and 8 slaves run on Linode. This arrangement has at least a few drawbacks:

* Our Linode servers are manually configured. They require frequent maintenance, and inconsistencies lead to surprising build failures.
* The fixed set of slaves don't match the pattern of our build jobs: jobs get backed up during the day, but servers are mostly unused overnight and on weekends.

The [Amazon EC2 Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Amazon+EC2+Plugin) allowed us to replace those slaves with a totally scripted environment. Now, slaves are spun up in the cloud whenever build jobs need them.

<!-- more -->

<!-- TODO steps for spawning instance -->

<!-- TODO AMI steps -->

<!-- TODO Jenkins configuration -->

<!-- TODO approach to labels (?) -->

## Outcome and Next Steps

This arrangement hasn't been in place for long, but we're excited about the benefits it's already delivered:

* Builds now take a predictable amount of time, since slaves automatically scale up to match demand.
* Slaves offer a more consistent and easily maintained configuration, so there are fewer spurious failures.
* Despite higher costs on EC2, we hope to spend about the same (or maybe even less) now that we'll need to operate only the master server during period of inactivity (like nights and weekends).

As proponents of _automating the hard stuff_, we get a real kick out of watching identical slaves spin up as builds trickle in each morning, then disappear as the queue quiets down in the evening. Still, there are a few improvements to be made:

* Our canonical slave's configuration should be scripted with [Chef](http://www.opscode.com/chef/). <!-- need more here -->
* Sharp-eyed readers will notice that our Jenkins master is still a Linode server. It might benefit from the same type of scripted configuration as the slaves.
* Cooler still would be for the EC2 plugin to take advantage of Amazon's [spot pricing](http://aws.amazon.com/ec2/spot-instances/). Though not supported at the moment, it would allow us to spend a fraction as much (or spend the same amount, but on more powerful resources).
