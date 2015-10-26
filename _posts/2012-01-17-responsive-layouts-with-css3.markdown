---
layout: post
title: "Responsive Layouts with CSS3"
date: 2012-01-17 11:03
comments: true
author: mattm
categories: [Design, CSS, HTML5]
---
All of the [SCSS](http://sass-lang.com/) stylesheets used to design this blog compile down to one file (view the source of this page and check out screen.css), and there isn't any JavaScript affecting the layout. But there are really three versions of this page. If you're reading this on a smartphone, what you see is almost entirely different from what you would see if you were reading this in a full screen browser. If you're on a computer, try making this page full screen and slowly resize it to make it smaller. You'll first notice that the Artsy logo disappears just before it would cover the text in the main column. Keep reducing the viewport and eventually the page will snap into a mobile format with the Artsy logo centered at the top, followed by the centered header text and mobile search box all above the index of recent posts.

## The Philosophy

Why bother? It's true that smartphone web browsers are pretty advanced and certainly can handle rendering the full version of this blog. But there's a big difference between ensuring a site works and creating a good experience for your audience regardless of the device they're using. If anything, advances in the mobile web make responsive layouts like the one on this blog even more necessary — as it becomes more and more likely that your users are viewing your site on a handheld screen, it becomes less acceptable to force your audience to zoom way into your page and follow the text with their thumbs.

The key to a good mobile design is to fix at least one axis — it's fine if the user has to scroll down or to the right to see the rest of the content, but making the user scroll diagonally means that the layout doesn't fit the screen. For text-heavy sites like this blog, it's best to just allow vertical scrolling. Aside from this consideration, links, text fields, and buttons must be large enough to allow for easy navigation with thumbs. The font size may need to be adjusted to optimize viewing on a mobile screen. On a Mac, you can use mobile Safari on the iPhone Simulator that comes with [Xcode](http://developer.apple.com/xcode/) to see how your site will look on a phone.

## Media Queries

The good news is that these responsive layouts aren't difficult to implement. When I set out to theme this [Octopress](http://octopress.org/) blog, our designer gave me two comps, one for the full version of the site and the other for the mobile version. The first step towards a responsive layout is to notice common elements between the two designs. If you compare the two versions of the blog, you'll notice that they contain essentially the same content. This means that we need only one template file for both designs, and definitely do not need to resort to creating a whole mobile subdomain to serve different content to small screens. For elements that aren't the same in the two designs, we can simply hide them by setting `display: none` for devices where the elements shouldn't be shown. I used this technique in a couple of places on the blog: the right sidebar is hidden on the mobile version, while the mobile search bar (which differs from the search bar on the side in that it has placeholder text and appears in the main content `div`) isn't displayed on the full version of the site.

But how do you apply different styles to the same elements depending on the size of the browser's viewport? There are a couple of ways, but by far the cleanest way is to use CSS3 media queries. Media queries allow developers to apply different styles to elements on a page depending on the media on which they are displayed, whether that medium is a screen, a projection, print, braille, etc. The most common use of media queries, however, is to create responsive layouts. Media queries come after an `@media` declaration. Directly after comes the definition of the media type: we're concerned with creating responsive layouts for screens, and as a result, we'll declare our styles under `@media screen`. To apply custom styles based on the size of the screen, we'll use media features, which come after the keyword `and` and are enclosed in parentheses. Here's the SCSS code used to style the Artsy logo on this blog:

``` scss
    #lrg-mark {
        background-image: url("../images/Logo.png");
        background-repeat: no-repeat;
        display: block;
        height: 92px;
        width: 249px;

        span {
          display: none;
        }

        @media screen and (min-width: 482px) {
          left: 35px;
          position: fixed;
          top: 15px;
        }
        @media screen and (max-width: 1280px) and (min-width: 482px) {
          display: none;
        }
        @media screen and (max-width: 481px) {
          margin: 0 auto 20px auto;
          background-position: center top;
        }
    }
```

The styles that are common to all viewports are written outside of `@media` declarations at the top of the styles for `#lrg-mark` — regardless of the screen size, we want the logo to be the same image and the same size, and we don't want to display the span inside of the div that contains fallback text. The rest of the styles are given in media queries: for a large viewport, we want the logo fixed in the upper right corner, for slightly smaller viewports, we want it to disappear, and for mobile viewports, we want it centered on the screen. Note that 481px is a magic number: it's the width of an iPhone in landscape mode.

The media features `max-width` and `min-width` are a little misleading: they don't mean the maximum or minimum possible width of the user's screen. It's best to think of `max-` as "less-than-or-equal-to" and `min-` as "greater-than-or-equal-to." See [the W3C's website](http://www.w3.org/TR/css3-mediaqueries/) for a complete reference on CSS media queries.

## Making It Cross-Browser

CSS3 media queries are awesome, but even though all the latest versions of the major browsers support them, it's very likely that a portion of your site's visitors will be using browsers that don't support these new CSS features. Luckily, this problem has already been solved by great people who like to give away things for free. Just include [modernizr.js](https://github.com/Modernizr/Modernizr) on your page, and it will provide a JavaScript fallback for media queries, as well as for many other potentially unsupported CSS3 features.
