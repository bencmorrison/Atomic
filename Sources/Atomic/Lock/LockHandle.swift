// Copyright © 2026 Ben Morrison. All rights reserved.

import Foundation

/// Allocates handle identifiers while protecting the counter with a lock.
private final class LockIdentifier: @unchecked Sendable {
  let lock: NSRecursiveLock = NSRecursiveLock()
  private var currentID: UInt = 0

  func nextId() -> UInt {
    lock.lock()
    defer { lock.unlock() }
    currentID += 1
    return currentID
  }
}

/// Associates a lock with a stable identifier used to order lock acquisition.
///
/// Share the same handle between Atomic instances that use the same underlying lock.
/// Create only one handle per underlying lock. Separate handles for the same lock
/// prevent comparisons from recognising shared locks and can cause deadlocks.
public final class LockHandle: Comparable, Sendable {
  private static let lockIdentifier: LockIdentifier = .init()

  let id: UInt
  let lock: any AtomicLock

  /// Creates a handle with a new ordering identifier for the provided lock.
  /// - Parameter lock: The lock used to protect access to the wrapped values.
  public init(_ lock: any AtomicLock) {
    self.id = Self.lockIdentifier.nextId()
    self.lock = lock
  }

  /// Compares handles by their creation order for consistent lock acquisition.
  /// - Returns: Whether the left handle was assigned an identifier before the right.
  public static func <(lhs: LockHandle, rhs: LockHandle) -> Bool { lhs.id < rhs.id }
  /// Compares the identifiers of two handles, rather than their underlying locks.
  /// - Returns: Whether both values refer to the same handle.
  public static func ==(lhs: LockHandle, rhs: LockHandle) -> Bool { lhs.id == rhs.id }
}
