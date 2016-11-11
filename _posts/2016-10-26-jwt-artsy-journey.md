---
layout: post
title: "JSON Web Tokens: Artsy's Journey"
date: 2016-10-26 11:03
comments: true
author: ashkan
categories: [Authentication, JWT, API]
---

At Artsy we currently have thousands of client applications hitting our API and requesting authentication. When a user successfully authenticates through one of these clients, we want to embed basic user and application data in the resulting token rather than have to look up a session ID in the database on each request. For that we want to use JWT.

JWT (JSON Web Token) is a self-contained, secure and standard way of transmitting data between applications and clients as JSON objects. Using JWTs lets us use a standardized technology to cut our authentication workflow down by one round-trip.

We've recently switched our authentication flow to use [JWT](https://jwt.io), and I'm going to cover what they are, how we've used them and how we're handling the transition.

<!-- more -->

JWT has three separate sections which are separated by `.`: header, payload and signature.

`<header>.<payload>.<signature>`

Once decoded:

- The header section contains JSON defining the type of token and how to treat its contents.
- The payload section includes _claims_ and data provided by the token issuer about the user and application (things like token expiration time, user id, etc.)
- The signature section is used to verify the sender of the JWT and make sure token wasn't modified along the way.

![JWT example](/images/2016-10-26-jwt-artsy-journey/jwt-example.png)

<a href="https://jwt.io/introduction/" target="_blank">JWT</a> and <a href="https://tools.ietf.org/html/rfc7519" target="_blank">RFC 7519</a> provide more details about each section of JWT and how encoding, decoding and verification work.


# Where we were

After a successful login, our API would generate a custom JSON object including some basic information about the user and application, then encrypt it using a single server-side secret.

For every authenticated request we would have to decrypt the token, make sure the user and application were valid and the application still had access to our API. We were already _stateless_ since we didn't store tokens in our database. However, client applications had to make an API call to get any information about the authenticated user.

# Where we are going

We want to keep our current auth flow which is already stateless (tokens are not stored in database) and mainly replace our in-house generated access token with a more standard JWT. This let's us:

- Allow client applications to decode and use basic information from our token. This wasn't possible with our custom encrypted token. With JWT, each app can decode the token and get basic data out of it, check if the token is expired or not, etc. If the client wants to make sure a token is still valid, it can still call the API, like before, to re-validate and get more data about it.
- Possibly include different data in JWT payload for different applications. Some clients may request user roles with respect to galleries and others with respect to auction houses.
- Follow a well-defined standard and use existing libraries for creating and reading the token. JWT has a decent set of reserved _claims_ which can be used to describe the token in a unified language. A few examples:

  - `exp`: Expiration time.
  - `iat`: Time the token was issued.
  - `iss`: Issuer of the token (ex. our main API)
  - `aud`: Audience of the token (ex. our mobile application)
  - `jti`: A unique identifier for the token

Most JWT libraries honor these claims and can automatically validate them so we don't have to handle things like expiration ourselves.

In our new approach, every client application has its own secret key. When we get a new login for a specific application:

- We find the application in our database to make sure it is still valid and has access to our API.
- We use the application's secret key and generate a JWT

When we get an authenticated request:

- We decode the JWT without verifying the signature.
- From the JWT payload we get the `aud` (audience) attribute defining for which application this token was generated.
- We fetch the client application corresponding to the `aud` and verify the JWT's signature using that application's secret key.

# Transition

Changing authentication tokens can be tricky when we already have many clients using our old access token format. It turns out that since we aren't changing the authentication flow, it's easier than we might expect. We simply have to continue decoding the legacy token format until they've all expired or been replaced by JWTs.

Once we go live with this change:

- Any new successful authentication will use the JWT format.
- When validating existing tokens, we'll simply test if the token appears to be in the JWT format. If so, we'll decode it and validate the signature. If not, we'll attempt to decrypt it as a legacy token.
- Every time we get a legacy token, we increment a `legacy.token` metric via [Statsd](https://github.com/etsy/statsd). This way we can monitor the rate of legacy tokens we receive and decide when we can safely remove support for the legacy format. As you can see, legacy tokens are being replaced by the new format over time:

![Tracking legacy tokens](/images/2016-10-26-jwt-artsy-journey/graphite-legacy-tokens.png)

