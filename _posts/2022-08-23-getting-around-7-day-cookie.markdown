---
layout: epic
title: "Hacking Around Safari's 7-day Cookie Limit"
subtitle: What we learned while trying to fix our cookie consent banner
date: 2022-08-23
categories: [Privacy, Cookies, GDPR, CCPA]
author: [chris]
---

Amongst the many, many things that organizations have to contend with around
cookie consent laws is Apple's very own browser, Safari. Did you know that
Safari will only retain a client-side cookie for 7 days? This is in support of
Apple's [Intelligent Tracking Prevention (ITP)][itp] feature, designed to
protect a user's privacy.

These privacy efforts are great but, in hand with laws like [GDPR][] and
[CCPA][], their rollout often creates a UX nightmare for users without some
extra care. Here at Artsy, we've landed on a way to make things slightly less
bad and want to share our approach.

<!-- more -->

Scenario: Imagine that as a EU resident you visit artsy.net for the first time.
A banner appears asking you to `Accept` or `Deny` tracking cookies from our
site. You don't like tracking cookies, so you click the "Deny" button and the
banner disappears. All good, right? Nope! You visit Artsy a week later and
again, a banner appears asking you to choose your preferences. This happens
again and again until you switch browsers and realize that what you were
experiencing was Apple's ITP feature in action. After choosing your preferences,
the cookie we use to store them is erased after 7 days, necessitating another
interaction.

We thrashed around in this vicious cycle for months until we found a simple,
elegant solution thanks to a WebKit engineer's prompt (during Apple's open lab
calls at WWDC -- [which you too can schedule!][labs]) She mentioned that the
7-day cookie limitation only applies to _client-side cookies_ and that
**same-domain, secure, server-side cookies** are not limited to these
constraints.

This got us thinking. Our third-party cookie consent management service sets a
client-side cookie, not a server-side cookie. Could we perhaps overwrite the
client-side cookie with a server-side cookie _of the same name_ and trick Safari
into persisting the user preferences beyond the 7-day limit?

We gave it a try and... Yes. We. Can! And this means that you can too (and it's
also real easy to implement).

---

First, define an API endpoint server-side:

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

Next, call the endpoint from the client when your app boots or when preferences
have been set by the user:

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

And that's it. I'm not sure of the exact reason why we can overwrite cookies in
this way, but I suspect it has to do with Safari's assumption that a server we
control will always take precedence and thus assumes things are safe. And in 7
days, when Safari would otherwise erase the cookie, it will see that it's now
`secure` and ignore it, preserving the user's preferences.

[ccpa]: https://oag.ca.gov/privacy/ccpa
[gdpr]: https://gdpr-info.eu
[itp]: https://clearcode.cc/blog/intelligent-tracking-prevention-faq
[labs]: https://developer.apple.com/wwdc22/labs/
