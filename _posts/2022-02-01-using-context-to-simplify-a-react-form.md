---
layout: epic
title: Using Context to Simplify a VERY Large React Form
subtitle: How We Took Incremental Steps to Revamp the Artwork Form at Artsy
date: 2022-02-01
categories: [refactoring, react, context, typescript]
author: [anna, laura]
comment_id: 715
---

For those unfamiliar, Artsy is a fine art marketplace. Knowing that, it follows logically to say that the form via
which our partners list artworks for sale is an integral part of Artsy's core systems. This form, known only as
"The Artwork Form," is whispered about in the halls of Arty's New York headquarters. It is legendary. It is a
colossus. It is old enough not only to predate React v16.8 hooks and context APIs, but Artsy's use of React
entirely. The first version of the Artwork Form was built in 2014 using ruby and haml, and began its refactoring
into JS/JQuery/React a full 2 years later, after having expanded considerably from the original implementation.
That process (at least what we've gleaned from our git excavation) was incremental, experimental, and passed
through many hands before it landed in the lap of the current Partner Experience (PX) team.

<!-- more -->

PX has since been tasked with the maintenance of this unwieldy kaiju, spending endless amounts of time on seemingly
insignificant changes to behavior or UI, all while watching its performance degrade. Many of the people reading
this are already familiar with the story we're telling. Many have worked in their very own version of the tale, and
borne witness to the fact that legacy code of this scale becomes a living, breathing entity. The developers that
tend these beasts learn their patterns and idiosyncrasies, their little moans and groans, and for the sake of
expediency work within those constraints to accomplish their tasks. But when is enough, enough? When does the
developer time expended working within the constraints of an obsolete design begin to outweigh the time it would
take to simply _fix_ _the code_?

First, let's be honest: there is no single right answer to this question. When working in software development we
have to deal with certain realities: user experience vs. developer experience, lead time to the next release,
buy-in from stakeholders, etc. These factors may weigh more or less depending on the shop and the product. At Artsy
we're very lucky, in that our engineering department is given the time to attend to our tech debt and to be
deliberate about when and how we go about this. In the case of the Artwork Form, there were several issues that had
become too glaring to ignore:

1. The data coming in, and subsequently being passed to individual components, was being completely obscured by the
   amount of prop drilling and spreading that existed within the composed form.
2. The prolific use of `any` when typing data was disabling typescript and consequently removing its usefulness
   while still imposing all of its burdens.
3. The components within the form were tightly coupled, the number and specificity of props needed for each
   disallowing reuse in other parts of the app.

A few of us on the PX team decided to take matters into our own hands and address some of these key problems with
the Artwork Form. We came up with a plan to incrementally convert the form to use values from the Formik context,
use these values wherever possible to reduce prop-drilling, add much more complete types to the components to get
rid of all the `any`'s, and update some of our testing strategies as needed.

Here are the steps we took to do this conversion:

1. Create a hook that allows us to use the Formik context throughout the form

   The hook wraps [`useFormikContext`](https://formik.org/docs/api/useFormikContext) to allow all of our components
   inside of Formik to access the values from Formik context. It looks like this:

   ```typescript
   export function useArtworkForm(): FormikContextType<ArtworkValues> {
     const formikContext = useFormikContext<ArtworkValues>()
     return formikContext
   }
   ```

   We use `ArtworkValues` as the generic type so that when we are accessing `values` anywhere inside the component
   tree, `values` can be type-checked.

2. Convert all of the components in the form to functional components and to TypeScript. (Because the form is
   several years old, there were still many class components and many components that were not yet using
   TypeScript.) This step could be done in parallel with Step 1. One note here is that when converting files from
   JavaScript to TypeScript, we did not explicitly type the props in an interface. Once we can take advantage of
   our `useArtworkForm` hook, we will reduce the amount of props needed in each component, so we will hold off on
   typing the props until step 3.
3. The bulk of the work was making use of the `useArtworkForm` hook in the Artwork Form components. Starting with
   the lowest leaves of the component tree and moving up, we removed the `props` from the component definition and
   destructured any values we needed in the component from the `useArtworkForm` hook. Once we used everything we
   could from the context, we added back in any additional props that we would still need to have passed down from
   the parent. In many cases, this was no props at all—a particularly satisfying case. If the component still
   needed props passed down, we explicitly typed the props at the top of each component in an interface because we
   now knew exactly which props we would need inside of the component. Another key step here was going into the
   parent component and getting rid of any prop spreading (this: `...props`) and instead explicitly passing down
   exactly the props needed in the component (if there were any).

   1. A note on tests: Whenever we took advantage of the Formik context in a component, we were breaking that
      component's tests, because the wrappers we were using in the tests did not have access to the Formik context
      and were being passed props that the component was no longer looking at. We created a helper test wrapper
      that we could use in all of our Artwork Form tests to wrap the test's specific wrapper inside of a
      `<Formik/>` component and provide the specific `values` to use as the initial values for `Formik`. Many of
      our test cases involve passing different `values` into the component, which we originally did via props but
      now will do via the Formik context through the wrapper. Here's what the wrapper looks like:

   ```tsx
   export const TestFormikWrapper: React.FC<TestFormikWrapperProps> = (props) => {
     const { children, values } = props

     return (
       <Formik initialValues={values} onSubmit={jest.fn()}>
         {children}
       </Formik>
     )
   }
   ```

   Here is an example of `TestFormikWrapper` used in a test:

{% raw %}
   ```tsx
   describe("TestComponent", () => {
     it("displays values", () => {
       const wrapper = mount(
         <TestFormikWrapper values={{ name: "Andy Warhol" }}>
           <TestComponent />
         </TestFormikWrapper>
       )

       const name = wrapper.find("#name").html()
       expect(name).toInclude("Andy Warhol")
     })
   })
   ```
{% endraw %}

4. Once we completed the conversion all the way up the tree to the root component, the `ArtworkForm`, we typed that
   component as strictly as possible and made sure to get rid of `any`'s. There were quite a few when we started
   the process.

So, where did we end up? Now all of the components in the Artwork Form are making use of the `useArtworkForm` hook
if they were previously accessing any of the values from the Formik context from props. We have much less prop
drilling between components and instead explicitly pass down the props needed from parent to child. It's now much
more clear for developers what data is passing between the components and what data is actually being used in the
child. All of the components are also explicitly typed so we know exactly which props, if any, need to be passed
down from the parent. If any of these props are removed, TypeScript helps us by failing loudly.

One of the main pain points of the Artwork Form is that it's very difficult for new developers (whether new to
Artsy or new to the Partner Experience team) to contribute and make changes to the form without breaking something
or spending extra time figuring out how data is passed within the form. Hopefully, this change will make it easier
for developers to understand the Artwork From.

How did the Artwork Form get so complicated? Well, as we shared, the Artwork Form is the key to achieving one of
the PX team's core goals: surfacing the most accurate and rich information about artworks to collectors. We have to
allow partners to add more and increasingly specific pieces of metadata to artworks. The form has been growing and
for better or worse, will need to keep growing. Even though we expect to grow the form to meet metadata needs, we
do not put too much focus on the UX/UI of the Artwork Form in order to prioritize our collector-facing apps. (The
Artwork Form is only used by a relatively small subset of users, mostly gallery partners.) Hopefully, this refactor
will allow us to expand the form more seamlessly and will make it easier to navigate as it grows.

This refactor is still in its early days. The next steps for making the form easier to use (for both developers and
our end users) will require larger changes. When we think about further progress on revamping the Artwork Form, our
team is considering breaking the form up into smaller forms. Imagine, we are rendering several different top-level
`Formik` components that include discrete sections of the form, instead of just one giant `Formik` tree as we have
now. We would then combine these "mini forms" together, making better use of React's core principle of composition.

Breaking up the form would be a big change for the developer experience (but hopefully made easier by this
refactor). It could also involve big changes to the UI. The Artwork Form is not just hard to navigate for
developers. It's hard for users too. Over the next couple of months, our Product Manager will be working with one
of Artsy's user researchers to conduct user testing on the form. Feedback from galleries will help determine where
we next take this project. We're excited to have buy-in from our product team to work on a project that will
elevate the user experience while allowing us to use that opportunity to improve the developer experience as well.
