import Foundation

@testable import Atomic

enum TestLockKind: CaseIterable, Sendable {
  case serialQueue
  case concurrentQueue
  case recursiveLock
  case readerWriterLock

  func makeLock() -> any AtomicLock {
    switch self {
    case .serialQueue: DispatchQueue(label: "test.serial")
    case .concurrentQueue: DispatchQueue(label: "test.concurrent", attributes: .concurrent)
    case .recursiveLock: NSRecursiveLock()
    case .readerWriterLock: ReaderWriterLock()
    }
  }
}

enum TestFailure: Error, Equatable {
  case expected
}

// Uses its own lock so observations do not depend on the Atomic being tested.
final class TestLog: @unchecked Sendable {
  private let lock = NSLock()
  private var entries: [String] = []

  func append(_ entry: String) {
    lock.lock()
    defer { lock.unlock() }
    entries.append(entry)
  }

  func take() -> [String] {
    lock.lock()
    defer { lock.unlock() }
    let result = entries
    entries = []
    return result
  }
}

final class RecordingLock: AtomicLock {
  let name: String
  let log: TestLog
  private let lock = NSRecursiveLock()

  init(_ name: String, log: TestLog) {
    self.name = name
    self.log = log
  }

  func read<R>(_ action: () throws -> R) rethrows -> R {
    try lock.read {
      log.append("read \(name)")
      defer { log.append("release \(name)") }
      return try action()
    }
  }

  func write<R>(_ action: () throws -> R) rethrows -> R {
    try lock.write {
      log.append("write \(name)")
      defer { log.append("release \(name)") }
      return try action()
    }
  }
}

struct RecordingValue: Comparable {
  let value: Int
  let log: TestLog

  static func ==(lhs: RecordingValue, rhs: RecordingValue) -> Bool {
    lhs.log.append("equality")
    return lhs.value == rhs.value
  }

  static func <(lhs: RecordingValue, rhs: RecordingValue) -> Bool {
    lhs.log.append("ordering")
    return lhs.value < rhs.value
  }
}
