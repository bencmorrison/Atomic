// Copyright © 2025 Ben Morrison. All rights reserved.

import Foundation

/// Extends DispatchQueue to conform to AtomicLock protocol.
///
/// Behavior depends on queue type:
/// - **Concurrent queues**: Reads can execute in parallel, writes use barriers for exclusivity
/// - **Serial queues**: All operations execute sequentially, barrier flag has no effect
///
/// Use concurrent queues when you want reader-writer behavior similar to ReaderWriterLock.
/// Use serial queues when you want simple sequential access with Swift-friendly error handling.
extension DispatchQueue: AtomicLock {
  public func read<R>(_ action: () throws -> R) rethrows -> R {
    return try sync(execute: action)
  }
  
  public func write<T>(_ action: () throws -> T) rethrows -> T {
    try sync(flags: .barrier, execute: action)
  }
}
