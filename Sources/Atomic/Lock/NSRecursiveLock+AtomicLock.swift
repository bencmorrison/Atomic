// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation

/// Extends NSRecursiveLock to conform to AtomicLock protocol.
///
/// Note: Both read and write operations are exclusive (no concurrent access).
/// This lock allows recursion from the same thread but doesn't provide read concurrency.
/// Consider ReaderWriterLock or DispatchQueue if you need concurrent reads.
extension NSRecursiveLock: AtomicLock {
  public func read<R>(_ action: () throws -> R) rethrows -> R {
    lock()
    defer { unlock() }
    return try action()
  }
  
  public func write<T>(_ action: () throws -> T) rethrows -> T {
    lock()
    defer { unlock() }
    return try action()
  }
}
