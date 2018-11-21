---
layout: epic
title: Managing Secrets in a React Native App
date: 2018-06-15
author: erik
categories: [Technology, emission, reactnative, react, javascript, ios]
---

<!--
Iɴᴛʀᴏᴅᴜᴄᴛɪᴏɴ
-->

Hi! I'm Erik, a software engineer on the Purchase team. One of the most visible payoffs from Artsy's investments in React Native [over the past two years][react-native-tag] has been the opening up of our mobile codebase to contributors like myself coming primarily from web stacks. It's nice to be able to build mobile interfaces with the same declarative API used by so many of our web projects, but sometimes we still need to bridge the divide to our Objective-C and Swift ecosystem. One such case: replacing the app secrets typically loaded from a deploy environment or web developer's [dotenv][] file.

<!-- more -->
<!--
Mᴀɪɴ Bᴏᴅʏ
-->

[Emission][] is Artsy's React Native component library. It contains its own native app in the `/Example` folder, which uses [cocoapods-keys][] to store secrets while still letting us code in the open. In order to expose these keys to our React Native components, however, we must do a fair bit of setup. Here's a straightforward how-to that also makes a quick tour through the iOS ecosystem for web developers looking at the React Native JavaScript runtime today.

Links to examples below come from [this commit](https://github.com/artsy/emission/pull/1086/commits/4a2a3e9260e97d791536cf38376a06b0ad0946a8) which adds a key for the Stripe API to Emission. When we are finished, a client app (`/Example`, [Eigen][], etc.) will be able to initialize Emission with this secret, which will in turn make it available to React Native components.

## Steps

#### 1. Add the key to the app's Podfile.

This is the extent of `cocoapods-keys` official [setup][ck-setup], and after this you **could** set the key via `pod keys set <NAME>` or `pod install`... but we have more to do.

[/Example/Podfile](https://github.com/artsy/emission/blob/4a2a3e9260e97d791536cf38376a06b0ad0946a8/Example/Podfile#L63):

```diff
plugin 'cocoapods-keys', {
  :target => 'Emission',
  :keys => [
    'ArtsyAPIClientSecret',
    'ArtsyAPIClientKey',
+    'StripePublishableKey',
  ]
}
```

---

#### 2. Configure the library to consume our new key

We'll need to update the `initWithUserId...` function — one **fun** part of adjusting to Objective-C is that rather than named functions, we just refer to them by their entire signatures — to expose the new key as a property and add it to `constantsToExport` ([docs][constantstoexport]).

Note that this is happening in our _Emission Pod_; The pod now expects that key to be available in our _consuming_ Example app as defined above.

[/Pod/Classes/Core/AREmission.h](https://github.com/artsy/emission/blob/4a2a3e9260e97d791536cf38376a06b0ad0946a8/Pod/Classes/Core/AREmission.h#L17-L34):

```diff
// ENV Variables
 #import <React/RCTBridgeModule.h>

 @interface AREmissionConfiguration : NSObject <RCTBridgeModule>

+ @property (nonatomic, copy, readonly, nullable) NSString *stripePublishableKey;

 - (instancetype)initWithUserID:(NSString *)userID
           authenticationToken:(NSString *)token
                     sentryDSN:(nullable NSString *)sentryDSN
+         stripePublishableKey:(NSString *)stripePublishableKey
              googleMapsAPIKey:(nullable NSString *)googleAPIKey
                    gravityURL:(NSString *)gravity
                metaphysicsURL:(NSString *)metaphysics
                     userAgent:(NSString *)userAgent;
```

`AREmission`'s implementation (.m) needs to be configured to take this new key- It will be exported to our React Native components as `Emission`. We make our initializer match the signature defined in the header (.h) file, and add an instance `_stripePublishableKey` to match the `@property` declaration.

[/Pod/Classes/Core/AREmission.m](https://github.com/artsy/emission/blob/4a2a3e9260e97d791536cf38376a06b0ad0946a8/Pod/Classes/Core/AREmission.m#L24-L60):

```diff
 @implementation AREmissionConfiguration
 RCT_EXPORT_MODULE(Emission);
 # ...

 - (NSDictionary *)constantsToExport
 {
   return @{
+    @"stripePublishableKey": self.stripePublishableKey ?: @"",
     # ...lots more
   };
 }

 - (instancetype)initWithUserID:(NSString *)userID
            authenticationToken:(NSString *)token
                      sentryDSN:(NSString *)sentryDSN
+          stripePublishableKey:(NSString *)stripePublishableKey
               googleMapsAPIKey:(NSString *)googleAPIKey
                     gravityURL:(NSString *)gravity
                 metaphysicsURL:(NSString *)metaphysics
                      userAgent:(nonnull NSString *)userAgent
 {
     self = [super init];
     _userID = [userID copy];
+    _stripePublishableKey = [stripePublishableKey copy];
     # ... More copies...
     return self;
 }
```

_Why is `copy` needed at all? See [here](https://stackoverflow.com/questions/387959/nsstring-property-copy-or-retain/388002#388002)._

---

#### 3. Configure the example app to expose the new key to our library

After making sure we have imported the keys from `cocoapods-keys` we update Emission's setup to use the new initializer signature we defined above.

[Example/Emission/AppDelegate.m](https://github.com/artsy/emission/blob/4a2a3e9260e97d791536cf38376a06b0ad0946a8/Example/Emission/AppDelegate.m#L109):

```diff
#import <Keys/EmissionKeys.h>

  - (void)setupEmissionWithUserID:(NSString *)userID accessToken:(NSString *)accessToken keychainService:(NSString *)service;
  {
    # ...
     AREmissionConfiguration *config = [[AREmissionConfiguration alloc]
      initWithUserID:userID
      authenticationToken:accessToken
      sentryDSN:nil
+     stripePublishableKey:keys.stripePublishableKey
      googleMapsAPIKey:nil
      gravityURL:setup.gravityURL
      metaphysicsURL:setup.metaphysicsURL
      userAgent:@"Emission Example"];
    # ...
```

---

#### 4. Use that configured key in a React Native component.

`Emission` is now exposed along with its configured keys via React Native's [NativeModules][].

[src/lib/Components/Bidding/Screens/ConfirmFirstTimeBid.tsx](https://github.com/artsy/emission/blob/4a2a3e9260e97d791536cf38376a06b0ad0946a8/src/lib/components/bidding/screens/confirmfirsttimebid.tsx#l31):

```js
import { NativeModules } from "react-native";
const Emission = NativeModules.Emission || {};

stripe.setOptions({
  publishableKey: Emission.stripePublishableKey
});
```

<!--
Cᴏɴᴄʟᴜsɪᴏɴ
-->

That's it! Compared to a familiar dotenv file, **it** certainly means a bit more ceremony here, but we are working through React Native code, its containing Pod _and_ a consuming app. The process is more complicated, but it's also a nice overview of some fundamentals of Objective-C, iOS development and bridging the gap between react and mobile native code.

[react-native-tag]: https://artsy.github.io/search/?q=react+native
[dotenv]: https://www.npmjs.com/package/dotenv
[emission]: https://github.com/artsy/emission
[eigen]: https://github.com/artsy/eigen
[ck-setup]: https://github.com/orta/cocoapods-keys#usage
[cocoapods-keys]: https://artsy.github.io/blog/2015/01/21/cocoapods-keys-and-CI/
[ash]: https://twitter.com/ashfurrow/
[nativemodules]: https://facebook.github.io/react-native/docs/native-modules-ios.html
[constantstoexport]: https://facebook.github.io/react-native/docs/native-modules-ios.html#exporting-constants
