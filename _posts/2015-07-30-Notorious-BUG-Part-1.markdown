---
layout: post
title: "Notorious BUG – The Unbugged Sessions Part 1"
date: 2015-07-30 19:21
comments: true
article-class: "expanded-code"
categories: [Objective C, debugging]
author: eloy
---

When the odds are stacked against you, your mind is overflowing, and you are ready to just pop, there’s always practical
debugging tips to help you through a cloudy day.

In this post I’ll take you through a debugging session where I reproduce a crash, for which we were receiving a bunch of
crash reports, but I was unable to reproduce by just using the application.

It will cover the following topics:

* Narrow down the breakpoint to the method invocation where the crash occurs.
* Locate the exact instruction that causes the crash.
* Look at the implementation of the method where the crash occurs.
* Simulate the crash.

<!-- more -->

### The crash report

```
Hardware Model:  iPhone5,2
OS Version:      iPhone OS 8.1.2 (12B440)

Exception Type:  SIGSEGV
Exception Codes: SEGV_ACCERR at 0x10
Crashed Thread:  0

Thread 0 Crashed:
0   libobjc.A.dylib                      0x33034f46 objc_msgSend + 5
1   UIKit                                0x28d7e4bd -[UIScrollView _getDelegateZoomView] + 66
2   UIKit                                0x2599b757 -[UIScrollView _offsetForCenterOfPossibleZoomView:withIncomingBoundsSize:] + 42
[SNIP]
7   Artsy                                0x00107087 -[ARArtworkView setUpCallbacks] + 1238
[SNIP]
```

