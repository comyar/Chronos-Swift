//
//  Stopwatch.swift
//  Chronos
//
//  Created by ggiampietro on 2/2/17.
//  Copyright © 2017 com.comyarzaheri. All rights reserved.
//

import Foundation

struct Stopwatch {
    var startTime: UInt64 = 0
    var stopTime: UInt64 = 0
    let numer: UInt64
    let denom: UInt64
    
    init() {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)
    }
    
    mutating func start() {
        startTime = mach_absolute_time()
    }
    
    mutating func stop() {
        stopTime = mach_absolute_time()
    }
    
    var nanoseconds: UInt64 {
        return ((stopTime - startTime) * numer) / denom
    }
    
    var milliseconds: Double {
        return Double(nanoseconds) / 1_000_000
    }
    
    var seconds: Double {
        return Double(nanoseconds) / 1_000_000_000
    }
}
