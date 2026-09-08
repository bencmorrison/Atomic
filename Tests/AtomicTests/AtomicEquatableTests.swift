import Foundation
import Testing

@testable import Atomic

struct AtomicEquatableTests {

  @Test
  func testComparisonsWithSharedHandle() {
    let handle = LockHandle(DispatchQueue(label: "test.comparison.shared"))
    let first = Atomic(10, handle: handle)
    let equal = Atomic(10, handle: handle)
    let greater = Atomic(20, handle: handle)

    #expect(first == first)
    #expect(first == equal)
    #expect(equal == first)
    #expect(!(first == greater))
  }

  @Test
  func testComparisonsPreserveOperandOrder() {
    let firstHandle = LockHandle(DispatchQueue(label: "test.comparison.first"))
    let secondHandle = LockHandle(DispatchQueue(label: "test.comparison.second"))
    let greater = Atomic(20, handle: firstHandle)
    let lesser = Atomic(10, handle: secondHandle)

    #expect(!(lesser == greater))
    #expect(!(greater == lesser))

    lesser.set(20)
    #expect(lesser == greater)
    #expect(greater == lesser)
  }

  @Test
  func testSelfComparisonPreservesWrappedEquality() {
    let handle = LockHandle(DispatchQueue(label: "test.comparison.nan"))
    let atomic = Atomic(Double.nan, handle: handle)

    #expect(!(atomic == atomic))
  }

  @Test
  func testConcurrentReversedComparisons() async {
    let first = Atomic(10, handle: LockHandle(NSRecursiveLock()))
    let second = Atomic(20, handle: LockHandle(NSRecursiveLock()))

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<100 {
        group.addTask {
          #expect(!(first == second))
        }
        group.addTask {
          #expect(!(second == first))
        }
      }
    }
  }


  @Test(arguments: TestLockKind.allCases)
  func testWrappedAndPlainValues(kind: TestLockKind) {
    let atomic = Atomic(10, handle: LockHandle(kind.makeLock()))
    #expect(atomic == 10)
    #expect(10 == atomic)
    #expect(!(atomic == 20))
    #expect(!(20 == atomic))
    atomic.set(20)
    #expect(atomic == 20)
    #expect(20 == atomic)
  }

  @Test
  func testComparisonAcquiresBothLocksInCreationOrder() {
    let log = TestLog()
    let first = Atomic(RecordingValue(value: 10, log: log), handle: LockHandle(RecordingLock("first", log: log)))
    let second = Atomic(RecordingValue(value: 20, log: log), handle: LockHandle(RecordingLock("second", log: log)))
    let expected = ["read first", "read second", "equality", "release second", "release first"]

    _ = first == second
    #expect(log.take() == expected)
    _ = second == first
    #expect(log.take() == expected)
  }

  @Test
  func testSharedHandleIsAcquiredOnlyOnce() {
    let log = TestLog()
    let handle = LockHandle(RecordingLock("shared", log: log))
    let first = Atomic(10, handle: handle)
    let second = Atomic(20, handle: handle)

    _ = first == second
    #expect(log.take() == ["read shared", "release shared"])
    _ = first == first
    #expect(log.take() == ["read shared", "release shared"])
  }

  @Test(arguments: TestLockKind.allCases)
  func testSharedAndSeparateHandles(kind: TestLockKind) {
    let shared = LockHandle(kind.makeLock())
    let first = Atomic(10, handle: shared)
    let equal = Atomic(10, handle: shared)
    let greater = Atomic(20, handle: LockHandle(kind.makeLock()))
    #expect(first == equal)
    #expect(equal == first)
    #expect(!(first == greater))
    #expect(!(greater == first))
  }
}
