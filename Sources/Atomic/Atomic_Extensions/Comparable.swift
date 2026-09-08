// Copyright © 2026 Ben Morrison. All rights reserved.

extension Atomic: Comparable where T: Comparable {
  /// Compares the wrapped values while holding their read locks in handle order.
  /// A shared handle is locked once. Values are compared in operand order.
  /// Call this outside locked closures, and ensure the wrapped comparison does not
  /// reenter Atomic operations, to avoid recursive locking or lock order conflicts.
  /// - Returns: Whether the left wrapped value is less than the right wrapped value.
  public static func <(lhs: Atomic<T>, rhs: Atomic<T>) -> Bool {
    compare(lhs, rhs, using: <)
  }
  /// Compares the wrapped value with another value while holding its read lock.
  /// - Returns: Whether the wrapped value is less than the provided value.
  public static func <(lhs: Atomic, rhs: T) -> Bool { lhs.perform { $0 < rhs} }
  /// Compares a value with the wrapped value while holding its read lock.
  /// - Returns: Whether the provided value is less than the wrapped value.
  public static func <(lhs: T, rhs: Atomic) -> Bool { rhs.perform { lhs < $0} }

}
