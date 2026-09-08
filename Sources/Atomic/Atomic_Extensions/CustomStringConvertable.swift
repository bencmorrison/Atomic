// Copyright © 2026 Ben Morrison. All rights reserved.

extension Atomic: CustomStringConvertible where T: CustomStringConvertible {
  /// The wrapped value's description, created while holding the read lock.
  public var description: String { perform { String(describing: $0) }}
}

extension Atomic: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
  /// The wrapped value's debug description enclosed in `Atomic(...)`.
  /// The description is created while holding the read lock.
  public var debugDescription: String { perform { "Atomic(\(String(reflecting: $0)))" }}
}
