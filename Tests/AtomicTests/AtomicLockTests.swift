import Foundation
import Testing

@testable import Atomic

struct AtomicLockTests {

  @Test(arguments: TestLockKind.allCases)
  func testReadAndWriteReturnResultsAndPropagateErrors(kind: TestLockKind) {
    let lock = kind.makeLock()
    #expect(lock.read { 42 } == 42)
    #expect(lock.write { "result" } == "result")
    #expect(throws: TestFailure.expected) {
      try lock.read { throw TestFailure.expected }
    }
    #expect(throws: TestFailure.expected) {
      try lock.write { throw TestFailure.expected }
    }

    let finished = DispatchSemaphore(value: 0)
    Thread.detachNewThread {
      #expect(lock.write { 100 } == 100)
      finished.signal()
    }
    #expect(finished.wait(timeout: .now() + 5) == .success)
  }

  @Test(arguments: TestLockKind.allCases)
  func testWriterWaitsForReader(kind: TestLockKind) {
    let lock = kind.makeLock()
    let log = TestLog()
    let readerEntered = DispatchSemaphore(value: 0)
    let releaseReader = DispatchSemaphore(value: 0)
    let writerStarted = DispatchSemaphore(value: 0)
    let writerEntered = DispatchSemaphore(value: 0)
    let finished = DispatchGroup()

    finished.enter()
    Thread.detachNewThread {
      defer { finished.leave() }
      lock.read {
        log.append("reader entered")
        readerEntered.signal()
        #expect(releaseReader.wait(timeout: .now() + 5) == .success)
        log.append("reader leaving")
      }
    }
    defer { releaseReader.signal() }
    guard readerEntered.wait(timeout: .now() + 5) == .success else {
      Issue.record("Reader did not acquire its lock")
      return
    }

    finished.enter()
    Thread.detachNewThread {
      defer { finished.leave() }
      writerStarted.signal()
      lock.write {
        log.append("writer entered")
        writerEntered.signal()
      }
    }
    #expect(writerStarted.wait(timeout: .now() + 5) == .success)
    #expect(writerEntered.wait(timeout: .now() + .milliseconds(50)) == .timedOut)
    releaseReader.signal()
    guard finished.wait(timeout: .now() + 5) == .success else {
      Issue.record("Reader and writer did not finish")
      return
    }
    #expect(log.take() == ["reader entered", "reader leaving", "writer entered"])
  }

  @Test(arguments: TestLockKind.allCases)
  func testWriterExcludesReadersAndWriters(kind: TestLockKind) {
    let lock = kind.makeLock()
    let writerEntered = DispatchSemaphore(value: 0)
    let releaseWriter = DispatchSemaphore(value: 0)
    let contenderStarted = DispatchSemaphore(value: 0)
    let contenderEntered = DispatchSemaphore(value: 0)
    let finished = DispatchGroup()

    finished.enter()
    Thread.detachNewThread {
      defer { finished.leave() }
      lock.write {
        writerEntered.signal()
        #expect(releaseWriter.wait(timeout: .now() + 5) == .success)
      }
    }
    defer { releaseWriter.signal() }
    guard writerEntered.wait(timeout: .now() + 5) == .success else {
      Issue.record("Writer did not acquire its lock")
      return
    }

    for write in [false, true] {
      finished.enter()
      Thread.detachNewThread {
        defer { finished.leave() }
        contenderStarted.signal()
        if write {
          _ = lock.write { contenderEntered.signal() }
        } else {
          _ = lock.read { contenderEntered.signal() }
        }
      }
    }
    for _ in 0..<2 {
      #expect(contenderStarted.wait(timeout: .now() + 5) == .success)
    }
    #expect(contenderEntered.wait(timeout: .now() + .milliseconds(50)) == .timedOut)
    releaseWriter.signal()
    #expect(finished.wait(timeout: .now() + 5) == .success)
  }

  @Test(arguments: [TestLockKind.concurrentQueue, .readerWriterLock])
  func testReadersCanOverlap(kind: TestLockKind) {
    let lock = kind.makeLock()
    let entered = DispatchSemaphore(value: 0)
    let release = DispatchSemaphore(value: 0)
    let finished = DispatchGroup()

    for _ in 0..<2 {
      finished.enter()
      Thread.detachNewThread {
        defer { finished.leave() }
        lock.read {
          entered.signal()
          #expect(release.wait(timeout: .now() + 5) == .success)
        }
      }
    }
    // Both readers must enter before either is allowed to leave.
    for _ in 0..<2 {
      #expect(entered.wait(timeout: .now() + 2) == .success)
    }
    for _ in 0..<2 { release.signal() }
    #expect(finished.wait(timeout: .now() + 5) == .success)
  }

  @Test
  func testRecursiveLockAllowsNestedReadsAndWrites() {
    let lock = NSRecursiveLock()
    let result = lock.write {
      lock.read {
        lock.write { 42 }
      }
    }
    #expect(result == 42)
  }
}
