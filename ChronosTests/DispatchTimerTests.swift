//
//  DispatchTimerTests.swift
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


// MARK: - DispatchTimerTests Implementation

class DispatchTimerTests : XCTestCase {
    
    // 5 second timeout for async tests
    var timeout: DispatchTime {
        return DispatchTime(uptimeNanoseconds:(DispatchTime.now() + 5).uptimeNanoseconds)
    }
    
    func testConvenienceInitializer() {
        let timer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, count: Int) in
            // nothing to do
        })
        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(timer.isRunning)
    }
    
    func testDispatchTimer() {
        let semaphore = DispatchSemaphore(value: 0)
        
        let timer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, count: Int) in
            if count == 10 {
                semaphore.signal()
            }
        })
        
        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(timer.isRunning)
        
        timer.start(true)
        
        let _ = semaphore.wait(timeout: timeout)
        
        timer.cancel()
    }
    
    func testRepeatedTimerUsage() {
        let semaphore = DispatchSemaphore(value: 0)
        var flag: Bool = false
        
        let dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, invocations: Int) in
            let dTimer = timer as! DispatchTimer
            
            if invocations == 5 && !flag {
                flag = true
                timer.pause()
                
                XCTAssertTrue(dTimer.isValid)
                XCTAssertFalse(dTimer.isRunning)
                
                timer.start(true)
                
                XCTAssertTrue(dTimer.isValid)
                XCTAssertTrue(dTimer.isRunning)
            }
            
            if invocations == 10 && flag {
                timer.cancel()
                
                XCTAssertFalse(dTimer.isValid)
                XCTAssertFalse(dTimer.isRunning)
                
                semaphore.signal()
            }
        })
        
        dispatchTimer.start(true)
        
        XCTAssertTrue(dispatchTimer.isValid)
        XCTAssertTrue(dispatchTimer.isRunning)
        
        let _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    func testStartPassCancel() {
        let dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, invocations: Int) in
            
        })
        
        XCTAssertTrue(dispatchTimer.isValid)
        XCTAssertFalse(dispatchTimer.isRunning)
        
        dispatchTimer.start(true)
        
        XCTAssertTrue(dispatchTimer.isValid)
        XCTAssertTrue(dispatchTimer.isRunning)
        
        dispatchTimer.pause()
        
        XCTAssertTrue(dispatchTimer.isValid)
        XCTAssertFalse(dispatchTimer.isRunning)
        
        dispatchTimer.cancel()
        
        XCTAssertFalse(dispatchTimer.isValid)
        XCTAssertFalse(dispatchTimer.isRunning)
    }
    
    func testIsRunning() {
        let dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, invocations: Int) in
            
        })
        
        dispatchTimer.start(true)
        
        XCTAssertTrue(dispatchTimer.isRunning)
    }
    
    func testIsNotRunning() {
        let dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, invocations: Int) in
            
        })
        
        XCTAssertFalse(dispatchTimer.isRunning)
    }
    
    func testIsValid() {
        let dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, invocations: Int) in
            
        })
        
        XCTAssertTrue(dispatchTimer.isValid)
    }
    
    func testIsNotValid() {
        let dispatchTimer: DispatchTimer = DispatchTimer(interval: 0.25, closure: { (timer: RepeatingTimer, invocations: Int) in
            
        })
        
        dispatchTimer.start(true)
        dispatchTimer.cancel()
        
        XCTAssertFalse(dispatchTimer.isValid)
    }
    
    func testTimeInterval() {
        var stopwatch = Stopwatch()
        stopwatch.start()
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        var records = [Double]()
        
        let timeout = 22.2
        let interval = 5.5
        
        let dispatchTimer = DispatchTimer(interval: interval) { (timer: RepeatingTimer, invocations: Int) in
            stopwatch.stop()
            records += [floor(stopwatch.seconds)]
            
            if invocations == Int(floor(timeout/interval))-1 {
                exp.fulfill()
            }
        }
        
        dispatchTimer.start(false)
        
        waitForExpectations (timeout: timeout) { _ in
            XCTAssertTrue(records.count == Int(timeout/interval))
            for i in 0..<Int(floor(timeout/interval)) {
                XCTAssertTrue(records[i] == floor(interval*Double(i + 1)))
            }
        }
    }
    
    func testTimeIntervalStartingNow() {
        var stopwatch = Stopwatch()
        stopwatch.start()
        
        let exp = expectation(description: "\(#function)\(#line)")
        
        var records = [Double]()
        
        let timeout = 22.2
        let interval = 5.5
        
        let dispatchTimer = DispatchTimer(interval: interval) { (timer: RepeatingTimer, invocations: Int) in
            stopwatch.stop()
            records += [floor(stopwatch.seconds)]
            
            if invocations == Int(floor(timeout/interval)) {
                exp.fulfill()
            }
        }
        
        dispatchTimer.start(true)
        
        waitForExpectations (timeout: timeout) { _ in
            XCTAssertTrue(records.count == Int(timeout/interval)+1)
            for i in 0...Int(floor(timeout/interval)) {
                XCTAssertTrue(records[i] == floor(interval*Double(i)))
            }
        }
    }
}
