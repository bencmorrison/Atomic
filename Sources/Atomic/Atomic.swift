//
//  Atomic.swift
//
//
//  Created by Benjamin Morrison on 12/7/2022.
//

import Foundation

/**
 A wrapper for the type that allows atomic access and modifcation of the wrapped value.
 */
public struct Atomic<T> {
    internal let lock = ReadWriteLock()
    internal var value: T
    
    public init(_ value: T) {
        self.value = value
    }
    
    /**
     Atomic getting for the value that has been wrapped for atomic access.
     - Returns: The stored value of the defined type
     */
    public func get() -> T {
        lock.readLock()
        defer { lock.unlock() }
        return value
    }
    
    /**
     Sets the wrapped value to the new value.
     - Parameter newVaule: The value to update the wrapped value to
     */
    public mutating func set(_ newValue: T) {
        lock.writeLock()
        defer { lock.unlock() }
        value = newValue
    }
    
    /**
     The `modify(_)` function use a closure to allow operations on the wrapped
     value and provide a new value when done working.
     - Parameter value: The current value of the wrapped value
     - Returns: The value to set the wrapped value to
     */
    public typealias ModifingClosure = (_ value: T) -> T
    
    /**
     Allows modification to happen to the wrapped value. While the closure
     is being executed, the wrapped value is guarenteed to not be changed.
     - Parameter closure: The closure that will do the work and return the new
                          value for the wrapped value.
     - Returns: The new value of the wrapped value (discardable).
     */
    @discardableResult
    public mutating func modify(_ closure: ModifingClosure) -> T {
        lock.writeLock()
        defer { lock.unlock() }
        value = closure(value)
        return value
    }
}
