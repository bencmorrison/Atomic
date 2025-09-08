// Copyright © 2023 Ben Morrison. All rights reserved.

import Foundation

/// A wrapper for the type that allows atomic access and modification of the wrapped value.
public final class Atomic<T> {
  internal let lock: any AtomicLock
  internal var value: T
  
  /// Creates an instance of Atomic that will wrap the provided value.
  /// - Parameters:
  ///   - value: The value that we want to wrap for atomic operations.
  ///   - lock: The AtomicLock you want to use with Atomic.
  ///           DispatchQueue and NSRecursiveLock are prime examples. There is also
  ///           `ReaderWriterLock` as well. Default: DispatchQueue
  public init(
    _ value: T,
    lock: any AtomicLock = DispatchQueue(label: "co.bcm.Atomic", attributes: .concurrent)
  ) {
    self.lock = lock
    self.value = value
  }
  
  /// Atomic getting for the value that has been wrapped for atomic access.
  /// - Returns: The stored value of the defined type
  public func get() -> T {
    lock.read { value }
  }
  
  /// Sets the wrapped value to the new value.
  /// - Parameter newValue: The value to update the wrapped value to
  public func set(_ newValue: T) {
    lock.write { self.value = newValue }
  }
  
  /// The `modify(_)` function uses a closure to allow operations on the wrapped
  /// value and modify the value in the closure.
  /// - Parameter value: A reference to the current wrapped value.
  public typealias ModifyClosure = (_ value: inout T) throws -> Void
  
  /// Allows modification to happen to the wrapped value. While the closure
  /// is being executed, the wrapped value is guaranteed to not be changed.
  /// - Parameter closure: The closure that will do the work and return the new
  ///                      value for the wrapped value.
  /// - Returns: The value after modification.
  @discardableResult
  public func modify(_ closure: ModifyClosure) rethrows -> T {
    try lock.write {
      try closure(&value)
      return value
    }
  }

  /// The `perform(_)` function uses a closure to allow operations on the wrapped
  /// value and modify the value in the closure.
  /// - Parameter value: A reference to the current wrapped value.
  public typealias PerformClosure = (_ value: T) throws -> Void
  
  /// Allows performing an operation while using the wrapped value. Durning
  /// the time the closure is being run, the value is guaranteed to not change.
  /// - Parameter closure: The closure that will do the work.
  public func perform(_ closure: PerformClosure) rethrows {
    try lock.read { try closure(value) }
  }
}
