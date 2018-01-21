//
//  Locking.swift
//  Locking
//
//  Created by Ben Morrison on 21/1/18.
//  Copyright © 2018 Benjamin C Morrison. All rights reserved.
//

import Foundation

/**
 Wraps a type in a queue to perform serial operations on that value. This allows for many thread access to the wrapped value without worry of it being changed randomly.
 */
struct Locking<T>: CustomStringConvertible {
    // MARK: - Private Instance Variables
    private var _value: T
    private let queue = DispatchQueue(label: "com.bencmorrson.locking<t>",
                                      qos: .default,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .inherit,
                                      target: nil)
    init(_ value: T) {
        self._value = value
    }
    
    /**
     Sets and returns the stored value synchronously.
     */
    var value: T {
        get {
            var val: T!
            
            queue.sync {
                val = _value
            }
            
            return val
        }
        set {
            queue.sync {
                self._value = newValue
            }
        }
    }
    
    // MARK: - Operational Functions
    /**
     Used for the `ensure(_:)` function.
     - Parameter startValue: The ensured value for duration of the ensure block run.
     - Returns: The new value that the stored value should be.
     */
    typealias EnsureBlock = (_ startValue: T) -> T
    
    /**
     The `ensure(_)` allows you to perform complext operations on and around the locked value without fear of it changing.
     */
    @discardableResult mutating func ensure(performBlock: EnsureBlock) -> T {
        var newValue: T!
        
        queue.sync {
            let preVal = self._value
            newValue = performBlock(preVal)
            self._value = newValue
        }
        
        return newValue
    }
    
    /**
     Used in the `compare(_:)` function to comparing the values between two `Locking<T>`.
     - Parameters:
        - lhs: The Left Hand Side of the compare
        - rhs: The Right Hand Side of the compare
     - Returns: The results of the comparison.
     */
    typealias CompareBlock = (_ lhs: T, _ rhs: T) -> Bool
    
    /**
     Compares the current `Locking<T>` with another `Locking<T>`
     
     - Parameters:
        - with: The locked object you are comparing withis. This will be the rhs.
        - comparisonBlock: The closure that defines the comparison rules for the lhs and rhs.
     - Returns: The results of the comparison.
     */
    func compare(with: Locking<T>, comparisonBlock: CompareBlock) -> Bool {
        var retVal = false
        
        queue.sync {
            retVal = comparisonBlock(self._value, with.value)
        }
        
        return retVal
    }
    
    //MARK: - CustomStringConvertible
    var description: String {
        return String(describing: _value)
    }
}
