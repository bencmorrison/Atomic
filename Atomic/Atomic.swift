//
//  Locking.swift
//  Locking
//
//  Created by Ben Morrison on 21/1/18.
//  Copyright © 2018 Benjamin C Morrison. All rights reserved.
//

import Foundation

@propertyWrapper struct Atomic<T> {
    private let lock = NSLock()
    private var _wrappedValue: T
    
    var wrappedValue: T {
        set {
            lock.lock()
            _wrappedValue = newValue
            lock.unlock()
        }
        get {
            var value: T
            
            lock.lock()
            value = _wrappedValue
            lock.unlock()
            
            return value
        }
    }
    
    init(wrappedValue: T) {
        _wrappedValue = wrappedValue
    }
}
