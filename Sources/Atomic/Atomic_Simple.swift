// Copyright © 2023 Ben Morrison. All rights reserved.

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
