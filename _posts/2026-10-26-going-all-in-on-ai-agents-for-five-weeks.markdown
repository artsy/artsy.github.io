---
layout: epic
title: "Going All In on AI Agents for Five Weeks: What I Learned"
date: 2026-10-26
author: mounir
categories: [ai, mobile, engineering]
---

> **Author's note:** This article reflects my own experiences and opinions. AI helped me edit and organize the writing.

Until two months ago, I was on an infrastructure team we have at Artsy, called Sapphire. Although we were aware of everything being shipped to the Artsy mobile app, and strived to make product teams' lives easier by improving developer experience and platform stability, we didn't really build product features very often. Or at least I didn't.

I was part of Sapphire for over a year and a half. Before that, I was building products, as I had almost always done.

Right before switching to Sapphire, LLMs started getting better, and back then Sonnet 3 and Opus 3 were among the best. I enjoyed using them for small tasks, but they weren't really special without much context. I often didn't even think of using an LLM when a task got complicated, and trusted only myself with it.

Then came Opus 4.5. And oh boy.

It was the beginning of a new era. It was good. Really good. I enjoyed using it for infrastructure work, and I was able to ship a lot with it. I started really stretching it to see how far I could push it.

I was able to ship some massive upgrades to our old API gateways that would have taken an unreasonable amount of engineering time before, and build in-house alternatives to tools we were paying thousands of dollars per year for.

It changed how I build software, and made me venture into areas I don't usually touch, with far more confidence, especially for non-critical internal features where I could afford to be less meticulous about implementation details. I learned a lot, and I was really excited to apply those learnings to building products.

Then came August, and I was assigned to a product team again.

It wasn't just a regular team. It was a team built to take advantage of the latest AI models and explore what's currently possible if we change the shape of teams and remove common bottlenecks.

We had a tight deadline, one that I thought was impossible (SPOILER: I was wrong), to build a new product of moderate-to-large size: **City Guide**.

I'll leave you with a summary of how that went.

![Fireworks experiment summary for City Guide](/images/2026-10-26-going-all-in-on-ai-agents-for-five-weeks/city-guide-fireworks.png)

*One correction to the screenshot: the actual development work took five weeks, not eight. The screenshot covers the broader August 11–October 7 reporting period.*

## What did I learn from this?

The core work of software engineering remained the same. But how the work gets done changed **A LOT**.

### I should write tech plans more often

Here's what I mean by this: building a strong design initially still pays off. Even with LLM help, I prefer to design the architecture myself, or at least own the decisions behind it.

Think it through. SOLID principles still apply, and setting up the backbone of a feature correctly and applying the right design principles will make the job of your agents easier, just as it did when working with teams the old way.

But with one difference this time: you can afford to make mistakes and change the architecture, most of the time.

The good thing is that LLMs and prototyping make writing great tech plans easier, too. I can brainstorm myself and also ask multiple models to challenge my thinking, suggest alternatives, and give me an initial round of feedback before I share anything with colleagues.

### Being a PM is the new job

One thing I didn't expect from this experience was how important product management skills would become.

When building features becomes so much easier, it's incredibly tempting to keep expanding the scope. You start thinking about all the things you could add, because suddenly they don't seem that expensive anymore.

But knowing when to stop is just as important as knowing what to build.

I had to remind myself to resist that temptation, keep the scope under control, and ship things incrementally, building on top of what we already had, just as we always did before.

Another big part of my job became orchestration: breaking down work, deciding what to prioritize, delegating tasks to agents, and making sure everything comes together. Some of that orchestration can already be delegated to agents, and who knows how much more they'll handle in the future. But for now, I still need to own the higher-level direction.

And even if agents do most of the implementation, you're still part of a team. You need to keep tickets up to date, communicate progress, keep your teammates in the loop, and manage stakeholders, especially on a project moving as fast as this one.

### Prototypes speak better than words

Do you remember the times when you needed to talk to a designer or a PM to suggest something and get them to buy into it, maybe because you didn't describe it well enough, or because it was hard to imagine without building it?

Those days are almost gone. Now it's easier than ever to generate prototypes. You can simply build the thing and demo it.

Prototypes are also not just a way to showcase ideas, but a way to validate your interfaces and help validate your tech plan. You can quickly build something, see how it behaves, discover assumptions you hadn't considered, and use those learnings to improve your design before committing to the actual implementation.

This was something I found really valuable, and I think it was a wow moment for me.

