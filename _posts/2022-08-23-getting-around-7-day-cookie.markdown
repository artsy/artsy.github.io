---
layout: epic
title: "Hacking Around Safari's 7-day Cookie Limit"
subtitle: What we learned while trying to fix our cookie consent banner
date: 2022-08-23
categories: [Safari Cookies Consent Banner]
author: [chris]
---

Amongst the many, many things that organizations have to contend with around
cookie consent laws is Apple's very own Safari. Did you know that Safari will
only persist client-side cookies for 7 days? This is in support of Apple's
[Intelligent Tracking Prevention (ITP)](https://clearcode.cc/blog/intelligent-tracking-prevention-faq),
designed to improve user privacy.

These privacy efforts are great for users, but in hand with laws like the
[GDPR](https://gdpr-info.eu/) and [CCPA](https://oag.ca.gov/privacy/ccpa) they
create a UX nightmare for users. Here at Artsy we've landed on a way to make
things slightly less bad and want to share our approach.

<!-- more -->

Scenario: Imagine you're a resident of the EU and visit Artsy.net for the first
time. A banner appears asking you to `Accept` or `Deny` tracking cookies from
our site. You don't like tracking cookies, so you click the 'Deny' button and
the banner disappears. All good, right? Nope! You visit Artsy a week later and
again, a banner appears asking you about your preference. This happens again and
again until you switch browsers and realize that what you were just experiencing
was Apple's ITP in action; even though you've rejected tracking cookies, the
cookie we've used to store your preferences is erased after 7 days,
necessitating another interaction.

While pondering how to work around this UX issue we landed on a pretty simple
solution, prompted by a comment from a Safari Engineer we were able schedule a
conference call with. She mentioned that the 7-day cookie limitation only
applies to _client-side cookies_, and that **same-domain, secure, server-side
cookies aren't limited to these constraints**.

This got us thinking. Our 3rd party cookie-consent management service sets a
client-side cookie, not a server-side cookie. Could we perhaps "hijack" the
client-side cookie with a server-side cookie _of the same name_ and trick safari
into persisting the user preferences across the 7-day limit?

We gave it a try and... Yes. We. Can! And this means that you can too. (And it's
also real easy to implement.)

---

First, define a server-side endpoint:

```tsx
const app = express()

app.get("/set-tracking-preferences", (req, res) => {
  const { trackingPreferences } = req.query

  const cookieConfig = {
    maxAge: 10000000,
    httpOnly: false,
    secure: true, // important!
  }

  if (trackingPreferences !== "undefined") {
    // Overwrite client-side cookie with cloned, secure server-side version
    res.cookie("trackingPreferences", trackingPreferences, cookieConfig)
  }

  res.send("Tracking preferences set.")
})
```

Next, call the server-side endpoint from the client when your app boots or when
the preferences have been set by the user:

```tsx
import cookies from "cookies-js"

const App = () => {
  useEffect(() => {
    const trackingPreferences = encodeURIComponent(cookies.get("trackingPreferences"))

    fetch(
      `/set-tracking-preferences?trackingPreferences=${trackingPreferences}`
    )
  }, [])

  return <CookieConsentBanner onClick={...} />
}
```

And that's it. While I'm not sure of the exact reason why we can overwrite
cookies in this way, I suspect it has to do with Safari's assumption that a
server we control will always take precedence thus assumes things are safe. And
in seven days, when Safari returns to erase the cookie, it will see that it's
now `secure` and will ignore, preserving the user's preferences.
