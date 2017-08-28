---
layout: post
title: Making Artsy Editorial Accessible
date: 2017-07-06
categories: []
author: eve
---

During Artsy's recent 2017 Hackathon we tackled making all our our editorial content [accessible](https://en.wikipedia.org/wiki/Accessibility). The idea was hatched at  Berlin JSConf this spring, where [Laura Carvajal gave a talk](https://youtu.be/H4FzW9oFObs) following the *Financial Times*' experience implementing better accessibility requirements, and how they built these considerations into their testing process.

What does accessibility mean in a browser? Generally this means supporting the wide range of assistive technologies for users with vision or motor impairments, including screen readers, mouseless navigation using a keyboard or eye tracking. Interestingly these technologies are implemented at the OS level rather than the browser itself. Macs include a built in screen-reader, [JAWS](http://www.freedomscientific.com/Products/Blindness/JAWS) is the most popular application in this vein. It is also notable that browsers do not track users who employ assistive tools.

A central tenant of Artsy's mission is to 'make art as accessible as music'. Expanding access to writing on art and culture for the visually impaired follows through on this statement in a very literal way. Furthermore, there is no reason to ignore this audience; accommodating use of assistive technologies is an ethically responsible thing to do. Two users on [WebAIM's forum](http://webaim.org/discussion/mail_thread?thread=6326) excellently present the case for this developer responsibility:

> "Looking at accessibility as a way to serve a specific population is missing the point that accessibility is about inclusion of all people."

> "Users may be highly resistant to having their disabilities identified as they go throughout the web. Most persons with disabilities would really just rather that *the Web just work* for them."


## Putting it into practice

Screen readers take note of semantic elements like headings or `<nav>`, and follow our page's elements in the order written. By smartly structuring HTML one can optimize how pages are interpreted when using them. Absolute and fixed spacing are ignored in this context, so a visual understanding of your site may prioritize different information or present it in a different order than expected. This means that in JavaScript-oriented environments, and where elements are inserted on the client, it is important to keep all elements necessary to navigating available in a semantic form at all times, including drop downs.

We used three tools to evaluate pain points on our site: the npm module [pa11y](https://github.com/pa11y/pa11y), Chrome's [Accessibility Developer Tools](https://chrome.google.com/webstore/detail/accessibility-developer-t/fpkknkljclfencbdbgkenhalefipecmb?utm_source=chrome-ntp-icon), and [WAVE](http://wave.webaim.org/)&mdash; a web accessibility evaluation tool by [WebAIM](http://webaim.org/), a non-profit dedicated to "empowering organizations to make their own content accessible".  All three work similarly- input a web address, and an error report is generated. Pally works in the terminal, and can export to a csv, and even create a dashboard. Chrome handily provides a color-coded scorecard in addition to an error report. Because Chrome's report lives in the browser's console, it is especially easy to inspect your code directly from an error. However, each report brought up unique issues, so it is prudent to try a few.

We found a range of warnings and errors on our first run, where chrome gave us a failing grade of 62 on our first pass, and pa11y raked up 48 errors- not counting a sizeable number of warnings. Luckily, most of theses changes are fast and easy:

- Adding meta language property to (`<html lang="en">`)
- Increasing the meta property for maximum scale to 5
- Adding hidden text to icon only links and UI elements
- Adding alt text to all images
- Including aria form attributes on input fields
- Using semantic roles for article body (`<div role='article'>`)
- Removal of duplicate IDs from pages
- Removing vendor ids from SVG files (often duplicates in our case)

You can check out a summary of changes we implemented in Pull Requests [here](https://github.com/artsy/force/pull/1730) and [here](https://github.com/artsy/force/pull/1732).

There were several places on our site where we wanted to include text that was intended only to screen readers- however, display: none is not necessarily acceptable for this context. Instead we opted for absolute positing of these elements far off screen.

```css
// hides text that is only for screen-readers

.screen-reader-text {
  position: absolute;
  left: 10000px;
  top: auto;
  width: 1px;
  height: 1px;
  overflow: hidden;
}
```

A few challenges were encountered as we made our way through process. My research brought up mixed messages on `display: none`. For example, Artsy renders the main menu in both desktop and mobile versions, but hides one based on the user agent. We got errors with all testing frameworks for having duplicate IDs, despite the fact that these elements were hidden.  This is a problem that would be well solved with React, where we could render content based to screen width rather than hiding it.

![Chrome Accessibility Audit Score](/images/2017-08-29-Making-Artsy-Editorial-Accessible/Chrome-Accessibility-Dashboard.png)

Another road block we encountered was for headers that contain links&mdash; which our reports recognized as empty headers, rather than reading the link. We use linked headings frequently for section titles in our articles, so this is an issue we are still mitigating. And lastly, using a screen reader is a skill set all its own! While our Chrome audit score is now far higher than where we started, my own experience using a screen reader proved far more difficult than expected-- to be completely sure our implementation is working I hope to find an experienced screen-reader user to give it a spin.



