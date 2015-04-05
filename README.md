![](https://raw.githubusercontent.com/Olympus-Library/Resources/master/chronos-header.png)

# Overview
[![Build Status](https://travis-ci.org/Olympus-Library/Chronos-Swift.svg)](https://travis-ci.org/Olympus-Library/Chronos)
[![Version](http://img.shields.io/cocoapods/v/Chronos-Swift.svg)](http://cocoapods.org/?q=Chronos)
[![Platform](http://img.shields.io/cocoapods/p/Chronos-Swift.svg)]()
[![License](http://img.shields.io/cocoapods/l/Chronos-Swift.svg)](https://github.com/Olympus-Library/Chronos/blob/master/LICENSE)

Chronos is intended to be a collection of useful Grand Central Dispatch utilities. Currently Chronos only includes a timer utility, but the whole library is under active development. If you have any specific requests or ideas for new utilities, don't hesitate to create a new issue.

Chronos is part of a larger library for iOS and OS X called [Olympus](https://github.com/Olympus-Library), which is currently under active development.

# Usage 

### Quick Start

Chronos is available through Cocoa Pods. Add the following to your Podfile:

```ruby
pod 'Chronos-Swift'
```

###### Note: 

If you see the following error message:

> [!] Unable to find a specification for `Chronos-Swift`

Due to a bug in libgit2, your local copy of the Cocoapods Specs repository may need to be removed and re-cloned. More information on why and how to do this is available on the [Cocoapods blog](http://blog.cocoapods.org/Repairing-Our-Broken-Specs-Repository/).

### Using a Dispatch Timer

```swift
import Chronos

var timer = DispatchTimer(interval: 0.25, closure: {
            (timer: DispatchTimer, count: Int) in
                println("Execute repeating task here")
            })

/** Starting the timer */
timer.start(true) // Fires timer immediately

/** Pausing the timer */
timer.pause()

/** Permanently canceling the timer */
timer.cancel()

```

# Requirements

* iOS 8.0 or higher
* OS X 10.10 or higher

# License 

Chronos is available under the [MIT License](LICENSE).

# Contributors

* [@comyarzaheri](https://github.com/comyarzaheri)
* [@schun93](https://github.com/schun93)
