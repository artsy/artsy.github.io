---
layout: post
title: The Anatomy of an Editorial Feature
date: 2019-03-05
author: eve
categories: [reaction, javascript, publishing]
---

![The Year in Visual Culture 2018](http://files.artsy.net/images/2018-visual-culture-screengrab.gif "The Year in Visual Culture 2018")

On select occasions since 2015, Artsy Editorial has created a number of custom, one-off articles featuring unique layouts, styles and experiences. After trying a number of implementations, the [`EditorialFeature`](https://github.com/artsy/reaction/tree/master/src/Components/Publishing/EditorialFeature) component was introduced to the process during Artsy’s 2018 year-in-review projects.  

By moving the implementation of custom articles to Artsy’s component library, we were able to remove some of the friction and time investment necessary for engineers to spin up these articles, and enable bespoke layouts to be housed in Artsy.net’s Article domain rather than a custom Express app. Acting essentially as a wrapper to accept article data, any component can be rendered as a child of the `EditorialFeature` component, allowing for flexible combinations of new and existing features, and for minimal or maximal interventions.

<!-- more -->

For a light-weight customization, a developer might add props for unique text or background colors. Medium-touch could involve wrapping an existing layout in a styled-component declaring further css interventions to font-size, borders, margins or other layout properties. The space is an open canvas, so the option is available to build every element from scratch, introduce JS interactivity, and to interact with any data saved to the article model in a completely new way. The scale of a project can vary widely, but determined by weighing priorities of editorial intent, proposed designs, engineering capabilities/availability, and budget.

Some examples of articles created with the `EditorialFeature` component include:

- The Most Influential Artists of 2018 - [Components](https://github.com/artsy/reaction/tree/master/src/Components/Publishing/EditorialFeature/Components/Eoy2018Artists) | [Article](https://www.artsy.net/article/artsy-editorial-influential-artists-2018)
- The Year in Visual Culture 2018 - [Components](https://github.com/artsy/reaction/blob/master/src/Components/Publishing/EditorialFeature/Components/Eoy2018Culture.tsx) | [Article](https://www.artsy.net/article/artsy-editorial-people-defined-visual-culture-2018)


# Custom articles by domain:

**1. [In Force (Artsy.net)](https://github.com/artsy/force)**

- Whether an article requires a custom layout is determined in Force’s [article routing](https://github.com/artsy/force/blob/master/src/desktop/apps/article/routes.ts). This is achieved by passing the prop `customEditorial`-- a string shorthand for a specific article-- to Reaction’s top-level `Article` component. The `customEditorial` prop is pulled from Force’s editorial feature "[master list](https://github.com/artsy/force/blob/master/src/desktop/apps/article/editorial_features.ts)", which ties an `article._id` to a communicative string that will be received by Reaction. In addition to data saved to an article model, the component will also receive all data displayed in the footer including related articles and display ads. Custom articles are rendered as a standalone page, meaning they are excluded from infinite scroll and do not render the main site header.

**2. [In Reaction (Artsy’s component library)](https://github.com/artsy/reaction)**

- In Reaction’s top-level [`Article`](https://github.com/artsy/reaction/blob/master/src/Components/Publishing/Article.tsx) component, the presence of a `customEditoral` prop routes an article to the [`ArticleWithFullScreen`](https://github.com/artsy/reaction/blob/master/src/Components/Publishing/Layouts/ArticleWithFullScreen.tsx) component. From here, the article is given context for image slideshows and tooltip helpers, and the  `EditorialFeature` component is rendered rather than the component designated by the article’s specified layout. A `FeatureLayout` is displayed by default, but any article can be converted into a custom feature, regardless of the `article.layout` value. Inside the `EditorialFeature` component, a switch statement is used to associate the string variable for the feature with its affiliated top-level component.

**3. [In Writer/Positron (CMS & API for articles)](https://github.com/artsy/positron)**

- Because `EditorialFeature` accepts an article data-model, it can be edited using the Writer CMS. However it is important to note that a custom layout is rendered by Force only. While editing, what users see is dicated by the `article.layout` property. Writer's features are exposed based on this property, so a particular custom article’s layout should be determined by the features most suited to the content and design.  For example, if you need a header-image or video, a feature article would be a logical choice because that content can easily be created and edited in Writer. If the article relies heavily on content from related articles, you might choose to customize a series article instead.

# Creating a custom feature

![The Most Influential Artists of 2018](http://files.artsy.net/images/2018-influentual-artists-screengrab.gif "The Most Influential Artists of 2018")

**A custom layout is enabled via three steps:**

- Add a new object to the `customEditorialArticles` [master list](https://github.com/artsy/force/blob/master/src/desktop/apps/article/editorial_features.ts), indicating the `article._id` and `name`. Names are usually a shorthand for the content, and used because they are descriptive (unlike an `_id`), and will not change over time like a title or slug has potential to do.
```javascript
    {
      name: "MY_CUSTOM_FEATURE",
      id: "12345" // mongo _id
    }
```
- Create your custom component in the `EditorialFeature/Components` directory
- Add your `customEditorial` string to `EditorialFeature`’s switch statement to enable rendering custom component
```javascript
    case "MY_CUSTOM_FEATURE": {
      return <MyCustomFeature {...props} />
    }
```

Although these features historically receive high traffic via search and other channels, they usually have little internal visibility a few months after they are published. For this reason it is recommended that, in addition to any unit tests, developers create a snapshot of the custom article so that unexpected regressions are flagged in a test failure.  

# History & Context
Previously we have used multiple strategies to implement these features, using two sometimes overlapping concepts: Curations and SuperArticles.

![Artists for Gender Equality](http://files.artsy.net/images/2017-gender-equality-screengrab.gif "Artists for Gender Equality")

**Curations:**

A [Curation](https://github.com/artsy/positron/tree/master/src/api/apps/curations) is a model in Positron’s API that has no schema-- meaning it accepts any data shape. This can be a handy solution for content that does not conform to the existing article model. However, this strategy comes with significant overhead and a few quirks:

- A [custom edit UI must be created](https://github.com/artsy/positron/tree/master/src/client/apps/settings/client/curations) and maintained indefinitely
- A custom Express app is required by Force to render the content
- Because data is in a unique shape, components often must be fully custom
- It is difficult to track visual changes over time

Despite these pitfalls, Curations remain useful for special cases, especially those which involve interactive navigation through content.

Published examples of custom articles that use curations are:

- [Artists for Gender Equality](https://www.artsy.net/gender-equality)
- [Inside the Biennale](https://www.artsy.net/venice-biennale)
- [The Year in Art 2016](https://www.artsy.net/2016-year-in-art)

_See [previous blog post](http://artsy.github.io/blog/2017/02/01/year-in-art/) on creating The Year in Art 2016._

**SuperArticles:**

An article where the `is_super_article` field is set to true includes the ability to attach related articles and sponsor-related fields to an article. It also exempts an article from the infinite scroll feed, and renders a custom header (in place of the main site navigation) and footer. The SuperArticle [header](https://github.com/artsy/force/blob/master/src/desktop/components/article/templates/super_article_sticky_header.jade) and [footer](https://github.com/artsy/force/blob/master/src/desktop/components/article/templates/super_article_footer.jade) both include navigation options to view and visit related, aka sub-article, content. 

The first SuperArticle was also the [first custom feature](https://www.artsy.net/2015-year-in-art), and its attributes were made available to all articles when launched. However, its weakness lies in a conflation of a series and a sponsor as a single concept. In practice we have seen that they are not mutually exclusive. Additionally, support for this feature was built in Backbone, and hasn’t always behaved as expected when inserted into our React-heavy ecosystem. Since the SuperArticle was created, we have extended the ability for any article to accept either or both sponsor and related article data, and we are currently in the process of deprecating this concept. 

Existing SuperArticles include:

- [The Year in Art 2016](https://www.artsy.net/2016-year-in-art)
- [The Year In Art 2015](https://www.artsy.net/2015-year-in-art)
- [The 100 Most Expensive Artists at Auction](https://www.artsy.net/article/artsy-editorial-the-100-most-expensive-artists)

# Takeaways for developers
- We try to work with our editorial and design teams to ensure new editorial content maps as closely to our existing article data-model and CMS features as possible. That way, we can have an upfront conversation about the constraints our systems might impose on designs.
- Relying heavily on existing article and system components ensures that system-wide changes (for example, changes to breakpoints) will be inherited
- Always create snapshot tests to monitor how an article changes over time
