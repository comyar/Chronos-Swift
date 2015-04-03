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
    internal static let TmpDispatchTimerExecutionQueueNameSuffix    = "CHRONOS"
}

class DispatchTimer : NSObject {
    //Swift does not allow weak closure variables
    //MARK: Type Definitions
    typealias DispatchTimerInitFailureBlock     = ((Void) -> Void)?
    typealias DispatchTimerCancellationBlock    = ((DispatchTimer?) -> Void)
    typealias DispatchTimerExecutionBlock       = ((DispatchTimer?, Int) -> Void)
    
    //MARK: Internal Instance Variables
    private(set) var _interval:          NSTimeInterval?
    private(set) var _executionQueue:    dispatch_queue_t?
    private(set) var _executionClosure:  DispatchTimerExecutionBlock?
    
    //MARK: Private Instance Variables
    private      var _v:             CHRVolatile = CHRVolatile(_running: 0, _invocations: 0)
    private(set) var _queue:         dispatch_queue_t?
    private(set) var _timer:         dispatch_source_t?
    
    //MARK: Initializers for DispatchTimers
    override init() {
        fatalError("Must use either designated initializer or convenience initializer.")
    }
    
    init?(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionBlock, executionQueue: dispatch_queue_t, failureClosure: DispatchTimerInitFailureBlock) {
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _executionQueue)
        
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
            
            super.init()
            return nil
        }
        
        super.init()
    }
    
    convenience init?(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionBlock) {
        let executionQueueName: String          = "\(Static.DispatchTimerExecutionQueueNamePrefix).\(Static.TmpDispatchTimerExecutionQueueNameSuffix)"
        let executionQueue: dispatch_queue_t    = dispatch_queue_create((executionQueueName as NSString).UTF8String, DISPATCH_QUEUE_SERIAL)
        
        self.init(interval: interval, executionClosure: executionClosure, executionQueue: executionQueue)
    }
    
    convenience init?(interval: NSTimeInterval, executionClosure: DispatchTimerExecutionBlock, executionQueue: dispatch_queue_t) {
        self.init(interval: interval, executionClosure: executionClosure, executionQueue: executionQueue, nil)
    }
    
    deinit {
        "Deinitialized"
    }
}