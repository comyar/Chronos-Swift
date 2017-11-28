//
//  ChronosTests.swift
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
//


// Mark:- Imports

import Foundation


// Mark:- Constants and Functions

private let queuePrefix = "com.chronos.dispatchTimer"

// MARK:- DispatchTimer Implementation

/**
A DispatchTimer allows you to create a Grand Central Dispatch-based timer
object. A timer waits until a certain time interval has elapsed and then
fires, executing a given closure.

A timer has limited accuracy when determining the exact moment to fire; the
actual time at which a timer fires can potentially be a significant period
of time after the scheduled firing time. However, successive fires are
guarenteed to occur in order.
*/
@objc
@available (iOS, introduced: 8.0)
@available (OSX, introduced: 10.10)
open class DispatchTimer : NSObject, RepeatingTimer {
  
    fileprivate var valid       = State.invalid
    fileprivate var running     = State.paused
    fileprivate var timer:  DispatchSourceTimer
    fileprivate var leeway: UInt64 {
        return UInt64(0.05 * interval) * NSEC_PER_SEC;
    }
    private let timebaseNumer: Double
    private let timebaseDenom: Double
    
    // MARK: Properties
    
    /**
    The timer's execution queue.
    */
    open let queue: DispatchQueue!
    
    /**
    The timer's execution interval, in seconds.
    */
    open let interval: Double!
    
    /**
    The timer's execution closure.
    */
    open let closure: ExecutionClosure!
    
    /**
    The number of times the execution closure has been executed.
    */
    open fileprivate(set) var count = 0
    
    /**
    true, if the timer is valid; otherwise, false.
    
    A timer is considered valid if it has not been canceled.
    */
    open var isValid: Bool {
        return (valid == State.valid)
    }
    
    /**
    true, if the timer is currently running; otherwise, false.
    */
    open var isRunning: Bool {
        return (running == State.running)
    }
    
    // MARK: NSObject
    override fileprivate init() { fatalError("Cannot initialize with init(). Use convenience or designated initializer.") }
    deinit { cancel() }
    
    // MARK: Creating a Dispatch Timer
    
    /**
    Creates a DispatchTimer object.
    
    - parameter interval:        The execution interval, in seconds.
    - parameter closure:         The closure to execute at the given interval.
    
    - returns: A newly created DispatchTimer object.
    */
    convenience public init(interval: Double, closure: @escaping ExecutionClosure) {
        let name = "\(queuePrefix).\(UUID().uuidString)"
        let queue = DispatchQueue(label: name, attributes: [])
        self.init(interval: interval, closure: closure, queue: queue)
    }
    
    /**
    Creates a DispatchTimer object.
    
    - parameter interval:        The execution interval, in seconds.
    - parameter closure:         The closure to execute at the given interval.
    - parameter queue:           The queue that should execute the given closure.
    - parameter failureClosure:  The closure to execute if creation fails.
    
    - returns: A newly created DispatchTimer object.
    */
    public init(interval: Double, closure: @escaping ExecutionClosure, queue: DispatchQueue) {
      self.timer = DispatchSource.makeTimerSource(queue: queue)
      self.valid = State.valid
      self.queue      = queue
      self.interval   = interval
      self.closure    = closure
      
      //set timebase info
      var info = mach_timebase_info(numer: 0, denom: 0)
      mach_timebase_info(&info)
      self.timebaseNumer = Double(info.numer)
      self.timebaseDenom = Double(info.denom)
        
      super.init()
      
      weak var weakSelf: DispatchTimer? = self
      
      timer.setEventHandler {
        if let strongSelf = weakSelf {
          strongSelf.closure(strongSelf, strongSelf.count)
          strongSelf.count += 1
        }
      }
    }
  
    // MARK: Using a Dispatch Timer
  
    /**
    Starts the timer.
    
    - parameter now:     true, if the timer should fire immediately.
    */
    open func start(_ now: Bool) {
        validate()
        if OSAtomicCompareAndSwap32Barrier(State.paused, State.running, &running) {
            timer.schedule(deadline: startTime(interval, now: now),
                           repeating:.nanoseconds(Int((interval * self.timebaseNumer) / self.timebaseDenom)))
          timer.resume()
        }
    }
    
    /**
    Pauses the timer and does not reset the count.
    */
    open func pause() {
        validate()
        if OSAtomicCompareAndSwap32Barrier(State.running, State.paused, &running) {
            timer.suspend()
        }
    }
    
    /**
    Permanently cancels the timer.
    
    Attempting to start or pause an invalid timer is considered an error and will throw an exception.
    */
    open func cancel() {
        if OSAtomicCompareAndSwap32Barrier(State.valid, State.invalid, &valid) {
          if running == State.paused {
            timer.resume()
          }
          
          running = State.paused
          timer.cancel()
        }
    }
  
    fileprivate func validate() {
        if valid != State.valid {
            NSException(name: NSExceptionName.internalInconsistencyException,
                reason: "Attempting to use invalid DispatchTimer",
                userInfo: nil).raise()
        }
    }
}
