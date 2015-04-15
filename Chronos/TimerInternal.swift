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
    static let stopped: Int32   = 2
    static let invalid: Int32   = 0
    static let valid:   Int32   = 1
}


// MARK:- Type Aliases

/**
The closure to execute if the timer fails to create a dispatch source.
*/
public typealias FailureClosure     = ((Void) -> Void)?

/**
The closure to execute when the timer fires.

:param: timer   The timer that fired.
:param: count   The current invocation count. The first count is 0.
*/
public typealias ExecutionClosure   = ((RepeatingTimer, Int) -> Void)