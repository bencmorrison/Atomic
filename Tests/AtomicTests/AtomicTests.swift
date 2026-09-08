import Foundation
import Testing

@testable import Atomic

struct AtomicTests {

  @Test
  func testInitialization() {
    let atomic = Atomic(42)
    #expect(atomic.get() == 42)
  }

  @Test
  func testInitializationWithCustomLock() {
    let lock = NSRecursiveLock()
    let atomic = Atomic(42, handle: LockHandle(lock))
    #expect(atomic.get() == 42)
  }

  @Test
  func testGetAndSet() {
    let atomic = Atomic(0)

    atomic.set(100)
    #expect(atomic.get() == 100)

    atomic.set(-50)
    #expect(atomic.get() == -50)
  }

  @Test
  func testModify() {
    let atomic = Atomic(10)

    let result = atomic.modify { value in
      value *= 2
      return value
    }

    #expect(result == 20)
    #expect(atomic.get() == 20)
  }

  @Test
  func testModifyWithArray() {
    let atomic = Atomic([1, 2, 3])

    let result = atomic.modify { array in
      array.append(4)
      array.append(5)
      return array
    }

    #expect(result == [1, 2, 3, 4, 5])
    #expect(atomic.get() == [1, 2, 3, 4, 5])
  }

  @Test
  func testModifyReturnsRemovedElement() {
    let atomic = Atomic([1, 2, 3])

    let removed = atomic.modify { array in
      array.removeFirst()
    }

    #expect(removed == 1)
    #expect(atomic.get() == [2, 3])
  }

  @Test
  func testPerform() {
    let atomic = Atomic("Hello")
    var capturedValue: String = ""

    atomic.perform { value in
      capturedValue = value + " World"
    }

    #expect(capturedValue == "Hello World")
    #expect(atomic.get() == "Hello")  // Original unchanged
  }

