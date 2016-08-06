//
//  VariableTimerTests.swift
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


// MARK: - VariableTimerTests Implementation

class VariableTimerTests : XCTestCase {
    func testVariableTimerConvenienceInitializer() {
        let variableTimer: VariableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            
        }) { (timer: VariableTimer, count: Int) -> Double in
                return 0.00
        }
        
        XCTAssertTrue(variableTimer.isRunning == false)
        XCTAssertTrue(variableTimer.isValid == true)
    }
    
    func testStartNow() {
        let semaphore = DispatchSemaphore(value: 0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        let variableTimer: VariableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 5 {
                timer.cancel()
                semaphore.signal()
            }
        }) { (timer: VariableTimer, count: Int) -> Double in
                intervalInvocations.append(count)
                return 0.25
        }
        
        variableTimer.start(true)
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        XCTAssertEqual(6, executedInvocations.count);
        XCTAssertEqual(5, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3, 4, 5]
        let expectedIntervalInvocations = [1, 2, 3, 4, 5]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
        
    }
    
    func testStartNowPauseInsideStartNowInside() {
        let semaphore = DispatchSemaphore(value: 0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        let timer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 0 {
                timer.pause()
                timer.start(true)
            } else if count == 3 {
                timer.cancel()
                semaphore.signal()
            }
        }) { (timer: VariableTimer, count: Int) -> Double in
                intervalInvocations.append(count)
                return 0.25
        }
        
        timer.start(true)
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        XCTAssertEqual(4, executedInvocations.count);
        XCTAssertEqual(2, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3]
        let expectedIntervalInvocations = [2, 3]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
    }
    
    func testStartPauseInsideStartNowInside() {
        let semaphore = DispatchSemaphore(value: 0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        let timer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 0 {
                timer.pause()
                timer.start(true)
            } else if count == 3 {
                timer.cancel()
                semaphore.signal()
            }
        }) { (timer: VariableTimer, count: Int) -> Double in
                intervalInvocations.append(count)
                return 0.25
        }
        
        timer.start(false)
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        XCTAssertEqual(4, executedInvocations.count);
        XCTAssertEqual(3, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3]
        let expectedIntervalInvocations = [0, 2, 3]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
    }
    
    func testStartPauseInsideStartInside() {
        let semaphore = DispatchSemaphore(value: 0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        let timer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 0 {
                timer.pause()
                timer.start(false)
            } else if count == 3 {
                timer.cancel()
                semaphore.signal()
            }
        }) { (timer: VariableTimer, count: Int) -> Double in
                intervalInvocations.append(count)
                return 0.25
        }
        
        timer.start(false)
        
        semaphore.wait(timeout: DispatchTime.distantFuture)
        
        XCTAssertEqual(4, executedInvocations.count);
        XCTAssertEqual(4, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3]
        let expectedIntervalInvocations = [0, 1, 2, 3]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
    }
    
    func testTimerPauseBeforeStart() {
        let semaphore = DispatchSemaphore(value: 0)
        let variableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            semaphore.signal()
        }) { (timer: VariableTimer, count: Int) -> Double in
                return 0.25
        }
        
        variableTimer.pause()
        
        XCTAssertFalse(variableTimer.isRunning);
        XCTAssertTrue(variableTimer.isValid);
        
        variableTimer.start(true)
        
        XCTAssertTrue(variableTimer.isRunning);
        XCTAssertTrue(variableTimer.isValid);
        
        semaphore.wait(timeout: DispatchTime.distantFuture);
        
        variableTimer.cancel()
    }
    
    func testTimerCancelBeforeStart() {
        let semaphore = DispatchSemaphore(value: 0)
        let variableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            semaphore.signal()
        }) { (timer: VariableTimer, count: Int) -> Double in
                return 0.25
        }
        
        XCTAssertFalse(variableTimer.isRunning);
        XCTAssertTrue(variableTimer.isValid);
        
        variableTimer.cancel()
        
        XCTAssertFalse(variableTimer.isValid);
        
        //XCTAssertThrowsSpecific(variableTimer.start(true), NSException); Does not exist in swift.
    }
}
