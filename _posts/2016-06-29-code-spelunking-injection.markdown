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

I am of the \_why [camp of programming](https://www.smashingmagazine.com/2010/05/why-a-tale-of-a-post-modern-genius/#dont-be-afraid-to-take-risks) - the code we are spelunking through can feel foreign to modern Objective-C, and it's not got tests. The end result of all this code _is_ beautiful, whether the code is - is a matter of perspective. 

## Targets

* InjectionPlugin - The user facing Xcode plugin
* InjectionLoader - A Bundle target which is used to skip patching a project for injection.
* iOSBundleTemplate - A folder to a reference implementation of a iOS Project
* OSXBundleTemplate - A folder to a reference implementation of a OSX Project
* unhide - A command line tool that extracts symbols from a Swift Framework

## Implementation Order

I want to go through the code-base from the perspective what happens when it:

* Loads up inside Xcode.
* Recieves a call to inject.

### Launch

All Xcode plugins have the exact same launch process, you [define a class][principal_class] in the info.plist, this class, `INPluginMenuController`, gets `+ pluginDidLoad:` called, this is where you [set up a shared instance][launch_shared], and can keep a reference to your bundle.

This eventually triggers the interesting stuff, in `applicationDidFinishLaunching:`. It first pulls out some [useful private classes][private_classes] from Xcode, they're moved into instance variabels - these are used later. 

It then sets up the [user interface from a nib file][nib_setup], which [DIs][di] in a lot of the instance variables, and will send you to get a new version of Injection if it fails. It then sets up the menu ( note: [interesting use of c-structs here][menu_structs] ) and starts a TCP server, then registers for when a `NSWindow` becomes active.

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

Here is it [running][bbrowser_running] in [Bonjour Browser][bbrowser]. So, what does this server do? That's handled inside `INPluginClientController`. I don't know why it uses a substring of your MAC address.

At its simplest, the server exists to send messages between running multiple applications and the injection plugin. We'll get back to what the server does later.

#### Inside Xcode

The plugin will keep track of the key editor window, [this is done][window_checking] by making sure the window's controller is of the class `IDEWorkspaceWindowController` and that it has a corresponding file.

That's basically everything now, until a user decides to start using Injection. So we're going to move to what happens when you press `ctrl + =`. 

#### On Preparing for Injection

The work starts at `injectSource` [from INPluginMenuController][inject_source]. 

The first thing it does is make sure the current file is grab the current file, then saves it. It then checks what type of file it is, as only `.m, .mm, .swift or .storyboard` can be injected.

Next, it pulls out a reference to the currently running LLDB session, the console in the bottom of Xcode. It checks if the server has any active clients. 

OK, to understand this you need to understand what "unpatched injection" is. In order to support code injection, your app has to have some way to communicate back to the TCP server hosted in Xcode. This can be done either by [including some source code][unpatched] in your project, or by adding it in at runtime. Including the source code, is "patching" your project to allow injection. It's optional because of what comes next.

If there are no clients connected, then requests a pause from LLDB, allowing interaction, it then waits a few microseconds to give the debugger chance to load. Once it's loadded `loadBundle:` is [called][load_bundle]. This is the second target from the list at the top, and is hosted inside the plugin's bundle (meta...).

Injection then sends `expr -l objc++ -O -- (void)[[NSClassFromString(@"NSBundle")  bundleWithPath:@"/Users/orta/Library/Application Support/Developer/Shared/Xcode/Plug-ins/InjectionPlugin.xcplugin/Contents/Resources/InjectionLoader.bundle"] load]` into the debugger. Causing the same code as the patch to exist inside your app.
 
With that verified, it's ready to inject the source code.

#### Code Injection Compilation

If everything is good, and ready to go, and we've got confirmation that a client exists, Injection starts monitoring for file changes inside your Xcodeproject.

A lot of the code injection work is done inside perl scripts, another new language for me. OK, so, at the end of `injectSource` it runs [injectSource.pl][injection_source_pl] with an argument of the file to inject.

Note, a lot of ground-work for the perl scripts is done inside [common.pm][common_pm] - which is a module the other [scripts import][use_common].

It is the role and responsibility of this script to setup, maintain and amend an xcodeproject that compiles just the class that has changed into a new bundle. Luckily for me this is pretty well documented `:D`. 

It starts out by copying a template xcodeproject (either `iOSBundleTemplate` or `OSXBundleTemplate`) into your current project directory. I [add this][eigen_gitignore] to the `.gitignore`.

Next it pulls out the build settings for all these keys `FRAMEWORK_SEARCH_PATHS HEADER_SEARCH_PATHS USER_HEADER_SEARCH_PATHS GCC_VERSION ARCHS VALID_ARCHS GCC_PREPROCESSOR_DEFINITIONS GCC_ENABLE_OBJC_EXCEPTIONS` from your project, into the sub-project.

Next it determines how to handle code-signing on the app, as it supports both simulator and on-device. 

After that if needs to understand how to compile an individual file, so it gets a reference to the build log dirs for the [derived data][derived_data_logs] for your app. They're zipped, files, so it unzips them and parses the log. Here's an example of what [compiling a single class from Eigen looks like][a_build_log] (I've highlighted the useful bits). Internally, this is called the learnt db.

The learnt db is used to compile a class to be individually compiled into a `injecting_class.o` file, I can't quite figure out where that file comes from though. 

To wrap up the compilation it needs to take the compiled object `injecting_class.o` and statically link it to the bundle that is generated inside the sub-project. Here is the [command line generation][learnt_command], building the script is a little bit [more involved][learn_build] - but that's generally because it's trying to support a lot of user options. The main class that exists in the bundle is `BundleContents`.

The compiled bundle is then renamed so that you don't have name clashes, it's just incremental integers. My current sub-project I'm using for debugging looks like this:

![Injection Subproject](/images/2016-06-29-injection-overview/injection_subproject.png)

With the `Logs` dir being a symlink to the derived data folder. 

With that done, it will [include any nibs][compile_nibs] from compiling storyboards, and [code-sign the bundle][code_sign_bundle] if it's going to a device. Finally it echoes out [the new bundle path][new_bundle_path] in aso that the next step can happen.

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
* If it succeds, [write the location][client_file_loc] of the `BundleInjection` file to the server. Triggering the first of the socket work on the server.
* Expect a response of the [server's][server_bundle_loc] version of `BundleInjection`
* If the bundle is compiling storyboards on iOS, [swizzle some][nib_swizzling] of the UINib init functions.
* Pass the [home directory of the app][client_app_home] to the server.

From there the socket goes into runloop mode on it's on thread. 

#### Client Socket Runloop

As with server monitoring, the client listens for strings that begin with special prefixes:

* `~` - Injects, then Re-creates the app degelate + view controller heirarchy.
* `/` - [Loads][load_bundle_client] the bundle path that was sent in.
* `>` - Accepts a file or directory to [be sent through the socket][sending_files_to_client].
* `<` - Sends a requested file or directory to [through the socket][sending_files_from_client].
* `#` - [Recieves][client_update_image] an `NS/UIImage` via NSData from the server, for Tunable Parameters.
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

Which is where this goes from "complex", to "I couldn't do this." Let's start of quoting the README that John and I worked on for a while.

> It can be tough to look through all of the memory of a running application. In order to determine the classes and instances to call the injected callbacks on, Injection performs a "sweep" to find all objects in memory. Roughly, this involves looking at an object, then recursively looking through objects which it refers to. For example, the object's instance variables and properties.

> This process is seeded using the application's delegate and all windows. Once all the in-memory reference are collected, Injection will then filter these references to ones that it has compiled and injected. Then sending them the messages referenced in the callbacks section.

> If no references are found, Injection will look through all objects that are referred to via sharedInstance. If that fails, well, Injection couldn't find your instance. This is one way in which you may miss callbacks in your app.


####  Client Injection Sweep

`BundleInjection.h` adds a few methods to NSObject for injection:

```objc
@interface NSObject(injected)
+ (void)injectedClass:(Class)aClass;
+ (void)injected;
- (void)injected;
- (void)onXprobeEval;
- (void)setViewController:vc;
@end
```


#### Parameters




[di]: http://artsy.github.io/blog/2016/06/27/dependency-injection-in-swift/
[bonjour]: https://en.wikipedia.org/wiki/Bonjour_%28software%29
[bbrowser]: http://tildesoft.com
[bbrowser_running]: /images/2016-06-29-injection-overview/selected-bonjour.png
[eigen_gitignore]: https://github.com/artsy/eigen/pull/1236/files#diff-a084b794bc0759e7a6b77810e01874f2R46
[derived_data_logs]: /images/2016-06-29-injection-overview/build_logs.png
[a_build_log]: /images/2016-06-29-injection-overview/a_build_log.png
[badge]: /images/2016-06-29-injection-overview/badge.png

[principal_class]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Info.plist#L21-L22
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
[unpatched]: https://github.com/johnno1962/injectionforxcode/blob/master/documentation/patching_injection.md
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
[asking_for_app_path]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/INPluginClientController.m#L216
[watch_project]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/INPluginMenuController.m#L432-L436
[fstream]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/FileWatcher.m#L31
[app_architecture]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/INPluginClientController.m#L229-L230
[BundleInjection.h]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h
[bundle_loader]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L359
[param_setup]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L366-L367
[tunable]: https://github.com/johnno1962/injectionforxcode/blob/master/documentation/tunable_parameters.md
[client_arch]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L383-L400
[client_file_loc]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L415
[server_bundle_loc]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L417
[nib_swizzling]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L424-L429
[client_app_home]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L443
[load_bundle_client]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L644
[sending_files_to_client]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L476
[sending_files_from_client]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L492
[client_update_image]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/Classes/BundleInjection.h#L540
[auto_loaded_notify]: https://github.com/johnno1962/injectionforxcode/blob/master/InjectionPluginLite/injectSource.pl#L303-L308