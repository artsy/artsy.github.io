---
layout: epic
title: "Collaborating Across Time and Space"
subtitle: "something!!!"
date: 2025-02-06
categories: [Pair Programming, Discovery, Tech Planning, Working Across Difficult Timezones]
author: [lidi, jackie]
---


Hey I'm Lidi and I'm Jackie (this is Jackie)
We are two engineers working on technical discovery and implementing a brand new feature at Artsy.
We work at a global company and our overlapping hours London and NY are mostly filled with team and company meetings.  We in a very special phase of our project, one where were trying to lay out a strong technical vision and foundation while our team conduct design iterations. We work closely with design and product to help iteratively build and advise the product vision.

A fun fact about us, we work closely together but we are an ocean apart.
**3,560 mi / 5729.265 kms** to be exact, so we have to be very intentional about our time and how we communicate asynchronously. In this post we will discuss our learnings and ways of working we used.*****

---

## Discuss opportunities for parallelizable chunks of work

Since our overlapping hours tend to comprise of team meetings and ceremonies, we need to highly optimize the time we have together ****** ADD MORE ***

## Ways we use our tools

# Github Branching

We have one main working branch and we branch off the main branch to explicitly show the diff of what we worked on during our own working hours. Something like using the diff to showcase ideas and ways were thinking and get clear feedback ASAP ******** This visual difference in Github's UI helped us a lot to compare different approaches for the same problem.

- Table Tennis ideas and PRs^^^ ** find an example ***

^^^Finding the smallest shippible chunks
Using the comments and papertrailing we left to write tickets and become trackable action items to keep us moving forward at a high velocity

# Self Reviews

We also heavily self review when writing our exploration code. We leave inline comments and notes of our thinking and ideas to leave for the other person to view. ****** SHOW EXAMPLES and find examples where were doing this *****

# Slack threads and Loom and More

We leave discussions in the open, use slack threads to catch eachother up for the next day and share openly for other team members to join in. Always leaving the barrier to contribute as low as possible. This in not only used for technical discussions but for ways of working ****** project planning ideas ***show examples***

- Discuss in the open, premature optimization.........taking things iteratively....discussion whats the smallest chunk of work possible to move the project forward.

*** Not afraid to call each other, keeps feedback loops tight, us on the same pages, and ambiguity small

***** add notes **

# Async Communication

Papertrailing We are leaving a lot of breadcrumbs not only for eachother but it naturally becomes useful for the larger team. Decisions are discussed in the open and documented using our tools above. Leaving a nice papertrail and generating some natural documentation as we iterate. This allows other members of the team not working on this workstream to gain context and quickly get up to speed should they join us.

We make agreements regards our next steps that work as mini-contracts between the two of us. We constantly touchbase to
review those, to interate on it and to come up with new ones. This ensures we do not step on each other's toes and it
prevents us from spending half a period working on the coding portion of an idea that the other one might not even be
onboard on a higher level. When reviewing code, we want to make the best usage of our time focusing on the solution for
a well defined problem rather than bumping heads on the problem itself.

# Discuss opportunities for parallelizable chunks of work

Iterative and using the software we are building. Testing is engrained in our working process. Also end to end testing.
One of us worked on the websockets front end integration **** add context *, while the other worked on designing a
GraphQL layer for this work**** we could both move forward without blocking the other.

One of Artsy's values, Impact Over Perfection, is crucial here. We keep that in mind to foster a collaborative environment
aiming for the biggest impact. If the feature we're coming up with requires full end-to-end implementation, we do not
want to block the client-side work by discussions around the backend patterns on a premature level. As soon as we have a
clear definition of the high-level architecture we want to achieve, we build the basic mechanism to allow the API
endpoints to return the relevant data (or to collect it). By early merging this, we unblock the client-side work to
happen in parallel to further discussions regarding the back-end implementation details.

# Overall baseline of true trust and how to build that culture

Make it work and then refactor work, in the words of Sandi Metz, we have a working culture of red, green, and refactor. Get the main goals of the code working, add test coverage to document and capture a snapshot of the expected behavior. With these pillars in place, we can freely refactor with the safey of test coverage and not do too much at once ***

We prioritise an ego-free space. Kicking off new chunks of work can be exciting, but supporting each other to get stuff
through the finish line is what makes us great as a team. If there are critical discussions, blocker issues or pending
code reviews to be made posing a challenge to one of us, the other one always prioritise these over pushing more topics
to the queue.

# In conclusion

We both truly want the same things: a successful project with expandable and healthy technology choices that are easy for others engineers to contribute to and expand (that also support an ever changing set of user needs)*****
