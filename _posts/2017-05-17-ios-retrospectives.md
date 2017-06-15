---
layout: post
title: iOS Retrospectives
date: 2017-05-27
categories: [ios, eigen]
author: ash
---

In the 1990s, Harvard researcher Amy Edmonson made the unexpected discovery that in hospitals, [higher performing teams reported making more mistakes](https://www.researchgate.net/publication/250959492_Learning_from_Mistakes_Is_Easier_Said_Than_Done_Group_and_Organizational_Influences_on_the_Detection_and_Correction_of_Human_Error). This is unexpected because one would assume that _better_ performers would make _fewer_ mistakes. In fact, the number of mistakes isn't what distinguishes higher-performing teams, but rather it's their attitude towards discussing – and learning from – their failures.

I've spent the past eight months reading more about [psychological safety](https://en.wikipedia.org/wiki/Psychological_safety): the shared belief that team members won't be punished for speaking up with mistakes or questions or ideas. As a result, I've been trying to operationalize psychological safety on my own team, and part of that includes discussing and learning from our mistakes. At Artsy, we candidly discuss site outages or production bugs on the web, but haven't historically been great at communicating about iOS problems.

I want to start doing more retrospectives after things go wrong. So this week, I held my first iOS retrospective.

<!-- more -->

It consisted of three parts:

1. Preparation.
1. A meeting.
1. Follow-up.

Let's discuss each one. And remember: the most important part of a bug retrospective is to _learn_. Encourage others to ask questions, or propose ideas.

### Prep Work

Prep work involved adapting Artsy's [site outage post-mortem](https://artsy.github.io/blog/2014/11/19/how-to-write-great-outage-post-mortems/) for this less serious bug. I drafted a short document with the following information:

- **Summary**: A short paragraph about what happened, and a timeline of when the bug was reported, when it was first introduced, when it was fixed, and when the fix was submitted to the App Store. Include screenshots if available.
- **Cause**: Technical details about the cause of the problem. Include code snippets if appropriate.
- **Resolution**: Technical details about the fix for the problem, including links to pull requests. The fix was one-line, so I included a git diff as well.
- **Post-Mortem**: A discussion of what contributed to the bug, and how can the team can avoid those problems in the future.

Remember, each section is frame around learning from what went wrong with the goal of preventing similar issues from happening in the future.

The preparation took me about a half hour, but would have been faster if I had taken more notes earlier. The bug in question had taken place three weeks ago – I wish I had held the retrospective earlier.

### Meeting

I invited our Auctions dev team to the meeting and our product manager, but I made it clear that everyone's attendence was optional. During the meeting, I went through the retrospective document I had prepared, answered some questions, and took some notes for further follow-up.

### Follow-up

After the meeting, I addressed the follow-up items. In our case, this involved fixing a problem where our staging servers use data that's not reprepsentive of the data used in production. Additionally, we've made changes to how we test certain scenarious in our iOS app.

Finally, I shared the document with the wider team. In this case, it was the Auctions Operations team. As a developer, I want to empower my teammates to understand why software sometimes behaves unexpectedly.

---

So when should you do a retrospective? The answer is "probably more often than you do now." I know our team could benefit from more of them, and I think the Artsy Engineering team could too. I'm not concerned about doing them too often – I would rather that than not doing them enough.

Remember that the benefits of a retrospective aren't limited to learning from a single mistake; retrospectives encourage a _culture_ of learning from mistakes, which (as Edmonson discovered in hospital settings) is far more valuable.
