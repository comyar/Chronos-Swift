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

import UIKit
import XCTest

class ChronosTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConvenienceInitializer() {
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer?, invocations: Int) -> Void in
        })
        
        XCTAssertTrue(dispatchTimer._isValid, "Pass")
        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
    }
    
    func testDispatchTimer() {
        var semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer, invocations: Int) -> Void in
            if invocations == 10 {
                dispatch_semaphore_signal(semaphore)
                timer.cancel()
                
                XCTAssertFalse(timer._isValid, "Pass")
                XCTAssertFalse(timer._isRunning, "Pass")
            }
        })
        
        dispatchTimer.start(true)
        
        XCTAssertTrue(dispatchTimer._isValid, "Pass")
        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssert(true, "Pass")
    }
    
    func testRepeatedTimerUsage() {
        var semaphore: dispatch_semaphore_t = dispatch_semaphore_create(0)
        var second: Bool = false
        
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer, invocations: Int) -> Void in
            if invocations == 5 && !second {
                second = true
                timer.pause()
                
                XCTAssertTrue(timer._isValid, "Pass")
                XCTAssertFalse(timer._isRunning, "Pass")
                
                timer.start(true)
                
                XCTAssertTrue(timer._isValid, "Pass")
                XCTAssertTrue(timer._isRunning, "Pass")
            }
            
            if invocations == 10 && second {
                timer.cancel()
                
                XCTAssertFalse(timer._isValid, "Pass")
                XCTAssertFalse(timer._isRunning, "Pass")
                
                dispatch_semaphore_signal(semaphore)
            }
        })
        
        dispatchTimer.start(true)
        
        XCTAssertTrue(dispatchTimer._isValid, "Pass")
        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssert(true, "Pass")
    }
    
    func testIsRunning() {
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer?, invocations: Int) -> Void in
        })
        
        dispatchTimer.start(true)
        
        XCTAssertTrue(dispatchTimer._isRunning, "Pass")
    }
    
    func testIsNotRunning() {
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer?, invocations: Int) -> Void in
        })
        
        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
    }
    
    func testIsValid() {
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer?, invocations: Int) -> Void in
        })
        
        XCTAssertTrue(dispatchTimer._isValid, "Pass")
    }
    
    func testIsNotValid() {
        var dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, executionClosure: {
            (timer: DispatchTimer?, invocations: Int) -> Void in
        })
        
        dispatchTimer.start(true)
        dispatchTimer.cancel()
        
        XCTAssertFalse(dispatchTimer._isRunning, "Pass")
    }
}