### Mindset change: your imagination is the limiting factor to what you can ship

While working on City Guide, I had a request a week before release to add recommendations to part of the experience.

This is the kind of request you would usually plan months ahead, requiring special expertise, one that I don't possess. I was about to reject it. Then I decided to actually ask Fable about the effort it would take to build.

To my surprise, Fable found opportunities in existing features and old work that had already been done, and came straight back with a plan of action. I approved it as it was and instructed Opus to build it. And it worked like a charm from the get-go!

Eventually we changed the weights and improved the recommendation logic to our taste, but we shipped it.

I didn't go deep into every implementation detail or get too nitpicky about the code, and I was fine with that. Just as I'd be fine, as a tech lead, with an ML engineer building something whose inner workings I don't fully understand.

As always, it's up to us engineers to decide when to cross our T's and dot our I's, and when to be fine with some knowledge gaps. But more than ever, ownership is key here. Being meticulous is good, but it can also hurt you and become a limiting factor.

### MCP integrations

One thing I really enjoyed during this project was how much more I could do with agents thanks to MCP integrations.

Beyond QA, which I'll mention in a moment, I could have agents validate my backend live, making sure things worked before I started building on top of them. I also used integrations to create and update tickets, move them around, build dashboards, inspect tracking events, and get early signals about feature performance.

But one of my favorite use cases was something we initially missed: building a knowledge bank of everything we'd discussed and decided.

Because the project moved so quickly, and some teammates were on holiday at the beginning, we didn't properly document all our decisions and milestones as we went. Later, I was able to go back through our Slack conversations and notes and build a comprehensive Notion page with our discussions, decisions, and milestones, plus a dashboard for what's next and what's nice to have.

Agents aren't just helping me write code. They're helping me manage the engineering process around it.

### Token management

I was lucky that Artsy allowed me to use as many tokens as I needed for this project, responsibly, without strict spending limits. And I'm grateful for that freedom.

The higher-end models are often worth the cost because they're simply that good. But there's obviously a financial aspect to consider. I can imagine token usage becoming something engineering teams will want to monitor more carefully.

Things are changing fast, and I don't know where the industry will land, but I hope we don't become overly restricted in model usage just to save tokens. At least from my experience, the best models are often worth paying for.

### Investing in automated and AI code reviews

One thing that had a tremendous impact on this project was investing in automated AI code reviews.

At Artsy, we have an automated code review action that runs on every commit, reviewing different aspects of the changes.

Improving the review prompt to make it more accurate, comprehensive, and faster had a significant impact on our development process. It helped us ship faster and with more confidence, especially when most PRs weren't reviewed by humans.

I think **investing in automated AI reviews is becoming increasingly valuable as development gets faster**, and it's something we're continuing to improve at Artsy.

Another important lesson is to **document what agents get wrong**. Whenever you discover gaps, recurring mistakes, or learn something new, don't hesitate to write those findings down, incorporate them into your review process, and share them with the team. That way, other engineers can benefit from those learnings, and the whole team can continuously improve how it works with agents.

If you're curious about how we're approaching automated reviews, check out our open-source repository: [Artsy/Duchamp](https://github.com/artsy/duchamp).

### QA is faster, but the same gaps remain

One area where agents made a massive difference for me was QA.

They can spin up browser sessions, interact with simulators, test flows end to end, and even take before-and-after screenshots. QA suddenly got much faster.

But I also learned that the same gaps we had before still exist. If your QA plan is incomplete, agents can execute it perfectly and still miss important bugs.

During City Guide, we missed an Android-specific scenario in our QA flow, and that gap eventually made it into production. Fortunately, we were able to ship a fix using Expo Updates.

It was a good reminder that agents make testing cheaper, not automatically complete. **Figuring out what to test is still our responsibility.**

## Final thoughts

Five weeks of building City Guide changed how I think about software engineering.

The core principles haven't changed. Good architecture still matters, and making the right technical decisions is as important as ever.

What changed for me is how much I feel I need to know about every implementation detail.

I'm becoming more comfortable treating agents the way I treat engineers on a team I lead. I don't need to understand every line of code they write, just as I wouldn't expect to know every detail of a feature built by another engineer.

That doesn't mean lowering my standards. In many cases, I find that the newer models write cleaner code than I would myself.

But **ownership is different from knowing every implementation detail**. I'm still responsible for the architecture, the important decisions, and what ships to users.

That's the shift I'm still learning.
