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
    
    /**
     The `holdWhile(_:)` function uses a closure to allow operations to happen with
     the Atomic value while preventing changes to the value.
     - Parameter value: The current value of the wrapped value
     */
    public typealias HoldClosure = (_ value: T) -> ()
    
    /**
     Allows you to hold the value of the Atomic object while the closure
     is being executed. No changes to the value will happen.
     - Parameter closure: The closure that is doing the work with the
                          value.
     */
    public func holdWhile(_ closure: HoldClosure) {
        lock.readLock()
        defer { lock.unlock() }
        closure(value)
    }
    
    
    private let holding = Holding()
    
    /**
     Allows the placement of an indefinate hold on the value while work is being done.
     - Note: a `fatalError` will occure when a `hold()` is not matched with a `release()`
             before another hold is called
     - Returns: The current value
     */
    @discardableResult
    public mutating func hold() -> T {
        lock.readLock()
        guard holding.placeHold() else { fatalError("Atomic is already holding the value") }
        return value
    }
    
    /**
     Removes the placement of an indefinate hold on the value while work is being done.
     - Note: a `fatalError` will occure when a `hold()` is not matched with a `release()`
             before another hold is called
     */
    public mutating func release() {
        guard holding.removeHold() else { fatalError("Atomic is not already holding the value") }
        lock.unlock()
    }
}
