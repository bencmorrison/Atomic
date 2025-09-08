// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation

/// A reader-writer lock implementation using pthread_rwlock_t that allows multiple concurrent
/// readers or a single exclusive writer.
///
/// This lock is optimized for scenarios with frequent reads and infrequent writes. Multiple
/// threads can hold read locks simultaneously, but write operations are exclusive and block
/// all other operations.
///
/// Use this when:
/// - You have significantly more reads than writes
/// - Read performance is critical
/// - You don't need recursive locking
///
/// Performance characteristics:
/// - Multiple concurrent readers: ✅ Allowed
/// - Exclusive writer: ✅ Blocks all other operations
/// - Recursive locking: ❌ Not supported
public final class ReaderWriterLock: AtomicLock {
  private var rwLock = pthread_rwlock_t()
  
  public init() {
    pthread_rwlock_init(&rwLock, nil)
  }
  
  deinit {
    pthread_rwlock_destroy(&rwLock)
  }
  
  /// Executes the given action while holding a read lock.
  ///
  /// Multiple threads can execute read operations concurrently. The action will block
  /// if there's an active writer, but multiple readers can proceed simultaneously.
  ///
  /// - Parameter action: The closure to execute while holding the read lock
  /// - Returns: The result of the action closure
  /// - Throws: Any error thrown by the action closure
  public func read<R>(_ action: () throws -> R) rethrows -> R {
    pthread_rwlock_rdlock(&rwLock)
    defer { pthread_rwlock_unlock(&rwLock) }
    return try action()
  }
  
  /// Executes the given action while holding an exclusive write lock.
  ///
  /// Write operations are exclusive - no other reads or writes can occur while
  /// this executes. The action will wait for all current readers to finish before proceeding.
  ///
  /// - Parameter action: The closure to execute while holding the write lock
  /// - Throws: Any error thrown by the action closure
  public func write<T>(_ action: () throws -> T) rethrows -> T {
    pthread_rwlock_wrlock(&rwLock)
    defer { pthread_rwlock_unlock(&rwLock) }
    return try action()
  }
}
