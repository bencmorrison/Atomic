//
//  LockingTest+Operators.swift
//  LockingTests
//
//  Created by Ben Morrison on 21/1/18.
//  Copyright © 2018 Benjamin C Morrison. All rights reserved.
//

import XCTest
@testable import Locking

class LockingTest_Operators: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAssigningLockingToLocking() {
        let sut1 = Locking<String>("SUT 1")
        var sut2 = Locking<String>("SUT 2")
        XCTAssertNotEqual(sut1.value, sut2.value)
        
        sut2 <= sut1
        XCTAssertEqual(sut1.value, sut2.value)
    }
    
    func testAssigningRawToLocking() {
        var sut1 = Locking<String>("SUT 1")
        let sut2: String = "Raw String"
        
        sut1 <= sut2
        XCTAssertEqual(sut1.value, sut2)
    }
    
    func testAssigningLockingToRaw() {
        var sut1: String = "Raw String"
        let sut2 = Locking<String>("SUT 2")
        
        sut1 <= sut2
        XCTAssertEqual(sut1, sut2.value)
    }
    
    func testAssigningOptionalLockingToNonOptionalRaw() {
        var sut1: String? = "Raw String"
        let sut2 = Locking<String?>("SUT 2")
        
        sut1 <= sut2
        XCTAssertEqual(sut1, sut2.value)
    }
    
    func testAssigningNonOptionalLockingToOptionalRaw() {
        let sut1: String? = "Raw String"
        var sut2 = Locking<String>("SUT 2")
        
        sut2 <= sut1!
        XCTAssertEqual(sut1, sut2.value)
    }
}
