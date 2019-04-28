# InterprocessCommunication

This is a small document that walks through the general approach to setting up XPC services as implemented in the [InterprocessCommunication repository](https://github.com/Grayson/InterprocessCommunication).  It's not a step-by-step tutorial, but it should demonstrate the basic steps and highlight some of the more important caveats and potential problems.  Not every commit is mentioned, but I'm hoping that the commits are small enough to be easily understandable if you really wanted to see each and every step.

You should also note that this code is not of production quality.  The demonstration is merely a simple example of how to send messages between multiple applications using XPC.  Error handling and proper server/client architecture are not implemented in favor of simplification.

## Setup

First things first, we set up [two applications in Xcode](https://github.com/Grayson/InterprocessCommunication/commit/23a5082a7dd0845714220d564005dce6dd392c08).  This isn't terribly interesting.  One will be the main application and the second will wind up being a service.  The service is the central application that sends messages back and forth between clients.  The service application (called "Bridge" here) should be a [background application](https://github.com/Grayson/InterprocessCommunication/commit/61cca305d3af8e403c7a06acbae7ee640a2f31ea).  The Bridge app will be built along with the main app and [installed into `<app wrapper>/Contents/Library/LoginItems/` ](https://github.com/Grayson/InterprocessCommunication/commit/82c8cb7a718d5a2eee26c676692eae06b56089cd).

By default, Xcode has added a bit too much to our Bridge application.  It will be built as an app bundle, but it should behave more like a command line application.  To that end, we'll [remove the `@NSApplicationMain` tag and add a main.swift file](https://github.com/Grayson/InterprocessCommunication/commit/12650fb490c2d082b4a63df1f97b571e1195f846).

## Creating a simple "Ping" service

Just to make sure everything is up and running, we'll create a Ping service.  We'll [define a protocol](https://github.com/Grayson/InterprocessCommunication/commit/4e8c0e9493f0a901d6d827e0101986507c14bc89) to define this service.  It's very important that this protocol is annotated with `@objc`.  In several places, the difference between ObjC and Swift will cause problems unless we make our Swift code conform appropriately.

The service is simple.  When it receives a ping, [it just responds](https://github.com/Grayson/InterprocessCommunication/commit/a08d7c9905196bc5cc27b9827cc3adab7ff7126c#diff-01e4c6bd4b2394b355b3f67e03642028R12) with the pong.  We then extend our Bridge's main.swift to [start an NSXPCListener and respond to connections](https://github.com/Grayson/InterprocessCommunication/commit/d262d61d234041ff13f51ccb4fb5331e77037917).  For simplicity, the `XPCDelegate` inherits from `NSObject`.  This effectively makes it behave as an ObjC object and performs message passing.  It's worth mentioning that registering the listener causes the thread to stop executing.  The Bridge now listens for connections on a background thread.

## Connecting to the "Ping" service

The main application now has two tasks.  It should [launch the Bridge application and make a connection](https://github.com/Grayson/InterprocessCommunication/commit/a2b5265f77f625058226968822bdd96f7779b7bc).  These tasks are relatively simple.  Now, when the main application runs, it will also launch the Bridge app.  The Bridge app will remain running when the main app stops.  When the main app runs, it "pings" the Bridge.  The Bridge then responds and the callback in the main app is executed.

## Making things slightly more complicated

A basic ping service is a nice demo and proof that things are working.  However, we may want to actually send more complicated data over the wire.  We'll start by defining some [basic protocols for client and server](https://github.com/Grayson/InterprocessCommunication/commit/def379c975170bfb1cf6a515a2a3edd3420c9b40).  Then, we'll implement a [basic server](https://github.com/Grayson/InterprocessCommunication/commit/acc1c441f9dc28c3526d5571143a8ea3dc23063a).  Note that the server receives `NSXPCListenerEndpoint`.  This is kept very basic for implementation details.  Alternatively, we could define a "client" object that implemented `NSSecureCoding` and had a reference to the endpoint, but `NSXPCListenerEndpoint` implements `NSSecureCoding` and is the smallest basic building block for what we need.  We create a connection and store them for later.

We also need [an implementation for the Client](https://github.com/Grayson/InterprocessCommunication/commit/03b9a4d58517570d90c7c215f842c077841b977b) and we need to [extend the main app](https://github.com/Grayson/InterprocessCommunication/commit/d0bfff31dc9dce62733250a0720bd7455c23194e).  We'll create an anonymous listener and send its endpoint to the Server.

For demonstration purposes, we'll also [create a third app](https://github.com/Grayson/InterprocessCommunication/commit/67693bbb3f68bd87a3bfb0f58927d2238e7ea592).  This third app shares much of its code with the main application.  It was created just to have a differentiated app instance that could demonstrate two (or more) applications speaking to each other through the Bridge.

Now, we can [make a few changes](https://github.com/Grayson/InterprocessCommunication/compare/d0bfff31dc9dce62733250a0720bd7455c23194e...9109598c3fbdb936a7af158e30583a722ae016b9) such as creating a UI and displaying the messages received from the Server.  Also, we'll just create [one Server instance](https://github.com/Grayson/InterprocessCommunication/commit/3876136e1c30f69cc448cff3cf5fc58868a73594) rather than creating a unique one for each connection.  They'd never see each other otherwise.  With these changes, we can launch the main app and the demo app.  Any message sent from one should appear in the text views of both!

## Implementing Secure Coding

While it's nice to be able to send across basic information (strings, numbers, data, and collection classes like dictionaries and arrays are available, so you may not need much more), you may want to be able to send arbitrary objects over the wire.  To do that, you'll need to implement `NSSecureCoding`.  There are a few caveats.  We'll start with [this example](https://github.com/Grayson/InterprocessCommunication/commit/f34cf7224e168265624bbe2f460f407158d7187f):

First, you need to make sure that your object can be unambiguously found by the ObjC runtime.  If you have a file that's compiled into multiple projects, they'll be implicitly namespaced.  For this reason, you'll need to stabilize the name.  One tactic would be to put the class into a separate framework and link all projects to it or, more simply, to use the `@objc(<name>)` property.

Second, your object will need to inherit from `NSObject` and implement `NSSecureCoding`.  This involves implementing `func encode(with aCoder: NSCoder)` and `init?(coder aDecoder: NSCoder)` as well as `static var supportsSecureCoding: Bool`.  You should know that `NSSecureCoding` is a bit stricter than `NSCoding` (which is expected).  In the decoding, you'll need to specify the expected type of each object.  You'll get exceptions from the decoder if you don't.

Finally, you'll need to tell the XPC interface what to expect.  You'll need to update both the [server](https://github.com/Grayson/InterprocessCommunication/commit/72067c4821e14961c19774c0ad89b25d6b741846#diff-e82d83dda9eebf856ae78ae4e44b7609R17) and the [client](https://github.com/Grayson/InterprocessCommunication/commit/426ad683c2182082c26366761ea0ed3acdcde6f0#diff-82c3bb69f7c35a1ee3ec17901b35ec20R29).  This effectively tells the XPC plumbing what to expect.  If it receives something unexpected, you'll have thrown exceptions.

## And update for macOS 10.13

macOS 10.13 broke the InterprocessCommunication app.  The XPC bridge was failing with an `EXC_BAD_INSTRUCTION` exception (which was, not-helpfully being hidden due to it's status as a background/hidden app).  The solution appears to be to [avoid the singleton `NSXPCListener`](https://github.com/Grayson/InterprocessCommunication/commit/65dd045c862139f8fc2c16c160bfde6778d33a93).  That solved the crash, but the Bridge would stop immediately.  The [run loop needed to be kicked off](https://github.com/Grayson/InterprocessCommunication/commit/9c828a3e27b3f586cb3b3c9464f47bb55ee2ecd7).  This restores functionality to the Communicator.  The code was also updated to Swift 4.2 and a *more* recent version of Xcode, but it isn't quite up to date.  If anyone runs into problems with a newer version of Swift or Xcode, please let me know.
