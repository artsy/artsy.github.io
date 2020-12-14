---
layout: epic
title: "How Artsy Hires Engineers"
date: "2019-01-23"
author: [ash, lily, steve-hicks]
categories: [people, best practices, hiring, culture, process, team]
css: dialogue
comment_id: 528
---

Interviewing is hard. Interviewers want to make sure they're hiring the person who will add the most value to their
team; candidates want to make sure they're joining a company that aligns with their goals and perspectives.

Recent trends in hiring are white-boarding sessions, trivia questions, and hours of take-home assignments. At
Artsy, we don't use any of these. We often get asked why not - and how we assess technical skill without them.

<!-- more -->

We think our interview process at Artsy is unique, but we also think our interview process is great. We'd love to
see the tech community examine its hiring practices, and hopefully to adopt some of what's made our hiring process
successful. Focusing on knowledge and facts that are already acquired is one way to approach hiring; we prefer to
look at how a person can fill a gap in our team and help us grow.

<aside class="dialogue">
  <div class="question">
    <h3>What surprised you about the hiring process at Artsy while you were a candidate?</h3>
  </div>
  <div class="answer">
    <img src="/images/dialogue/ash.jpg">
    <p class="intro">Ash Furrow says...</p>
    <p>What most surprised me at the time was <em>who</em> was interviewing me. I had a teleconference screening with Artsy's now-CTO before moving on to in-person interviews. Since I was living in Amsterdam at the time, Artsy flew me to its nascent London office to meet two interviewers: a data engineer and a member of (what was then) the Arts team.</p>
    <p>I was surprised, but encouraged, to be speaking with someone who wasn't an engineer. They asked me questions to find out what motivated me, to evaluate how well those motivations would help Artsy achieve its mission. It was a natural fit!</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/lily.jpg">
    <p class="intro">Lily Pace says...</p>
    <p>Everything. I was pleasantly surprised by how different the interview process at Artsy was from my previous experiences, which felt more like standardized tests than conversations. The underlying presumption with "traditional" tech hiring practices is that candidates are somehow trying to trick their way into positions they aren’t qualified for. It's no wonder that impostor syndrome is so prevalent in underrepresented groups when the interview process is set up like an interrogation.</p>
    <p>I felt like the interviewers at Artsy had read my resume and cv and taken it at face value, so the interview was spent diving deeper into my skill-set and personality and determining compatibility, instead of trying to identify gaps in my knowledge.</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/steve.jpg">
    <p class="intro">Steve Hicks says...</p>
    <p>With 20 years (!!!) of experience as a software engineer, I've seen my share of interviews - from both sides. On the hiring side, I've said for years that technical interviews are unnecessary. If I can get a 30 minute conversation with a candidate, I feel like I can learn enough about them to know if they can do the job from a technical perspective. It's much less about knowing trivia or syntax, and much more about having the personality to solve problems.</p>
    <p>I'd never experienced that on the candidate side, though. When I did, I definitely felt like Artsy had forgotten part of the interview. Where was the whiteboard? The homework? People looking over my shoulder while I coded an anagram-checker? A technical challenge has been a part of every interview I've done as a candidate - until Artsy.</p>
  </div>
</aside>

