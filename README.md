# Atomic

Atomic is a wrapper for accessing a value atomically. Atomic is mostly just a random project that scratches an itch.

## Swift Package

This is now a Swift Package!

## `Atomic<T>`

This is the main Atomic class that allows you to wrap a value for atomic usage. Reads and writes through the wrapper are protected by a lock. Changes made directly to objects referenced by the wrapped value are not protected.

### Usage

```swift
import Atomic

// Create an atomic string
let atomic = Atomic<String>("Atomic String")

// Gets the current value
let value = atomic.get()

// Sets the atomic value to the passed in value
atomic.set("New Atomic String")

// Modifies the value
atomic.modify { value in
    value.append(" with more text")
}

// Reads the value while holding the read lock
let index = atomic.perform { value in
    value.firstIndex(of: " ")
}

// Replaces the value and returns the previous value under one write lock
let previous = atomic.exchange("Replacement String")
```

### Returning a result from modify

`modify` gives the closure mutable access under the write lock and returns the closure's result. To receive the updated value, return it explicitly. A closure without a return value returns `Void`.

```swift
let pending = Atomic(["First", "Second"])

// Removes and returns an item under one write lock
let next = pending.modify { items in
    items.isEmpty ? nil : items.removeFirst()
}
```

Both `modify` and `perform` propagate errors thrown by their closures. Changes made in `modify` before an error is thrown are not rolled back.

### Sharing a lock

Each Atomic creates its own handle using a concurrent DispatchQueue by default. To use a custom lock, create a `LockHandle`. Share that handle between instances that need the same lock.

```swift
import Foundation

let handle = LockHandle(NSRecursiveLock())
let first = Atomic(10, handle: handle)
let second = Atomic(20, handle: handle)
```

Create only one handle per underlying lock. Wrapping the same lock in separate handles prevents comparisons from recognising that the lock is shared.

Closures passed to `perform` and `modify` execute while a lock is held. Calling Atomic operations from inside those closures can reenter a lock or acquire locks in an inconsistent order, causing deadlocks.

### Protocol support

- `Equatable` compares wrapped values while holding their read locks in handle order. Shared handles are locked once. Call comparisons outside locked closures, and ensure wrapped equality does not reenter Atomic operations.
- `Comparable` uses the same ordered locking as `Equatable`, while preserving operand order when comparing values. The same restrictions on comparisons inside locked closures apply. Values changing between comparisons can still make sorting inconsistent.
- `Encodable` and `Decodable` are available independently when the wrapped type supports them. Only the value is encoded. Decoding creates a new default handle.
- `CustomStringConvertible` and `CustomDebugStringConvertible` are available when the wrapped type supports the corresponding protocol. Formatting runs under the read lock.
- `Identifiable` identifies the Atomic instance, with identity stable for its lifetime. Changing its value does not change its identity.

### Tests

The tests use Swift Testing. Run them with `swift test`.
