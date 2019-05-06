---
layout: epic
title: "Artsy Writing Office Hours"
date: "2019-05-06"
author: [ash]
categories: [writing, culture]
---

Welcome back to my series on writing for engineers. In the last post, we discussed [technical writing on the
web][ash_post] from an individual's perspective: how do you get started? how do you leverage the web? how do you
improve? In today's post, I want to change directions; instead of focusing on how _individuals_ write, we'll
discuss how _teams_ write.

<!-- more -->

To get started, I want to return the quote that opened up my first post. When
[interviewed by the New York Times developer blog](https://open.nytimes.com/five-questions-with-orta-therox-d5bb9659c50b),
Artsy alumnus [Orta][] said:

> One of my colleagues, Ash Furrow, is really the powerhouse behind improving the state of our public
> documentation. He runs weekly writing workshops internally and always encourages achievements as being
> post-worthy. Sometimes the best practice is to have someone who cares encouraging you. It works for me.

This post is going to pick this quote apart, but first I want to address something upfront:

**If you're thinking about helping others write, then you should do it**. Having the desire to help others write is
the only qualification for _actually helping_. You might think that in order to help others write, you should first
become a proficient writer yourself. This is backwards. I became the writing powerhouse that Orta mentions _by
helping others write_.

Let's think about this in terms of coding. When you help teach someone, _you also_ learn a lot. Assisting others
solidifies concepts _for you_ and helps _you_ hone your own skills. We recognize that engineers are ready to mentor
other engineers long before they become _experts_; indeed, it's usually _through mentoring_ that they become
experts.

This is how writing works, too.

Engineering teams really benefit from having a culture of writing (and of sharing knowledge in general). To
summarize the benefits of teams which write:

- Generally speaking, documentation is important – but writing and maintaining it is difficult. A team culture of
  writing can help make it easier.
- Public blog posts increase a team's reputation, which makes it easier for the team to hire (and onboard) new
  members.
- Teaching and learning from colleagues helps [cultivate a sense of psychological safety][p_s].

I don't want to go into detail about the benefits here, but if you'd like to learn more, you can check out [this
talk][talk].

<iframe width="100%" height="400" src="https://www.youtube.com/embed/SjjvnrqDjpM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Okay let's dive in.

## Just Show Up

> [Ash] runs weekly writing workshops.

Most of success is honestly just showing up. By itself, having a time and space set aside for colleagues to come
and write every week has pushed the team culture towards valuing writing. But it took time.

Six months after I started running weekly office hours, no one was really showing up. One or two people here and
there, but that was it. Orta said that he'd have cancelled the event by then, due to lack of interest. Here's the
thing, though: the value of the writing office hours transcends just what gets written. Having a weekly place to
come to write tells the team that _writing is important_. It says something, to have writing office hours, even if
no one shows up.

At first, writing office hours were aspirational. That's okay. There are still weeks where no one shows up. That's
okay, too. Besides, even if no one showed up, _I_ still got an hour to write, so it was definitely worth my time.

But Orta had a point: people weren't showing up, so I looked at that problem. I asked around and it turned out that
people were interested in _sharing knowledge_ but weren't always keen to write a blog post. So I changed my
approach.

Nowadays when I announce the writing office hours at our [weekly engineering standup][standup], I am clear that it
isn't _just_ for writing. I now let people know that this is a place where they can come for help with whatever
knowledge-sharing they're interested in. Let's take a look at a few examples:

- An engineer wanted to speak at a conference, so they brought their ideas and we outlined a talk proposal.
- A product manager wanted to document how Artsy's product team works, so we worked on turning that documentation
  into a public blog post.
- An engineer was planning an architecture review meeting to get the team up to speed on how some of our systems
  worked. They brought their slides and we went through the presentation together; I gave some feedback on what
  worked well and what was unclear.
- An engineer had an idea for a blog post, but the post was too big and they felt overwhelmed. They brought their
  outline and we worked to break it into several smaller posts.

So you can see that writing office hours grew to include more than just writing. And as the event helped more
people accomplish their knowledge-sharing goals, I folded those success stories into my weekly standup pitch.

I also knew I needed to make it easier to write blog posts. Lots of engineers wanted to write, but had a difficult
time starting. To help, I created some [engineering blog post templates][templates] to kick-start new blog posts.
Sometimes, engineers just didn't know where to go to write a new blog post, so I did some pairing and lunch&learns
demonstrating the blog's setup.

I still call the event "writing office hours" because it rolls of the tongue better than "knowledge-sharing office
hours", but that's basically what they've become!

## Frame Deliverables as Blog Posts

> [Ash] always encourages achievements as being post-worthy.

Here's my take: engineering work should be approached _primarily as a learning opportunity_. A traditional
engineering project might be structured around building some product, but my approach is to structure it around how
to _learn_ how to build some product. As a team learns how to build it, the product is a natural consequence of
that learning. If you're familiar with my talk on [building compassionate software][], this will sound familiar.
It's also reflected in Artsy's [psychological safety engineering principle][principles].

A byproduct of this framing of work in terms of _learning_ experiences is that it lends itself naturally to framing
work as _teaching_ experiences (ie: blog posts or other knowledge-sharing). So if you're writing a new feature, or
fixing a difficult bug, or building a whole new app, then you should be thinking about the blog post as a
deliverable for that project. At least I do, anyway. The benefit of my approach is that others don't need to share
my views on teaching and learning – as long as I'm there to support them, we can work together to share what they
inevitably learn. We'll touch more on this in the next section.

A really common response I get to "hey have you thought about writing a blog post about this?" is that "this isn't
really worth writing a post about." I disagree. Even if a subject has been written about before, it has never been
written about from _your perspective_. And short posts are valuable, too – just think about how often you'll be
searching for an answer to a question and find a short, simple blog post that's unblocked you. Here is a selection
of short, focused posts from the Artsy blog:

- [Using OCR To Fix a Hilarious Bug][ocr] (bug fix becomes a blog post)
- [Being a Good OSS Citizen][oss_citizen] (an open source pull request becomes a blog post)
- [Upgrading Volt to CircleCI 2.0][volt_upgrade] (an infrastructure upgrade becomes a blog post)
- [How To Debug Jest Tests][debug] (learning a tool becomes a blog post)

As you can see, each of these are small posts that represent significant engineering effort. Our time is valuable,
and only through sharing what we learn ([as we learn it][contemporaneous]) can we really honour the title of
_engineer_.

## Caring is Sharing

> Sometimes the best practice is to have someone who cares encouraging you.

Yup, this is the part of the post where I talk about feelings. I don't think you can effectively lead _anything_ –
not a blog, not a team – without caring about the people around you.

Another way I tried to increase attendance to writing office hours was to reach out to colleagues one-on-one to
offer my help (and mention the office hours). The first thing I did was look for engineers who _wanted_ to write
more. Artsy uses [Lattice][] to help employees accomplish their goals, so I looked for anyone who had shared a goal
related to knowledge-sharing. I found a few and reached out to them to offer my help achieve those goals.

But that was just a one-off way to find people interested in writing; what I wanted to build was an ongoing way to
encourage more blog posts. I found this _one weird trick_: just pay attention to what people were working on.
That's it. If I heard that someone had experimented with a new technology, or shipped a new feature, or solved an
interesting bug, I would contact them privately to ask if they'd be interested in writing a post about it.
Sometimes over Slack, sometimes in person.

Over the years, I've perfected my pitch:

- Emphasize the learning experience they've gone through: "That must have been a difficult
  feature/bug/investigation. Good job figuring it out!"
- Ask them if they've thought about writing a blog post (in a lot of cases, they had!): "Have you thought about
  writing a blog post about this? The engineering blog would be a great spot, or you could use your personal blog."
- Describe the value of writing: "Lots of people have faced this same issue – a blog post would be really valuable
  to the whole web developer community!"
- Offer to help and tell them about weekly writing office hours: "I run writing office hours every Wednesday at
  2:00, but feel free to ping me directly if I can help out before then."
- Emphasize that, while I'm here to help, there is no pressure to write: "No pressure, of course! I know you're
  busy with such-and-such project."

Pitching them is only the first step – I'd then create recurring reminders in OmniFocus to follow-up with every few
weeks. I'd DM them to ask how the post was going and if I could help get them to the next step. So if they were
still working on an outline, I'd offer to help them finish it. Or if they had an outline and were working on
filling it out, I'd offer to read what they had so far and give feedback. It really depended on the person and
their goals. At two reminders, I'd offer to stop reminding them if it wasn't helpful. After five or so reminders,
with no progress, I'd quietly drop them from my OmniFocus list. No shame.

It might sound like a lot of work, but it's actually just a few small recurring tasks. With a little care and the
right system for managing my own time, I might spend 10 minutes a week following up with people. The important part
is just caring about the person and their knowledge-sharing goals (whatever they are).

I would estimate that my success rate was about 50%. That's pretty great, actually! Some blog posts just didn't go
anywhere, and that's okay. Everyone is busy. Some were months-long journeys that _did_ eventually get posted. But
some blog posts grew to be much more than blog posts – in one case, it grew to an entire working group of engineers
who are now investing in everyone's capacity to grow as an engineer.

Like I said earlier, writing office hours became about more than _just_ writing.

---

We saw in the [last post][ash_post] how to become a proficient technical writer. We saw in this post how to nurture
a culture of writing on a team. It's an ongoing process – as I learn more, I'll be sure to share what I learn with
all of you. Take care.

[ash_post]: https://ashfurrow.com/blog/technical-writing-on-the-web/
[orta]: https://twitter.com/orta
[standup]: https://github.com/artsy/README/blob/master/events/open-standup.md
[lattice]: https://lattice.com
[templates]: https://artsy.github.io/blog/2017/12/01/engineering-blog-post-templates/
[building compassionate software]: https://ashfurrow.com/blog/building-compassionate-software/
[principles]: https://github.com/artsy/README/blob/master/culture/engineering-principles.md#psychological-safety
[talk]: https://www.youtube.com/watch?v=SjjvnrqDjpM
[ocr]: https://artsy.github.io/blog/2015/11/05/Using-OCR-To-Fix-A-Hilarious-Bug/
[oss_citizen]: https://artsy.github.io/blog/2016/01/28/being-a-good-open-source-citizen/
[volt_upgrade]: https://artsy.github.io/blog/2018/01/19/upgrading-volt-to-circleci-two/
[debug]: https://artsy.github.io/blog/2018/08/24/How-to-debug-jest-tests/
[contemporaneous]: https://ashfurrow.com/blog/contemporaneous-blogging/
[p_s]: https://ashfurrow.com/blog/building-better-software-by-building-better-teams/
