---
layout: epic
title: "Knowledge Shares For Great Good"
date: 2020-12-09
categories: [teams, culture, people]
author: ash
---

Sharing knowledge! What a concept! [In my recent blog post](/blog/2020/09/29/becoming-mobile-first-at-artsy/), I discussed "Knowledge Share" meetings (also known simply as "Knowledge Shares", or abbreviated "KS") and I want to dive deeper into them today. Last time, I described them as follows:

> Knowledge Shares are a <u>structured</u> time to facilitate <u>unstructured learning</u>. Anyone can bring a topic to Knowledge Share, from a ticket that they're stuck on to an idea they have to a neat trick they recently learned.

These meetings were really instrumental in ramping up the Mobile Experience team, but their history goes back a bit further. Today, we're going to discuss the origins of Knowledge Shares at Artsy, how they've evolved, the value they provide us as engineers, and how I'd recommend you adopt them on your team.

Let's go!

<!-- more -->

To my recollection, the Auctions team was the first at Artsy to start doing "Knowledge Share" meetings. It was late 2016, I think. We were a small team of about five engineers, but were spread across many different front-end apps and back-end microservices. To make sure Artsy's nascent auction business was a success, every engineer on the team had to have a working understanding of every one of our codebases. The team's lead, Alan, suggested that devote an hour each week to sharing knowledge so no one person would become a silo.

The idea is simple enough: spend time working on something together. Kind of like pair programming, but with a slightly bigger group. Maybe there would be a ticket someone had that we would start together. Or maybe there had been a production incident that we wanted to investigate together. Maybe someone had an idea for a new technical approach to some problem and they wanted early feedback. 

I think this forum worked well for us because our team was small and had a high level of interpersonal trust. Leading a five-person [mobbing session](https://en.wikipedia.org/wiki/Mob_programming) could be really intimidating, and later I'll discuss how I've since structured the Knowledge Shares that I lead to make everyone feel welcome contributing.

And they worked great! Other engineers learned about the iOS front-end code that I had written, and I learned about the back-end systems that powered that front-end. This was important for the team because our response time to production incidents was critical – one extra minute of looking up docs or finding a specific URL could make the difference between a happy user winning their lot, or an unhappy user taking their business elsewhere.

As time went on, other product teams started their own Knowledge Shares. They proliferated naturally throughout Artsy Engineering. When I started the Mobile Experience team in 2019, Knowledge Shares were one of the first recurring team meetings I scheduled. After a few months, I got really positive feedback about them. In fact, engineers wanted more of them. So I scheduled a second hour-long Knowledge Share each week.

Today, Knowledge Shares are for more than just engineers. They are for product managers, designers, data analysts, and other team stakeholders. Sometimes engineers from other teams even join my team's Knowledge Shares, though scheduling becomes a hassle at a certain scale. We start each Knowledge Share with team-wide topics that apply to more than only engineers; we then move on to engineering-specific topics. This lets non-engineers still contribute while also letting them drop off so the engineers can dig into code.

Here are some examples of things that we have used Knowledge Shares for:

- Sharing early designs for upcoming project work.
- Going over work-in-progress pull requests and soliciting feedback on the technical approach.
- Spiking on big-picture projects together, to help us plan what work needs to happen and in which order.
- Exploring anonymized user sessions to learn more about how our product actually gets used in the real world.
- Investigating small quality-of-life problems with our codebase's developer experience and working on solutions.
- Brainstorming about how to address specific pieces of technical debt.

Topics range from the technical to the product-focused, from what has already shipped to what is still on the drawing board. This breadth of focus helps everyone on the team feel like they can contribute. We keep a shared document of evergreen topic ideas and everyone is encouraged to add to it. As Tech Lead, I also send Slack reminders before each meeting to solicit for timely topics.

Throughout the normal course of our week, topics will naturally come up for discussion – topics that would normally need their own meeting to be scheduled. But instead, we can use the time we already have scheduled. For example: if an engineer has feedback on a new feature's design, we don't need to schedule a dedicated meeting for that conversation – we can use a Knowledge Share. It might feel like having recurring "Knowledge Share" meetings only adds more meetings to everyone's already-busy calendars. But in our experience, these Knowledge Shares prevent us from scheduling _yet more_ one-off meetings, so it balances out as a time-saver.

As a Tech Lead, I like to use Knowledge Shares as an opportunity to reinforce the shared understanding that _learning_ is our paramount goal. That is to say, our goal isn't to _build_ some new feature, but is rather to _learn **how** to build_ that new feature. That's why I emphasize in our Knowledge Shares that _learning is contributing_ (language which I added to our engineering onboarding docs). New team members might not have topics of their own, but they're encouraged to contribute by learning and by asking questions.

When I described the origins of Knowledge Shares above, I said that they worked well on the early Auctions team because the team already had a high level of interpersonal trust. But looking back at those early days, I have to admit that I'm not sure which came first: the Knowledge Shares, or the trust? Having now bootstrapped two product teams at Artsy, I can tell you that Knowledge Shares are a key tool I use as Tech Lead to get teams working well together, quickly. The experience of being confused (together) and then gaining understanding (together) is great for building up [the interpersonal trust that makes teams perform well](https://ashfurrow.com/blog/building-better-software-by-building-better-teams/). I just can't recommend Knowledge Shares enough!

Today, Knowledge Shares at Artsy provide a variety of benefits. Among others, those benefits are:

- De-siloing information, to prevent any one engineer from becoming a single-point-of-failure for Artsy's systems.
- Getting the team used to working together, used to communicating with one another, and used to providing and accepting feedback.
- Surfacing problems developers commonly run into during day-to-day work – and then fixing them permanently, together.
- Fostering a sense that everyone "owns" this meeting (and, by extension, everyone "owns" the team's culture).

Okay, so, let's imagine I've sold you on the idea of Knowledge Shares. Great! So where do you start? How do you get your team on board? 

If you are the team's lead then adopting Knowledge Shares is quite easy: send your team this blog post, tell them you want to try Knowledge Shares, try them out, and discuss what everyone thinks in an upcoming retrospective. Whether you make the Knowledges Shares mandatory, or just encourage everyone's participation, is up to you. They are mandatory for engineers on my team, but I accept the responsibility of making sure the meetings providing value to all engineers. I trust you to make these work well for however your team works.

What if you're _not_ the team lead? That's okay, you have options. If you're comfortable, I would recommend following the same steps as above. Send your team this blog post, express interest in trying out a weekly Knowledge Share, and schedule something. (By showing this kind of leadership initiative, it won't be long before you find yourself leading your own team!) But if you want to avoid stepping on toes, you can also discuss this with your team's lead privately. Every team is different and I trust you to navigate your own team best.
