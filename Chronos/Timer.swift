//
//  Timer.swift
//  Chronos
//
//  Copyright (c) 2015 Andrew Chun, Comyar Zaheri. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

import Foundation

// MARK:- Type Definitions

/**
    The closure to execute if the timer fails to create a dispatch source.
*/
public typealias FailureClosure     = ((Void) -> Void)?

/**
    The closure to execute when the timer fires.

    :param: timer   The timer that fired.
    :param: count   The current invocation count. The first count is 0.
*/
public typealias ExecutionClosure   = ((Timer, Int) -> Void)

// MARK:- Timer Protocol

/**
    Types adopting the 'Timer' protocol can be used to implement methods to control a timer
*/
public protocol Timer {
    /**
        Starts the timer
    
        :param: now true, if timer starts immediately; false, otherwise.
    */
    func start(now: Bool)
    
    /**
        Pauses the timer.
    */
    func pause()
    
    /**
        Cancels and invalidates the timer.
    */
    func cancel()
}