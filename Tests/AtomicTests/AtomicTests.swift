import XCTest
@testable import Atomic

final class AtomicTests: XCTestCase {
  
  func testInitialization() {
    let atomic = Atomic(42)
    XCTAssertEqual(atomic.get(), 42)
  }
  
  func testInitializationWithCustomLock() {
    let lock = NSRecursiveLock()
    let atomic = Atomic(42, lock: lock)
    XCTAssertEqual(atomic.get(), 42)
  }
  
  func testGetAndSet() {
    let atomic = Atomic(0)
    
    atomic.set(100)
    XCTAssertEqual(atomic.get(), 100)
    
    atomic.set(-50)
    XCTAssertEqual(atomic.get(), -50)
  }
  
  func testModify() {
    let atomic = Atomic(10)
    
    let result = atomic.modify { value in
      value *= 2
    }
    
    XCTAssertEqual(result, 20)
    XCTAssertEqual(atomic.get(), 20)
  }
  
  func testModifyWithArray() {
    let atomic = Atomic([1, 2, 3])
    
    let result = atomic.modify { array in
      array.append(4)
      array.append(5)
    }
    
    XCTAssertEqual(result, [1, 2, 3, 4, 5])
    XCTAssertEqual(atomic.get(), [1, 2, 3, 4, 5])
  }
  
  func testPerform() {
    let atomic = Atomic("Hello")
    var capturedValue: String = ""
    
    atomic.perform { value in
      capturedValue = value + " World"
    }
    
    XCTAssertEqual(capturedValue, "Hello World")
    XCTAssertEqual(atomic.get(), "Hello") // Original unchanged
  }
  
  func testConcurrentReads() {
    let atomic = Atomic(42)
    let expectation = XCTestExpectation(description: "Concurrent reads complete")
    expectation.expectedFulfillmentCount = 100
    
    let queue = DispatchQueue.global(qos: .default)
    
    for _ in 0..<100 {
      queue.async {
        let value = atomic.get()
        XCTAssertEqual(value, 42)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  func testConcurrentWrites() {
    let atomic = Atomic(0)
    let expectation = XCTestExpectation(description: "Concurrent writes complete")
    expectation.expectedFulfillmentCount = 100
    
    let queue = DispatchQueue.global(qos: .default)
    
    for i in 0..<100 {
      queue.async {
        atomic.set(i)
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 5.0)
    
    // Final value should be one of the written values
    let finalValue = atomic.get()
    XCTAssertTrue((0..<100).contains(finalValue))
  }
  
  func testConcurrentIncrement() {
    let atomic = Atomic(0)
    let expectation = XCTestExpectation(description: "Concurrent increments complete")
    expectation.expectedFulfillmentCount = 1000
    
    let queue = DispatchQueue.global(qos: .default)
    
    for _ in 0..<1000 {
      queue.async {
        atomic.modify { value in
          value += 1
        }
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10.0)
    XCTAssertEqual(atomic.get(), 1000)
  }
  
  func testMixedConcurrentOperations() {
    let atomic = Atomic([Int]())
    let expectation = XCTestExpectation(description: "Mixed operations complete")
    expectation.expectedFulfillmentCount = 300
    
    let queue = DispatchQueue.global(qos: .default)
    
    // Writers
    for i in 0..<100 {
      queue.async {
        atomic.modify { array in
          array.append(i)
        }
        expectation.fulfill()
      }
    }
    
    // Readers
    for _ in 0..<200 {
      queue.async {
        atomic.perform { array in
          _ = array.count // Just read the count
        }
        expectation.fulfill()
      }
    }
    
    wait(for: [expectation], timeout: 10.0)
    
    let finalArray = atomic.get()
    XCTAssertEqual(finalArray.count, 100)
    XCTAssertEqual(Set(finalArray), Set(0..<100))
  }
  
  func testDifferentLockTypes() {
    let testCases: [any AtomicLock] = [
      DispatchQueue(label: "test.serial"),
      DispatchQueue(label: "test.concurrent", attributes: .concurrent),
      NSRecursiveLock(),
      ReaderWriterLock()
    ]
    
    for lock in testCases {
      let atomic = Atomic(0, lock: lock)
      
      atomic.set(42)
      XCTAssertEqual(atomic.get(), 42)
      
      atomic.modify { value in
        value *= 2
      }
      XCTAssertEqual(atomic.get(), 84)
      
      var performResult = 0
      atomic.perform { value in
        performResult = value + 10
      }
      XCTAssertEqual(performResult, 94)
    }
  }
  
  func testErrorHandling() {
    let atomic = Atomic("test")
    
    enum TestError: Error {
      case testFailure
    }
    
    // Test that errors propagate correctly
    XCTAssertThrowsError(try atomic.modify { _ in
      throw TestError.testFailure
    }) { error in
      XCTAssertTrue(error is TestError)
    }
    
    // Verify value wasn't changed after error
    XCTAssertEqual(atomic.get(), "test")
  }
  
  func testRecursiveLockRecursion() {
    let lock = NSRecursiveLock()
    let atomic = Atomic(10, lock: lock)
    
    // Test that recursive calls work by calling get() from within perform()
    var result = 0
    atomic.perform { value in
      result = value + atomic.get() // This should work
    }
    
    XCTAssertEqual(result, 20)
  }
}
