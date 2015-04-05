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


// MARK: - Imports

import XCTest


// MARK: - ChronosTests Implementation

class ChronosTests: XCTestCase {
  
    // 5 second timeout for async tests
    var timeout: dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
    }
    
    func testConvenienceInitializer() {
        var timer = DispatchTimer(interval: 0.25, closure: {
            (timer: DispatchTimer, count: Int) -> Void in
                // nothing to do
        })
        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(timer.isRunning)
    }
  
    func testDispatchTimer() {
        var semaphore = dispatch_semaphore_create(0)

        var timer = DispatchTimer(interval: 0.25, closure: {
            (timer: DispatchTimer, count: Int) -> Void in
          if count == 10 {
            dispatch_semaphore_signal(semaphore)
          }
        })

        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(timer.isRunning)

        timer.start(true)

        dispatch_semaphore_wait(semaphore, timeout)

        timer.cancel()
    }
  
//    func testDispatchTimer() {
//        var semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
//        
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer, invocations: Int) -> Void in
//            if invocations == 10 {
//                dispatch_semaphore_signal(semaphore)
//                timer.cancel()
//                
//                XCTAssertFalse(timer._isValid, "Pass")
//                XCTAssertFalse(timer._isRunning, "Pass")
//            }
//        })
//        
//        dispatchTimer.start(true)
//        
//        XCTAssertTrue(dispatchTimer._isValid, "Pass")
//        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
//        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//        
//        XCTAssert(true, "Pass")
//    }
//    
//    func testRepeatedTimerUsage() {
//        var semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
//        var flag: Bool = false
//        
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer, invocations: Int) -> Void in
//            if invocations == 5 && !flag {
//                flag = true
//                timer.pause()
//                
//                XCTAssertTrue(timer._isValid, "Pass")
//                XCTAssertFalse(timer._isRunning, "Pass")
//                
//                timer.start(true)
//                
//                XCTAssertTrue(timer._isValid, "Pass")
//                XCTAssertTrue(timer._isRunning, "Pass")
//            }
//            
//            if invocations == 10 && flag {
//                timer.cancel()
//                
//                XCTAssertFalse(timer._isValid, "Pass")
//                XCTAssertFalse(timer._isRunning, "Pass")
//                
//                dispatch_semaphore_signal(semaphore)
//            }
//        })
//        
//        dispatchTimer.start(true)
//        
//        XCTAssertTrue(dispatchTimer._isValid, "Pass")
//        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
//        
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//        
//        XCTAssert(true, "Pass")
//    }
//    
//    func testStartPassCancel() {
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer?, invocations: Int) -> Void in
//        })
//        
//        XCTAssertTrue(dispatchTimer._isValid, "Pass")
//        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
//        
//        dispatchTimer.start(true)
//        
//        XCTAssertTrue(dispatchTimer._isValid, "Pass")
//        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
//        
//        dispatchTimer.pause()
//        
//        XCTAssertTrue(dispatchTimer._isValid, "Pass")
//        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
//        
//        dispatchTimer.cancel()
//        
//        XCTAssertFalse(dispatchTimer._isValid, "Pass")
//        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
//    }
//    
//    func testIsRunning() {
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer?, invocations: Int) -> Void in
//        })
//        
//        dispatchTimer.start(true)
//        
//        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
//    }
//    
//    func testIsNotRunning() {
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer?, invocations: Int) -> Void in
//        })
//        
//        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
//    }
//    
//    func testIsValid() {
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer?, invocations: Int) -> Void in
//        })
//        
//        XCTAssertTrue(dispatchTimer._isValid, "Pass")
//    }
//    
//    func testIsNotValid() {
//        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
//            (timer: DispatchTimer?, invocations: Int) -> Void in
//        })
//        
//        dispatchTimer.start(true)
//        dispatchTimer.cancel()
//        
//        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
//    }
}