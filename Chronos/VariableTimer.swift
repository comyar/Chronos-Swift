//
//  VariableTimer.swift
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


// MARK:- Imports

import Foundation


// MARK:- Constants and Functions

private let queuePrefix = "com.chronos.variableTimer"


// MARK:- VariableTimer Implementation

/**
A VariableTimer allows you to create a Grand Central Dispatch-based timer object
that allows for variable time intervals between each firing. Each successive
time interval is obtained by executing the given interval closure.

A timer has limited accuracy when determining the exact moment to fire; the
actual time at which a timer fires can potentially be a significant period of
time after the scheduled firing time. However, successive fires are guarenteed
to occur in order.
*/
@objc
@available (iOS, introduced=8.0)
@available (OSX, introduced=10.10)
public class VariableTimer : NSObject, RepeatingTimer {
    private var valid                   = State.invalid
    private var running                 = State.paused
    private var isExecuting             = false
    private var shouldFireImmediately   = false
    private var timer: dispatch_source_t!
    
    // MARK: Type Aliases
    
    /**
    The closure to execute the next interval length.
    
    - parameter timer:   The timer that fired.
    - parameter count:   The next invocation count. The first count is 0.
    */
    public typealias IntervalClosure = ((timer: VariableTimer, count: Int) -> Double)
    
    // MARK: Properties
    
    /**
    The timer's execution queue.
    */
    public let queue: dispatch_queue_t!
    
    /**
    The timer's execution closure.
    */
    public let closure: ExecutionClosure!
    
    /**
    The timer's interval closure.
    */
    public let intervalProvider: IntervalClosure!
    
    /**
    The number of times the execution closure has been executed.
    */
    public private(set) var count: Int = 0
    
    /**
    true, if the timer is valid; otherwise, false.
    
    A timer is considered valid if it has not been canceled.
    */
    public var isValid: Bool {
        return valid == State.valid
    }
    
    /**
    true, if the timer is currently running; otherwise, false.
    */
    public var isRunning: Bool {
        return running == State.running
    }
    
    // MARK: NSObject
    
    override private init() { fatalError("Cannot create timer with init.") }
    deinit { cancel() }
    
    // MARK: Creating a Variable Timer
    
    /**
    Creates a VariableTimer object.
    
    - parameter executionClosure:    The closure to execute at a variable interval.
    - parameter intervalClosure:     The closure to execute to obtain a variable
    interval.
    
    - returns: A newly created VariableTimer object.
    */
    convenience public init(closure: ExecutionClosure, intervalProvider: IntervalClosure) {
        let name    = "\(queuePrefix).\(NSUUID().UUIDString)"
        let queue   = dispatch_queue_create((name as NSString).UTF8String, DISPATCH_QUEUE_SERIAL)
        self.init(closure: closure, intervalProvider: intervalProvider, queue: queue)
    }
    
    /**
    Creates a VariableTimer object.
    
    - parameter executionClosure:    The closure to execute at a variable interval.
    - parameter intervalClosure:     The closure that provides time intervals.
    - parameter queue:               The queue that should execute the given closure.
    
    - returns: A newly created VariableTimer object.
    */
    convenience public init(closure: ExecutionClosure, intervalProvider: IntervalClosure, queue: dispatch_queue_t) {
        self.init(closure: closure, intervalProvider: intervalProvider, queue: queue, failureClosure: nil)
    }
    
    /**
    Creates a VariableTimer object.
    
    - parameter executionClosure:    The closure to execute at a variable interval.
    - parameter intervalClosure:     The closure that provides time intervals.
    - parameter queue:               The queue that should execute the given closure.
    - parameter failureClosure:      The closure to execute if creation fails.
    
    - returns: A newly created VariableTimer object.
    */
    public init(closure: ExecutionClosure, intervalProvider: IntervalClosure, queue: dispatch_queue_t, failureClosure: FailureClosure) {
        if let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue) {
            self.timer = timer
            self.valid = State.valid
        } else if let failureClosure = failureClosure {
            failureClosure()
        } else {
            print("Failed to create dispatch source for timer.")
        }
        
        self.queue              = queue
        self.closure            = closure
        self.intervalProvider   = intervalProvider
        
        super.init()
        
        weak var weakSelf: VariableTimer? = self
        
        dispatch_source_set_event_handler(timer, {
            if let strongSelf = weakSelf {
                strongSelf.shouldFireImmediately = false
                strongSelf.isExecuting = true
                strongSelf.closure(strongSelf, strongSelf.count)
                ++strongSelf.count
                if !strongSelf.shouldFireImmediately {
                    strongSelf.schedule(strongSelf.shouldFireImmediately)
                }
                strongSelf.isExecuting = false
            }
        })
    }
    
    /**
    Schedules the next execution closure
    
    - parameter now: true, if the execution closure should be scheduled immediately;
    false, otherwise
    */
    func schedule(now: Bool) {
        if isValid {
            let interval = intervalProvider(timer: self, count: count)
            dispatch_source_set_timer(timer, startTime(interval, now: now), UInt64(interval * Double(NSEC_PER_SEC)), 0)
        }
    }
    
    // MARK: Using a Variable Timer
    
    /**
    Starts the timer.
    
    - parameter now:     true, if the timer should fire immediately.
    */
    public func start(now: Bool) {
        validate()
        if OSAtomicCompareAndSwap32Barrier(State.paused, State.running, &running) {
            if now {
                self.shouldFireImmediately = true
                dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, DISPATCH_TIME_FOREVER, 0)
            } else if !isExecuting {
                schedule(now)
            }
            dispatch_resume(timer)
        }
    }
    
    /**
    Pauses the timer and does not reset the count.
    */
    public func pause() {
        validate()
        if OSAtomicCompareAndSwap32Barrier(State.running, State.paused, &running) {
            dispatch_suspend(timer)
        }
    }
    
    /**
    Permanently cancels the timer.
    
    Attempting to start or pause an invalid timer is considered an error and
    will throw an exception.
    */
    public func cancel() {
        if OSAtomicCompareAndSwap32Barrier(State.valid, State.invalid, &valid) {
            if let timer = timer {
                if running == State.paused {
                    dispatch_resume(timer)
                }
                
                running = State.paused
                dispatch_source_cancel(timer)
            }
        }
    }
    
    private func validate() {
        if valid != State.valid {
            NSException(name: NSInternalInconsistencyException,
                reason: "Attempting to use invalid DispatchTimer",
                userInfo: nil).raise()
        }
    }
}