Artsy's process of hiring new engineers was created and is maintained _by_ our current engineers. It has evolved
over time as we learn new lessons and new perspectives join our team. Our process has always been driven by a
top-down culture of respect for candidates, which aligns with
[our company values](https://github.com/artsy/README/blob/master/culture/what-is-artsy.md#artsy-values). Our team
currently has 36 engineers, and we refreshed our hiring practices last year to support our team's growth; we hired
a dozen engineers in 2018. We don't use recruiters (though we did to hire our recent VP of Engineering).

Our former Director of Web Engineering has a blog post where he
[describes Artsy's hiring process](https://www.zamiang.com/post/learning-from-artsy-how-to-hire-awesome-engineers).
Though some specifics have since changed, the foundations remain the same.

> If Artsy has a secret sauce, it is how it hires. All else falls from the assumption that they have hired the best
> people who want to work together to achieve Artsy’s mission.

Our hiring process starts with an informational, where candidates are met for a coffee or over a teleconference
call. We have [public documentation](https://github.com/artsy/README/blob/master/playbooks/informationals.md) so
candidates can know what to expect. We do a lot of these and move candidates who we think would succeed at Artsy on
to in-person interviews. The interviews last 3 hours and are split across four 45-minute
[behavioral interviews](https://www.livecareer.com/career/advice/interview/behavioral-interviewing), conducted by
engineers and other colleagues, ranging from gallery liaisons to product managers to editorial writers. Artsy
generally, and Engineering specifically, have both significantly invested in helping interviewers be effective and
consistent; this includes documentation, question banks, and [unconscious bias](https://managingbias.fb.com)
training.

Each interviewer is given key areas to focus on, based on the candidate's background. We have documentation
specifying how to evaluate each of these areas, including example questions. These areas include, but aren't
limited to:

- Comprehension of Artsy
- Artsy company values alignment
- Ability to communicate complex ideas
- Learning and adaptation
- Self-learning and drive
- Independence and teamwork
- Systems development
- Product knowledge

After the interview, feedback is written up as quickly as possible. To limit bias, interviewers can't see each
other's feedback until after they write up their own. The write-up includes a recommendation: do you think we
should move on to reference checks? Answers are either "strong yes", "yes", "no", or "strong no"; after everyone
has completed their write-ups, the interviewers debrief and reflect on how to do a better job next time. Their
feedback is used by the hiring manager to decide whether to move on to reference checks.

Quoting again from our former Director of Web's blog post:

> Artsy believes that 'references are not a defense against hiring poorly, they are a way to hire great people'.

Artsy's reference checks are in-depth and deserve their own blog post; they are _key_ to our hiring process. We
know that job interviewers only evaluate how good someone is at interviewing, so we put a larger emphasis than most
companies on references. The most accurate predictor of future job performance is past job performance, not how
well someone can perform in an interview.

If we decide to hire the candidate, we make them a job offer. Artsy offers what we think is a fair wage based on
the local market and the candidate; we do not low-ball candidates and we don't negotiate on compensation.

## What's wrong with typical hiring practices?

There are many tactics for assessing a candidate's technical abilities, but we've found that many are unfair to the
candidate. Some strategies put unnecessary pressure on the candidate. Some select against qualified candidates who
have competing responsibilities outside work. Some unwittingly weed out underrepresented applicants, even at a time
when companies are trying to diversify their teams.

### In-person coding challenges

The intention of in-person coding challenges is to verify that the engineer can "actually write code." This
strategy puts excessive pressure on the candidate to perform in front of an audience. This is usually not a good
reflection of what the candidate would be doing if they were hired. Sometimes it **is** a reflection of the
stressful conditions on the team, and the act of applying pressure to the candidate is intentional, to measure
their ability to handle it. In either case, we don't feel like this is how we want to measure engineers; it just
doesn't reflect reality.

### Whiteboard interviews

One intention of whiteboard interviews is to reduce the stress on the candidate, because they don't have to worry
about code syntax while under a microscope. These types of interviews still lead to
[stressful conditions](https://code.dblock.org/2012/12/08/five-ways-to-torture-candidates-in-a-technical-interview.html),
though, and they don't provide a good measure of what makes a great teammate or even a great developer. Again,
sometimes the pressure is intentional, to see how the candidate reacts.

It can be very difficult to find a problem that is succinct enough for a whiteboard exercise but still reflective
of the work the candidate will actually be doing on the job. The ability to write an algorithm to search a binary
tree might be reflective of whether a candidate has a traditional Computer Science degree, but doesn't necessarily
speak to their ability to build complex interfaces or streamline performance. More importantly, whether or not they
can write a binary search tree from scratch on a whiteboard doesn't even necessarily speak to their ability to
_use_ search trees in day-to-day work. Questions like this can eliminate excellent developers who took a
non-traditional approach to their knowledge building but are still highly capable.

### Sample code

Sometimes a company will request a code sample from candidates - after all, what shows off their ability to code
better than their actual code? The downfall of this strategy is that it eliminates developers who don't have code
they can share. Many great engineers work for closed-source companies; many great engineers have family
responsibilities that prevent them from contributing to open-source at night.

It is also important to consider the insularity and biases that exist in the open source community that can make
contributing more difficult for developers from underrepresented groups. A study published in the PeerJ Computer
Science journal found that women’s contributions to open source projects were accepted more frequently than men’s
contributions when the gender of the contributor was unknown. However, when the gender of the contributor was
apparent, men's contributions were
[accepted more frequently than women's](https://code.likeagirl.io/gender-bias-in-open-source-d1deda7dec28).

### Take-home challenges

The most recent trend in hiring is the take-home exercise. The goal is honorable - have the candidate produce code
on their own time, so they aren't overwhelmed with the pressure of an audience. We’ve found that requiring this
early in the process is unfair, and including it later in the process is uninformative; by the time a take-home
challenge would be appropriate, we have already evaluated the candidate's technical skills to our satisfaction
(more on that later).

This strategy also assumes the candidate has time to work on homework. Many single parents do not for example, nor
do engineers who care for family members. There can also be misalignment on the expected time to complete a
take-home challenge. While the exercise might take a current engineer at the company 2 hours to complete, that
doesn't consider several factors: (1) a candidate might not be familiar with all technologies requested, and can
easily lose time to research and learning; (2) the candidate wants to look good, so they're likely to work longer
than you expect; and (3) the candidate might be interviewing for several companies at once, and have multiple
competing assignments to work on.

Many companies use take-home challenges early in the hiring process to shift the burden of evaluation from the
company on to the candidates themselves. This unfairly excludes lots of potentially amazing colleagues.

<aside class="dialogue">
  <div class="question">
    <h3>Why do you think these kinds of bad hiring practices are so common in the tech industry? And what sets hiring practices in tech apart from hiring in other industries?</h3>
  </div>
    <div class="answer">
    <img src="/images/dialogue/steve.jpg">
    <p class="intro">Steve Hicks says...</p>
    <p>We are very logical people in the tech industry. We want to create algorithms or heuristics for everything, including hiring. Using a yardstick like "Fizz Buzz" or trivia questions allows us to easily narrow down the candidate pool. It's a simple, intentional form of gate-keeping. The hiring algorithm is much easier to write when it's "Oh, you don't know what a closure is? Sorry, we're not interested." It's much harder to write a hiring algorithm that respects nuance: "well...it depends. Maybe you have different experiences than I do. It'll take some digging to find out if our experiences will complement each other."</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/lily.jpg">
    <p class="intro">Lily Pace says...</p>
    <p>I think the tech industry has an elitism problem, and this is reflected in the way candidates are evaluated. There’s a general feeling in some parts of the industry that what we do is different and somehow elevated from other professions, that engineering is a skill that only a select few are capable of, not something that anyone can learn with the right training and enthusiasm. Making candidates go through a gauntlet of challenges during the interview process reinforces this idea.</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/ash.jpg">
    <p class="intro">Ash Furrow says...</p>
    <p>I think when looking at the current state of the computer programming industry, and its hiring practices, we need to pay special attention to its history. The original computer programmers of the twentieth century were women, but they were <a href="https://www.theguardian.com/careers/2017/aug/10/how-the-tech-industry-wrote-women-out-of-history">systematically pushed out of the industry</a>. One way they were pushed out was through discriminatory hiring practices, especially interview questions and techniques specifically designed to exclude non-white, non-male applicants. Sadly, these hiring practices persist, even if their original motivations have been obscured by time.</p>
  </div>
</aside>

## What we do instead

In addition to the above strategies not being fair, we've found that they measure things that are secondary to what
we're looking for.

Artsy is more complicated than FizzBuzz. Too complicated for any one engineer to build, in fact. Individual
engineers working alone can’t build the software Artsy needs to succeed – they must work together. So the skills we
evaluate for are things like empathy, communication, and kindness. Not that technical skills aren’t important, but
the ability to communicate and learn is more important.

Engineers who excel at empathy, communication, and kindness can pick up the technical stuff once they're hired;
personal and interpersonal skills are harder to teach. Adding a colleague to the team who lacks these skills could
harm the culture we've built.

When you interview with Artsy as an engineer, you won't just meet other engineers and a manager. You'll meet with
people from other departments too. If you're hired as an Artsy engineer, you're going to work with folks from all
across the company - we want to make sure you can communicate with them because that's something we do every day.

<aside class="dialogue">
  <div class="question">
    <h3>How has this impacted your day-to-day work at Artsy so far?</h3>
  </div>
  <div class="answer">
    <img src="/images/dialogue/lily.jpg">
    <p class="intro">Lily Pace says...</p>
    <p>I had a negative experience in the past with a coworker who lacked empathy and boundaries and made me feel unwelcome and othered as the only woman on the team and someone from a non-traditional background. It made me afraid to ask for help and stifled my progress. This experience made me hesitant to open up to new coworkers, especially when I needed assistance. Because Artsy evaluates candidates based on empathy, communication, and kindness, I arrived with a <a href="https://medium.com/artsy-blog/what-it-feels-like-to-work-in-a-supportive-environment-for-female-engineers-3c994a001007">level of trust in my new coworkers</a> that usually takes weeks or months to develop. </p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/steve.jpg">
    <p class="intro">Steve Hicks says...</p>
    <p>In most of my previous jobs, it's taken me a while to learn who I can be vulnerable around and who I can't. At Artsy I have quickly learned that I don't need to worry about it. I feel an incredible sense of psychological safety with the Artsy team. I can be vocal about not understanding something, and I can ask for help without feeling like a burden or fool.</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/ash.jpg">
    <p class="intro">Ash Furrow says...</p>
    <p>I'm a sensitive person. I don't like pointless or inflammatory conflict – I find it distracting and counterproductive. However, I can relax and let my guard down at Artsy. My sensitivity to how others are feeling is a part of my contributions to the team, and I'm able to fold the emotional wellbeing that <strong>I</strong> get from everyone back into our team: a sort of constantly-accelerating feedback loop of good feelings.</p>
  </div>
</aside>

## But we still evaluate technical aptitude

Technical aptitude is less important to us than interpersonal skills, but it is still important. Note that we said
"aptitude," not "skills": we don't expect our engineers to already know everything about the tech stack we're
using. Instead, we expect them to have a strong ability to learn our stack and use it effectively once they have.
(This is touched on in our docs on
[what we look for in junior engineers](https://github.com/artsy/README/blob/master/careers/juniors.md).)

So if we skip all the usual tactics for evaluating technical aptitude, how do we do it? **By talking to people**.

We learn a lot about candidates in their interviews. We'll have a conversation with them about technology. Instead
of white-boarding, we ask them to describe what they like about their favorite library, or what they wish they
could change. We ask them to describe some legacy code they’ve worked with, and ask them how they think it got that
way. We’re looking for a mix of technical skills as well as empathy and an ability to communicate nuanced ideas.

## References are important to us

We also learn a lot through reference checks. Our reference checks aren't simply validation of your employment
history - they are a 30 minute-long conversation with each of your three references that go into detail about your
work history and career growth. It's quite an in-depth conversation, with questions structured to dig into
specifics about the candidate's behavior.

An Artsy reference call might include the following structured questions:

> In your capacity as [relationship to the candidate], how many people have you worked with in the candidate's
> role?

> Okay, in _just_ terms of job performance, how you rank the candidate out of that [X] many people?

> Okay, finally, what's the difference between [the candidate's rank] and number one? How would the candidate need
> to grow to get to number one?

The first question establishes the context for the reference. The second question primes the reference to use that
context when answering the next question. The third question is what we're _actually_ interested in. These aren't
easy or comfortable questions, but they give us an insight into the candidate's career, history, and areas to grow.

Fully half of our decision to make an offer or not is based on our reference checks. Artsy Engineering candidates
go through the same reference check process as anyone applying for a job at Artsy, with Engineers sitting in on the
call with Artsy's hiring staff.

### But seriously, we really care about the personal side

We also make sure every interview ends amicably. No candidate should feel bad after interviewing with Artsy, even
if we don't give them an offer. This seems self-evident to us, given our values, but it makes a lot of business
sense to maintain our reputation as an engineering team.

## Our hiring practice philosophy

One of our core values at Artsy is that
[People Are Paramount](https://github.com/artsy/README/blob/master/culture/what-is-artsy.md#people-are-paramount).
We like to think that our interview process was built to reflect this.

We see the interview process as an opportunity to build a relationship with a candidate. We talk to them to find
out if they're a good fit for Artsy, and we help them decide if Artsy is a good fit for them. Our hiring process
focuses more on human skills than most processes do. It's not perfect, but it has served us well.

<aside class="dialogue">
  <div class="question">
    <h3>Where do you still think Artsy has to grow, in terms of how it hires engineers?</h3>
  </div>
  <div class="answer">
    <img src="/images/dialogue/lily.jpg">
    <p class="intro">Lily Pace says...</p>
    <p>I think Artsy is really unique and innovative in how it evaluates candidates and I think the more we can express this in our job postings the better. Stressing alignment with our values and an ability to learn and posting fewer hard requirements are some simple ways to convey to potential applicants that we evaluate differently.</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/ash.jpg">
    <p class="intro">Ash Furrow says...</p>
    <p>I think one area we've historically struggled with, and still do, is sourcing candidates from a wide range of backgrounds. Artsy Engineering's hiring pool still draws heavily from the professional networks of existing Artsy staff; while this has a lot of benefits, it also has the potential to exclude groups who aren't already represented on our team.</p>
  </div>
  <div class="answer">
    <img src="/images/dialogue/steve.jpg">
    <p class="intro">Steve Hicks says...</p>
    <p>I agree with Ash. I think all companies hire based on their employees' networks, because that's the easiest way to find people. <a href="https://twitter.com/seldo/">Laurie Voss</a> talked about this recently on <a href="https://reactpodcast.simplecast.fm/33">the React Podcast</a>. He pointed out that diversity at NPM has been better than average since the company started; and that the ratios of diversity have been consistent from the beginning, as a result of hiring from their own networks. I'd love to see Artsy hire beyond our networks (and as a result expand our networks).</p>
  </div>
</aside>

Our hiring process will never be "finished" because we're always improving on it. Some recent improvements are
inward-facing to help _us_ get better, like:

- Starting a #dev-ersity Slack channel for talking about how to diversify our team and the industry at large.
- Integrating hiring updates into our weekly standup.
- Creating a Slack bot for engineers to monitor our hiring pipeline.
- Periodically rotating hiring managers to spread institutional knowledge and get new perspectives.
- Many, many docs written on guiding the process.

Artsy engineers, guided by our company values, created the hiring process for new engineers. Combined with an
iterative process and a desire to constantly improve, we've created a hiring process that is fair, effective, and
respectful. This kind of engineering-led approach is gaining popularity; for example, Microsoft recently
[revamped its hiring process](https://blog.usejournal.com/rethinking-how-we-interview-in-microsofts-developer-division-8f404cfd075a)
with this approach.

We hope this catches on.

So what can _you_ do? A great first step is to send this post to your HR rep. Another great step is to open source
your hiring documentation; you'd be surprised how motivating this can be, and it's a great opportunity to get
feedback from other companies. Leave a comment below, let's brainstorm on other ways to improve the state of hiring
in software engineering!

And remember: while _you_ might be motivated based on what feels "right", businesses are motivated by bottom lines.
Fortunately for us, the evidence is on our side: this is a better way to hire, for everyone.
