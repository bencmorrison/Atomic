// Copyright © 2023 Ben Morrison. All rights reserved.

import Foundation

/// A wrapper for the type that allows atomic access and modification of the wrapped value.
public struct Atomic<T> {
    internal let lock = NSRecursiveLock()
    internal var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    /// Atomic getting for the value that has been wrapped for atomic access.
    /// - Returns: The stored value of the defined type
    public func get() -> T {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
    
    /// Sets the wrapped value to the new value.
    /// - Parameter newValue: The value to update the wrapped value to
    public mutating func set(_ newValue: T) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
    
    /// The `modifyAfter(_)` function use a closure to allow operations on the wrapped
    /// value and provide a new value when done working.
    /// - Parameter value: The current value of the wrapped value
    /// - Returns: The value to set the wrapped value to
    public typealias ModifyAfterClosure = (_ value: T) -> T
    
    /// Allows modification to happen to the wrapped value. While the closure
    /// is being executed, the wrapped value is guaranteed to not be changed.
    /// - Parameter closure: The closure that will do the work and return the new
    ///                      value for the wrapped value.
    /// - Returns: The new value of the wrapped value (discardable).
    @available(*, deprecated, renamed: "modifyAfter", message: "Renamed to modifyAfter(_:)")
    @discardableResult
    public mutating func modify(_ closure: ModifyAfterClosure) -> T {
        modifyAfter(closure)
    }
    
    /// Allows modification to happen to the wrapped value. While the closure
    /// is being executed, the wrapped value is guarenteed to not be changed.
    /// - Parameter closure: The closure that will do the work and return the new
    ///                      value for the wrapped value.
    /// - Returns: The new value of the wrapped value (discardable).
    @discardableResult
    public mutating func modifyAfter(_ closure: ModifyAfterClosure) -> T {
        lock.lock()
        defer { lock.unlock() }
        value = closure(value)
        return value
    }
    
    /// The `modifyIn(_)` function use a closure to allow operations on the wrapped
    /// value and modify the value in the closure.
    /// - Parameter value: A refernce to the current wrapped value.
    public typealias ModifingInClosure = (_ value: inout T) -> Void
    
    /// Allows modification to happen to the wrapped value. While the closure
    /// is being executed, the wrapped value is guarenteed to not be changed.
    /// - Parameter closure: The closure that will do the work and return the new
    ///                      value for the wrapped value.
    /// - Returns: The new value of the wrapped value (discardable).
    @discardableResult
    public mutating func modifyIn(_ closure: ModifingInClosure) -> T {
        lock.lock()
        defer { lock.unlock() }
        closure(&value)
        return value
    }
    
    /// The `holdWhile(_:)` function uses a closure to allow operations to happen with
    /// the Atomic value while preventing changes to the value.
    /// - Parameter value: The current value of the wrapped value
    public typealias HoldClosure = (_ value: T) -> ()
    
    /// Allows you to hold the value of the Atomic object while the closure
    /// is being executed. No changes to the value will happen.
    /// - Parameter closure: The closure that is doing the work with the
    ///                      value.
    public func holdWhile(_ closure: HoldClosure) {
        lock.lock()
        defer { lock.unlock() }
        closure(value)
    }
    
    private var isBeingHeld: Bool = false
    
    /// Allows the placement of an indefinite hold on the value while work is being done.
    /// - Note: a `fatalError` will occur when a `hold()` is not matched with a `release()`
    ///         before another hold is called
    /// - Returns: The current value
    public func hold() throws -> T {
        lock.lock()
        assert(!isBeingHeld, "You must call release() before another hold()")
        return value
    }
    
    /// Removes the placement of an indefinite hold on the value while work is being done.
    /// - Note: a `fatalError` will occur when a `hold()` is not matched with a `release()`
    ///         before another hold is called
    public func release() throws {
        assert(isBeingHeld, "You must call hold() before release()")
        lock.unlock()
    }
}
