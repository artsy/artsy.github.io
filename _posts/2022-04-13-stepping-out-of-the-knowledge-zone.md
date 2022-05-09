---
layout: epic
title: Stepping Out Of The Knowledge Zone
subtitle: How I went out to face my fears
date: 2022-04-13
categories: [teams, velocity, integrity, cypress, forque, horizon]
author: [kaja]
comment_id: 715
---

As I am writing my first blog post for Artsy, here is a short introduction on who I am: My name is Kaja and I am an
engineer in our Berlin entity. As a Ruby-born programmer I am calling myself a backend engineer, but that also may
change and is more about emotional identification and less about what I actually do (as you will see in this blog
post). My background is not in engineering at all. In university I graduated in philosophy and historical
linguistics, both the most impractical but most beautifully theoretical subjects I can think of. I really love
being in the world of ideas and thought experiments that challenge the current status of what _is_, as opposed to
what is _thinkable_.

<!-- more -->

At Artsy I am currently working in the PX (Partner Experience) Team and since I joined 1 year ago, most of my time
in the PX team has been dedicated to the implementation of the Artsy Shipping feature. In the backend I helped
tying the ties between the external ARTA-API (a white glove shipping company) and our own service that is managing
the shipping and order statuses of the artworks that are ordered online. In the front end I implemented some forms
for that feature and some so called hooks. I felt like a fish in the water with these tasks, because the company
that I had worked at before was a shipping company and I did the same thing from the other side of the API
relationship. In the same language (Ruby on Rails).

Here is another fact about me that is a premises for what comes next: I enjoy to be a learner of new things much
more than being an expert about things that I already know. Of course being an expert is also flattering the ego,
but after a while it can feel repetitive and make your soul feel old and tired. While the experience of being new
to something and not an expert at all can give you a rejuvenating prickle. On the other side it can be scary to
admit not knowing something and also the ego will feel small and hurt. But I learned that overcoming the hurt ego
is my way to happiness in life and I am practicing every day to let go of the idea of me being the admirable expert
and commit to the philosophical open mind of the "The only thing I know, is that I don't know.".

In the search of something new that I don't know I stretched out my feelers\* and wanted to continue my learnings
in Elixir. At my previous job I had done quite some work in that new language and still felt non-experty enough in
it to feel the prickle of learning it. It turned out to be a bit difficult since there were not many people around
me able to pair and guide me through some problems and the actual work to be done there did not appear to have
enough priority to be taking so much of my work time.

One thing I personally care a lot about is the general health of the code base and that the whole machine of a
distributed system is well oiled and working in a way that makes it easy to contribute to. This is why I also
really care about updating dependencies and feel personally in charge of doing that without anyone giving me this
role. That care and my first rotation at Artsy has made me cross the paths with the velocity team several times. I
understood that the care for the health of the code base is a shared emotion with the velocity team members and I
felt heard when they picked up this urgent topic in a platform practice (an open somewhat informal meeting for all
the devops/infrastructure things). My curiosity for the velocity team grew.

But did I reach out to the velocity team to ask for some collaboration on the dependency updates? No. You have the
privilege of having a female perspective here in the blog post and I can give you some insights on the barriers for
me as a woman in tech. While the PX team is well equipped with women engineers, the velocity team only consists of
men. This plus the aura of tech-geniuses that usually surrounds the people who do devops from the perspective of an
engineer made me feel nervous and shy to reach out to the velocity team members.

Another thing that happened was that during some of these beloved dependency updates I had to change the docker
file of the project, because I needed a newer ruby image. The ruby image we used was a specific artsy ruby image
and we did not have one for the ruby version that I needed, so here I had to go and change the whole docker file
set up. I did not know much about docker and what all these funny `RUN` commands actually did and just tried and
guessed and broke stuff as I went along and at some point got stuck. So naturally I reached out to our dev-help
channel and was quickly having the help of Andre, our velocity team member in the German time zone. He paired with
me and explained the docker commands on the go and made everything seem so simple and straight forward, while also
being super nice and approachable talking about his cat and his favorite Brazilian food, that I had to question my
own prejudice about the velocity team members and come to the conclusion that they might all be men and super good
at what they did, but that at least one of them was really good at demystifying stuff and helping me out.

