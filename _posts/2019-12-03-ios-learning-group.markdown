---
layout: epic
title: "iOS Learning Group"
date: "2019-12-03"
author: [ash]
categories: [ios, learning, culture]
---

Regular readers of our blog might be familiar with [Culture Amp](https://www.cultureamp.com), a tool Artsy uses to
collect anonymous feedback and take action on cultural issues (we most recently discussed the tool
[in this blog post](https://artsy.github.io/blog/2019/04/19/having-a-coffee-with-every-engineer/)). At a
company-wide level, Culture Amp has helped guide everything from Artsy's evolving culture, to our physical work
spaces, to our support for remote work. At an engineering-team level, we've also been using Culture Amp to guide
our choices in technology, documentation, and training.

In this blog post I'll be detailing a recent learning course we ran to share knowledge about how Artsy builds iOS
software for our entire engineering team.

<!-- more -->

Let's start at the beginning. Earlier this year, Artsy Engineering ran a survey through Culture Amp to get answers
to the following questions:

1. What is our team's opinion on our current technology choices?
2. What is our team's familiarity with or preparedness for our current technology?
3. Where are the areas of strength and opportunities for both learning and teaching?

There are a lot of things we learned from this survey, and among them was a desire for engineers to better
understand how to build iOS software at Artsy. With a nudge (and support!) from our _Peer Learning Working Group_,
I set out to create a learning plan. I wasn't starting from scratch – we already ran a few learning groups on
topics ranging from Scala fundamentals to React Hooks. We used the lessons learned from _those_ experiences to
define and deliver a learning plan.

I started by booking five sessions, spread out by a week. I picked a time that was a good fit for as many engineers
as possible, and I scheduled them a month ahead to give people a chance to move their schedules around. Scheduling
them up front was important, to give learners a sense of what to expect; previous learning groups had suffered from
inconsistent schedules, which led to intermittent attendance. I also asked each Tech Lead to make sure at least one
engineer from their team attended.

Next was the actual curriculum. In the spirit of "proudly discovered elsewhere", we actually looked at using
existing learning resources that someone else had already developed. However, since
[our iOS stack is a bit unique](https://artsy.github.io/series/react-native-at-artsy/) and I was keen to keep
honing my own skills as a technical educator, we decided to make our own. With the help of our Peer Learning
Working Group, we set learning objectives for the five sessions. Here was the original plan:

- **Week 1**: This week, we will cover how iOS software is developed, QA'd, and deployed. By the end of this
  session, all participants should be able to pull the latest code from [Eigen](https://github.com/artsy/eigen)
  (our native iOS repo) and [Emission](https://github.com/artsy/emission) (our React Native repo), see their work
  in an iOS simulator, and link the two projects together.
- **Week 2**: This week, we will cover what makes React Native distinct from React on the web, as well as how Artsy
  leverages shared infrastructure (such as our design-system, [Palette](https://github.com/artsy/palette)) to make
  it easier for engineers to work in either one.
- **Week 3**: This week, we will cover how to create a new view controller. View controllers are the main unit of
  composition for native iOS apps, and we integrate our "Scene" React components _as_ view controllers. This
  includes routing between view controller, from both native Objective-C and React Native code.
- **Week 4**: This week, we will create our own React component to fit within the new view controller from Week 3.
  This will be a Relay container, fetching data from our GraphQL API,
  [Metaphysics](https://github.com/artsy/metaphysics). We will cover how to fetch data, how to _re_-fetch data, as
  well as how Eigen and Emission integrate together to provide client-side API response caches (both Relay and
  others).
- **Week 5**: This is the final week. Participants are asked to bring an iOS bug from their product team's backlog
  that they would like to fix. Pairing is encouraged.

Things mostly went to plan. I made sure to provide the learning resources at least a day or two ahead of each
session; this let me respond to feedback from the previous week, and also gave learners a chance to review
materials ahead of time.

Every session was recorded for anyone who missed it. We had a shared Slack channel set up for questions, so
engineers could help each other. I also made sure to provide weekly office hours: this was space for people who
missed sessions to catch up, or to just dig into concepts in more detail. I'll return to the topic of office hours
later in this post.

Around the time of the learning group, I was reading
_[Make It Stick: The Science of Successful Learning](https://www.amazon.com/Make-Stick-Science-Successful-Learning/dp/0674729013/ref=sr_1_1?keywords=making+it+stick&qid=1575314498&sr=8-1)_.
The book is written for people who want to improve their own learning skills, but it was _very_ helpful to read as
I was developing and delivering this curriculum. Here are a few lessons that I learned from the book that were
helpful while teaching engineers at Artsy about how we build iOS software:

- If someone tries to do something themselves _before_ being told how to do it, the attempt will strengthen their
  understanding of the underlying concept. To put this into practice, I would often ask learners questions that I
  didn't expect they could answer yet, and the resulting discussion was always worthwhile.
- Interleaving different concepts together helps learners form connections between those concepts. This was
  especially important, since a big motivator for using React Native at Artsy was to share skills between web and
  iOS codebases. As an example of putting this into practice, I interleaved a discussion of
  [Relay](https://relay.dev) into our curriculum; I hoped to show learners both a new perspective of Relay, as well
  as show them how familiar writing React Native code was to writing React web code.
- Allowing for some forgetting to take place before reviewing concepts will
  [help strengthen learner's understanding](https://njcideas.wordpress.com/2017/09/22/the-cognitive-science-of-studying-massed-practice-vs-spaced-practice/).
  To put this into practice, I would return to topics from a few weeks ago to cement their understanding with
  learners.

I had to push through some discomfort as an educator, too. Each session ended with homework questions, which we
reviewed at the top of the next session. I would ask each question and then just sit there, in awkward silence,
while everyone looked around for someone to answer. Eventually, inevitably, someone would.

All of the learning materials
[are open source](https://github.com/artsy/README/tree/master/resources/mobile/learning-group). While the materials
are mostly specific to Artsy, they may be of help to others. And regardless, we want to adhere to our
[Open Source by Default](https://github.com/artsy/README/blob/master/culture/engineering-principles.md#open-source-by-default)
principle.

We learned quite a lot from delivering this curriculum – lessons we can apply to our next learning group:

- Learners appreciated the weekly schedule set upfront, affirming what we learned from previous learning groups.
- Learners appreciated having access to the materials ahead of time.
- Learners appreciated having the sessions recorded, to be reviewed later (or watched, in case they missed the
  session).
- Learners appreciated having office hours available; even though the office hours weren't well-attended, learners
  appreciated having access to them if they needed to.
- Learners even appreciated the awkward silences while I waited for an answer to my questions. (One survey
  respondent described it as "like pulling teeth, but helpful.")
- Learners are varied in how they want to learn. Some liked going through things together. Some thought we went too
  slow. Still others thought we should expect learners to do more work ahead of class.

This last point is worth expanding upon. While everyone learns differently, there is a distinction between what
_feels_ effective and what _is_ effective. I tried to structure the course so that it was accessible to as many
types of learners as possible: some like to review materials ahead of time, some like to have them on hand during
the session, etc. Some are in-person, others are remote, still others are reviewing the recording. I could write
another blog post about learning styles, but for now it suffices to say that I aimed for _inclusion_ of as many
different learners as possible while also recognizing that I can't make everyone happy.

As I enter a new chapter of my own career, leading Artsy's new Mobile Experience team, it was helpful to return to
some fundamentals; to get familiar with technology choices that we made years ago
([choices which I originally resisted](https://ashfurrow.com/blog/swift-vs-react-native-feels/)); and to learn from
learners' perspectives as beginners. The future of iOS software at Artsy is very bright, and now every product team
is more prepared than ever to deliver user experiences that are of a quality worthy of art.
