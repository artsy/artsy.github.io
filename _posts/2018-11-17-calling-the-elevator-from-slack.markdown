---
layout: epic
title: Calling the Elevator from Slack
date: 2018-11-17
author: [db]
categories: [elevators, slack, ifttt, hackathon]
---
Artsy's New York HQ occupies four top floors of [401 Broadway](http://401broadway.com), located in historic Tribeca at the intersection of Broadway & Canal St., famous for its sellers of fake designer bags. Five elevators carry you up to our breathtaking views, albeit slowly.

Despite having been fully rebuilt in the last few years these machines are simply too few for the too many people working in the building. The lobby gets packed in the morning. The floors are crowded with coworkers waiting for an elevator to go to lunch around noon. Elevators make all local stops.

Because everything is a technology problem, I decided to improve this situation during our fall hackathon by building a Slack bot to call the elevator. Slack it, keep working for a few minutes, then dash out when you hear the elevator "ding", collectively gaining hours of productivity!

<!-- more -->
### Pressing the Button

The first challenge in building an elevator bot was pressing the call button. The elevators didn't have an API and it's unlikely that the building would have let me rewire the controls. I found the excellent [Switch Bot](https://www.switch-bot.com) and bought one for $29. With battery-powered button attached to the wall I could call the elevator from my desk using my iPhone, over Bluetooth. The bot pushed the button for me. Genius!

![](/images/2018-11-17-calling-the-elevator-from-slack/elevator-button.gif)

### Calling the Elevator with Curl

By adding a $49.- SwitchBot Hub I managed to wire my bot to a [IFTTT web hook](https://ifttt.com/maker_webhooks). This involved creating a new applet, configuring the _if_ to receive a web hook called "elevator-on-25" and a _then_ to press a SwitchBot button.

IFTTT web hooks can be triggered with a `GET` or a `POST`. The URL to `POST` to is a bit difficult to find and is located in [Maker Webhook Settings](https://ifttt.com/services/maker_webhooks/settings) and looks like `https://maker.ifttt.com/use/your-key`. If you navigate to that URL you will see a UI that gives you a convenient `curl` shortcut, eg. `curl -X POST https://maker.ifttt.com/trigger/call-elevator-on-25/with/key/your-key`.

I could now call the elevator with `curl`!

![](/images/2018-11-17-calling-the-elevator-from-slack/elevator-doors.gif)

Note that when the SwitchBot Hub worked (it required a few reboots and iPhone app restarts), it only worked with a 2.4G Wifi.

### Calling the Elevator from Slack

As someone who had invested excessive amounts of time into Slack bots (I co-maintain the [slack-ruby organization](https://github.com/slack-ruby) and run half a dozen bots in production, including the [very popular ping-pong leaderboard bot](https://www.playplay.io)) my initial reaction was to roll out a full blown bot service to press elevator buttons.

Fortunately, I was running out of time and looked for an easier solution. Slack's Outgoing WebHooks can `POST` to an URL in a response to a random command in any Slack channel. I configured "call elevator on 25" to `POST` to IFTTT in a few seconds. My mission was accomplished without writing a line of code.

![](/images/2018-11-17-calling-the-elevator-from-slack/slack-outgoing-webhook.png)

Another IFTTT web hook would send a message to Slack saying that the elevator was on its way.

![](/images/2018-11-17-calling-the-elevator-from-slack/call-elevator-on-25.gif)

Mission accomplished!
