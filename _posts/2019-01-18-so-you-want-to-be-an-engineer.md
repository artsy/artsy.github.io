---
layout: epic
title: "So You Want to Be an Engineer"
date: "2019-01-18"
author: [matt_dole]
categories: [artsy, beginners, culture, engineering, people, team]
---

First of all, that's very exciting! Software engineering is pretty darn cool—you get to learn lots of new things,
understand the technology you use every day better, and contribute to the mysterious maw known as "the internet".

Last February, I also decided that I wanted to pursue computer engineering. I'd been at Artsy for a bit less than
two years at that point, first as a marketing intern working on SEO and then as a coordinator on the CRM (read:
email) team. I'd consistently been working on small technical projects; first doing
[some work](https://github.com/artsy/positron/commit/3176282a3ea94c626e9d851b7c0dd27a1bb0fcb4) on a tool for SEO
optimization for our Editorial team, then building
[emails with MJML](http://artsy.github.io/blog/2018/11/19/mjml/), and a few other bits and bobs. But I didn't think
of it as a serious pursuit.

Mostly, that was due to my experience programming in the past—I'd done a bit of coding before coming to Artsy. In
undergrad at Grinnell College I did a bit over half of a CS degree, and I even did a summer of research at Wash U
St. Louis. At the time, I felt that programming wasn't right for me, and I dropped the major during my third year.

It was Artsy's Engineering team that convinced me that programming was something that I both could and should do.
Our engineers have always welcomed learners and been happy to answer questions and empower other teams to do
technical work. I eventually realized that the parts of my work where I was coding were the parts I enjoyed the
most, and that I would likely feel more fulfilled if I made programming my full-time occupation.

Here's what that journey looked like. Hopefully my experience proves helpful to you as you begin (or finish) yours!

# Step One: Tell People What You Want

This might've been the single biggest learning I took away from this experience: _if you tell people you want
something, you might just get it._

That may sound super obvious. It wasn't for me. I've usually been very passive in my career decisions, taking the
path of least resistance and considering myself lucky when I was able to keep progressing. In this case, I was
making a substantial departure from that idea by being proactive about what it was I wanted.
[This post](https://engineering.gusto.com/i-didnt-want-to-be-a-manager-anymore-and-the-world-didnt-end/) by
[Noa Elad](https://twitter.com/NoaElad) does a great job with this topic as well and is certainly worth a read.

The first person I told at Artsy was [Orta](https://github.com/orta). He'd often encouraged me to develop my
technical skills, and since he knows Artsy's engineering team and stack better than just about anyone, I figured
he'd be able to point me in the right direction when it came to learning resources and navigating company politics
to get to my eventual goal.

The second person I told was my manager on the CRM team. It was a little strange—I wasn't telling her that I was
leaving, exactly, but just that I wanted to pursue a different career. There was no hard deadline; I had no idea
when or if it would be possible to become an engineer. I did know that it's what I wanted, and so if I told her,
she'd be able to advocate for me (I was lucky to have a manager who I trusted and who I was confident would do so).

The third person I told was Artsy's CTO, [dB](https://www.dblock.org/). This was Orta's recommendation—he would be
able to tell me if and when a move might be possible, and he could suggest things I should do to improve my chances
of making the switch.

I also didn't keep it a secret from the rest of my team or the company. I didn't show up wearing a shirt that said
"ENGINEER" on it, but I told people, "I'm working on becoming an engineer. I'm really hoping to stay at Artsy, but
if there's not a role open for me, that's fine—I'll search elsewhere."

# Step Two: What Should You Learn?

The answer to that question really depends on who you are, where you work, and where you _want_ to work.

I had a decent grounding in CS fundamentals thanks to my experience in undergrad. As a result, I initially decided
I wouldn't do a coding bootcamp—I felt I had enough experience to benefit from the multitude of online courses out
there.

----- OLD STUFF -----

# Learning to Focus

One of the biggest changes I've noticed in my first few weeks on engineering is how different the pace of work is.
In my old role, my attention was usually divided between several different tasks—I was constantly jumping from
email to slack, meeting to meeting, coding to strategy. I habitually mashed cmd + tab and was keeping a constant
eye on multiple communication channels. I rarely had time—or a need—to focus on one task for long periods of time.

On engineering, the reverse is true. I have much larger blocks of time, and success is measured not in terms of
repeated, everyday tasks punctuated by big initiatives, but in constant, measurable progress.

An example: I keep daily checklists, carrying over uncompleted tasks from day to day. Here's my checklist from
Tuesday, December 11:

```
- [x] Promoted content documentation
- [x] Promoted content for January w/ Lansing
- [x] Review Carolyn's work exercise
- [x] Make decisions on the two candidates in greenhouse
- [x] Connect Molly, Owen, and Daniel about email asset for MIA
- [x] Set up automated outreach handoff with nicholas + juliana
- [x] Set up coffee/meeting for Jun + Lansing
- [x] Development convo self assessment
```

As you can see, that's quite a few disparate tasks both large and small. And this doesn't take into account a lot
of the small occurrences that punctuated my day-to-day, such as QAing that day's Editorial email, answering
questions from project stakeholders on Slack, and reviewing stats for recent email sends.

By contrast, here's my checklist for January 22nd:

```
- [x] PR force changes from Friday
- [ ] 30m of work on blog post
- [ ] Resolve Sailthru library issues
- [ ] What role should I take in the filter ticket? Schedule a meeting with Devon?
```

I'm cherrypicking a little here, but you get the idea—my lists are consistently 3 - 4 items now, with 1 item
usually taking the lion's share of time and effort.

As a result, I now have to figure out how to focus on something for a big chunk of the day instead of swapping
between items quickly and often.

# Be your own rubber duck

My first couple weeks were largely focused on setting up my development environment—downloading services,
configuring environment variables, setting up logins, etc. etc. In the process, I ran into a few hiccups, and got
some great help from the rest of Artsy's dev team.

I also was reminded of the importance of problem solving solo. Artsy's engineers are an incredibly kind and helpful
bunch, and they're welcome to help as often as needed, but I also need to be able to do things myself sometimes.
One of the strategies I've landed on is effectively "self rubber-ducking." Before asking someone else for help, I
start by typing up (or, if I'm alone, talking out loud about) my questions and problems. Here's a snippet I typed
up when I was troubleshooting an issue last week:

```
- What is my issue?
    - My local version of Force is still showing the old version of the page
    - I bet it has something to do with my environment variables
- What have I tried so far?
    - I added my user_id and access token to Reaction's .env file. I don't think that's it though. What are the other differences?
    - Tried adding `NEW_ARTWORK_PAGE_THRESHOLD=10` (which equals 100%) to my .env file. It's also worth noting that even though it doesn't say as much in the readme, this is a hokusai application, so I might want to try copy_env instead of the cp .env.oss .env recommended in the force startup
    - oh! yes! that worked! it's correctly broken!
    - Nice job, self
```

In this case, even though I was feeling completely stumped, stating my problem and the steps I tried helped me
clarify my thoughts and figure out a solution. And in cases when I haven't been able to figure out the problem,
having gone through the exercise of defining the problem and documenting my attempts to solve it has made it easier
and faster to get help because I'm better able to articulate the issue at hand.

# Conclusion

I'm lucky to work at an organization where moving from email marketing to engineering is possible. I didn't take it
for granted that I would be able to transition into Engineering at Artsy—really, I assumed it wouldn't be.

### To add

I hadn't read this article, but I am a beneficiary of policy #1 (tell people about your interest in transitioning)
https://engineering.gusto.com/i-didnt-want-to-be-a-manager-anymore-and-the-world-didnt-end/ Pairing is super
important. I was working on a system where I was the main maintainer and knew most things. Now I'm working on
systems where dozens of people have worked on the code and I don't know shit
