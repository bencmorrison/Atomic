import XCTest
@testable import Atomic

final class AtomicTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCreation() {
        let testIntVal: Int = 10
        let intSut = Atomic<Int>(testIntVal)
        XCTAssertEqual(testIntVal, intSut.get())
        
        let testStringVal: String = "Test String"
        let stringSut = Atomic<String>(testStringVal)
        XCTAssertEqual(testStringVal, stringSut.get())
        
        let testOptIntVal: Int? = 10
        let optIntSut = Atomic<Int?>(testOptIntVal)
        XCTAssertEqual(testOptIntVal, optIntSut.get())
        
        let testOptStringVal: String? = "🤨"
        let stringOptSut = Atomic<String?>(testOptStringVal)
        XCTAssertEqual(testOptStringVal, stringOptSut.get())
    }
    
    func testSettingValue() {
        var testVal: Int = 10
        var sut = Atomic<Int>(testVal)
        XCTAssertEqual(testVal, sut.get())
        
        testVal = 100
        
        let afterModify = sut.modify { value in
            return testVal
        }
        
        XCTAssertEqual(testVal, afterModify)
        XCTAssertEqual(testVal, sut.get())
    }
    
    func testEquality() {
        let lhsSut = Atomic<Int>(100)
        var rhsSut = Atomic<Int>(200)
    
        XCTAssertFalse(lhsSut == rhsSut)
        
        rhsSut.set(100)
        
        XCTAssertTrue(lhsSut == rhsSut)
        XCTAssertFalse(lhsSut != rhsSut)
    }
    
    func testComparison() {
        let lhsSut = Atomic<Int>(100)
        let rhsSut = Atomic<Int>(200)
        
        XCTAssertTrue(lhsSut < rhsSut)
        XCTAssertFalse(lhsSut > rhsSut)
        XCTAssertTrue(lhsSut <= rhsSut)
        XCTAssertFalse(lhsSut >= rhsSut)
    }
    
    func testCodable() {
        let value = CodableObject(firstValue: "I'm a String", secondValue: 102)
        let atomic = Atomic<CodableObject>(value)
        
        XCTAssertEqual(value, atomic.get())
        
        let encodedValue = try? JSONEncoder().encode(value)
        let encodedAtomic = try? JSONEncoder().encode(atomic)
        
        XCTAssertNotNil(encodedValue)
        XCTAssertNotNil(encodedAtomic)
        
        let decodedValue = try? JSONDecoder().decode(CodableObject.self, from: encodedValue!)
        let decodedAtomic = try? JSONDecoder().decode(Atomic<CodableObject>.self, from: encodedAtomic!)
        
        XCTAssertNotNil(decodedValue)
        XCTAssertNotNil(decodedAtomic)
        
        XCTAssertEqual(decodedValue, value)
        XCTAssertEqual(decodedAtomic!.get(), atomic.get())
        
        XCTAssertEqual(decodedValue!, decodedAtomic!.get())
    }
}

private struct CodableObject: Codable, Equatable {
    let firstValue: String
    let secondValue: Int
}
