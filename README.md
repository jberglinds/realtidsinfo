# realtidsinfo
I have a bus stop right outside my door. I also happen to have colored
HomeKit lights.  When catching the bus, I hate to get out there too early,
just to find the bus being late.  
This is a native iPad app for displaying real time departure information for
SL bus stops - using HomeKit lights.

Written in Objective-C.

|![Realtidsinfo GIF](https://github.com/jberglinds/realtidsinfo/blob/master/Screenshots/Realtidsinfo.gif?raw=true)|![Lights GIF](https://github.com/jberglinds/realtidsinfo/blob/master/Screenshots/Lights.gif?raw=true)|
|---|---|
|![Adding Stops](https://github.com/jberglinds/realtidsinfo/blob/master/Screenshots/Add_Stop.png?raw=true)|![Configuring Lights](https://github.com/jberglinds/realtidsinfo/blob/master/Screenshots/Select_Lights.png?raw=true)|

## Getting Started
### Prerequisites
This project uses [Cocoapods](http://cocoapods.org/) for dependency management.
Dependencies are declared in the `Podfile`. 

```shell
# Installing Cocoapods for Xcode 8 + 9
$ sudo gem install cocoapods
```

### Installing
```shell
# Clone the repo
$ git clone https://github.com/jberglinds/realtidsinfo.git

$ cd realtidsinfo

# Install dependencies with Cocoapods
$ pod repo update
$ pod install

# Open the workspace in Xcode (Not .xcodeproj/ !)
$ open Realtidsinfo.xcworkspace/
```

#### Trafiklab
The app gets its data from the [Trafiklab](https://www.trafiklab.se) APIs.
In order for this to work, you need to set up your own Trafiklab account and
populate the `Realtidsinfo/API-keys.plist` file with your own API keys.
The app currently uses the following Trafiklab APIs:
* [SL Realtidsinformation 4](https://www.trafiklab.se/api/sl-realtidsinformation-4) (realtimedeparturesV4)
* [SL Platsuppslag](https://www.trafiklab.se/api/sl-platsuppslag) (typeahead)
* [SL Närliggande hållplatser](https://www.trafiklab.se/api/sl-narliggande-hallplatser) (nearbystops)

## Built With
* [AFNetworking](https://github.com/AFNetworking/AFNetworking) - HTTP Networking
* [Regexer](https://github.com/fortinmike/Regexer) - Obj-C regex simplifier
Written in Objective-C.