The new learnings about docker lit a fire in me: I wanted to learn more of this mysterious world of infrastructure.
After letting the thoughts and feelings simmer for another week or so, I had a 1:1 with my manager Christian. He
has some magical question asking powers that truly trigger introspection and I ended up hearing myself say to him:
"I wish I could do something like an internship in the velocity team!". Here it was. The actual wish had formed
into something that is actionable and as I learned totally possible. My Manager did some magic managing and _piff
paff_ here I was starting my 2 sprint (4 weeks) rotation in the velocity team!

At first I was still a bit scared and nervous. Would I be able to contribute anything or would I just be an
annoyance to the team? Would I make a fool of myself and be branded as a stereotypical woman who doesn't know
anything about tech (this is coming from many years of being perceived as a person without any tech skills). I
latched myself onto the thought, that Andre would be the person that I could talk to and that I knew he was not
going to bite my head off. I also realized in the organizing process that there was Matt Jones, another velocity
team member, who was reaching out to me and being super open and kind and having great communication skills and it
made me feel less scared.

The first week came up and I found myself in meetings with the velocity team mostly listening at the beginning as I
was lacking some context in the conversations, but not feeling super weird as I saw that there was nothing of the
expected mysterious witch craft happening but a very straight forward Kanban board where the only unknowns where
some names of tools that I had not used before. I was also glad to see some of the faces in the meetings showing
signs of human struggle like tiredness, a very relatable thing. During my first week I didn't really know what to
do as some of the tasks suddenly got blocked or changed or appeared to be already solved and the only thing that
kept popping up as a suggestion was to do some work on integrity, our little QA robot that automatically clicks
through the staging interfaces and checks if it behaves as expected. The general reasoning of people in the team
was "I don't really know javascript and this cypress stuff, so it would be cool if you can take over some of the
integrity tasks". I was still too shy to loudly admit that I myself was also not knowing anything about JS or
cypress. I felt that as a web developer coming to the velocity team they would think, but is there anything that
she knows if she doesn't know docker nor JS??

Matt Jones asked me for feedback on my first week as he wanted to make sure that this was a useful learning
experience for me and I told him openly that I felt a bit confused on what my tasks were and that I also didn't
know how to fix these tests in integrity and that the only other task that was assigned to me was seeming like a
dead end to me. That other task was to implement a new user role into something that is called the _old admin_!
Somehow this made my neck hair stand up. Implementing a new feature into a half way sunset service? I looked into
the code to see if this would be simple and straight forward and saw myself confronted with somewhat outdated
coffeescript and felt a cold shudder.

The second week began and as Matt had made me join some meetings on discussing how and if we should set up an
Artsy.net local docker container for the development and what other services than force (our main service for
Artsy.net) would be useful to the engineers that usually worked on force. It was an interesting learning experience
especially because Elena, the engineering Manager on the velocity and data platform teams, was asking some really
good critical questions that made me realize there was more to it than just a simple docker run for a single
project. She mentioned problems with node and the usability of the development environment, talked about previous
experiences with such aims and how it was not working as smoothly as imagined.

The second week in the velocity team also brought along some team building time. I joined a coffee call and it was
super interesting to finally also feel like I was getting to know the other mysterious team members of velocity. We
talked about our international backgrounds and it was great to hear so many stories about where people had come
from and what languages they had grown up with. This finally was melting my heart for the team and I lost my last
little bit of fear and shyness.

