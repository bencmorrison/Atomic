//
//  LockingTests.swift
//  LockingTests
//
//  Created by Ben Morrison on 21/1/18.
//  Copyright © 2018 Benjamin C Morrison. All rights reserved.
//

import XCTest
@testable import Atomic

class LockingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreation() {
        let testIntVal: Int = 10
        @Atomic var intSut = testIntVal
        XCTAssertEqual(testIntVal, intSut)
        
        let testStringVal: String = "Test String"
        @Atomic var stringSut = testStringVal
        XCTAssertEqual(testStringVal, stringSut)
        
        let testOptIntVal: Int? = 10
        @Atomic var optIntSut = testOptIntVal
        XCTAssertEqual(testOptIntVal, optIntSut)
        
        let testOptStringVal: String? = "🤨"
        @Atomic var stringOptSut = testOptStringVal
        XCTAssertEqual(testOptStringVal, stringOptSut)
    }
    
    func testSettingValue() {
        var testVal: Int = 10
        @Atomic var sut = testVal
        XCTAssertEqual(testVal, sut)
        
        testVal = 100
        sut = testVal
        XCTAssertEqual(testVal, sut)
    }
    
    func testThreadDontLock() {
        let queue = DispatchQueue(label: "AtomicTest-Queue")
        let expect1 = expectation(description: "Loop 1")
        let expect2 = expectation(description: "Loop 2")
        let expect3 = expectation(description: "Loop 3")
        let expect4 = expectation(description: "Loop 4")
        
        @Atomic var sut: String = ""
        
        queue.async {
            for _ in 0...500 {
                sut = UUID().uuidString
            }
            expect1.fulfill()
        }
        
        queue.async {
            for _ in 0...500 {
                sut = UUID().uuidString
            }
            expect2.fulfill()
        }
        
        queue.async {
            for _ in 0...500 {
                sut = UUID().uuidString
            }
            expect3.fulfill()
        }
        
        queue.async {
            for _ in 0...500 {
                sut = UUID().uuidString
            }
            expect4.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
