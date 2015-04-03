//
//  DispatchTimer.swift
//  Chronos
//
//  Created by Andrew Chun on 4/2/15.
//  Copyright (c) 2015 com.zero223. All rights reserved.
//

import Foundation

struct Static {
    internal static let STOPPED: Int = 0
    internal static let RUNNING: Int = 1
    internal static let DispatchTimerExecutionQueueNamePrefix = "com.chronos.execution"
}

class DispatchTimer : NSObject {
    //Swift does not allow weak closure variables
    typealias DispatchTimerInitFailureBlock     = ((Void) -> Void)?
    typealias DispatchTimerCancellationBlock    = ((DispatchTimer?) -> Void)?
    typealias DispatchTimerExecutionBlock       = ((DispatchTimer?, Int) -> Void)?
    
    var v: CHRVolatile = CHRVolatile(_running: 0, _invocations: 0)
}