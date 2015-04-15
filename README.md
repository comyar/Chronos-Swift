![](https://raw.githubusercontent.com/Olympus-Library/Resources/master/chronos-header.png)

# Overview
[![Build Status](https://travis-ci.org/Olympus-Library/Chronos-Swift.svg)](https://travis-ci.org/Olympus-Library/Chronos)
[![Version](http://img.shields.io/cocoapods/v/Chronos-Swift.svg)](http://cocoapods.org/?q=Chronos)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Olympus-Library/Chronos-Swift)
[![Platform](http://img.shields.io/cocoapods/p/Chronos-Swift.svg)]()
[![License](http://img.shields.io/cocoapods/l/Chronos-Swift.svg)](https://github.com/Olympus-Library/Chronos/blob/master/LICENSE)

**Notice:** The Travis-CI build is currently failing due to compatibility issues with Swift 1.2/Xcode 6.3.
<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Related Issue: [Travis-CI#3216](https://github.com/travis-ci/travis-ci/issues/3216)

Chronos is a collection of useful Grand Central Dispatch utilities. If you have any specific requests or ideas for new utilities, don't hesitate to create a new issue.

Chronos is part of a larger library for iOS and OS X called [Olympus](https://github.com/Olympus-Library), which is currently under active development.

## Utilities

* **DispatchTimer** - A repeating timer that fires according to a static interval, e.g. "Fire every 5 seconds".
* **VariableTimer** - A repeating timer that allows you to vary the interval between firings, e.g. "Fire according to the function `interval = 2 * count`. 

# Usage 

### Quick Start

Chronos is available through Cocoa Pods. Add the following to your Podfile:

```ruby
pod 'Chronos-Swift'
```

Chronos is available through Carthage. Add the following to your Cartfile:

```ruby
github "https://github.com/Olympus-Library/Chronos-Swift" "master"
```

###### Note: 

If you see the following error message:

> [!] Unable to find a specification for `Chronos-Swift`

Due to a bug in libgit2, your local copy of the Cocoapods Specs repository may need to be removed and re-cloned. More information on why and how to do this is available on the [Cocoapods blog](http://blog.cocoapods.org/Repairing-Our-Broken-Specs-Repository/).

### Using a Dispatch Timer

```swift
import Chronos

var timer = DispatchTimer(interval: 0.25, closure: {
            (timer: RepeatingTimer, count: Int) in
                println("Execute repeating task here")
            })

/** Starting the timer */
timer.start(true) // Fires timer immediately

/** Pausing the timer */
timer.pause()

/** Permanently canceling the timer */
timer.cancel()

```

### Using a Variable Timer

```swift
import Chronos

var variableTimer: VariableTimer = VariableTimer(closure: { 
            (timer: RepeatingTimer, count: Int) -> Void in
                println("Execute repeating task here")
        }) {(timer: VariableTimer, count: Int) -> Double in
                return Double(2 * count) // Return interval according to function
        }

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
