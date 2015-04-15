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
        var variableTimer: VariableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                return 0.00
        }
        
        XCTAssertTrue(variableTimer.isRunning == false)
        XCTAssertTrue(variableTimer.isValid == true)
    }
    
    func testStartNow() {
        var semaphore = dispatch_semaphore_create(0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        var variableTimer: VariableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 5 {
                timer.cancel()
                dispatch_semaphore_signal(semaphore)
            }
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                intervalInvocations.append(count)
                return NSTimeInterval(count)
        }
        
        variableTimer.start(true)
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssertEqual(6, executedInvocations.count);
        XCTAssertEqual(5, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3, 4, 5]
        let expectedIntervalInvocations = [1, 2, 3, 4, 5]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
        
    }
    
    func testStartNowPauseInsideStartNowInside() {
        var semaphore = dispatch_semaphore_create(0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        var timer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 0 {
                timer.pause()
                timer.start(true)
            } else if count == 3 {
                timer.cancel()
                dispatch_semaphore_signal(semaphore)
            }
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                intervalInvocations.append(count)
                return NSTimeInterval(Double(count))
        }
        
        timer.start(true)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssertEqual(4, executedInvocations.count);
        XCTAssertEqual(2, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3]
        let expectedIntervalInvocations = [2, 3]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
    }
    
    func testStartPauseInsideStartNowInside() {
        var semaphore = dispatch_semaphore_create(0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        var timer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 0 {
                timer.pause()
                timer.start(true)
            } else if count == 3 {
                timer.cancel()
                dispatch_semaphore_signal(semaphore)
            }
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                intervalInvocations.append(count)
                return NSTimeInterval(Double(count))
        }
        
        timer.start(false)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssertEqual(4, executedInvocations.count);
        XCTAssertEqual(3, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3]
        let expectedIntervalInvocations = [0, 2, 3]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
    }
    
    func testStartPauseInsideStartInside() {
        var semaphore = dispatch_semaphore_create(0)
        var executedInvocations: [Int] = []
        var intervalInvocations: [Int] = []
        
        var timer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            executedInvocations.append(count)
            if count == 0 {
                timer.pause()
                timer.start(false)
            } else if count == 3 {
                timer.cancel()
                dispatch_semaphore_signal(semaphore)
            }
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                intervalInvocations.append(count)
                return NSTimeInterval(Double(count))
        }
        
        timer.start(false)
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        XCTAssertEqual(4, executedInvocations.count);
        XCTAssertEqual(4, intervalInvocations.count);
        
        let expectedExecutedInvocations = [0, 1, 2, 3]
        let expectedIntervalInvocations = [0, 1, 2, 3]
        
        XCTAssertEqual(expectedExecutedInvocations, executedInvocations);
        XCTAssertEqual(expectedIntervalInvocations, intervalInvocations);
    }
    
    func testTimerPauseBeforeStart() {
        var semaphore = dispatch_semaphore_create(0)
        var variableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            dispatch_semaphore_signal(semaphore)
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                return 2.00
        }
        
        variableTimer.pause()
        
        XCTAssertFalse(variableTimer.isRunning);
        XCTAssertTrue(variableTimer.isValid);
        
        variableTimer.start(true)
        
        XCTAssertTrue(variableTimer.isRunning);
        XCTAssertTrue(variableTimer.isValid);
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        variableTimer.cancel()
    }
    
    func testTimerCancelBeforeStart() {
        var semaphore = dispatch_semaphore_create(0)
        var variableTimer = VariableTimer(closure: { (timer: RepeatingTimer, count: Int) -> Void in
            dispatch_semaphore_signal(semaphore)
            }) { (timer: VariableTimer, count: Int) -> NSTimeInterval in
                return 2.00
        }
        
        XCTAssertFalse(variableTimer.isRunning);
        XCTAssertTrue(variableTimer.isValid);
        
        variableTimer.cancel()
        
        XCTAssertFalse(variableTimer.isValid);
        
        //XCTAssertThrowsSpecific(variableTimer.start(true), NSException); Does not exist in swift.
    }
}