//
//  DispatchTimer.swift
//  Chronos
//
//  Created by Andrew Chun on 4/2/15.
//  Copyright (c) 2015 com.zero223. All rights reserved.
//

import Foundation

//MARK Static Global Variables
struct Static {
    internal static let STOPPED: Int32                              = 0
    internal static let RUNNING: Int32                              = 1
    internal static let DispatchTimerExecutionQueueNamePrefix       = "com.chronos.execution"
}

struct Semaphore<T> {
    internal var _v: T {
        willSet {
            dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        }
        
        didSet {
            dispatch_semaphore_signal(_semaphore)
        }
    }
    internal var _semaphore:dispatch_semaphore_t
    
    init(value: T, semaValue: Int) {
        _v = value
        _semaphore = dispatch_semaphore_create(semaValue)
    }
}

class DispatchTimer : NSObject {
    //Swift does not allow weak closure variables
    //MARK: Type Definitions
    typealias DispatchTimerInitFailureClosure   = ((Void) -> Void)?
    typealias DispatchTimerCancellationClosure  = ((DispatchTimer?) -> Void)
    typealias DispatchTimerExecutionClosure     = ((DispatchTimer?, Int) -> Void)
    
    //MARK: Internal Instance Variables
    private(set) var _interval:         NSTimeInterval?
    private(set) var _executionQueue:   dispatch_queue_t?
    private(set) var _executionClosure: DispatchTimerExecutionClosure?
    
    //MARK: Private Instance Variables
    private         var _running:       Semaphore<Int32> = Semaphore<Int32>(value: 0, semaValue: 1)
    private         var _invocations:   Semaphore<Int64> = Semaphore<Int64>(value: 0, semaValue: 1)
    private(set)    var _timer:         dispatch_source_t?
    
    //MARK: Initializers for DispatchTimers
    override init() {
        fatalError("Must use either designated initializer or convenience initializer.")
    }
    
    init(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionClosure, executionQueue: dispatch_queue_t, failureClosure: DispatchTimerInitFailureClosure) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, executionQueue)
        
        if let timer = _timer {
            _interval           = interval
            _executionQueue     = executionQueue
            _executionClosure   = executionClosure //Need to implement NSCopying in order to copy
        } else {
            if let failureClosure = failureClosure {
                failureClosure()
            } else {
                println("Failed to create dispatch source for timer.")
            }
            
            NSException(name: "Dispatch Source Creation Failed:", reason: "Creation of a dispatch_source_t object failed with type dispatch_source_type_timer.", userInfo: nil).raise()
        }
        
        super.init()
    }
    
    convenience init?(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionClosure) {
        let UUID: NSUUID = NSUUID()
        let stringUUID: String = String(UUID.UUIDString)
        
        let executionQueueName: String          = "\(Static.DispatchTimerExecutionQueueNamePrefix).\(stringUUID)"
        let executionQueue: dispatch_queue_t    = dispatch_queue_create((executionQueueName as NSString).UTF8String, DISPATCH_QUEUE_SERIAL)
        
        self.init(interval: interval, executionClosure: executionClosure, executionQueue: executionQueue)
    }
    
    convenience init?(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionClosure, executionQueue: dispatch_queue_t) {
        self.init(interval: interval, executionClosure: executionClosure, executionQueue: executionQueue, nil)
    }
    
    deinit {
        "Deinitialized"
    }
    
    private class func startTime(interval: NSTimeInterval, now: Bool) -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, now ? 0 : Int64(interval) * Int64(NSEC_PER_SEC))
    }
    
    private class func leeway(interval: NSTimeInterval) -> UInt64 {
        return UInt64(0.05 * interval) * NSEC_PER_SEC
    }
    
    func start(now: Bool) {
        if (OSAtomicCompareAndSwap32(Static.STOPPED, Static.RUNNING, &_running._v)) {
            if let interval = _interval {
                dispatch_source_set_timer(_timer, DispatchTimer.startTime(interval, now: now), UInt64(interval) * NSEC_PER_SEC, DispatchTimer.leeway(interval))
                dispatch_source_set_event_handler(_timer) {
                    [weak self] in
                        if let strongSelf = self {
                            strongSelf._executionClosure?(strongSelf, Int(strongSelf._invocations._v))
                            OSAtomicIncrement64(&strongSelf._invocations._v)
                        }
                }
                dispatch_resume(_timer)
            }
        }
    }
    
    func pause() {
        if (OSAtomicCompareAndSwap32(Static.RUNNING, Static.STOPPED, &_running._v)) {
            dispatch_source_cancel(_timer)
        }
    }
    
    func stop() {
        if (OSAtomicCompareAndSwap32(Static.RUNNING, Static.STOPPED, &_running._v)) {
            dispatch_source_cancel(_timer)
            _invocations._v = 0
        }
    }
}