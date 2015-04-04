/*
The MIT License (MIT)

Copyright (c) 2015 Andrew Chun

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Foundation

//MARK Static Global Variables
struct Static {
    internal static let STOPPED: Int32                              = 0
    internal static let PAUSED:  Int32                              = 1
    internal static let RUNNING: Int32                              = 2
    internal static let DispatchTimerExecutionQueueNamePrefix       = "com.chronos.execution"
}

struct Semaphore<T> {
    internal var _semaphore:dispatch_semaphore_t
    internal var _v: T {
        willSet {
            dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        }
        
        didSet {
            dispatch_semaphore_signal(_semaphore)
        }
    }
    
    init(value: T, semaValue: Int) {
        _v = value
        _semaphore = dispatch_semaphore_create(semaValue)
    }
}

class DispatchTimer : NSObject {
    //MARK: Type Definitions
    typealias DispatchTimerInitFailureClosure   = ((Void) -> Void)?
    typealias DispatchTimerCancellationClosure  = ((DispatchTimer) -> Void)
    typealias DispatchTimerExecutionClosure     = ((DispatchTimer, Int) -> Void)
    
    //MARK: Internal Instance Variables
    private(set) var _interval:         NSTimeInterval?
    private(set) var _executionQueue:   dispatch_queue_t?
    private(set) var _executionClosure: DispatchTimerExecutionClosure?
                 var _isValid:          Bool {
                     get {
                         return _cancelled == false ? true : false
                     }
                 }
                 var _isRunning:        Bool {
                     get {
                         return _running._v == Static.RUNNING ? true : false
                     }
                 }
    
    //MARK: Private Instance Variables
    private         var _running:       Semaphore<Int32> = Semaphore<Int32>(value: Static.PAUSED, semaValue: 1)
    private         var _invocations:   Semaphore<Int64> = Semaphore<Int64>(value: 0, semaValue: 1)
    private         var _cancelled:     Bool?
    private(set)    var _timer:         dispatch_source_t?
    
    //MARK: Initializers for DispatchTimers
    override init() {
        fatalError("Must use either designated initializer or convenience initializer.")
    }
    
    init(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionClosure, executionQueue: dispatch_queue_t, failureClosure: DispatchTimerInitFailureClosure) {
        super.init()
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, executionQueue)
        
        if let timer = _timer {
            _interval           = interval
            _executionQueue     = executionQueue
            _executionClosure   = executionClosure
            _cancelled          = false
            
            dispatch_source_set_event_handler(_timer) {
                self._executionClosure?(self, Int(self._invocations._v))
                self._invocations._v++
            }
        } else {
            if let failureClosure = failureClosure {
                failureClosure()
            } else {
                println("Failed to create dispatch source for timer.")
            }
            
            _cancelled = true
        }
    }
    
    convenience init(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionClosure) {
        let UUID:               NSUUID          = NSUUID()
        let stringUUID:         String          = String(UUID.UUIDString)
        let executionQueueName: String          = "\(Static.DispatchTimerExecutionQueueNamePrefix).\(stringUUID)"
        let executionQueue: dispatch_queue_t    = dispatch_queue_create((executionQueueName as NSString).UTF8String, DISPATCH_QUEUE_SERIAL)
        
        self.init(interval: interval, executionClosure: executionClosure, executionQueue: executionQueue)
    }
    
    convenience init(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionClosure, executionQueue: dispatch_queue_t) {
        self.init(interval: interval, executionClosure: executionClosure, executionQueue: executionQueue, nil)
    }
    
    deinit {
        cancel()
    }
    
    private class func startTime(interval: NSTimeInterval, now: Bool) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, now ? 0 : Int64(interval) * Int64(NSEC_PER_SEC))
    }
    
    private class func leeway(interval: NSTimeInterval) -> UInt64 {
        return UInt64(0.05 * interval) * NSEC_PER_SEC
    }
    
    private func isValid() {
        if let cancelled = _cancelled {
            if cancelled {
                NSException(name: "Cancellation Exception:", reason: "Cannot restart DispatchTimer that has been cancelled.", userInfo: nil).raise()
            }
        }
    }
    
    func start(now: Bool) {
        isValid()
        
        if OSAtomicCompareAndSwap32(Static.PAUSED, Static.RUNNING, &_running._v) {
            if let interval = _interval {
                dispatch_source_set_timer(_timer, DispatchTimer.startTime(interval, now: now), UInt64(interval) * NSEC_PER_SEC, DispatchTimer.leeway(interval))
                dispatch_resume(_timer)
            }
        }
    }
    
    func pause() {
        isValid()
        
        if OSAtomicCompareAndSwap32(Static.RUNNING, Static.PAUSED, &_running._v) {
            if let timer = _timer {
                dispatch_suspend(_timer)
            }
        }
    }
    
    func cancel() {
        if OSAtomicCompareAndSwap32(Static.RUNNING, Static.STOPPED, &_running._v) || OSAtomicCompareAndSwap32(Static.PAUSED, Static.STOPPED, &_running._v) {
            if let timer = _timer {
                dispatch_source_cancel(_timer)
            }
            _invocations._v = 0
            _cancelled      = true
        }
    }
}