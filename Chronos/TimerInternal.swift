//
//  TimerInternal.swift
//  Chronos
//
//  Created by Andrew Chun on 4/14/15.
//  Copyright (c) 2015 com.comyarzaheri. All rights reserved.
//


// MARK:- Imports

import Foundation


// MARK:- State struct

internal struct State {
    static let paused:  Int32   = 0
    static let running: Int32   = 1
    static let invalid: Int32   = 0
    static let valid:   Int32   = 1
}


// Mark:- Constants and Functions

internal func startTime(_ interval: Double, now: Bool) -> DispatchTime {
    return DispatchTime.now() + Double(now ? 0 : Int64(interval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
}


// MARK:- Type Aliases

/**
The closure to execute when the timer fires.

- parameter timer:   The timer that fired.
- parameter count:   The current invocation count. The first count is 0.
*/
public typealias ExecutionClosure   = ((RepeatingTimer, Int) -> Void)
