---
layout: post
title: "JSON Web Tokens: Artsy's Journey"
date: 2016-10-26 11:03
comments: true
author: ashkan
categories: [Authentication, JWT, API]
---

At Artsy we currently have ~1730 client applications hitting our API and requesting authentication. When a user successfully authenticates through one of these clients, we want to embed basic user/application data in the resulting token rather than have to look up a session ID in the database on each request. For that we want to use JWT.

JWT (JSON Web Token) is a self-contained, secure and standard way of transmitting data between applications and clients as JSON objects.
<!-- more -->
JWT has three separate sections which are separated by `.`: header, payload and signature.

`<header>.<payload>.<signature>`

Once decoded:

- The header section contains JSON defining the type of token and how to treat its contents.

- The payload section includes _claims_ and data provided by token issuer about the user/application, things like token expiration time, user id and etc.

- Signature section is used to verify the sender of the JWT and make sure token wasn't modified along the way.

![JWT example](/images/2016-10-26-JWT-Artsy-Journey/jwt-example.png)

<a href="https://jwt.io/introduction/" target="_blank">JWT</a> and <a href="https://tools.ietf.org/html/rfc7519" target="_blank">RFC 7519</a> provide more details about each section of JWT and how encoding, decoding and verification work.


# Where we were

After a successful login, our API would generate a custom JSON object including some basic information about the user and application, then encrypt it using a single server-side secret.
For every authenticated request we would have to decrypt the token, make sure user and application are valid and application still has access to our API. We are already _stateless_ since we don't store tokens in our database.
However, client applications had to make an API call to get any information about the authenticated user.


# Where we are going
We want to keep our current auth flow which is already stateless and mainly replace our in-house generated access token with a more standard JWT. What that gives us is:

- Client applications are able to decode and use basic information out of our token. With our in-house generated access token this was not possible since they don't share the secret. With JWT each app can decode the token and get basic data out of it, it can check if token is expired or not and etc. If client is doing something that needs to make sure token is still valid, it can still call the API, like before, to re-validate and get more data about it.

- Possibly include different data in JWT payload for different applications. Some clients may request user roles with respect to galleries and others with respect to auction houses..

- Follow a well-defined standard and use existing libraries for creating and reading the token. JWT has a decent set of reseverd _claims_ which can be used to describe the token in a unified language. Few examples:

  - `exp`: Expiration time.
  - `iat`: Time this JWT was issued.
  - `iss`: Issuer of this JWT (ex. our main API)
  - `aud`: Audience of this JWt (ex. Our mobile application)
  - `jti`: JWT ID, unique identifier for this JWT

Most JWT libraries honor these claims and can automatically validate them so we don't have to handle things like expiration ourselves.

In our new approach, every `ClientApplication` has it's own secret key. When we get a new login for specific application:

- We find the application in our database to make sure it is still valid and has access to our API.

- We use this application's secret key and we generate a JWT

When we get an authenticated request:

- We decode JWT without verifying the signature.

- From JWT payload we get the aud (audience) attribute which defines for which application this JWT was generated.

- We fetch `ClientApplication` for this `aud` and we verify JWT's signature using this application's secret key.

# Transition

Changing authentication token can be tricky when we already have many clients using our old access token format. It turns out that since we aren't changing the authentication flow, it's easier than we might expect. We simply have to continue decoding the legacy token format until they've all expired or been replaced by JWTs.

Basically once we go live with this change:

- Any new successful authentication will use the JWT format.

- When validating existing tokens, we'll simply test if the token appears to be in the JWT format. If so, we'll decode it and validate the signature. If not, we'll attempt to decrypt it as a legacy token.

- Eventually, we can safely remove support for the legacy format.

