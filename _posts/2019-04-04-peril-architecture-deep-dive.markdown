---
layout: epic
title: "Peril Architecture Deep Dive"
date: "2019-04-04"
author: [orta]
categories: [reactnative, ios, community, roads and bridges]
---

For the [last two years][intro_peril], we've used [Peril] to automate quite a lot of process at Artsy. You can see
a full overview of what [we automate in `artsy/README`][peril_readme]. As a service, Peril is a bit of an iceberg
of complexity, most tooling-y developers at Artsy have [contributed][settings-contrib] to our user-land Dangerfiles
but very few have touched the server itself.

To lower that barrier, I gave our Engineering team a run through of how the server works and how a lot of the
pieces come together. Jump [to YouTube](https://www.youtube.com/watch?v=3HNmiNHCvdA) for the video, or click more
for a smaller inline preview.

<!-- more -->

{% youtube 3HNmiNHCvdA %}

[intro_peril]: /blog/2017/09/04/Introducing-Peril/
[peril_readme]: https://github.com/artsy/README/blob/master/culture/peril.md
[settings-contrib]: https://github.com/artsy/peril-settings/graphs/contributors
[peril]: https://github.com/danger/peril
