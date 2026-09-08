// Copyright © 2026 Ben Morrison. All rights reserved.

extension Atomic: Equatable where T: Equatable {
  /// Compares the wrapped values while holding their read locks in handle order.
  /// A shared handle is locked once. Equality uses the wrapped values, even when
  /// both operands refer to the same Atomic instance.
  /// Call this outside locked closures, and ensure the wrapped comparison does not
  /// reenter Atomic operations, to avoid recursive locking or lock order conflicts.
  /// - Returns: Whether the wrapped values are equal.
  public static func ==(lhs: Atomic, rhs: Atomic) -> Bool {
    compare(lhs, rhs, using: ==)
  }
  /// Compares the wrapped value with another value while holding its read lock.
  /// - Returns: Whether the values are equal.
  public static func ==(lhs: Atomic, rhs: T) -> Bool { lhs.perform { $0 == rhs} }
  /// Compares a value with the wrapped value while holding its read lock.
  /// - Returns: Whether the values are equal.
  public static func ==(lhs: T, rhs: Atomic) -> Bool { rhs.perform { lhs == $0} }
}
