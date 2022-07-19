//
//  File.swift
//  
//
//  Created by Benjamin Morrison on 19/7/2022.
//

import Foundation

internal final class Holding {
    private let lock = ReadWriteLock()
    private var isHolding: Bool = false
    
    func placeHold() -> Bool {
        lock.writeLock()
        defer { lock.unlock() }
        
        guard !isHolding else { return false }
        isHolding = true
        return true
    }
    
    func removeHold() -> Bool {
        lock.writeLock()
        defer { lock.unlock() }
        
        guard isHolding else { return false }
        isHolding = false
        return true
    }
}
