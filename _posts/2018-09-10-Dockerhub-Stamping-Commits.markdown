---
layout: epic
title: "Stamping the commit SHA into the ENV vars of a running Docker-based app"
date: 2018-09-10
author: orta
categories: [docker, peril, env-vars]
---

For what feels like the last 3-6 months, I've been trying to figure out how to know what the commit is for the
Docker runtime in Peril. Roughly: every master commit on Peril triggers a Docker image on Docker Hub for the
environment in which JavaScript is running. There's a lag between creating the commit, having the image ready on
Docker Hub, and Peril using the new image. There's also space for these automated systems to go wrong, so I'd like
to be able to be certain in logging.

I've thrown a lot of commits and time every few weeks at this, so now that I've figured it out, I'll give you an
idea of what I needed to do to make it work in a micro-post.

<!-- more -->

**Step 1:** You need a custom build step, to do this, you need to create a file `hooks/build` in your repo:

```sh
#!/usr/bin/env sh

# This is so we can get the commit into the build log of a Dangerfile runner
# These come from https://docs.docker.com/docker-cloud/builds/advanced/

# For debugging all env vars
# printenv

#  Convert the location "/Dockerfile" to "Dockerfile"
FILE=$(echo -n $BUILD_PATH | tail -c +2)

if [ -z "${DOCKER_TAG}" ]; then
  docker build --build-arg=COMMIT=$(git rev-parse --short HEAD) --build-arg=BRANCH=$SOURCE_BRANCH -t $IMAGE_NAME -f $FILE .
else
  docker build --build-arg=COMMIT=$(git rev-parse --short HEAD) --build-arg=BRANCH=$DOCKER_TAG -t $IMAGE_NAME -f $FILE .
fi
```

There's a list of examples in [this repo](https://github.com/thibaultdelor/testAutobuildHooks) - though the build
one is too simple for our needs here. If you need something that's not there, then remove the comment marker before
`printenv` to the script to see
[what env vars](https://github.com/danger/peril/commit/61f447d13476fee9fa0686225ff3ca76d416088f) are available
([here's an example build](https://hub.docker.com/r/dangersystems/peril/builds/benoxzftncgdsmwugr9bpjn/)).

**Step 2:** Edit your `Dockerfile` to take the additional arguments `COMMIT` and `BRANCH` from `ARG`.

```diff
MAINTAINER Orta Therox
+ ARG BRANCH="master"
+ ARG COMMIT=""
+ LABEL branch=${BRANCH}
+ LABEL commit=${COMMIT}

ADD . /app
WORKDIR /app

+ # Now set it as an env var
+ ENV COMMIT_SHA=${COMMIT}
+ ENV COMMIT_BRANCH=${BRANCH}
```

Err, that should be everything. I mean, I did call it a micro-post. Trying to implement this has broken the Peril
runner a bunch of times on staging, so I'm mainly just helping out other docker newbies.

Some links that helped me get there:

- [Add git commit hash to ENV](https://github.com/docker/hub-feedback/issues/600)
- [Feature request: Build args on docker hub](https://github.com/docker/hub-feedback/issues/508#issuecomment-243968310)
- [Inject Git source commit metadata into the image](https://github.com/elasticdog/tiddlywiki-docker/commit/993c7e9e8d5207d110270458f0f18839656ca126)
- [Configure automated builds from GitHub](https://docs.docker.com/docker-hub/github/)

Remember folks, Ash says you should [write as you learn](https://ashfurrow.com/blog/contemporaneous-blogging/), so
write up those small wins.