_This crash report was shortened for clarity sake, you can find the full report
[here](https://gist.github.com/alloy/cfaab5b754fdd2c551e0)._

Now, this might not be the toughest nut to crack –if you’ve been doing UIKit development for a while, you may already
know that `UIScrollView` does not weakify it’s `delegate`– but instead of just going by experience and making some
changes, let’s see if we can’t figure out exactly what’s happening, for the sake of reproducing and confidently making
the right fix.

The lines near the top of the stack trace tell me that it’s probably a message being sent to some garbage memory, i.e.
a released object, so that’s where I want to be poking around.

### Getting at often called locations

So I want to get at the 2nd frame in the stack, but that method and the one at the 3rd frame get invoked _a lot_ while
navigating to the view I want to debug. There’s many ways to do this, but the simple approach I often take in these
cases is to set a breakpoint for the last frame in the stack that is _unique to the location that I want to get at_ and
then keep refining the breakpoints every time I hit one.

In this case that starts off with a breakpoint in
[our code](https://github.com/artsy/eigen/blob/1.7.0/Artsy/Classes/Views/ARArtworkView.m#L85):

```
(lldb) b -[ARArtworkView setUpCallbacks]
Breakpoint 1: where = Artsy`-[ARArtworkView setUpCallbacks] + 19 at ARArtworkView.m:101, address = 0x000000010e722853
```

With that set I then navigate to the view I want to get at and, once the breakpoint is hit, set the breakpoint for a
frame that’s even closer to the location I want to get at:

```
Process 74926 stopped
* thread #1: tid = 0x1b5faf, 0x000000010e722853 Artsy`-[ARArtworkView setUpCallbacks](self=0x00007fc99c95b230, _cmd=0x000000010eb60e58) + 19 at ARArtworkView.m:101, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x000000010e722853 Artsy`-[ARArtworkView setUpCallbacks](self=0x00007fc99c95b230, _cmd=0x000000010eb60e58) + 19 at ARArtworkView.m:101

(lldb) b -[UIScrollView _offsetForCenterOfPossibleZoomView:withIncomingBoundsSize:]
Breakpoint 2: where = UIKit`-[UIScrollView _offsetForCenterOfPossibleZoomView:withIncomingBoundsSize:], address = 0x00000001105c1fb7
```

And finally I repeat the process and set the breakpoint that I _really_ want to get to:

```
(lldb) b -[UIScrollView _getDelegateZoomView]
Breakpoint 3: where = UIKit`-[UIScrollView _getDelegateZoomView], address = 0x00000001105bf8cd
```

### Locating the instruction that crashes by looking at the real _on-device_ framework (iPhoneOS SDK)

By this point, I’m left with the realization that I don’t have a device running iOS 8.1.x anymore –the above was all on
the simulator– and thus jumping through the code in a debugger on a device is not going to be reliable. Instead, I’m
going to take a look at the disassembly and (pseudo) decompiled code in [Hopper](http://www.hopperapp.com) –a tool I
highly suggest you go and buy **right now**, it’s ridiculously cheap for the amount of time it will save you–.

To be able to do so, though, I first had to get a copy of UIKit for one of the devices of which we received crash logs.

* **Firmware decryption keys**: keys for many variants are listed
  [here](https://www.theiphonewiki.com/wiki/Firmware_Keys). If the model you need is not listed you’ll have to manually
  figure out the key, which is beyond the scope of this article.

* **Download firmware**: you can find links for all variants on
  [this page](https://www.theiphonewiki.com/wiki/Firmware). I chose iOS 8.1.2 for the 2nd revision of the iPhone 5
  (iPhone 5,2), because the keys to decrypt that are known and it’s one of the devices and OS versions for which we had
  received crash reports.

* **Decrypt image**: there are a bunch of tools that allow you to decrypt firmware images, which are listed
  [here](https://www.theiphonewiki.com/wiki/Category:Decryption). I’m using
  [xpwn’s ‘dmg’ tool](https://www.theiphonewiki.com/wiki/Dmg_(command)) which you can get from
  [planetbeing’s GitHub repo](https://github.com/planetbeing/xpwn/tree/master/dmg). Once you’ve got the key from
  [here](https://www.theiphonewiki.com/wiki/Firmware_Keys), or have otherwise manually figured it out, you can decrypt
  the disk image like so:

```
$ unzip -d iPhone5,2_8.1.2 iPhone5,2_8.1.2_12B440_Restore.ipsw
$ cd iPhone5,2_8.1.2
$ /path/to/xpwn/dmg/dmg extract 058-09875-017.dmg decrypted.dmg -k 02e89744a7143b9bac48fd1adc32a8ed6bcf74d428d0861d790153accb96a413e1c3b8d8
```

* **Extract UIKit from shared DYLD cache**: for performance reasons, Apple decided to create one big cache that
  contains all of the commonly used frameworks, including UIKit. To get just UIKit, you’ll need to use any of the tools
  listed [here](http://iphonedevwiki.net/index.php/Dyld_shared_cache#Cache_extraction), I used
  [dyld_decache](https://github.com/kennytm/Miscellaneous/downloads):

```
$ open decrypted.dmg
$ /path/to/dyld_decache-v0.1c -o Extracted -f UIKit /Volumes/SUOkemoTaos12B440.N42OS/System/Library/Caches/com.apple.dyld/dyld_shared_cache_armv7s
$ ls -l Extracted/System/Library/Frameworks/UIKit.framework/UIKit
-rw-r--r--  1 eloy  staff  12142776 Aug  1 10:50 Extracted/System/Library/Frameworks/UIKit.framework/UIKit
```

With that out of the way, I can finally load that up in Hopper and look at the instruction. I can get the offset of
the instruction from the stack frame, specifically the ‘66’ in
`-[UIScrollView _getDelegateZoomView] + 66`. This means that the instruction’s address is that of the function it is
located in _plus_ 66, which, as you can see in the below screenshot, is halfway through the `objc_msgSend` call:

{% include expanded_img.html url="/images/2015-07-30-Notorious-BUG-1/Hopper-Disassembled.png" title="The assembly of the `-[UIScrollView _getDelegateZoomView]` method." %}

If you want to get into the details of what these instructions are doing, I suggest you read up on a blog post such as
[this article by Mike Ash](https://www.mikeash.com/pyblog/friday-qa-2011-12-30-disassembling-the-assembly-part-3-arm-edition.html).
The important part here is that you can easily see that it’s all related to sending the following message to the scroll
view’s delegate:

```
[delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]
```

Hopper can give us (pseudo) decompiled code for this method, which looks like the following:

{% include expanded_img.html url="/images/2015-07-30-Notorious-BUG-1/Hopper-Decompiled.png" title="The pseudo-code of the `-[UIScrollView _getDelegateZoomView]` method." %}

Based on that, it’s clear to see that that’s what happens and so it’s the delegate that points to garbage, `0x10` in
this crash report to be specific.

### Simulating the crash

Now that I know what’s happening, it’s time to simulate the crash on the Simulator so that I can confidently make the
fix for what I think is going wrong.

Based on the above, I now know that, on the Simulator, this crash would occur around the 16th instruction, which is
where the `-respondsToSelector:` message gets sent, so I’ll jump to just before it, but _after_ where the `delegate`
variable would get set:

```
(lldb) disassemble --frame
UIKit`-[UIScrollView _getDelegateZoomView]:
-> 0x1105bf8cd:  pushq  %rbp
   0x1105bf8ce:  movq   %rsp, %rbp
   0x1105bf8d1:  pushq  %r15
   0x1105bf8d3:  pushq  %r14
   0x1105bf8d5:  pushq  %rbx
   0x1105bf8d6:  pushq  %rax
   0x1105bf8d7:  movq   %rdi, %r14
   0x1105bf8da:  movq   0xd344ef(%rip), %rax      ; UIScrollView._zoomView
   0x1105bf8e1:  movq   (%r14,%rax), %rbx
   0x1105bf8e5:  testq  %rbx, %rbx
   0x1105bf8e8:  jne    0x1105bf97b               ; -[UIScrollView _getDelegateZoomView] + 174
   0x1105bf8ee:  movq   0xd344c3(%rip), %r15      ; UIScrollView._delegate
   0x1105bf8f5:  movq   (%r14,%r15), %rdi
   0x1105bf8f9:  movq   0xd08228(%rip), %rdx      ; "viewForZoomingInScrollView:"
   0x1105bf900:  movq   0xd02df9(%rip), %rsi      ; "respondsToSelector:"
   0x1105bf907:  callq  *0xac2783(%rip)           ; (void *)0x0000000111fe1000: objc_msgSend
[SNIP]

(lldb) step --count 13
Process 74926 stopped
* thread #1: tid = 0x1b5faf, 0x00000001105bf8f9 UIKit`-[UIScrollView _getDelegateZoomView] + 44, queue = 'com.apple.main-thread', stop reason = instruction step into
    frame #0: 0x00000001105bf8f9 UIKit`-[UIScrollView _getDelegateZoomView] + 44
UIKit`-[UIScrollView _getDelegateZoomView] + 44:
   0x1105bf8f5:  movq   (%r14,%r15), %rdi
-> 0x1105bf8f9:  movq   0xd08228(%rip), %rdx      ; "viewForZoomingInScrollView:"
   0x1105bf900:  movq   0xd02df9(%rip), %rsi      ; "respondsToSelector:"
   0x1105bf907:  callq  *0xac2783(%rip)           ; (void *)0x0000000111fe1000: objc_msgSend
   0x1105bf90d:  xorl   %ebx, %ebx
```

At this instruction, the object to which the message will be sent has been assigned to the `$rdi` register, which in my
case is still the expected and valid object:

```
(lldb) po $rdi
<ARArtworkViewController: 0x7fc99c9681d0>
```

At this point I can just override the register with the garbage shown in the crash report:

```
(lldb) register write rdi 0x10
```

And finally continue execution and let the crashing occur:

```
(lldb) bt
* thread #1: tid = 0x1b5faf, 0x0000000111fe1005 libobjc.A.dylib`objc_msgSend + 5, queue = 'com.apple.main-thread', stop reason = EXC_BAD_ACCESS (code=1, address=0x10)
  * frame #0: 0x0000000111fe1005 libobjc.A.dylib`objc_msgSend + 5
    frame #1: 0x00000001105bf90d UIKit`-[UIScrollView _getDelegateZoomView] + 64
    frame #2: 0x00000001105c1fe9 UIKit`-[UIScrollView _offsetForCenterOfPossibleZoomView:withIncomingBoundsSize:] + 50
[SNIP]
    frame #7: 0x000000010e722853 Artsy`-[ARArtworkView setUpCallbacks] + 19
[SNIP]
```

💥

Perfect, an exact replica of the crash report, so now I know with confidence that the problem is that the
`ARArtworkViewController` is released by the time that method is called.

### Closing thoughts

The fix for this crash is simple and not really interesting for this post, as it’s all about the steps I took to arrive
there. I think these are way more interesting, as you can apply some/all of these in many different situations.

But for completeness sake, the fix is to make sure that [the scroll view’s delegate gets nillified](https://github.com/artsy/eigen/blob/356b88d1ff035a9f0aa28f19e42255c7152a88f4/Artsy/View_Controllers/Artwork/ARArtworkViewController.m#L28)
before the view controller is released and _in addition_ it lead to me figuring out why the scroll view was still even
alive at that time, which was [a block retention-cycle](https://github.com/artsy/eigen/commit/8db7b1e75563ee2ee7b547223cb02e1e646e7bd8).
