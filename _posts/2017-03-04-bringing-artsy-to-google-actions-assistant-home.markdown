---
layout: post
title: "Bringing Artsy to Google Assistant \"Home\" with Actions"
date: 2017-03-04
comments: true
author: db
categories: [Google Home, Google Assistant, Google Actions]
---
Last month we [brought Artsy to Amazon Alexa](/blog/2016/11/30/bringing-artsy-to-amazon-echo-alexa/). In this post we'll repeat that process and enable Artsy for Google Assistant, including Google Home.

tl;dr You can try Artsy on your Google Home now, say "Ok Google, talk to Artsy" or see [assistant.artsy.net](http://assistant.artsy.net) for more info.

<iframe width="560" height="315" src="https://www.youtube.com/embed/i9EpF18xZqQ?ecver=1" frameborder="0" allowfullscreen></iframe>

<!-- more -->

### Conversation Actions

Actions are two-way dialogs with users. A user invokes an action, which calls so-called _fulfillment_ code - a REST endpoint.

If you've never worked with Google Actions, read the [conversation actions intro](https://developers.google.com/actions/develop/conversation).

### Actions SDK

To write an action get the [actions SDK](https://developers.google.com/actions/develop/sdk/getting-started), which is a node.js client library, describe the actions in JSON and use a command-line tool called `gactions` or a web simulator to invoke the action code.

### Actions Server

The actions SDK can be called from any node.js application, or with some help from [google-actions-server](https://github.com/manekinekko/google-actions-server) (GAS) via boilerplate code in the [google-actions-starter](https://github.com/manekinekko/google-actions-starter) library.

An `action.json` that describes the actions, including the invocation trigger for each action and the text-to-speech voice for the agent to use.

```json
{
  "versionLabel": "1.0.0",
  "agentInfo": {
    "languageCode": "en-US",
    "projectId": "biesenbach-one",
    "invocationNames": ["artsy"],
    "voiceName": "female_1"
  },
  "actions": [{
    "initialTrigger": {
      "intent": "assistant.intent.action.MAIN"
    },
    "httpExecution": {
      "url": "https://biesenbach-one.appspot-preview.com"
    }
  }]
}
```

The action implementation lives in `lib/action.js` that imports and creates a new instance of `google-actions-server`, binds intents to functions and issues questions with `agent.ask` or sends final responses with `assistant.tell`.

```js
import { ActionServer } from '@manekinekko/google-actions-server';

class ArtsyAction {
  constructor() {
    this.agent = new ActionServer();

    this.agent.setGreetings([
      `What is the name of the artist you would like to hear about?`
    ]);
  }

  welcomeIntent(assistant) {
    return this.agent.randomGreeting();
  }

  textIntent(assistant) {
    var query = assistant.getRawInput();

    // TODO: respond to a query

    assistant.tell('You said ' + query + '.');
  }

  listen() {
    // the welcome intent is invoked when the user says "talk to Artsy"
    this.agent.welcome(this.welcomeIntent.bind(this));
    // the text action is invoked for any spoken text
    this.agent.intent(ActionServer.intent.action.TEXT, this.textIntent.bind(this));
    return this.agent.listen();
  }
}

module.exports = (new ArtsyAction()).listen();
```

With tests.

```
let request = require('supertest')

describe('Artsy', () => {
  let action;

  beforeEach(() => {
    action = require('../action');
  });

  afterEach(() => {
    action.close();
  });

  it('asks the name of the artist when launched', () => {
    return request(action)
      .post('/')
      .send({
        inputs: [{
          intent: 'assistant.intent.action.MAIN',
          raw_inputs: [{
            input_type: 2,
            query: "OK Google, talk to Artsy."
          }]
        }]
      })
      .expect(200).then((response) => {
        var ssml = response.body.expected_inputs[0].input_prompt.initial_prompts[0].ssml;
        expect(ssml).to.eql(`What is the name of the artist you would like to hear about?`);
      });
  });

  it('repeats a query', () => {
    return request(action)
      .post('/')
      .send({
        inputs: [{
          intent: 'assistant.intent.action.TEXT',
          raw_inputs: [{
            input_type: 2,
            query: "hello world"
          }],
          arguments: []
        }]
      })
      .expect(200).then((response) => {
        expect(response.body.expect_user_response).to.equal(false);
        var ssml = response.body.final_response.speech_response.text_to_speech;
        expect(ssml).to.equal('You said hello world.');
      });
  });
});
```

Find the [complete source code of the Artsy action on Github](https://github.com/artsy/biesenbach).

### Local Simulator

GAS does a good job at enabling running of a local development version.

* Run `ngrok` to proxy requests to the outside world.
* Run `npm run server` to start the local instance.
* Deploy a preview version of the app with `npm run action:autopreview`.
* Run `npm run action:simulate` for a local simulator, use [the web version](https://developers.google.com/actions/tools/web-simulator) or even a Google Home device registered under your development account.

<iframe width="560" height="315" src="https://www.youtube.com/embed/_biW8TDbBGo" frameborder="0" allowfullscreen></iframe>

### Certification

#### Fulfillment Endpoint

The certification process requires that you deploy the node.js application into a production environment, first. We deployed ours into Google Cloud, which involved creating a `vm.yaml`, creating a new deployment with `gcloud deployment-manager deployments create production --config vm.yaml`, transpiling JavaScript with `npm run build` and deploying the app with `gcloud app deploy`. You can just push the app to Heroku or AWS Lambda as well.

#### Google Actions API Project

Create a Google Actions API project from the [API Dashboard](https://console.developers.google.com/apis/dashboard) and configure the project in "Directory Listing". It's important to get the sample invocations right, eg. _"Ok Google, ask my first action to ..."_.

#### Deploy Action

Deploying the action makes it usable by others by submitting it for approval with Google. Once submitted you have to wait for your action to be rejected or approved, there's no way to un-submit an action without contacting support.

Change the `httpExecution` URL(s) in `action.json` to the deployed fulfillment URL, eg. `https://my-first-action.appspot-preview.com`, ensure the correct action ID is used in `package.json`, and run `npm run action:deploy`, which will register and deploy your action.

The application will appear under "Deployment History" in the API dashboard.

<center><img src='/images/2017-03-04-bringing-artsy-to-google-actions-assistant-home/actions-api.png'></center>

### Help

I found that the best place to ask questions was [stack overflow#actions-on-google](https://stackoverflow.com/questions/tagged/actions-on-google) and their unusually responsive [support team](https://developers.google.com/actions/support/?requesttype=support&prio=low).

### Code

Find the [complete source code on Github](https://github.com/artsy/biesenbach).