As I then started to look at integrity and list some of the tests in it that were flakey Joey, our director of
engineering, was helping me out leaving meaningful hints and comments on my notes. This plus the recent successful
coffee call with the team encouraged me to my next very risky step: In a meeting called "velocity mob session" I
proposed to the team members to mob together on some problem of integrity actually not being able to run certain
tests from two instances in the same time. It felt risky and scary driving a mob session in a repository that I
wasn't familiar with, reproducing a problem that I wasn't fully understanding and trying to solve it in a
language/framework that I was not an expert in. But the risk was totally worth it. It turned out to be a super
interesting and fun and collaborative mob session and we actually figured stuff out together with the whole team.
Nothing feels better than having a whole team figuring something out together. It really bonds to see stuff
happening as a shared experience.

The third week started and in a standup I admitted that I had not been following up on implementing a new role into
our _old-admin_ because I felt uneasy to add something new to a project that was stuck in a weird mid-deprecation
state. The team reacted quickly with a super good idea: Instead of adding something to the _old-admin_ I should set
up something that was going to be the new-admin in our environment so that people could contribute to it on the
upcoming hackathon. I was thrilled! Never have I witnessed the birth of a new project at Artsy and now I was
supposed to set the whole thing up and go through each step of putting it out there? Awesome! Also I had absolutely
no idea what that meant. Did I need to do some dangerous mystic exploration into the far away field of our system
being set up in kubernetes or something? I wasn't sure. All I had in mind were these complex huge graphs of our
system and how all the services were connected. How could I add another service into this huge spider web?

The first helpful thing was a little check list that Joey gave me of things that had to be done. Breaking the task
down into smaller task definitely already demystified the whole thing a bit. It looked something like:

- get typical local development working
- get `hokusai dev start` working (i.e., local development on docker)
- create staging deployment(s) and get them working
- CircleCI
- create production deployment(s) and get them working
- set up the project in [Horizon](https://github.com/artsy/horizon)

Also I knew that Roop was the point person for this project and had started setting up the github repo so I started
to set up the project locally myself and then went to reach out to him for my questions that had come up. This is
how I had my first ever pairing session with Roop and it was so much fun. After having the project working for me
locally I was informed that Devon had already put a tutorial video out there on how to set up a new project with
[hokusai](https://github.com/artsy/hokusai) in the artsy system. I watched the video and followed the steps along
and when I got stuck reached out to Devon directly and there I was having another interesting and fun pairing
session on setting up a new project with hokusai.

As you can see each step demystified this task further and further so that in the end after another bunch of fun
pairing sessions with Jian and Joey I got the new admin deployed and ready just in time for my week four of the
rotation: The hackathon week! During that week I was continuing my integrity work, pairing with different people
from different product teams on the flakey cypress tests and in the same time doing my own personal favorite
hackathon project: Updating dependencies in our code base. I will basically use every excuse I get to update our
dependencies, because they just need that love and I believe that we can get the code base to a point where it is
not so painful anymore to keep stuff up to date.

As the end of the fourth week came up, so did my end of the rotation with the velocity team and I was sad to leave.
I asked the team members to give me some feedback and was hoping to be able to work on the new admin and on
integrity and on the Artsy local docker stuff more in the future.

The following weeks some awesome feedback came in and I was glad to see that I was not the only one really enjoying
all the nice pairing and good times on the velocity team. As much as I like the PX team and also missed them, I
secretly hoped that some day in the future I could switch over to velocity in the long term. I knew now that I
would be learning so much and that none of this was scary anymore. And then it came: An email from Elena saying
that the velocity team was internally searching for a new member! Maybe the timing was just right, maybe the
universe just loves me so much... I don't know, but my wishes became true and I am now moving over to velocity. I
guess sometimes it is really worth leaning into the scary unknowns and going all the way there to see if it is
really so scary.

\*"Die Fühler ausstrecken" = German _to stretch out your feelers_ stands for "to prudently try and see something
that you don't know" as a snail would do to find her way forward very slowly and retreat from something unpleasant.
