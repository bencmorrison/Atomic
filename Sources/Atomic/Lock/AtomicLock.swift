// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation

/// Allows for any lock to be used that conforms to this protocol with the Atomic type.
public protocol AtomicLock {
  /// This will be called by `Atomic` when a read action is being performed.
  /// The provided locking system should lock for a read.
  /// - Parameter action: The read action being performed. This should be called
  ///                     after the lock is ready but before releasing.
  /// - Returns: Returns the value from the action closure.
  func read<R>(_ action: () throws -> R) rethrows -> R
  
  /// This will be called by `Atomic` when a write acton is being performed.
  /// The provided locking system should lock for a write.
  /// - Parameter action: The write action being performed.
  ///                     This should be called after the lock is ready but before releasing.
  /// - Returns: The value returned from the action closure.
  func write<T>(_ action: () throws -> T) rethrows -> T
}
