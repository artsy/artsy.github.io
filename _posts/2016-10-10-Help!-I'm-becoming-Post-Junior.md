---
layout: post
title: "Help! I'm becoming Post-Junior"
date: 2016-10-10 12:17
author: orta
categories: [culture, juniors]
series: Stages of Professional Growth
---

I’ve lived in NYC for 2 years now. This means I’ve been around long enough that some of the people I helped when they were learn to program have started to feel like they’re not “Juniors” anymore. 

There is no arbitrary timeframe that you can say applies to that feeling of career progression, but from the explanations I’ve had recently - it’s been about feeling confident in your code, your impact and wanting to improve both.

This post aims to be technology-agnostic, and if you sit somewhere at 1.5 -3 years of programming experience ( and most of that as writing production code ) then you’ll probably get something out of it. Though I’ll give some JS and iOS specific tips at the end.

—

This one is easy to start. At Artsy we have an [engineering ladder system][1] - which I’ll paraphrase below. It’s worth the full read though.

Key point:

> Performance evaluation at Artsy is composed of the what, _i.e. what you achieve that contributes to your team’s goals and ultimately Artsy goals_, and the how, _i.e. how you act and how those actions contribute to Artsy’s culture and values_.

We measure your career stage by your **impact** at Artsy, this is initially on the products you’re working on, but eventually moves out to the culture and the business:

- **Engineer 1** - Can ship a well defined product feature.
- **Engineer 2** - Can independently own a product features, and can handle the communication with others around it.
- **Engineer 3** - Can handle a suite of features, and broadly contribute within a domain. Can improve company culture.
- **Engineer 4** - Can improve and be a multiplier on other people’s work, can anticipate larger trends and affect culture to avoid or steer in that direction.
- **Engineer 5** - Defines technical culture, works on impacting all parts of our businesses and creates new opportunities for the company.

What we’re talking about here is the transition from Engineer 1, to Engineer 2. Here’s our full unabridged description of an Engineer 2.

> ▪	Consistently writes and delivers correct and clean quality code with guidance.

> ▪	Self-sufficient and makes steady progress on tasks.

> ▪	Knows when to ask for help and how to get unblocked.

> ▪	Makes steady, well-paced progress without the need for constant significant feedback from more senior engineers.

> ▪	Owns a small-to-medium feature from technical design through completion.

> ▪	Provides help and support outside of area under their responsibility.

What can we gleam from this, so we start thinking of ways to improve ourselves as individual contributors?

## Increasing your Responsibility with Cross Team Interactions

It’s very unlikely that you are making all of the calls in a product. What is hopefully happening is that your team figures out a plan to ship something in a reasonable timeframe and as a team you assign each other smaller tasks that make that work.

It’s very likely that as a junior, you will be given the most well-defined small tasks. In OSS we call these the “[easy first steps][2].” tasks that can be done atomically, without requiring more interaction with designers or members of the product team. This is a feature, that eventually turns into a bug. 

When it’s time to divvy up responsibilities, you should consider speaking up about taking tasks that are blocking people, but require further investigation outside of your dev team.

This could be checking up occasionally with an API team, or leasing with different parts of the business to get confirmation on a specific detail. These kind of skills are not the sort of things you get in a computer science degree, and those without them are in a great place to other skills they’ve learned.

It is generally the vagueness that makes the task harder, work your way to making the task clean - then you have a well defined next step. 

## Learn From Your Project's History 

When you work, you’re probably working inside an application that other people have built. They have laid the frameworks down, established the team norms and architectural choices that could have existed for years before you arrived. 

Part of what gives you that feeling of confidence in your code is you’re comfortable within the architectural ecosystem you’re used to: e.g. React + Relay, iOS MVVM, Backbone + Express, Rails + CoffeeScript. You’re probably getting good at using them, and that’s awesome.

To evolve from just that you need to really understand why these choices were made, what their trade-offs are and what was the reasoning for that platform to even exist in the first place.

By understanding the history of the choices that you have been living with, you can make better decisions in the future.

## The Bigger Picture

There is no “One True Solution” for anything in programming. You should be wary of anyone that tries to tell you all similar sounding things should be done one way. The things you work on are likely a combination of different patterns that work together to become “an app.”

Understanding your patterns well, and knowing when to apply them will get you far. If you want to go further still, you need to be able to step back from your patterns and try to see larger pictures. A feature that you write this week  _with a little bit more abstraction today_ could make it much easier to write something next week. Writing better abstractions makes it easier for you to become a multiplier for other peoples work.

The hard bit is trying to see what that is. Realistically, this is about understanding where the product is, and what it’s roadmap is for the next few iterations as well as trying to think about abstractions that may not be available inside your project.

## Studying Outside Your Daily Craft

Some problems can be handled particularly well by different architectural patterns.  Without knowing they exist, how can you think that they are something you can use?

This leads to an interesting problem, how do you learn new architectural pattens?

- **Process**: You’re probably using some form of [agile development][3], understand what that [really means][4] and how it compares to others. Try reading [Getting Things Done][5] and I’ve heard good things about [Personal Kanban][6].

-  **Code Architecture**: Here are some book recommendations, [Clean Code][7], [The Pragmatic Programmer][8], [Elements of Reusable Object-Oriented Software][9] and [Working Effectively with Legacy Code][10].

- **Tooling**: There is never one way to do something, so try something else. Switch text editor for a month, or explore alternative methods of doing the same thing.

You can use this knowledge to start offering useful advice that can start to influence your team, for example could be in the form of trying few new idea and offering feedback on their tradeoffs.

## Helping others

