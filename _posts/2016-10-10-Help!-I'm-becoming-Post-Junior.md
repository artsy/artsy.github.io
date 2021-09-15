---
layout: post
title: "Help! I'm becoming Post-Junior"
date: 2016-09-10 12:17
author: orta
categories: [culture, juniors]
series: Stages of Professional Growth
---

I’ve lived in NYC for 2 years now. I’ve been around long enough that some of the people I helped when they started learning have begun to feel like they’re not “Juniors” anymore.

They have begun feeling confident in their code, their responsibilities at the company and wanting to improve both. It's a feeling that maybe, just maybe, [you're not struggling to stay afloat anymore][1].

This post aims to be technology-agnostic, and if you sit somewhere at 1.5 - 3 years of programming experience then you’ll probably get something out of it. On top of that,  I’ll give some pragmatic JS and iOS specific tips at the end.

<!-- more -->

This post is easy to start. At Artsy we have an [engineering ladder system][2] - which I’ll paraphrase below. It’s worth the full read though.

Key point:

> Performance evaluation at Artsy is composed of the what, _i.e. what you achieve that contributes to your team’s goals and ultimately Artsy goals_, and the how, _i.e. how you act and how those actions contribute to Artsy’s culture and values_.

We measure your career stage by your **impact** at Artsy, this is initially on the products you’re working on, but eventually moves out to the culture and the business:

- **Engineer 1** - Can ship a well defined product feature.
- **Engineer 2** - Can independently own a product feature and can handle the communication with others around it.
- **Engineer 3** - Can handle a suite of features, and broadly contribute within a domain. Can improve company culture.
- **Engineer 4** - Can improve and be a multiplier on other people’s work, can anticipate larger trends and affect culture to avoid or steer in that direction.
- **Engineer 5** - Defines technical culture, works on impacting all parts of our businesses and creates new opportunities for the company.

What we’re talking about here is the transition from Engineer 1, to Engineer 2. Here’s our full unabridged description of an Engineer 2.

> ▪   Consistently writes and delivers correct and clean quality code with guidance.

> ▪   Self-sufficient and makes steady progress on tasks.

> ▪   Knows when to ask for help and how to get unblocked.

> ▪   Makes steady, well-paced progress without the need for constant significant feedback from more senior engineers.

> ▪   Owns a small-to-medium feature from technical design through completion.

> ▪   Provides help and support outside of area under their responsibility.

What can we gleam from this, so we start thinking of ways to improve ourselves as individual contributors?

## Increasing your Responsibility with Cross Team Interactions

It’s very unlikely that you are making all of the calls in a product. What is hopefully happening is that your team figures out a plan to ship something in a reasonable timeframe and as a team you assign each other smaller tasks that make that work.

It’s very likely that as a junior, you will be given the most well-defined small tasks. In OSS we call these the “[easy first steps][3].” Tasks that can be done atomically, without requiring more interaction with designers or members of the product team. Initially this is a feature (in that you get easy tasks), that eventually turns into a bug (you want to contribute at a higher level).

When it’s time to divvy up responsibilities, you should consider speaking up about taking tasks that are blocking people, but require further investigation outside of your dev team.

These responsibilities could be checking up on the status of an API with a platform team, or communicating with different parts of the business to get confirmation on specific details. It is the vagueness that makes the task harder, work your way towards making the task clear - then you have a well defined project.

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

- **Process**: You’re probably using some form of [agile development][4], understand what that [really means][5] and how it compares to others. Try reading [Getting Things Done][6] and I’ve heard good things about [Personal Kanban][7].

-  **Code Architecture**: Here are some book recommendations, [Clean Code][8], [The Pragmatic Programmer][9], [Elements of Reusable Object-Oriented Software][10] and [Working Effectively with Legacy Code][11].

- **Tooling**: There is never one way to do something, so try something else. Switch text editor for a month, or explore alternative methods of doing the same thing.

You can use this knowledge to start offering useful advice that can start to influence your team, for example could be in the form of trying few new idea and offering feedback on their tradeoffs.

As this is useful to both you and your employer, you should consider talking to your manager about booking time in your work calendar for doing 30 minutes of career development once a week studying topics like these.

## Helping others

You can help your team out by using some of the skills from above.  You can then start thinking of expanding your influence within the company. By being a programmer you already have skills that a lot of people would like to learn or have a better working knowledge of it.

If you’ve got this far in the article, it’s very likely you’ve got enough skills to [lead][12] [workshops][13] internally, and write blog posts about [your experiences][14] to [help other developers][15] at your level. For example, this month I’ve ran a workshop on keyboard shortcuts and on learning to program in Swift. Both of them required maybe 2 hours of preparation, and an email or two announcing that it’s happening.

Other options are to give [technical talks][16] within your company on specific topics, for example [Licensing for OSS code][17] is a talk I gave internally to Artsy. We now have a weekly team “Lunch & Learn” where we give anyone the chance to talk, or request a talk on a topic.

This gives a lot of space for personal growth too, as these are really easy to transition into blog posts and meetup talks.

Finally, try to pair with programmers outside of your direct team, it could be on whatever they’re working on - you’ll learn a bit more about other systems and they’ll get to [rubber duck][18] their problems.

## Side Projects

I’ve tried to focus this post specifically on things you can do on work time. Not everyone has the ability to go home and spend a few hours on this and that. However, programming at the early stage can generally be a “you get out what you put in” kind of deal with time.

