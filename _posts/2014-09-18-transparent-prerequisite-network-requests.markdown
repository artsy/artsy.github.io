---
layout: post
title: "Transparent Prerequisite Network Requests with Swift and ReactiveCocoa"
date: 2014-09-22 11:26
comments: true
categories: [iOS, networking, Open-Source, mobile]
author: ash
---

Artsy's [API](http://developers.artsy.net) requires something called an [XApp
token](https://developers.artsy.net/docs/authentication) in order to perform
requests. The token comes back with an expiry date, after which the token will
no longer work. A new token will have to be fetched.

```json
{
	"xapp_token": "SOME_TOKEN",
	"expires_in":"2014-09-19T12:22:21.570Z"
}
```

In our previous iOS apps, tragically written in Objective-C, we have a lot of
code that looks like the following. `getXappTokenWithCompletion:` checks to
make sure that there is a valid token. If there is, it invokes the completion
block immediately. Otherwise, it fetches a token, sets it in a static variable,
and then invokes the completion block.

```objc
[ArtsyAPI getXappTokenWithCompletion:^(NSString *xappToken, NSDate *expirationDate) {
    [ArtsyAPI getSomething:^(NSDictionary *results) {
       // do something
    } failure:^(NSError *error) {
        // handle herror
    }];
}];
```

That's kind of ugly. A better approach might be to embed the token-requesting
logic within the `getSomething:` method. But that kind of sucks, since we'd have
to reproduce that logic for *every* network-accessing method. If we have ten
methods, that's ten times we need to duplicate that logic.

With our [new app](https://github.com/artsy/eidolon) (written in Swift), we're
using a network abstraction layer we've created called [Moya](https://github.com/AshFurrow/Moya).
Moya sits on top of [Alamofire](https://github.com/Alamofire/Alamofire) and
provides an abstraction for API endpoints. Instead of having ten different
network-accessing methods, there is only *one* method to which you pass one of
the ten different possible `enum` values. This means you have compile-time
safety in your networking code, but that's not really what we're here to talk
about.

<!-- more -->

Moya has this cool last-minute closure that it invokes to sign requests, so we
can sign these requests like this.

```
var endpointsClosure = { (target: ArtsyAPI, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<ArtsyAPI> in
        let endpoint: Endpoint<ArtsyAPI> = Endpoint<ArtsyAPI>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters)

        // Sign all non-XApp token requests
        switch target {
        case .XApp:
            return endpoint
        default:
            return endpoint.endpointByAddingHTTPHeaderFields(["X-Xapp-Token": /* global XApp token */])
        }
    }
```

So that's kind of cool.

Since there is only *one* method for accessing the API, we can easily inject
the token-checking method there. Something like

```
public func XAppRequest(token: ArtsyAPI, completion: MoyaCompletion) {
    if /* token is valid */ {
        moyaProvider.sharedProvider.request(token, completion: completion)
    } else {
	    moyaProvider.request(ArtsyAPI.XApp, completion: { (data, statusCode, error) -> () in
	        /* store token somewhere */
	        moyaProvider.sharedProvider.request(token, completion: completion)
	    })
	}
}
```

That's *better*, but it's still kind of ugly. We've got duplicated code in
there, and we're just kind of abstracting away the callback mess; it still
exists, we just don't see if as often.

OK, so what alternative is there? Well, Moya supports a [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
extension that uses *signals* instead of callback closures. Super-cool. So we
can rewrite our `XAppRequest` function to be the following.

```
private func XAppTokenRequest() -> RACSignal {
    let newTokenSignal = moyaProvider.request(ArtsyAPI.XApp).filterSuccessfulStatusCodes().mapJSON().doNext({ (response) -> Void in
        /* store new token globally */
    }).logError().ignoreValues()

    let validTokenSignal = RACSignal.`return`(/* does the token exist and is valid? */)
    return RACSignal.`if`(validTokenSignal, then: RACSignal.empty(), `else`: newTokenSignal)
}

public func XAppRequest(token: ArtsyAPI) -> RACSignal {
    return XAppTokenRequest().then({ () -> RACSignal! in
        return moyaProvider.request(token, method: method, parameters: parameters)
    })
}
```

Neato. So we have abstracted the "check if there is a valid token and get one if
there isn't" into its own private method called `XAppTokenRequest`. If the token
exists and is valid, then the function returns `RACSignal.empty()`, a signal
which completes immediately. Otherwise, we perform a fetch, which completes
when the XApp token request is finished.

Then we just need to use `then` on `RACSignal` to create a new signal that is
generated once the `XAppTokenRequest` signal completes. Since the `then` closure
is only invoked once the `XAppTokenRequest` signal completes, the newly created
request signal will be generated after the token is set, which is ideal.

All the code above is kind of simplified. That's OK, since it's just a proof of
concept. If you want the full code, it's all available [on GitHub](https://github.com/artsy/eidolon/blob/1804044dfa8b22d9f765a621a5dbde357440146c/Kiosk/App/ArtsyAPI.swift#L87-L112)
and the conversation surrounding this change is in a [merged pull request](https://github.com/artsy/eidolon/pull/29).

If you have run into this problem and have a different solution, we'd love to
hear from you.
