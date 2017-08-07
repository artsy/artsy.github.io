---
layout: epic
title: CAalling NAtive Code
date: 2017-07-31
author: orta
categories: [mobile, ios, emission, fastlane]
---

https://facebook.github.io/react-native/docs/communication-ios.html


Let's look at how we do it in Emission:

```objc
#import <Foundation/Foundation.h>

@class AREventsModule, ARSwitchBoardModule, ARTemporaryAPIModule, ARRefineOptionsModule, ARWorksForYouModule, RCTBridge;

NS_ASSUME_NONNULL_BEGIN

@interface AREmission : NSObject

@property (nonatomic, strong, readonly) RCTBridge *bridge;
@property (nonatomic, strong, readonly) AREventsModule *eventsModule;
@property (nonatomic, strong, readonly) ARSwitchBoardModule *switchBoardModule;
@property (nonatomic, strong, readonly) ARTemporaryAPIModule *APIModule;
@property (nonatomic, strong, readonly) ARRefineOptionsModule *refineModule;
@property (nonatomic, strong, readonly) ARWorksForYouModule *worksForYouModule;

+ (instancetype)sharedInstance;
+ (void)setSharedInstance:(AREmission *)instance;

- (instancetype)initWithUserID:(NSString *)userID
           authenticationToken:(NSString *)authenticationToken;
[...]

@end

NS_ASSUME_NONNULL_END

```

* So there's an `AREmission` singleton
* We scope the exposed functions, or promises into Native Module objects
* These are all read-write properties so that the consuming apps can control behavior, not emission

* I want to make one that handles getting a photo from the camera-roll
* Show a `UIImagePickerController`

* If a photo is taken then pass that back to RN
* If the photo wasn't taken pass back null
* Sounds like a Result/Promise to me

* So we want to make a new module

```objc
typedef void(^ARTakePhotoTrigger)(UIViewController *_Nonnull controller, _Nonnull RCTPromiseResolveBlock resolve, _Nonnull RCTPromiseRejectBlock reject);

@interface ARTakeCameraModule : NSObject <RCTBridgeModule>
@property (nonatomic, copy, nullable, readwrite) ARTakePhotoTrigger triggerCreatingACameraPhoto;
@end
```

* Needs a VC to show modal on

* Add implementation

```objc
#import "ARTakeCameraPhotoModule.h"

#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/UIView+React.h>
#import <React/RCTRootView.h>

@implementation ARTakeCameraModule

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(triggerCameraModal:(nonnull NSNumber *)reactTag initialSettings:(nonnull NSDictionary *)initial currentSettings:(nonnull NSDictionary *)current resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *rootView = [self.bridge.uiManager viewForReactTag:reactTag];
        while (rootView.superview && ![rootView isKindOfClass:RCTRootView.class]) {
            rootView = rootView.superview;
        }

        self.triggerCreatingACameraPhoto(rootView.reactViewController, resolve, reject);
    });
}

@end
```

* This exposes `ARTakeCameraModule.triggerCameraModal(reactTag)` to the JS, here's how we'd use it. I want access to the Component's view controller, so we pass that in.

```ts
import { findNodeHandle, NativeModules } from "react-native"
const { ARTakeCameraModule } = NativeModules

async function triggerCamera(component: React.Component<any, any>): Promise<any> {
  let reactTag
  try {
    reactTag = findNodeHandle(component)
  } catch (err) {
    console.error("could not find tag for ARTakeCameraModule.triggerCameraModal")
    return
  }
  return ARTakeCameraModule.triggerCameraModal(reactTag)
}

export default { triggerCamera }
```

* Which will pass in the view for the React Component, which is eventually turned into a UIViewController inside the native code above.
* This eventually calls the promise block which is a readwrite property
* This means that any consumer of this library needs to set the block for `triggerCreatingACameraPhoto` inside the `AREmission`

* Our example app is a consumer of the library, so we can add something trivial there.

```objc
emission = [[AREmission alloc] initWithUserID:userID authenticationToken:accessToken packagerURL:jsCodeLocation useStagingEnvironment:useStaging];
[AREmission setSharedInstance:emission];

[...]

emission.cameraModule.triggerCreatingACameraPhoto = ^(UIViewController * _Nonnull controller, RCTPromiseResolveBlock  _Nonnull resolve, RCTPromiseRejectBlock  _Nonnull reject) {
    resolve(@{});
}
```

And now we can look at adding some code to call our new module in the react world

```jsx
export default class SelectFromPhotoLibrary extends React.Component<Props, State> {
  [...]

  onPressNewPhoto = () => {
    triggerCamera(this).then(photo => {
      if (photo) {
        console.log("Cancelled")
      } else {
        console.log("Got photo back")
        console.log(photo)
      }
    })
  }
}
```
