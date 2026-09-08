// Copyright © 2023 Ben Morrison. All rights reserved.

import Foundation

/// A wrapper for the type that allows atomic access and modification of the wrapped value.
///
/// Access through this wrapper is protected by its lock handle. If the wrapped value
/// contains references, changes made directly to those objects are not protected.
/// Closures run while the lock is held. Calling back into an Atomic from a closure
/// requires care with lock recursion and the order in which locks are acquired.
public final class Atomic<T>: @unchecked Sendable {
  internal let handle: LockHandle
  internal var value: T

  private var lock: any AtomicLock { handle.lock }

  /// Creates an instance of Atomic that will wrap the provided value.
  /// - Parameters:
  ///   - value: The value that we want to wrap for atomic operations.
  ///   - handle: The lock handle you want to use with Atomic. Share the same handle
  ///             between instances that need to use the same lock. Default: A new
  ///             handle using a concurrent DispatchQueue.
  public init(
    _ value: T,
    handle: LockHandle = .init(DispatchQueue(label: "co.bcm.Atomic", attributes: .concurrent))
  ) {
    self.handle = handle
    self.value = value
  }

  /// Atomic getting for the value that has been wrapped for atomic access.
  /// The read lock is released before the value is returned to the caller.
  /// - Returns: The stored value of the defined type. Reference values are not copied.
  public func get() -> T {
    lock.read { value }
  }

  /// Sets the wrapped value to the new value.
  /// - Parameter newValue: The value to update the wrapped value to
  public func set(_ newValue: T) {
    lock.write { self.value = newValue }
  }

  /// The closure used by `modify(_:)` to change the wrapped value and return a result.
  /// - Parameter value: Mutable access to the current wrapped value.
  /// - Returns: The result of the closure, which does not have to be the wrapped value.
  public typealias ModifyClosure<R> = (_ value: inout T) throws -> R

  /// Allows modification to happen to the wrapped value while holding the write lock.
  /// Other operations using the same handle wait until the closure has finished.
  /// Changes made before an error is thrown are not rolled back.
  /// - Parameter closure: The closure that will modify the value and return a result.
  /// - Returns: The result of the closure. Return the wrapped value explicitly if needed.
  /// - Throws: Any error thrown by the closure.
  @discardableResult
  public func modify<R>(_ closure: ModifyClosure<R>) rethrows -> R {
    try lock.write { try closure(&value) }
  }

  /// The closure used by `perform(_:)` to read the wrapped value and return a result.
  /// - Parameter value: The current wrapped value.
  /// - Returns: The result of the closure, which does not have to be the wrapped value.
  public typealias PerformClosure<R> = (_ value: T) throws -> R

  /// Allows performing an operation while holding the read lock. Writes using the
  /// same handle wait until the closure has finished. Use `modify(_:)` for mutations.
  /// - Parameter closure: The closure that will read the value and return a result.
  /// - Returns: The result of the closure, which does not have to be the wrapped value.
  /// - Throws: Any error thrown by the closure.
  public func perform<R>(_ closure: PerformClosure<R>) rethrows -> R {
    try lock.read { try closure(value) }
  }

  /// Replaces the wrapped value and returns its previous value under one write lock.
  /// Other operations using the same handle cannot run between the read and replacement.
  /// - Parameter newValue: The value to replace the wrapped value with.
  /// - Returns: The value stored before the replacement.
  @discardableResult
  public func exchange(_ newValue: T) -> T {
    lock.write {
      let old = value
      value = newValue
      return old
    }
  }

  /// Compares two wrapped values while acquiring their read locks in handle order.
  /// Shared handles are locked once. The closure receives values in operand order.
  internal static func compare(
    _ lhs: Atomic,
    _ rhs: Atomic,
    using comparison: (T, T) -> Bool
  ) -> Bool {
    if lhs.handle === rhs.handle {
      return lhs.lock.read { comparison(lhs.value, rhs.value) }
    }

    let (first, second) = lhs.handle < rhs.handle ? (lhs, rhs) : (rhs, lhs)
    return first.lock.read {
      second.lock.read {
        comparison(lhs.value, rhs.value)
      }
    }
  }
}