You can help your team out by using some of the skills from above.  You can then start thinking of expanding your influence within the company. By being a programmer you already have skills that a lot of people would like to learn or have a better working knowledge of it.

If you’ve got this far in the article, it’s very likely you’ve got enough skills to lead workshops internally, and to write blog posts about your experiences to help other developers at your level. For example, this month I’ve ran a workshop on keyboard shortcuts and on learning to program in Swift. Both of them required maybe 2 hours of preparation, and an email or two announcing that it’s happening.

Other options are to give [technical talks](http://artsy.github.io/blog/2016/03/09/public-speaking-part1-is-it-for-me/) within your company on specific topics, for example [Licensing for OSS code][11] is a talk I gave internally to Artsy. We now have a weekly team “Lunch & Learn” where we give anyone the chance to talk, or request a talk on a topic. 

This gives a lot of space for personal growth too, as these are really easy to transition into blog posts and meetup talks.

Finally, try to pair with programmers outside of your direct team, it could be on whatever they’re working on - you’ll learn a bit more about other systems and they’ll get to [rubber duck][12] their problems.

## Side Projects

I’ve tried to focus this post specifically on things you can do on work time. Not everyone has the ability to go home and spend a few hours on this and that. However, programming at the early stage can generally be a “you get out what you put in” kind of deal with time.  

Side projects give you the chance to test out new ideas in an isolated environment that is totally under your control. They are great places for exploring what makes a system tick. Some side-projects are built to be [thrown away][13] others can [to last][14] [for years][15]. Both are valuable spaces for experimentation.

## Contributing to Open Source

A lot of people’s work relies on Open Source code and as you are starting to branch out into having a larger impact - perhaps making smaller improvements to the projects you rely on every day could help. This is [how I got started][16] working with larger projects in the Open Source world.

Interacting in these projects exposes you to whole new teams of people with, hopefully, very different perspectives. It will change you, you will change them.

## Wrap-up

This is no simple “one-step to consider yourself post-Junior" article. Only a collection of ideas that you can apply until you feel confident as you find you own ways to help out. As you grow, you grow in many different directions at once - and all of them are valid. 

You can grow by research, practice, doing things outside of work, doing small projects with others in work, experimentation with technology, interacting with more and more people and re-thinking existing approaches. Once you're outside of small feature work - there are so many ways you can contribute.   

We use the idea of an engineering ladder as a yardstick to ensure we treat developers fairly at Artsy. Different companies will have different ways of scoping how you measure up as a programmer. Your company's ladder can help offer direction for what they would love to see.

At the end of the day you’ve got your foundations now, and its time to start thinking about building yourself into a unique programmer and creating your own opinions. There’s never been a better time to start.

## Further Reading

- [What I Didn't Understand as a Junior Programmer][17]
- [Growing Beyond Junior][18]

## iOS Specific

- Study [GraphQL][19], study my entire series on [Cocoa Architecture][20] and our [app code reviews][21]. 
- Study MVC, MVVM, RxSwift, VIPER, Testing, BDD, CocoaPods & Swift Package Manager with an hour on each minimum.
- Read [objc.io][22], watch their videos too.
- Study other languages, and toolsets - it’s very easy to become silo’d in just Objective-C and Swift.

## JS Specific

- Study ES6, GraphQL, React, Relay, Redux, Angular 2, Flow, TypeScript, Carte Blanche, Webpack & Babel.
- Get a company account on [Egghead][23] - give yourself a timetable on work time to spend 30+ minutes once a week watching videos from it.
- Explore VS Code,Safari Web Inspector and Web Storm as different ways of doing the same thing, but with more tooling.

[1]:	/blog/2015/04/03/artsy-engineering-compensation-framework/
[2]:	https://github.com/danger/danger/issues?q=is%3Aissue+is%3Aopen+label%3A%22You+Can+Do+This%22
[3]:	http://agilemanifesto.org
[4]:	https://en.wikipedia.org/wiki/Agile_software_development
[5]:	https://www.amazon.co.uk/Getting-Things-Done-Stress-free-Productivity-ebook/dp/B00SHL3V8M/ref=sr_1_1?s=digital-text&ie=UTF8&qid=1473567686&sr=1-1&keywords=gtd
[6]:	https://www.amazon.co.uk/Personal-Kanban-Mapping-Work-Navigating-ebook/dp/B004R1Q642/ref=sr_1_6?s=digital-text&ie=UTF8&qid=1473567686&sr=1-6&keywords=gtd
[7]:	https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882
[8]:	https://www.amazon.com/Pragmatic-Programmer-Journeyman-Master/dp/020161622X/ref=pd_bxgy_14_img_3?ie=UTF8&psc=1&refRID=BX7MTECP16Z2VR3N3T25
[9]:	https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612
[10]:	https://www.amazon.co.uk/gp/product/B005OYHF0A/
[11]:	/blog/2015/12/10/License-and-You/
[12]:	https://en.wikipedia.org/wiki/Rubber_duck_debugging
[13]:	https://github.com/orta/you-can-do-it
[14]:	https://cocoapods.org
[15]:	http://danger.systems
[16]:	https://speakerdeck.com/orta/the-cocoapods-spec-repo-and-cocoadocs
[17]:	http://blog.alexnaraghi.com/what-i-didnt-understand-as-a-junior-programmer
[18]:	http://dbgrandi.github.io/growing_beyond_junior/
[19]:	/blog/2016/06/19/graphql-for-mobile/
[20]:	/series/cocoa-architecture/
[21]:	/series/ios-code-review/
[22]:	https://www.objc.io
[23]:	https://egghead.io