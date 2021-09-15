---
layout: post
title: Launching a Security Bug Bounty Program at Artsy
date: 2014-09-24 12:21
comments: true
categories: [Security,Best Practices]
author: db
---

Many established companies have bug bounty programs, including a recently publicized [Twitter Bug Bounty](http://www.forbes.com/sites/kashmirhill/2014/09/10/bug-bounty-programs). Some use services, such as [HackerOne](https://hackerone.com) or [BugCrowd](https://bugcrowd.com). In early September 2014 we quietly launched [our own Security Bug Bounty](https://artsy.net/security). Since then we have fixed 14 issues reported by 15 security researchers and paid $750 in bounty. In the process we have learned a ton and wanted to share some things that would have probably done a little bit differently, knowing what we know now.

In this post I will focus on both technical and non-technical takeaways, and will provide an extensive list of vulnerabilities that should have been dealt with before launching our bug bounty.

<!-- more -->

## Before You Begin

Our security bug bounty program started with an engineer (myself) creating a [document](https://artsy.net/security) on our website, largely inspired from other bug bounty programs. Our staff attorney wanted to review and edit it, something that definitely needed to be done.

A less evident step was to have a conversation with the finance department about whether or not bounty could be paid to individuals living in countries that may have U.S. sanctions imposed on them (see [What countries do I need to worry about in terms of U.S. sanctions?](http://www.treasury.gov/resource-center/faqs/Sanctions/Pages/answer.aspx)). We also needed to talk about the terms under which reward payments could be made at all - we now require the individual's full name and postal address. Other bounty programs, including [Github's](https://bounty.github.com/), require a [W9](http://www.irs.gov/pub/irs-pdf/fw9.pdf) for U.S. citizens or a [W8_BEN](http://www.irs.gov/pub/irs-pdf/fw8ben.pdf) for non-U.S. citizens before any payment can be made (we may start doing this as well).

Another question raised was regarding budget and how much money I expected to pay. With about $50 a bug I estimated that this program would not exceed about $1,000 in the first few months, with an initial spending spike, because with time bugs would be harder to find. This was the wrong way to think about it - hacking is a skill and better hackers are paid more to spend more time on a single issue. We are now receiving only a fraction of bug reports, but new issues typically required much more effort to engineer. Those cost us more money, proportional to potential reputation loss. To sum this up, I recommend budgeting a fixed quarterly amount and using it as a reference to cap the maximum amount of dollars paid for a single issue.

It should be clear that every dollar of the $1,000 spent each month is worth every penny when you consider having exploitable security vulnerabilities in your production systems.

## Security Bug Bounty Services

I have looked at the many bug bounty services and were quite impressed with their offerings, their ability to automatically recognize duplicates and to report on a security researcher's reputation. However, I didn't want to add yet another service in the plethora of services that we already use and wanted to have some brand control. In all honesty I do not know whether rolling out our own was or wasn't the best decision, but we're getting security bug reports, fixing real issues, and that's what matters.

## Full Time Attention Required

The early days of the bug bounty program needed full time attention from one engineer who knew the entire system very well. This meant reading every report, triaging it as something new or already known, and opening detailed issues in the internal bug tracking systems. We labeled every issue as "Security Bounty" and created a "Security Bounty" project in Pivotal Tracker for issues that span multiple projects. We also found it useful to keep a Google Docs Spreadsheet to track the individuals reporting issues in a way where you can easily copy-paste all the issues that they have reported into an email to give them an update. [Here's such a blank spreadsheet](https://docs.google.com/spreadsheets/d/1_Bq0jMImwU_r2-R76d2vqsYPLt9AB02lz2ZowK77yHc/edit?usp=sharing) with some formulas that can instantly tell you how many issues were opened, fixed, etc.

## Communicating the Program to the Team

After running the program for a week I sent an email with a bit of statistics and explanations to the entire team. The entire e-mail can be found [here](https://gist.github.com/dblock/5781f9b4931191de42b4), and if there's one thing you retain from this post, that should be it. The e-mail was extremely well received, highlighting both the importance of explaining all-the-things to the rest of the company and being very transparent about such sensitive issues as security.

## Classes of Bugs

While we were very diligent about large classes of potential vulnerabilities, such as SQL injections, most issues reported by the independent security researchers were also avoidable and should have been fixed before launching the program. Other issues should have been reviewed and acknowledged as a known, but acceptable risk upfront as well.

### SSL, Secure Cookies and HSTS

If you let users signup and log-in or enter any personal information, your entire site must run under SSL. We were half way through this transition with some services still open for both SSL and non-SSL requests. Also you must enable [HSTS](https://scotthelme.co.uk/hsts-the-missing-link-in-tls), so that browsers that have visited your site before make an SSL request even if the user typed a non-SSL address, avoiding leaking session data over an insecure connection.

In Rails, HSTS is turned on with `config.force_ssl = true`. In node.js applications we use [an HSTS middleware](https://github.com/artsy/force/blob/master/lib/middleware/hsts.coffee) combined with [a redirect middleware](https://github.com/artsy/force/blob/master/lib/middleware/ensure_ssl.coffee), but you might also want to check out [helmet](https://github.com/evilpacket/helmet).

Redirecting from HTTP to HTTPS is a compromise, it allows existing non-SSL clients and the myriad of existing links out there to keep functioning, however it exposes users to a potential risk of sending data over a non-encrypted connection, first. This is mitigated by using HSTS and by making sure session cookies carry a `secure=true` option.

### Clickjacking Vulnerabilities

Make sure your site is not vulnerable to clickjacking. These attacks rely on loading the target page in an `iframe`. A simple test is to try to embed your site in the [code in this gist](https://gist.github.com/dblock/8a91f805e97ba2325278).

The standard and very simple fix is to deny framing by using the `X-Frame-Options` header with a `SAMEORIGIN` or, better, `DENY` value. There's a rather advanced explanation of this problem and the difference between these two values in an article about [clickjacking Google](http://webstersprodigy.net/2012/09/13/clickjacking-google). This is enabled by default in Rails, and can be turned on in node.js applications with [helmet](https://github.com/evilpacket/helmet).

### Cross-Site Scripting and Content Security Policy

Spend time looking for Cross-Site Scripting (XSS) vulnerabilities in your code. The majority could have been known by actually attempting to enter JavaScript into the few user inputs that we have and then going to the pages that display that content. Then examine the code for any instances that render raw HTML, usually via `!=` in Jade templates or HAML. Track down how this data is inputted into the system and check whether these need to really be raw HTML. As a rule of thumb, do not trust the data in your database or data returned from your API, and encode or sanitize HTML when rendering it. We use the [Sanitize](https://github.com/rgrove/sanitize) gem in Ruby, as well as a [fix in our open-source front-end](https://github.com/artsy/force/commit/0902c3450a0de60ee2b3e45a08e2dab656b31d86) for how to deal with this in a node.js app.

Content Security Policy (CSP) also helps prevent cross-site-scripting. You can add a `Content-Security-Policy` header, or its variations, `X-WebKit-CSP` and `X-Content-Security-Policy`.

### Preventing User Abuse

Log-in as a user, note their session cookie and log the user out. If you can reuse the session cookie in a new browser, your're not actually logging users out. This is particularly problematic on public computers and seems to be an issue often exploited by man-in-the-middle malware. To fix this, you must track sessions server-side.

Another similar problem is that all user sessions must be invalidated when a user resets their password. Imagine that you suspect that your account has been compromised, changing a password should make you safe again and the attacker who logged in as you earlier should be logged out. This is something natively supported by many session management implementations, including Devise, by adding a "salt" stored with the user record into the session cookie and comparing it after a session is deserialized.

Finally, make sure you either lock accounts or throttle after too many login or password reset attempts.

Another related example is when attackers can spam users with legitimate requests, such as password resets. For example, we didn't [restrict how many SMS messages one can send](https://github.com/artsy/flare/pull/12) on our iPhone app download landing page. This particular instance had no actual benefit for the attacker, but could have really hurt our reputation. What would you say if a paying customer reported being spammed with anything coming from your company?

### Open Redirect

Review all HTTP redirects in your applications. A common problem is when you can supply a URI and be redirected to it after, for example, a social login. This, combined with an XSS, would leak your session cookies, so don't ever redirect outside of your application. Furthermore, this can be a source of an XSS by itself with data URLs, something I had never seen before.

### Mixed Content

Make sure the secure (HTTPS) pages aren't loading insecure (HTTP) javascript. A man-in-the-middle attack would enable injecting JavaScript into, otherwise, secure pages. Don't forget to check your error pages.

## Issues We Won't Fix

We attempt to fix every reported issue, even very small. A single vulnerability may not be a problem in isolation, but may be exploitable in combination with another unknown issue. Still, we want to be able to disagree with the risk assessment of the security researcher. Such issues require a detailed explanation in a well articulated and prepared response, as well as a mention in a list of issues not eligible for bounty in our program's description. Here're a few examples.

### User Enumeration and Discovery

Attackers often obtain databases of user e-mails and try to use those on other services with password dictionaries. When users enter the wrong password on login, you're supposed to be returning the same error message whether the account exists or not. While that would prevent user enumeration and make password attacks impractical, it's terribly unhelpful to the person trying to access your website. Many sites choose not to fix this, including Artsy. After-all, we will eventually have all of the 11 billion people on Artsy and the issue will be moot!

### Cross-Site Request Forgery

CSRF is a class of attacks that attempt to force a user to execute unwanted actions on a web application in which they are currently authenticated, often without their knowledge. This can be mitigated by ensuring that the action was triggered from a legitimately rendered page within a certain period of time. CSRF was disabled on Artsy following some complicated technical issues related to caching, and is something that would cost us a lot of time and effort to bring back. It's a real problem, but not a critical one, so we explicitly list it in our bug bounty rules as ineligible for bounty.

### User Identity

One of the most frequently reported issues is that we don't require e-mail verification, which is by design on Artsy. We used to have email verification, but too many users found it confusing and would never confirm their e-mail addresses. We treat emails as usernames, without any additional level of trust except for manually verified users, something internal to our systems.

### Sender Policy Framework

Having a Sender Policy Framework (SPF) record increases the chances people will get emails you send. Without one, your email has a greater chance of being marked as Spam. Adding an SPF may not be as simple, especially if you use multiple thirdparty services for delivering e-mail. Furthermore, it might make forwarded e-mails go to spam.

## Acknowledging Security Researchers

While most security researchers do an amazing job reporting issues, there's an unfortunately some number of bounty hunters who will dramatize issues or nag you for bounty payment or swag every other day. Many don't understand why it takes two weeks to get paid, why you disagree on their assessment of the problem, or will think that you're lying to them when you say a bug has been reported in the past by another security researcher. These are annoying and often discouraging exceptions.

I believe in the need of acknowledging the hard work done by the security researchers by listing their name on our security page, unless they don't want to. I want to thank each and every one of them.

I also do believe in the need to increase transparency into your process by listing the general category of issues after they have been fixed. I want users to trust us based on real data rather than on us just saying that we care about users' security and privacy. I think everyone understands that software has bugs, and I don't see any good reason to hide the security ones after they have been fixed.

## In Conclusion and a Word About Education

A security bug bounty helps our systems be more secure and our users to trust us more. But that alone is not enough. Overtime the complexity of every system increases and the development team grows. We can only succeed at earning our users' trust if we actually spend time on security as a team. This includes teaching individual contributors how to avoid similar issues or entire classes of problems. I strongly encourage you to make a lot of extra effort to explain exploit vectors to all developers, using the issues reported by the Security Bug Bounty program as a starting point.