Side projects give you the chance to test out new ideas in an isolated environment that is totally under your control. They are great places for exploring what makes a system tick. Some side-projects are built to be [thrown away][19] others can [to last][20] [for years][21]. Both are valuable spaces for experimentation.

## Contributing to Open Source

A lot of people’s work relies on Open Source code and as you are starting to branch out into having a larger impact - perhaps making smaller improvements to the projects you rely on every day could help. This is [how I got started][22] working with larger projects in the Open Source world.

Interacting in these projects exposes you to whole new teams of people with, hopefully, very different perspectives. It will change you, you will change them.

## Moving On

This is a [complicated topic][23], perhaps worth of it’s own post.

When you first start looking for a job in technology, you likely didn’t have too many choices and was pleased to have any offer. By this point, I’m hoping you’re at a point where you understand your value to a company.

Perhaps it’s worth thinking about what kind of space the company has for you to grow in. Since I started my career, Artsy is the only job I’ve been in for longer than 2 years. For some, I felt like I had outgrown my original role but could not find a space to grow into.

It’s worth re-evaluating. I do it every year in anticipation of my [annual write-ups][24].

## Wrap-up

This is no simple “one-step to consider yourself post-Junior" article. Only a collection of ideas that you can apply until you feel confident as you find you own ways to help out. As you grow, you grow in many different directions at once - and all of them are valid.

You can grow by research, practice, doing things outside of work, doing small projects with others in work, experimentation with technology, interacting with more and more people and re-thinking existing approaches. Once you're outside of small feature work - there are so many ways you can contribute.

We use the idea of an engineering ladder as a yardstick to ensure we treat developers fairly at Artsy. Different companies will have different ways of scoping how you measure up as a programmer. Your company's ladder can help offer direction for what they would love to see.

At the end of the day you’ve got your foundations now, and its time to start thinking about building yourself into a unique programmer and creating your own opinions. There’s never been a better time to start.

## Further Reading

- [What I Didn't Understand as a Junior Programmer][25]
- [Growing Beyond Junior][26]

## iOS Specific

- Study [GraphQL][27], study my entire series on [Cocoa Architecture][28] and our [app code reviews][29].
- Study MVC, MVVM, RxSwift, VIPER, Testing, BDD, CocoaPods & Swift Package Manager with an hour on each minimum.
- Read [objc.io][30], watch their videos too.
- Study other languages, and toolsets - it’s very easy to become silo’d in just Objective-C and Swift.

## JS Specific

- Study ES6, GraphQL, React, Relay, Redux, Angular 2, Flow, TypeScript, Carte Blanche, Webpack & Babel.
- Get a company account on [Egghead][31] - give yourself a timetable on work time to spend 30+ minutes once a week watching videos from it.
- Explore VS Code, Safari Web Inspector and Web Storm as different ways of doing the same thing, but with more tooling.

[1]:	https://ashfurrow.com/blog/normalizing-struggle/
[2]:	/blog/2015/04/03/artsy-engineering-compensation-framework/
[3]:	https://github.com/danger/danger/issues?q=is:issue+is:open+label:%22You+Can+Do+This%22
[4]:	http://agilemanifesto.org
[5]:	https://en.wikipedia.org/wiki/Agile_software_development
[6]:	https://www.amazon.co.uk/Getting-Things-Done-Stress-free-Productivity-ebook/dp/B00SHL3V8M/ref=sr_1_1?s=digital-text&ie=UTF8&qid=1473567686&sr=1-1&keywords=gtd
[7]:	https://www.amazon.co.uk/Personal-Kanban-Mapping-Work-Navigating-ebook/dp/B004R1Q642/ref=sr_1_6?s=digital-text&ie=UTF8&qid=1473567686&sr=1-6&keywords=gtd
[8]:	https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882
[9]:	https://www.amazon.com/Pragmatic-Programmer-Journeyman-Master/dp/020161622X/ref=pd_bxgy_14_img_3?ie=UTF8&psc=1&refRID=BX7MTECP16Z2VR3N3T25
[10]:	https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612
[11]:	https://www.amazon.co.uk/gp/product/B005OYHF0A/
[12]:	http://artsy.github.io/blog/2016/01/26/swift-at-artsy/
[13]:	http://artsy.github.io/blog/2016/08/31/Keyboard-Shortcuts-workshop/
[14]:	http://artsy.github.io/blog/2015/07/06/how-to-write-unit-tests-like-a-brood-parasite/
[15]:	http://artsy.github.io/blog/2015/06/04/an-eigenstate-of-mind/
[16]:	http://artsy.github.io/blog/2016/03/09/public-speaking-part1-is-it-for-me/
[17]:	/blog/2015/12/10/License-and-You/
[18]:	https://en.wikipedia.org/wiki/Rubber_duck_debugging
[19]:	https://github.com/orta/you-can-do-it
[20]:	https://cocoapods.org
[21]:	http://danger.systems
[22]:	https://speakerdeck.com/orta/the-cocoapods-spec-repo-and-cocoadocs
[23]:	https://github.com/artsy/artsy.github.io/pull/275#issuecomment-246227904
[24]:	http://orta.io/on/being/29
[25]:	http://blog.alexnaraghi.com/what-i-didnt-understand-as-a-junior-programmer
[26]:	http://dbgrandi.github.io/growing_beyond_junior/
[27]:	/blog/2016/06/19/graphql-for-mobile/
[28]:	/series/cocoa-architecture/
[29]:	/series/ios-code-review/
[30]:	https://www.objc.io
[31]:	https://egghead.io
