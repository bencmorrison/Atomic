//
//  Locking+Operators.swift
//  Locking
//
//  Created by Ben Morrison on 21/1/18.
//  Copyright © 2018 Benjamin C Morrison. All rights reserved.
//

import Foundation


extension Locking {
    /**
     Allows you to assign the value of one `Locking<T>` to another's value.
     
     - Parameters:
        - lhs: `inout` `Locking<T>` that is assigned the `rhs`'s value.
        - rhs: The value holder for `lhs.value`
     */
    static func <=(lhs: inout Locking<T>, rhs: Locking<T>) {
        lhs.value = rhs.value
    }
    
    /**
     Assigns the right hand side to the value of the left hand side.
     
     - Parameters:
        - lhs: `inout` `Locking<T>`
        - rhs: The value to be assigned to `lhs.value`
     */
    static func <=(lhs: inout Locking<T>, rhs: T) {
        lhs.value = rhs
    }
    
    /**
     Assigns the right hand side's value to the variable on the left hand side.
     
     - Parameters:
        - lhs: `inout` `T`
        - rhs: The `Locking<T>` who's value is assigned to the `lhs`
     */
    static func <=(lhs: inout T, rhs: Locking<T>) {
        lhs = rhs.value
    }
    
    /**
     Assigns the right hand side's value to the variable on the left hand side when both are optional.
     
     - Parameters:
        - lhs: `inout` `T?`
        - rhs: `Locking<T?>`
     */
    static func <=(lhs: inout T?, rhs: Locking<T?>) {
        lhs = rhs.value
    }
}
