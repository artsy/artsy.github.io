---
layout: post
title: "JWT, Artsy Journey"
date: 2016-10-26 11:03
comments: true
author: ashkan
categories: [Auth, JWT, API]
---

At Artsy we currently have ~1730 client applications hitting our API and requesting authentication. On a successful authentication, we want to be able to provide basic user/application data in the token so clients can use it without needing to call our API. For that we want to use JWT.

JWT (JSON Web Token) is a self-contained, secure way of transmitting data between applications and clients as JSON objects. Once decoded, JWT contains a JSON including 3 separate secions, header, payload and signature. Header section is used to define the type and details about the token itself. Payload seciton includes _claims_ and data provided by token issuer about the user/application, things like token expiration time, user id and etc. Signature section is used to verify the sender of the JWT and make sure token wasn't modified along the way.
<!-- more -->

# Where we were

After a successful login, our API would generate our own access token. Our encrypted access token included some basic information about the user and the application using the token.
For every authenticated request we would have to decrypt the token, make sure user and application are valid and application still has access to our API. We are already _stateless_ since we don't store tokens in our database.
We can share access tokens between applications and then each application has to make a call to our API to get basic user data.


# Where we are going
We want to keep our current auth flow which is already stateless and mainly replace our in-house generated access token to a more standard JWT. What that gives us is:

- Be able to decode and read basic information out of our token. With our in-house generated access token this could happen only if client application had duplicated our API side's decryption logic. With JWT each app can decode the token and get basic data out of it, it can check if token is expired or not and etc. If client is doing something that needs to make sure token is still valid, it can still call the API, like before, to make sure token is valid and get more data about it.

- Possibly include different data in JWT payload for different applications, if a JWT token was created for the application that deals with conversations, it doesn't need to know about the user's auction related information.

- Follow a well defined standard and use existing libaries for creating and reading token. JWT has a decent set of reseverd _claims_ which can be used to describe the token in a unified language. Few examples:

  - `exp`: Expiration time.
  - `iat`: Time this JWT was issued.
  - `iss`: Issuer of this JWT (ex. our main API)
  - `aud`: Audience of this JWt (ex. Our mobile application)
  - `jti`: JWT ID, unique identifier for this JWT

Most of JWT libraries honor these claims and can act upon them so we don't have to handle things like expiration ourselves.

# Transition

Changing authenticaiton token can be tricky when we already have lot of existing applications and clients using our old access token, it turns out since we are not changing anything in the auth flow it's actually easier than what we thought, we only need to support decoding our in-house access tokens for a while untill everyone switched to JWT. Basically once we go live with this change:

- Any new successful authentication will get JWT

- For any incoming authenticated requests, we will support decoding both JWT and legacy access tokens for a while and later we can remove support for legacy access tokens.

