---
layout: post
title: "Bringing Artsy to Amazon Echo \"Alexa\""
date: 2016-11-30
comments: true
author: db
categories: [Alexa, Amazon Echo]
---
tl;dr You can try Artsy on your Amazon Echo now, say "Alexa, enable Artsy" or see [alexa.artsy.net](http://alexa.artsy.net) for more info.

With its powerful automatic speech recognizer, accurate natural language understanding and outstanding text-to-speech capabilities, the Amazon Echo, nicknamed "Alexa", always impressed me. While not the first in its category and introduced in late 2014, Alexa was the first consumer device in my home to truly enable the conversation between human and machine. It was stationary, always listening for a wake word, and clearly outperformed all previous attempts when it came to the ability to receive commands from the other side of the apartment.

Alexa knows about the weather, but it doesn't know much about art.

In this post I'll dig a little inside the Alexa software platform and go over the technical details of bringing Artsy to the Echo, starting with a very simple "Ask Artsy about Norman Rockwell."

<a href='https://www.youtube.com/watch?v=zi3OubNiV9U' target='_blank'>
<iframe width="280" height="280" src="https://www.youtube.com/embed/zi3OubNiV9U" frameborder="0" allowfullscreen></iframe>
</a>

Find the [Artsy skill in the Alexa app](http://alexa.amazon.com/spa/index.html#skills/dp/B01MYLJO1N) and [the complete Skill code on Github](https://github.com/artsy/elderfield). And if you just want to learn to write a skill quickly, watch [@dblock live-code a skill in this video](https://www.youtube.com/watch?v=pzM4jv7k7Rg).

<!-- more -->

### How does Alexa work?

_Alexa_ is the software platform used by Alexa-enabled devices such as the _Amazon Echo_ or the _Echo Dot_. I used a $49.- Dot with headphones for most testing, and I have a bigger Echo at home (the main difference is the quality of the speaker). Because even a smaller Dot was sufficiently annoying to my coworkers, I wish it were battery powered, so I wouldn't need to unplug it to go run tests in a conference room.

Alexa waits for a _wake word_, either "Alexa" or "Amazon". It's always on and has a built-in speech recognizer for the wake word only. After it hears the wake word, a blue light ring turns on and the device starts transmitting the user's voice, called an _utterance_ to the Alexa platform in the cloud. The light ring is the indicator of it "listening". The cloud service will translate speech to text and run it through a natural language system to identify an _intent_, such as "ask Artsy about". The intent is sent to a _skill_, which is a piece of software living in the cloud that can generate a _directive_ to "speak" along with markup in [SSML](https://www.w3.org/TR/speech-synthesis) format, transformed into voice and finally sent in wave format back to the device to be played back to the user.

### Developer Prerequisites

You need an [Amazon Apps and Services Developer account](https://developer.amazon.com) and access to [AWS Lambda](https://console.aws.amazon.com/lambda). I've implemented the Artsy skill in node.js using [alexa-app](https://github.com/matt-kruse/alexa-app). You can find the [complete Skill code on Github](https://github.com/artsy/elderfield).

### Designing an Intent

To get Alexa to listen, you must design an intent. Each intent is identified by a _name_ and a set of _slots_. This is an order of magnitude more limited than what the Alexa system is capable of doing out of the box. It means that the platform _will not_ transcribe any text for your application, chatbot-style. The intents have to be simple and clear and use English language words or predefined vocabularies. Furthermore, Alexa has a lot of trouble with names as it constantly attempts to recognize them as dictionary words and no support for "wildcards".

I started implementing a fairly complicated "when is an artist born" intent, which turned to be too ambitious for Alexa to understand and ended up with a much simpler "ask artsy about an artist". I called this "AboutIntent", which takes an artist name as input (or slot).

```json
{
   "intents": [
      {
         "intent": "AboutIntent",
         "slots": [
            {
               "name": "VALUE",
               "type": "NAME"
            }
         ]
      }
   ]
}
```

The only possible sample utterance of this intent is "about {VALUE}", the "ask Artsy" portion is implied.

Since Alexa cannot understand artist names out of the box, I had to teach it with a custom, user-defined slot type added to the "Skill Interaction Model" with about a thousand most popular artist names on Artsy.

![Alexa interaction model](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/alexa-interaction-model.png)

### Implementing a Skill

Intents are the API of a skill, otherwise known as an Alexa app. Using [alexa-app](https://github.com/matt-kruse/alexa-app) makes implementing intents easy.

```js
var alexa = require('alexa-app');
var app = new alexa.app('artsy');

app.launch(function(req, res) {
    res
        // welcome message
        .say("Welcome to Artsy! Ask me about an artist.")
        // don't close the session, wait for user input (an artist name)
        // and provide a re-prompt in case the user says something meaningless
        .shouldEndSession(false, "Ask me about an artist. Say help if you need help or exit any time to exit.")
        // speak the response
        .send();
});

app.intent('AboutIntent', {
        "slots": {
            "VALUE": "NAME"
        },
        "utterances": [
            "about {-|VALUE}"
        ]
    },
    function(req, res) {
      // intent implementation goes here
    }
});
```

The skill expects a slot value as defined in the intent above.

```js
var value = req.slot('VALUE');

if (!value) {
  return res
    .say("Sorry, I didn't get that artist name.")
    // don't close the session, wait for user input again (an artist name)
    .shouldEndSession(false, "Ask me about an artist. Say help if you need help or exit any time to exit.");
} else {
  // asynchronously lookup the artist in the Artsy API, read their bio
  // tell alexa-app that we're performing an asynchronous operation by returning false
  return false;
}
```

We use the [Artsy API](https://developers.artsy.net) to implement the actual skill. There's not much more to it.

### Skill Development Mode

I found it convenient to host the skill inside an [alexa-app-server](https://github.com/matt-kruse/alexa-app-server) in development. It automatically loads skills from subdirectories with the following directory structure.

```
+--- server.js                  // the alexa-app-server host for development
+--- package.json               // dependencies of the host
+--- project.json               // lambda settings for deployment with apex
+----functions                  // all skills
     +--artsy                   // the artsy skill
        +--function.json        // describes the skill lambda function
        +--package.json         // dependencies of the skill
        +--index.js             // skill intent implementation
        +--schema.json          // exported skill intent schema
        +--utterances.txt       // exported skill uterrances
        +--node_modules         // modules from npm install
+--- node_modules               // modules from npm install
```

Note that the server exports the Express.js server for testing.

```js
var AlexaAppServer = require('alexa-app-server');

AlexaAppServer.start({
    port: 8080,
    app_dir: "functions",
    post: function(server) {
        module.exports = server.express;
    }
});
```

### Skill Modes

The skill is mounted standalone in AWS lambda, under alexa-app-sever in development and otherwise will export schema and utterances. It decides what to do based on `process.env['ENV']`, loaded from a ".env" file. The committed version of this file sets the value to "development".

```
{
    "ENV": "development"
}
```

The server loads `.env` from `server.js`.

```js
var config = require('./.env.json')

for (var key in config) {
    process.env[key] = config[key]
}
```

Finally, the skill can do different things in different environments.

```js
if (process.env['ENV'] == 'lambda') {
    exports.handle = app.lambda(); // AWS lambda
} else if (process.env['ENV'] == 'development') {
    module.exports = app; // development mode
} else {
    var fs = require('fs');
    // export schema and utterances
    // copy-paste the contents into the Interaction Model
    fs.writeFileSync('schema.json', app.schema());
    fs.writeFileSync('utterances.txt', app.utterances());
}
```

### Development and Test

Running the server locally with `node server.js` will create a simulator console on http://localhost:8080/alexa/artsy.

![lambda configuration](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/console.png)

We will use the test console to produce test JSON. The about intent translates into the following.

```json
{
    "session": {
        "sessionId": "SessionId...",
        "application": {
            "applicationId": "amzn1.ask.skill..."
        },
        "attributes": {},
        "user": {
            "userId": "amzn1.ask.account..."
        },
        "new": true
    },
    "request": {
        "type": "IntentRequest",
        "requestId": "EdwRequestId...",
        "locale": "en-US",
        "timestamp": "2016-11-12T22:03:54Z",
        "intent": {
            "name": "AboutIntent",
            "slots": {
                "VALUE": {
                    "name": "VALUE",
                    "value": "Norman Rockwell"
                }
            }
        }
    },
    "version": "1.0"
}
```

A mocha test uses the Alexa app server to make an HTTP request using the above intent data and expects well defined SSML output.

```js
chai = require('chai');
expect = chai.expect;
chai.use(require('chai-string'));
chai.use(require('chai-http'));

var server = require('../server');

describe('artsy alexa', function() {
    it('tells me about Norman Rockwell', function(done) {
        var aboutIntentRequest = require('./AboutIntentRequest.json');
        chai.request(server)
            .post('/alexa/artsy')
            .send(aboutIntentRequest)
            .end(function(err, res) {
                expect(res.status).to.equal(200);
                var data = JSON.parse(res.text);
                expect(data.response.outputSpeech.type).to.equal('SSML')
                var ssml = data.response.outputSpeech.ssml;
              expect(ssml).to.startWith('<speak>American artist Norman Rockwell ');
              done();
            });
    });
});
```

### Lambda Deployment

The production version of the Alexa skill is a Lambda function.

I created an "alexa-artsy" function with a new IAM role, "alexa-artsy" in AWS Lambda and copy-pasted the role URN into "project.json". This is a file used by [Apex](https://github.com/apex/apex), a Lambda deployment tool (`curl https://raw.githubusercontent.com/apex/apex/master/install.sh | sh`) along with awscli (`brew install awscli`). I had to configure access to AWS the first time, too (`aws configure`).

![lambda configuration](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/lambda-configuration.png)

In order to connect the lambda function with an Alexa skill, I added an "Alexa Skills Kit" trigger. Without this you get an obscure "Please make sure that Alexa Skills Kit is selected for the event source type of arn:..." error.

![lambda triggers](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/lambda-triggers.png)

I configured the "Service Endpoint" in the Alexa Skill configuration to point to my Lambda function.

![Alexa skill configuration](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/alexa-skill-configuration.png)

I deployed the lambda function with `apex deploy` and test the skill with `apex invoke` or from the Alexa test UI.

Each time we do a `apex deploy` it will create a new version of our function and will update `$LATEST` [Lambda alias](http://docs.aws.amazon.com/lambda/latest/dg/versioning-aliases.html). One way to handle versioning is to create a `$PROD` Lambda alias and point to `$PROD` when setting function in "Service Endpoint" step and each time we want to upate prod we need to update `$PROD` alias to point to latest version.

Also note that after each deploy with apex we need to set environment variables for the newly created version.

Logs didn't appear in AWS Cloudwatch with the execution policy created by default, I had to give the IAM "alexa-artsy" role more access to "arn:aws:logs:*:*:*" via an additional inline policy.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### Testing with Echoism

You can use [echosim.io](https://echosim.io) to test your skill. It's essentially identical to an Echo.

### Testing with Echo

I got an Echo Dot. Test skills appear automatically in the Alexa configuration attached to my account!

![alexa skills](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/alexa-skills.png)

I just try to [talk to it](https://www.youtube.com/watch?v=FYVOAU35Sio).

### Certification Process

![certified email](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/certified-email.png)

This took several weeks of back-and-forth. I should have gone through the [Alexa Skills Kit Voice Interface and User Experience Testing for Custom Skills](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-voice-interface-and-user-experience-testing) more thoroughly, but even after reading it a few times it wasn't obvious what the reviewers wanted.

![certified dashboard](/images/2016-11-30-bringing-artsy-to-amazon-echo-alexa/certified-dashboard.png)

Keep in mind that you need to go through certification process only if you are changing descriptions and details of the skill. If you updated the lambda function without modifying `utterances` or `schema` you don't have to go through certification process.

Here's a list of my mistakes.

#### Sample Phrases

The _Example Phrases_ in the _Publishing Information_ section of the certification UI must be present in your sample utterances. My three examples are _"Alexa, ask Artsy about Artsy"_, _"Alexa, ask Artsy about Andy Warhol"_ and _"Alexa, ask Artsy about Norman Rockwell"_.

The sample utterances are in the _Interaction Model_ section and must not include the wake word or any relevant launch phrasing. In the Artsy app I only have a single utterance with _"AboutIntent about {VALUE}"_, but lots of entries for _VALUE_ in the custom slot type. I forgot to include _artsy_ and _Norman Rockwell_ in those.

The skill got rejected mutliple times with _about artsy_ not working, so I eventually gave up on supporting that. Alexa would recognize it as _artsee_, _artzi_ and many other variations. I suspect testers pronounce it _artsay_ or _artsai_ and never get the correct response.

#### The Opening Line

The welcome prompt is required, and must describe what users can ask of the skill and the session must remain open for a user response. This means that in order to get your app certified you must build some kind of basic conversational ability. My first cut simply said _"Welcome to Artsy"_, which wasn't good enough. I added a prompt, _"Ask me about an artist."_ and included `shouldEndSession(false)` in the code.

#### Stop and Cancel Intents

The skill must exit appropriately when users say _"stop"_ or _"cancel"_. This means you must build at the very least an _AMAZON.StopIntent_, _AMAZON.CancelIntent_. In my first iteration a user would say _"Alexa open Artsy"_, then _"stop"_ and would get _"Sorry, I didn't get that artist name."_.

#### Help Intent

The skill must also implement _AMAZON.HelpIntent_ as a question. In my first iteration a user would say _"Alexa open Artsy"_, then _"help"_ and would get _"Sorry, I didn't get that artist name."_. Then help would say something like _"You can ask me about Artsy. Say cancel or stop at any time."_ The certification process requires a prompt, eg. _"What artist would you like to hear about?"_ and the session must remain open via `shouldEndSession(false)`.

### Skill and Code

Find the [Artsy skill in the Alexa app](http://alexa.amazon.com/spa/index.html#skills/dp/B01MYLJO1N).

Find the [complete Skill code on Github](https://github.com/artsy/elderfield).
