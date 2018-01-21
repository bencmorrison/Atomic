//
//  LockingTests.swift
//  LockingTests
//
//  Created by Ben Morrison on 21/1/18.
//  Copyright © 2018 Benjamin C Morrison. All rights reserved.
//

import XCTest
@testable import Locking

class LockingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreation() {
        let testIntVal: Int = 10
        let intSut = Locking<Int>(testIntVal)
        
        XCTAssertEqual(testIntVal, intSut.value)
        
        let testStringVal: String = "Test String"
        let stringSut = Locking<String>(testStringVal)
        
        XCTAssertEqual(testStringVal, stringSut.value)
        
        let testOptIntVal: Int? = 10
        let optIntSut = Locking<Int?>(testOptIntVal)
        
        XCTAssertEqual(testOptIntVal, optIntSut.value)
        
        let testOptStringVal: String? = "🤨"
        let stringOptSut = Locking<String?>(testOptStringVal)
        
        XCTAssertEqual(testOptStringVal, stringOptSut.value)
    }
    
    func testSettingValue() {
        var testVal: Int = 10
        var sut = Locking<Int>(testVal)
        XCTAssertEqual(testVal, sut.value)
        
        testVal = 100
        sut.value = testVal
        XCTAssertEqual(testVal, sut.value)
    }
    
    func testEnsure() {
        var testVal: Int = 10
        var sut = Locking<Int>(testVal)
        
        let addVal: Int = 287324
        testVal = testVal + addVal
        
        let newValue = sut.ensure { $0 + addVal }
        
        XCTAssertEqual(testVal, newValue)
        XCTAssertEqual(testVal, sut.value)
        XCTAssertEqual(newValue, sut.value)
    }
    
    func testCompare() {
        let testVal1: Int = 10
        let sut1 = Locking<Int>(testVal1)
        
        let testVal2: Int = 123
        let sut2 = Locking<Int>(testVal2)
        
        let controlRes = testVal1 == testVal2
        let sutResult = sut1.compare(with: sut2) { $0 == $1 }
        
        XCTAssertEqual(controlRes, sutResult)
        
        let sutSwapResult = sut2.compare(with: sut1) { $0 == $1 }
        
        XCTAssertEqual(controlRes, sutSwapResult)
        XCTAssertEqual(sutResult, sutSwapResult)
    }
}
