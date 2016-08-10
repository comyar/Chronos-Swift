//
//  OneShotTimerTests.swift
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


// MARK: - OneShotDispatchTimerTests Implementation

class OneShotDispatchTimerTests : XCTestCase {

    // 5 second timeout for async tests
    var timeout: dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, Int64(5.0 * Double(NSEC_PER_SEC)))
    }

    func testConvenienceInitializer() {
        let timer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in
            // nothing to do
        })
        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(timer.isRunning)
    }

    func testOneShotDispatchTimer() {
        let semaphore = dispatch_semaphore_create(0)

        let timer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in
            dispatch_semaphore_signal(semaphore)
        })

        XCTAssertTrue(timer.isValid)
        XCTAssertFalse(timer.isRunning)

        timer.start(true)

        dispatch_semaphore_wait(semaphore, timeout)

        XCTAssertFalse(timer.isRunning)

        timer.cancel()
    }

    func testTimerDoesntRepeat() {
        let expectation = expectationWithDescription("testTimerDoesntRepeat")
        var count: Int = 0

        let dispatchTimer: OneShotDispatchTimer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in

            dispatch_barrier_sync(dispatch_get_main_queue()) {
                count = count + 1
            }
        })

        dispatchTimer.start(true)

        XCTAssertTrue(dispatchTimer.isValid)
        XCTAssertTrue(dispatchTimer.isRunning)

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            XCTAssertEqual(count, 1)
            expectation.fulfill()
        })

        waitForExpectationsWithTimeout(5) { error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
            }
        }
    }

    func testStartPassCancel() {
        let dispatchTimer: OneShotDispatchTimer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in

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
        let dispatchTimer: OneShotDispatchTimer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in

        })

        dispatchTimer.start(true)

        XCTAssertTrue(dispatchTimer.isRunning)
    }

    func testIsNotRunning() {
        let dispatchTimer: OneShotDispatchTimer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in

        })

        XCTAssertFalse(dispatchTimer.isRunning)
    }

    func testIsValid() {
        let dispatchTimer: OneShotDispatchTimer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in

        })

        XCTAssertTrue(dispatchTimer.isValid)
    }

    func testIsNotValid() {
        let dispatchTimer: OneShotDispatchTimer = OneShotDispatchTimer(delay: 0.25, closure: { (timer: Timer) in

        })

        dispatchTimer.start(true)
        dispatchTimer.cancel()

        XCTAssertFalse(dispatchTimer.isValid)
    }
}
