//
//  File.swift
//  
//
//  Created by Benjamin Morrison on 19/7/2022.
//

import Foundation

@propertyWrapper struct SimpleAtomic<T> {
    internal var value: Atomic<T>
    
    public var wrappedValue: T {
        get { value.get() }
        set { value.set(newValue) }
    }
    
    public init(wrappedValue value: T) {
        self.value = Atomic<T>(value)
    }
}
