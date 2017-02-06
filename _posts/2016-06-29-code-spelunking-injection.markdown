---
layout: post
title: "Code Spelunking: Injection for Xcode Plugin"
date: 2016-06-29 12:00
author: orta
categories: [mobile, swift, xcode, tooling]
---

It was only three months ago that I came to the conclusion of just how much time I had wasted [on code compilation cycles](http://artsy.github.io/blog/2016/03/05/iOS-Code-Injection/), once I started to play with [Injection for Xcode](https://github.com/johnno1962/injectionforxcode). I still feel guilt about the time I wasted. However, I'm trying to turn that into something constructive. In order to do that, I need to have a solid understanding of the fundamentals on how Injection For Xcode works.

[Ash](https://ashfurrow.com/) says one of the best ways to [learn is to teach](https://ashfurrow.com/blog/teaching-learning/). So I'm going to try take you through a guided tour of the code-base. You need some pretty reasonable Objective-C chops to get this, but anyone with an app or two under their belt should be able to [grok](https://en.wikipedia.org/wiki/Grok) it. 

<!-- more -->

![Xcode Project Overview](/images/2016-06-29-injection-overview/overview.png)

You might find it easier to clone the repo and have Xcode open along-side this article, to quickly do that, run these commands to put it in a temporary folder via the terminal:

```sh
cd /tmp/
git clone https://github.com/johnno1962/injectionforxcode TempInjection
open TempInjection/InjectionPluginLite/InjectionPlugin.xcodeproj/
```

## A note on code style

I am of the \_why [camp of programming](https://www.smashingmagazine.com/2010/05/why-a-tale-of-a-post-modern-genius/#dont-be-afraid-to-take-risks) - the code we are spelunking through can feel foreign to modern Objective-C, and it's not got tests. [@Johno1962][johnno1962] described it to me as being like 1997's Objective-C. The end result of all this code _is_ beautiful, whether the code is - is a matter of perspective. I'm super happy it exists.

## Targets

* InjectionPlugin - The user facing Xcode plugin
* InjectionLoader - A Bundle used to skip patching a project for injection.
* iOSBundleTemplate - A folder to a reference implementation of a iOS Project
* OSXBundleTemplate - Same but for OSX Project
* unhide - A command line tool that extracts symbols from a Swift Framework

## Implementation Order

I want to go through the code-base from the perspective what happens when it:

* Loads up inside Xcode.
* Recieves a call to inject.

### Launch

All Xcode plugins have the exact same launch process, you [define a class][principal_class] in the info.plist, this class, `INPluginMenuController`, gets `+ pluginDidLoad:` called. This is where you [set up a shared instance][launch_shared], and can keep a reference to your bundle.

This triggers the interesting stuff in `applicationDidFinishLaunching:` this sets up the [user interface from a nib file][nib_setup], which [DIs][di] in a lot of the instance variables, and will send you to get a new version of Injection if it fails. It then sets up the menu ( note: [interesting use of c-structs here][menu_structs] ) and starts a TCP server, then registers for when a `NSWindow` becomes active.

#### Server

The server is a [c TCP socket][tcp_socket], prior to digging in here, I'd never needed to see one. I see a lot of references to Android injection, so I assume the low-level choice in a socket  was so the same code can do both platforms.

``` c
- (void)startServer {
    struct sockaddr_in serverAddr;

    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = INADDR_ANY;
    serverAddr.sin_port = htons(INJECTION_PORT);

    int optval = 1;
    if ( (serverSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0 )
        [self error:@"Could not open service socket: %s", strerror( errno )];
    [...] // skipping a bunch of error handling
    else if ( listen( serverSocket, 5 ) < 0 )
        [self error:@"Service socket would not listen: %s", strerror( errno )];
    else
        [self performSelectorInBackground:@selector(backgroundConnectionService) withObject:nil];
}
```

Assuming everything went well, then a [Bonjour][bonjour] [service][bonjour_service] is created advertising the socket on the network. This then moves to a background thread and starts a infinite runloop checking for new connections on the [socket every 0.5 seconds][socket_runloop].

Here is it [running][bbrowser_running] in [Bonjour Browser][bbrowser]. So, what does this server do? That's handled inside `INPluginClientController`. It uses a MAC address so that you can have multiple non-competing services running on the same network.

At its simplest, the server exists to send messages between running multiple applications and the injection plugin. We'll get back to what the server does later.

#### Inside Xcode

The plugin will keep track of the key editor window, [this is done][window_checking] by making sure the window's controller is of the class `IDEWorkspaceWindowController` and that it has a corresponding file.

That's basically everything set up for the plugin now, until a user decides to start using Injection. So we're going to move to what happens when you press `ctrl + =`. 

#### On Preparing for Injection

The work starts at `injectSource` [from INPluginMenuController][inject_source]. 

The first thing it does is grab the current file, then saves it. It then checks what type of file it is, as only `.m, .mm, .swift or .storyboard` can be injected.

Next, it pulls out a reference to the currently running LLDB session, the console in the bottom of Xcode. It checks if the server has any active clients. 

OK, to understand the next bit you need to understand what _"unpatched injection"_ is. In order to support code injection, your app has to have some way to communicate back to the TCP server hosted in Xcode. This can be done either by [including some source code][unpatched] in your project, or by adding it in at runtime. Including the source code, is "patching" your project to allow injection. It's optional because of what comes next.

If there are no clients connected, then requests a pause from LLDB, allowing the plugin to send messages to the running app, it then waits a few microseconds to give the debugger chance to load. Once it's loaded `loadBundle:` is [called][load_bundle].

Injection then sends `expr -l objc++ -O -- (void)[[NSClassFromString(@"NSBundle")  bundleWithPath:@"/Users/orta/Library/Application Support/Developer/Shared/Xcode/Plug-ins/InjectionPlugin.xcplugin/Contents/Resources/InjectionLoader.bundle"] load]` into the debugger. Causing the same code as the patch to exist inside your app.  This code comes from the second target from the list at the top, and is hosted inside the plugin's bundle (meta...).
 
With that verified, it's ready to inject the source code.

#### Code Injection Compilation

If everything is good, and ready to go, and we've got confirmation that a client exists, Injection starts monitoring for file changes inside your Xcodeproject.

A lot of the code injection work is done inside perl scripts, another new language for me. OK, so, at the end of `injectSource` it runs [injectSource.pl][injection_source_pl] with an argument of the file to inject.

Note, a lot of ground-work for the perl scripts is done inside [common.pm][common_pm] - which is a module the other [scripts import][use_common].

It is the role and responsibility of this script to setup, maintain and amend an xcodeproject that compiles just the class that has changed into a new bundle. Luckily for me this is pretty well documented `:D`. 

It starts out by copying a template xcodeproject (either `iOSBundleTemplate` or `OSXBundleTemplate`) into your current project directory. I [add this][eigen_gitignore] to the `.gitignore`.

Next it pulls out the build settings for all these keys `FRAMEWORK_SEARCH_PATHS HEADER_SEARCH_PATHS USER_HEADER_SEARCH_PATHS GCC_VERSION ARCHS VALID_ARCHS GCC_PREPROCESSOR_DEFINITIONS GCC_ENABLE_OBJC_EXCEPTIONS` from your project, into the sub-project.

Next it determines how to handle code-signing on the app, as it supports both simulator and on-device, and you need to sign to run any code on a device.

After that, if needs to understand how to compile an individual file, it gets a reference to the build log dirs for the [derived data][derived_data_logs] for your app. They're zipped files, so it unzips them and parses the log. Here's an example of what [compiling a single class from Eigen looks like][a_build_log] (I've highlighted the useful bits). Internally, this is called the learnt db.

The learnt db is used to compile a class to be individually compiled into a `injecting_class.o` file, I can't quite figure out where that file comes from though. 

To wrap up the compilation it needs to take the compiled object `injecting_class.o` and statically link it to the bundle that is generated inside the sub-project. Here is the [command line generation][learnt_command], building the script is a little bit [more involved][learn_build] - but that's generally because it's trying to support a lot of user options. The main class that exists in the bundle is `BundleContents`.

The compiled bundle is then renamed so that you don't have name clashes, it's just incremental integers. My current sub-project I'm using for debugging looks like this:

![Injection Subproject](/images/2016-06-29-injection-overview/injection_subproject.png)

With the `Logs` dir being a symlink to the derived data folder. 

With that done, it will [include any nibs][compile_nibs] from compiling storyboards, and [code-sign the bundle][code_sign_bundle] if it's going to a device. Finally it prints out [the new bundle path][new_bundle_path] in so the monitoring script can work with it.

#### Script Monitoring

The script to create the Xcode project, amend it, and compile is done as a separate process. It's [done][open_script] via the [function][popen] `popen`. This is then monitored in background, [listening for output lines][output_lines] that begins with `<`, `>`, `!`, `%` and `?`. The one that we're most interested in, is the `!` operator which tells the server the filepath of the now compiled `InjectionBundleX.bundle`, in my most recent case, this looked like `/Users/orta/dev/ios/energy/iOSInjectionProject/build/Debug-iphonesimulator/InjectionBundle4.bundle`.

This [tells the][tells_server] server running inside Xcode that it has a file to send to the clients.

#### How the server works

Alright, back to [the INPluginClientController][INPluginClientController]. Skipping over the option setting `IBAction`s and [RTF-formatted logging][rtf_logging]. We come to the initial connection responder: `setConnection:`. 

So, this is where I ended up a bit out of my comfort zone. This isn't a blog post about sockets and c though, so I'll annotate what's going on from the high level thoughout this [connection setup function][socket_connection].

* Grab some the main client file from socket, then if it's is an injection message, set the Injection console's info label to that filepath, this is the `BundleContents.m`.
* Otherwise inject all objects from a storyboard (not too sure whats going on there TBH)
* The server [asks the client][asking_for_app_path] for the app's path e.g. `/Users/orta/Library/Developer/CoreSimulator/Devices/CDC9D8EF-AAAD-47F8-8D53-C3C69551E85A/data/Containers/Data/Application/1F636180-7113-406E-88F8-7E43EFAC13F6"`
* There's some more communication around the [app's architecture][app_architecture].
* The app gets a [badge][badge] with the client count on it, so you know it's working.
* If checks if you want the File Watcher turned on.

From that point the server's job is mainly to pass messages and files that come out of the scripts between the client and the host doing the compilation.

#### File Watcher

As an option you can set in the preferences toggles a File Watcher. I found a bunch of references to this in the code, so I wanted to at least dig into that. When you turn it on, any save will trigger an injection. This is done by looking for the folder that your [project resides in][watch_project], then using Apple's [file system event stream][fstream] to monitor for save changes. Then when a new FS event is triggered, it re-injects that file. I bet it's turned off by default as you'll see errors when it's not compilable.

## Client-Side

We've hand-waved though the client-side of the app during the patching stage of installation, but to understand both parts of the system we need to cover the client side in a bit more depth. There's two aspects to it, the initial bundle/patch and incremental bundles that contain the new compiled code. 

#### Client Setup

To understand this, we need to grok a 1,200 LOC header file `:D`, it has a few responsibilities though. So we can try work through those, to [BundleInjection.h][BundleInjection.h]. Interesting note, when you are patching your application - you're actually making a link to a copy of this file inside your `/tmp/` dir.

```objc
#ifdef DEBUG
static char _inMainFilePath[] = __FILE__;
static const char *_inIPAddresses[] = {"10.12.1.67", "127.0.0.1", 0};

#define INJECTION_ENABLED
#import "/tmp/injectionforxcode/BundleInjection.h"
#endif
```

#### Client Socket Connection

Like the server, this has two responsibilities - using Bonjour to find the server, and raw socket communication. There is nothing unique about the Bonjour mutlicast work, so I'm skipping that. Once the socket knows how to establish a connection between processes `+ bundleLoader` [is called][bundle_loader] on a background thread.

So, what does `bundleLoad` do?

* It checks if it's a new Injection install in the app, [if so][param_setup] it sets up [INParameters and INColors][tunable] for tunable parameters.
* It then determines the [hardware architecture][client_arch] for it to be sent to the server for compilation later.
* Attempt to connect to the server, 5 times.
* If it succeeds, [write the location][client_file_loc] of the `BundleInjection` file to the server. Triggering the first of the socket work on the server.
* Expect a response of the [server's][server_bundle_loc] version of `BundleInjection`
* If the bundle is compiling storyboards on iOS, [swizzle some][nib_swizzling] of the UINib init functions.
* Pass the [home directory of the app][client_app_home] to the server.

From there the socket goes into runloop mode on it's on thread. 

#### Client Socket Runloop

As with server monitoring, the client listens for strings that begin with special prefixes:

* `~` - Injects, then Re-creates the app degelate + view controller hierarchy.
* `/` - [Loads][load_bundle_client] the bundle path that was sent in.
* `>` - Accepts a file or directory to [be sent through the socket][sending_files_to_client].
* `<` - Sends a requested file or directory to [through the socket][sending_files_from_client].
* `#` - [Receives][client_update_image] an `NS/UIImage` via NSData for Tunable Parameters.
* `!` - Logs to console
* Otherwise, assume it's another Tunable Parameter.

#### Loading the Bundle

When the new bundle is loaded [it triggers][auto_loaded_notify] this code:

``` objc
+ (void)load {
    Class bundleInjection = NSClassFromString(@"BundleInjection");
    [bundleInjection autoLoadedNotify:$flags hook:(void *)injectionHook];
}
```

Which does the job of letting the running app know that instances have been updated with new code. Injection does three things:

* A global NSNotification for .
* Sends all instances of classes injected a message that they've been injected.
* Sends all classes that have been injected a message they've been injected.

Which is where this goes from "complex", to "I would need to study up to do this." Let's start of quoting the README that [@Johno1962][johnno1962] and I worked on for a while.

> It can be tough to look through all of the memory of a running application. In order to determine the classes and instances to call the injected callbacks on, Injection performs a "sweep" to find all objects in memory. Roughly, this involves looking at an object, then recursively looking through objects which it refers to. For example, the object's instance variables and properties.

> This process is seeded using the application's delegate and all windows. Once all the in-memory reference are collected, Injection will then filter these references to ones that it has compiled and injected. Then sending them the messages referenced in the callbacks section.

> If no references are found, Injection will look through all objects that are referred to via sharedInstance. If that fails, well, Injection couldn't find your instance. This is one way in which you may miss callbacks in your app.

####  Class + Method Injections

So how does it pull that off? Calling `NSBundle`'s `- load` [here][bundle_load], calls the [load function to call on all classes][all_load] inside that new bundle. This triggers the load function from the `InjectionBundle` that is auto-generated during the Injection stage. Here's what one of mine looks like:

```objc
@interface InjectionBundle3 : NSObject
@end
@implementation InjectionBundle3

+ (void)load {
    Class bundleInjection = NSClassFromString(@"BundleInjection");
    [bundleInjection autoLoadedNotify:0 hook:(void *)injectionHook];
}

@end
```

This is generated from the `injectSource.pl` script [here][injection_hook]] `[bundleInjection autoLoadedNotify:$flags hook:(void *)injectionHook];` . It also comes with another function,

```c
int injectionHook() {
    NSLog( \@"injectionHook():" );
    [InjectionBundle3 load];
    return YES;
}
```

What we care about is `&injectionHook` which gets passed to `autoLoadedNotify` as a pointer to a function. Oddly enough, I'm a tad confused about the fact that the injection hook contains a reference to the function that calls it, but lets roll with it for now. Perhaps it's never actually called, _I asked_ -it's for Android support, and isn't used.

So, we've had a fairly typical `NSBundle` `- load` load our classes into the runtime. This triggered the `InjectionBundle.bundle` to have it's classes created, and the first thing it does is pass a reference back to the `BundleInjection` class instance for the `injectionHook` function that calls the `load` on the new classes.

_Note:_ terminology changes here, I've talked about a bundle, but now that the code is in the runtime, we start talking about it as a dynamic library. These bundles contain 2 files `Info.plist`, `InjectionBundleX` - so when I say dynamic library, I'm referring to the code that is inside the bundle that is linked ar runtime (and thus dynamically linked in.)

Next, Injection creates a [dynamic library info][dl_lib_info] [struct][dl_struct] and uses [dladdr][dladdr] to fill the struct, based on the function pointer. This lets Injection know where in memory the library exists. It's now safe in the knowledge that the code has been injected into the runtime. Injection will re-create the app structure, if requested - like when it receives a socket event of `~`.

We're getting into Mach-O binary APIs, so put on your crash helmets. Injection is going to use the dynamic library info, and [ask for the Objective-C][ask_classlist] `__classlist` via [getsectdatafromheader][getsectdatafromheader] for the new dynamic library. This works fine for Swift too, it _mostly_ has to be exposed to the Objective-C runtime. If you want to understand more about what this looks like, read [this blog post][objc_reverse] from [Zynamics][zynamics]. Injection then loops through the classes inside the library, via the most [intensely casted][class_references] line in of code in here: `Class *classReferences = (Class *)(void *)((char *)info.dli_fbase+(uint64_t)referencesSection);`.

These classes are then iterated though, and [new implementations of functions are swizzled][swizzling_meths] to reference the new implementations. With Swift you have no guarantee that the methods are `dynamic` so all their `vtable` [data is switched][swift_vtables]. If you don't know what a vtable is check this [page on Wikipedia][wiki_vtables]. 

Once all of the classes have had their methods switched, the [class table is updated][class_updates] to ensure that functions that rely on the class table ( e.g. `NSClassFromSelector` ) return the new values.

With valid class tables, and the newly injected functions added. Injection starts the memory sweep to send updated notifications. 

####  Class + Instance Notifications

At [this point][start_of_notifications] Injected does a run through the new class list again, if that class responds to the selector `+ injected` it runs it. It then does a check to see if the class's instances reponds to `- injected` if it does, it looks to see if it has any instances of the objects in it's liveObjects array. If the array hasn't been set up, then it needs to do a full memory sweep.

Injection has an [Xprobe][xprobe]-lite included inside it. This lives in [BundleSweeper.h][BundleSweeper.h]. The quote opening this notification section above gave the start away, BundleSweeper [looks at the app delegate][bprobe_seed] ( or a [Cocos2D director object][cocos2d]) and then starts to recursively look at every object that it's related to. This is done by adding a `bwseep` function to `NSObject` then individually customizing it for known container classes, and "reference" classes e.g [NSBlock][NSBlock], [NSData][NSData], NSString, NSValue etc. The `bsweep` function adds itself to the [shared list][shared_seen_list] of "objects seen", checks for an it being a [private class or a transition][UITransition], if it's not then it loops through the [IvarList][ivar_list] and runs `bsweep` on all of those. With that done, it casually tests to see if there are any weakly held objects that [tend to use common selectors][weak_selectors].

Let that simmer for a bit ( I jest, it's super fast. ) and then you have _almost_ every object in your object graph being told that they've been updated. I say almost because of the above caveat. Can't find all objects this way. Singletons that never are referenced strongly from another object inside the findable graph wouldn't get a notification this way for example.

With all the fancy class an instance nofications sorted, there is a good old reliable `NSNotification` - [here][injectioned_notification]. Which is what I based my [work on for Eigen][eigen_injection], super simple, extremely reliable and great for re-use.

![https://cloud.githubusercontent.com/assets/49038/13548868/131cbb1e-e2c8-11e5-9f61-4acdfd10b6aa.gif](https://cloud.githubusercontent.com/assets/49038/13548868/131cbb1e-e2c8-11e5-9f61-4acdfd10b6aa.gif).

---

**Phew!**

So, this covered the majority of how Injection for Xcode works. It's a _really_ powerful tool, that can vastly improve your day-to-day programming. When I showed a draft of this post to [@Johno1962][johnno1962] he reminded me that [Diamond][diamond] - his Swift scripting improvement tool, had it's own version of Injector inside that, that is much [simpler and a easier read][diamond_reloader] at 120 LOC. However, can't understand the future without understanding the past. 

A lot of the most complicated code is around:

* The client-server architecture, and about passing files/folders between the running application and the Xcode plugin.
* The recursive memory sweeping required to get a notification that it's done.

The actual work involved in [doing the injection, and replacing the classes][injection_overview] isn't particularly complicated, and is easy to understand without c/Mach-o domain knowledge. It's making sure the environment is set up and supporting useful features like Storyboards, Android via Apportable, ARC and no-ARC, 32bit vs 64bit and iOS vs Mac where things start to become more complex.

As of Xcode 8, Xcode Plugins are on the way out, though there are hacks to work around the system to install them, doing so might not be the smartest of moves yet. It's hard to see where the future lies here. However, 

![Giphy](http://media2.giphy.com/media/VHW0X0GEQQjiU/giphy.gif)

So we'll see in a few months.

If you're interested in this kind of stuff, follow [@Johno1962][johnno1962] on Twitter, he's [@Injection4Xcode][Injection4Xcode] - Chris Lattner follows him, so you know it's good stuff. He's always got some project that is pushing a boundry or two.

[di]: http://artsy.github.io/blog/2016/06/27/dependency-injection-in-swift/
[bonjour]: https://en.wikipedia.org/wiki/Bonjour_%28software%29
[bbrowser]: http://tildesoft.com
[bbrowser_running]: /images/2016-06-29-injection-overview/selected_bonjour.png
[eigen_gitignore]: https://github.com/artsy/eigen/pull/1236/files#diff-a084b794bc0759e7a6b77810e01874f2R46
[derived_data_logs]: /images/2016-06-29-injection-overview/build_logs.png
[a_build_log]: /images/2016-06-29-injection-overview/a_build_log.png
[badge]: /images/2016-06-29-injection-overview/badge.png

[principal_class]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Info.plist#L21-L22
[launch_shared]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L83-L94
[private_classes]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L125-L128
[nib_setup]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L131-L137
[menu_structs]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L151-L154
[tcp_socket]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L512-L535
[bonjour_service]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L539-L542
[socket_runloop]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L545-L557
[rtf_logging]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L129-L185
[socket_connection]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L189
[window_checking]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L214-L220
[inject_source]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L359
[unpatched]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/documentation/patching_injection.md
[load_bundle]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L404-L415
[injection_source_pl]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl
[common_pm]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/common.pm
[use_common]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L15
[learnt_command]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L331-L365
[learn_build]:https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L376-L467
[new_bundle_path]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L515
[compile_nibs]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L487-L503
[code_sign_bundle]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L505-L512
[popen]: http://linux.die.net/man/3/popen
[open_script]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L365
[output_lines]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L382
[tells_server]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L422-L423
[INPluginClientController]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m
[asking_for_app_path]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L216
[watch_project]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginMenuController.m#L432-L436
[fstream]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/FileWatcher.m#L31
[app_architecture]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/INPluginClientController.m#L229-L230
[BundleInjection.h]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h
[bundle_loader]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L359
[param_setup]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L366-L367
[tunable]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/documentation/tunable_parameters.md
[client_arch]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L383-L400
[client_file_loc]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L415
[server_bundle_loc]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L417
[nib_swizzling]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L424-L429
[client_app_home]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L443
[load_bundle_client]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L644
[sending_files_to_client]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L476
[sending_files_from_client]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L492
[client_update_image]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L540
[auto_loaded_notify]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L303-L308
[injected_notification]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L910
[auto_loader_notify]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L944
[injection_hook]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/injectSource.pl#L311-L315
[bundle_load]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L648
[all_load]: https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSBundle_Class/index.html#//apple_ref/occ/instm/NSBundle/load
[dl_lib_info]: https://github.com/davetroy/astmanproxy/blob/f4b952a717b7e982b585bf0daa86398add394a88/src/include/dlfcn-compat.h#L44-L54
[dl_struct]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L944-L946
[dladdr]: http://linux.die.net/man/3/dladdr
[getsectdatafromheader]: http://www.manpagez.com/man/3/getsectdatafromheader/
[ask_classlist]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L959-L981
[objc_reverse]: https://blog.zynamics.com/2010/07/02/objective-c-reversing-ii/
[zynamics]: https://zynamics.com
[class_references]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L988
[swizzling_meths]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L836-L845
[swift_vtables]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L847-L855
[wiki_vtables]: https://en.wikipedia.org/wiki/Virtual_method_table
[class_updates]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L911-L937
[start_of_notifications]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L1028
[xprobe]: https://github.com/johnno1962/Xprobe
[BundleSweeper.h]:https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h
[cocos2d]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L55
[bprobe_seed]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L47
[NSBlock]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L228
[NSData]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L221
[shared_seen_list]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L113-L117
[UITransition]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L119-L124
[ivar_list]: http://stackoverflow.com/questions/16304483/debug-obtain-a-list-of-all-instance-variables-of-an-object-unknown-type
[weak_selectors]: https://github.com/johnno1962/injectionforxcode/blob/16a9b8e93b458b1c5916e95df06fe8c74cb56862/InjectionPluginLite/Classes/BundleSweeper.h#L148-L160
[injectioned_notification]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L1065
[eigen_injection]: https://github.com/artsy/eigen/pull/1236
[diamond]: https://github.com/johnno1962/Diamond
[diamond_reloader]: https://github.com/johnno1962/Diamond/blob/master/Reloader/Reloader.m
[johnno1962]: https://github.com/johnno1962/
[Injection4Xcode]: https://twitter.com/Injection4Xcode
[injection_overview]: https://github.com/johnno1962/injectionforxcode/blob/2c1696e7301fdcf1d99a8a75be501df7c25d93e8/InjectionPluginLite/Classes/BundleInjection.h#L807-L938
[yaws]: https://github.com/johnno1962/Dynamo/commit/261e970cc171cec25b59121ece1e5248532eea1a
