//
//  OneShotDispatchTimer.swift
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

// Mark:- Constants and Functions

private let queuePrefix = "com.chronos.oneShotDispatchTimer"

// MARK:- OneShotDispatchTimer Implementation

/**
 A OneShotDispatchTimer allows you to create a Grand Central Dispatch-based timer
 object. A timer waits until a certain time interval has elapsed and then
 fires, executing a given closure.

 A timer has limited accuracy when determining the exact moment to fire; the
 actual time at which a timer fires can potentially be a significant period
 of time after the scheduled firing time.
 */
@objc
@available (iOS, introduced=8.0)
@available (OSX, introduced=10.10)
public class OneShotDispatchTimer : NSObject, OneShotTimer {
    private var valid       = State.invalid
    private var running     = State.paused
    private var timer:  dispatch_source_t?
    private var leeway: UInt64 {
        return UInt64(0.05 * delay) * NSEC_PER_SEC;
    }

    // MARK: Properties

    /**
     The timer's execution queue.
     */
    public let queue: dispatch_queue_t!

    /**
     The timer's execution delay, in seconds.
     */
    public let delay: Double!

    /**
     The timer's execution closure.
     */
    public let closure: OneShotExecutionClosure!

    /**
     true, if the timer is valid; otherwise, false.

     A timer is considered valid if it has not been canceled.
     */
    public var isValid: Bool {
        return (valid == State.valid)
    }

    /**
     true, if the timer is currently running; otherwise, false.
     */
    public var isRunning: Bool {
        return (running == State.running)
    }

    // MARK: NSObject
    override private init() { fatalError("Cannot initialize with init(). Use convenience or designated initializer.") }
    deinit { cancel() }

    // MARK: Creating a OneShotDispatchTimer

    /**
     Creates a OneShotDispatchTimer object.

     - parameter delay:           The execution delay, in seconds.
     - parameter closure:         The closure to execute after the given delay.

     - returns: A newly created OneShotDispatchTimer object.
     */
    convenience public init(delay: Double, closure: OneShotExecutionClosure) {
        let name = "\(queuePrefix).\(NSUUID().UUIDString)"
        let queue = dispatch_queue_create((name as NSString).UTF8String, DISPATCH_QUEUE_SERIAL)
        self.init(delay: delay, closure: closure, queue: queue)
    }

    /**
     Creates a OneShotDispatchTimer object.

     - parameter delay:           The execution delay, in seconds.
     - parameter closure:         The closure to execute after the given delay.
     - parameter queue:           The queue that should execute the given closure.

     - returns: A newly created OneShotDispatchTimer object.
     */
    convenience public init(delay: Double, closure: OneShotExecutionClosure, queue: dispatch_queue_t) {
        self.init(delay: delay, closure: closure, queue: queue, failureClosure: nil)
    }

    /**
     Creates a OneShotDispatchTimer object.

     - parameter delay:           The execution delay, in seconds.
     - parameter closure:         The closure to execute after the given delay.
     - parameter queue:           The queue that should execute the given closure.
     - parameter failureClosure:  The closure to execute if creation fails.

     - returns: A newly created OneShotDispatchTimer object.
     */
    public init(delay: Double, closure: OneShotExecutionClosure, queue: dispatch_queue_t, failureClosure: FailureClosure) {

        if let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue) {
            self.timer = timer
            self.valid = State.valid
        } else {
            if let failureClosure = failureClosure {
                failureClosure()
            } else {
                print("Failed to create dispatch source for timer.")
            }
        }

        self.queue      = queue
        self.delay      = delay
        self.closure    = closure

        super.init()

        weak var weakSelf: OneShotDispatchTimer? = self

        if let timer = timer {
            dispatch_source_set_event_handler(timer) {
                dispatch_source_cancel(timer); //Ensure timer only gets called once
                if let strongSelf = weakSelf {
                    strongSelf.closure(strongSelf)                    
                }
            }
        }
    }

    // MARK: Using a OneShotDispatch Timer

    /**
     Starts the timer.

     - parameter now:     true, if the timer should fire immediately.
     */
    public func start(now: Bool) {
        validate()
        if let timer = timer where OSAtomicCompareAndSwap32Barrier(State.paused, State.running, &running) {
            dispatch_source_set_timer(timer, startTime(delay, now: now), UInt64(delay * Double(NSEC_PER_SEC)), leeway)
            dispatch_resume(timer)
        }
    }

    /**
     Pauses the timer and does not reset the count.
     */
    public func pause() {
        validate()
        if let timer = timer where OSAtomicCompareAndSwap32Barrier(State.running, State.paused, &running) {
            dispatch_suspend(timer)
        }
    }

    /**
     Permanently cancels the timer.

     Attempting to start or pause an invalid timer is considered an error and will throw an exception.
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
                        reason: "Attempting to use invalid OneShotDispatchTimer",
                        userInfo: nil).raise()
        }
    }
}