  @Test
  func testConcurrentReads() async {
    let atomic = Atomic(42)

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<100 {
        group.addTask {
          let value = atomic.get()
          #expect(value == 42)
        }
      }
    }
  }

  @Test
  func testConcurrentWrites() async {
    let atomic = Atomic(0)

    await withTaskGroup(of: Void.self) { group in
      for i in 0..<100 {
        group.addTask {
          atomic.set(i)
        }
      }
    }

    // Final value should be one of the written values
    let finalValue = atomic.get()
    #expect((0..<100).contains(finalValue))
  }

  @Test
  func testConcurrentIncrement() async {
    let atomic = Atomic(0)

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<1000 {
        group.addTask {
          atomic.modify { value in
            value += 1
          }
        }
      }
    }

    #expect(atomic.get() == 1000)
  }

  @Test
  func testMixedConcurrentOperations() async {
    let atomic = Atomic([Int]())

    await withTaskGroup(of: Void.self) { group in
      // Writers
      for i in 0..<100 {
        group.addTask {
          atomic.modify { array in
            array.append(i)
          }
        }
      }

      // Readers
      for _ in 0..<200 {
        group.addTask {
          atomic.perform { array in
            _ = array.count  // Just read the count
          }
        }
      }
    }

    let finalArray = atomic.get()
    #expect(finalArray.count == 100)
    #expect(Set(finalArray) == Set(0..<100))
  }

  @Test
  func testDifferentLockTypes() {
    let testCases: [any AtomicLock] = [
      DispatchQueue(label: "test.serial"),
      DispatchQueue(label: "test.concurrent", attributes: .concurrent),
      NSRecursiveLock(),
      ReaderWriterLock(),
    ]

    for lock in testCases {
      let atomic = Atomic(0, handle: LockHandle(lock))

      atomic.set(42)
      #expect(atomic.get() == 42)

      atomic.modify { value in
        value *= 2
      }
      #expect(atomic.get() == 84)

      var performResult = 0
      atomic.perform { value in
        performResult = value + 10
      }
      #expect(performResult == 94)
    }
  }

  @Test
  func testErrorHandling() {
    let atomic = Atomic("test")

    enum TestError: Error {
      case testFailure
    }

    // Test that errors propagate correctly
    #expect(throws: TestError.self) {
      try atomic.modify { _ in
        throw TestError.testFailure
      }
    }

    // Verify value wasn't changed after error
    #expect(atomic.get() == "test")
  }

  @Test
  func testRecursiveLockRecursion() {
    let lock = NSRecursiveLock()
    let atomic = Atomic(10, handle: LockHandle(lock))

    // Test that recursive calls work by calling get() from within perform()
    var result = 0
    atomic.perform { value in
      result = value + atomic.get()  // This should work
    }

    #expect(result == 20)
  }


  @Test(arguments: TestLockKind.allCases)
  func testExchangeAndOptionalValues(kind: TestLockKind) {
    let atomic = Atomic<Int?>(nil, handle: LockHandle(kind.makeLock()))

    #expect(atomic.exchange(42) == nil)
    #expect(atomic.get() == 42)
    #expect(atomic.exchange(nil) == 42)
    #expect(atomic.get() == nil)
  }

  @Test(arguments: TestLockKind.allCases)
  func testModifyErrorKeepsMutationAndReleasesLock(kind: TestLockKind) {
    let atomic = Atomic([1], handle: LockHandle(kind.makeLock()))

    #expect(throws: TestFailure.expected) {
      try atomic.modify { value in
        value.append(2)
        throw TestFailure.expected
      }
    }

    // Use a different thread so recursive locks cannot hide a missing unlock.
    let finished = DispatchSemaphore(value: 0)
    Thread.detachNewThread {
      #expect(atomic.exchange([3]) == [1, 2])
      #expect(atomic.get() == [3])
      finished.signal()
    }
    #expect(finished.wait(timeout: .now() + 5) == .success)
  }

  @Test(arguments: TestLockKind.allCases)
  func testPerformResultAndErrorReleaseLock(kind: TestLockKind) {
    let atomic = Atomic([1, 2, 3], handle: LockHandle(kind.makeLock()))
    #expect(atomic.perform { $0.reduce(0, +) } == 6)

    #expect(throws: TestFailure.expected) {
      try atomic.perform { _ in throw TestFailure.expected }
    }

    let finished = DispatchSemaphore(value: 0)
    Thread.detachNewThread {
      #expect(atomic.exchange([]) == [1, 2, 3])
      finished.signal()
    }
    #expect(finished.wait(timeout: .now() + 5) == .success)
  }

  @Test(arguments: TestLockKind.allCases)
  func testConcurrentModifyReturnsUniqueValues(kind: TestLockKind) async {
    let atomic = Atomic(0, handle: LockHandle(kind.makeLock()))

    let results = await withTaskGroup(of: Int.self, returning: [Int].self) { group in
      for _ in 0..<200 {
        group.addTask {
          atomic.modify { value in
            value += 1
            return value
          }
        }
      }
      var results: [Int] = []
      for await result in group { results.append(result) }
      return results
    }

    #expect(results.sorted() == Array(1...200))
    #expect(atomic.get() == 200)
  }

  @Test(arguments: TestLockKind.allCases)
  func testConcurrentExchangePreservesEveryValue(kind: TestLockKind) async {
    let atomic = Atomic(0, handle: LockHandle(kind.makeLock()))

    var previous = await withTaskGroup(of: Int.self, returning: [Int].self) { group in
      for value in 1...200 {
        group.addTask { atomic.exchange(value) }
      }
      var results: [Int] = []
      for await result in group { results.append(result) }
      return results
    }
    previous.append(atomic.get())

    // Each value must appear exactly once, as an old value or the final value.
    #expect(previous.sorted() == Array(0...200))
  }

  @Test(arguments: TestLockKind.allCases)
  func testConcurrentRemovalDoesNotLoseOrDuplicateItems(kind: TestLockKind) async {
    let atomic = Atomic(Array(0..<100), handle: LockHandle(kind.makeLock()))

    let removed = await withTaskGroup(of: Int?.self, returning: [Int].self) { group in
      for _ in 0..<150 {
        group.addTask { atomic.modify { $0.popLast() } }
      }
      var results: [Int] = []
      for await result in group {
        if let result { results.append(result) }
      }
      return results
    }

    #expect(removed.sorted() == Array(0..<100))
    #expect(atomic.get().isEmpty)
  }

  @Test
  func testGetPreservesValueAndReferenceSemantics() {
    let array = Atomic([1, 2])
    var copy = array.get()
    copy.append(3)
    #expect(array.get() == [1, 2])

    final class Value { var count = 1 }
    let original = Value()
    let reference = Atomic(original)
    #expect(reference.get() === original)
    #expect(reference.exchange(Value()) === original)
  }
}
