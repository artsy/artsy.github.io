<img src="/images/react-native/artsy_react_logo.svg" style="width:200px; float:right;">

### "But the Artsy team is so well known for their Obj-C / Swift work"

React Native has completely changed the dev culture at Artsy. There is no dedicated "iOS team" anymore, and we have
web engineers regularly shipping code to our iOS app with barely any need for native engineer hand-holding. Since
2016, React Native has been a success for us.

We think React Native fits really well for API-driven apps, where the user interface then stays relatively static
after the initial load of data. There are amazing JavaScript tools like React, Relay, Jest and Styled Components
that help you only really write the domain specific code you need to write and then things like GraphQL and
TypeScript which gives you strict contracts with your API's data.

This series covers the reasons why we made that choice, our interactions with React Native, the tooling around it,
and shows how we've been handling some of the issues that come up as an early adopter.

Sidenote: we ran a conference with Facebook in 2018 called
[Artsy x React Native](http://artsy.github.io/artsy-x-react-native.html).
