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

To set up the build slave's Amazon Machine Image (AMI), we started from an [official Ubuntu 11.10](http://cloud-images.ubuntu.com/releases/oneiric/release/) (Oneiric Ocelot) AMI, ran initialization scripts to set up our build dependencies (MongoDB, Redis, ImageMagick, Firefox, RVM, NVM, etc.), packaged our modified instance into its own AMI, and then set up the EC2 Plugin to launch instances from this custom AMI.

Our AMI setup steps are captured entirely in a [GitHub gist](https://gist.github.com/2897653), but because our build requirements are specific to our applications and frameworks, most organizations will need to modify these scripts to their own use cases. Given that caveat, here's how we went from base Ubuntu AMI to custom build slave AMI:

1. We [launched](https://console.aws.amazon.com/ec2/home?region=us-east-1#launchAmi=ami-4dad7424) an Ubuntu 11.10 AMI `4dad7424` via the AWS console.
2. Once the instance was launched, we logged in with the SSH key we generated during setup.
3. We ran the following commands to configure the instance:

        curl -L https://raw.github.com/gist/2897653/_base-setup.sh | sudo bash -s
        sudo su -l jenkins
        curl -L https://raw.github.com/gist/2897653/_jenkins-user-setup.sh | bash -s

4. From the "Instances" tab of the AWS Console, we chose the now-configured instance, and from the "Instance Actions" dropdown, selected "Stop", followed by "Create Image (EBS AMI)".

Next we installed the Amazon EC2 Plugin on our Jenkins master, and entered the following configuration arguments for the plugin. (Replace the AMI ID with your own, the result of Step 4 above.)

![Jenkins EC2 Plugin configuration](http://f.cl.ly/items/08280H2Y2C1H3v3K1D2Q/Image%202012.07.10%2012:12:30%20PM.png)

New build slaves began spawning immediately in response to job demand! Our new "Computers" page on Jenkins looks like this:

![Jenkins computer list](http://f.cl.ly/items/1t2s3w2y0o1Q0s3Z2d0K/Image%202012.07.10%2011:45:26%20AM.png)

We have the option of provisioning a new build slave via a single click, but so far, this hasn't been necessary, since slaves have automatically scaled up and down with demand. We average around 4-8 build slaves during the day, and 0-1 overnight and on weekends.

## Outcome and Next Steps

This arrangement hasn't been in place for long, but we're excited about the benefits it's already delivered:

* Builds now take a predictable amount of time, since slaves automatically scale up to match demand.
* Slaves offer a more consistent and easily maintained configuration, so there are fewer spurious failures.
* Despite higher costs on EC2, we hope to spend about the same (or maybe even less) now that we'll need to operate only the master server during period of inactivity (like nights and weekends).

As proponents of _automating the hard stuff_, we get a real kick out of watching identical slaves spin up as builds trickle in each morning, then disappear as the queue quiets down in the evening. Still, there are a few improvements to be made:

* Our canonical slave's configuration should be scripted with [Chef](http://www.opscode.com/chef/). <!-- need more here -->
* Sharp-eyed readers will notice that our Jenkins master is still a Linode server. It might benefit from the same type of scripted configuration as the slaves.
* Cooler still would be for the EC2 plugin to take advantage of Amazon's [spot pricing](http://aws.amazon.com/ec2/spot-instances/). Though not supported at the moment, it would allow us to spend a fraction as much (or spend the same amount, but on more powerful resources).
