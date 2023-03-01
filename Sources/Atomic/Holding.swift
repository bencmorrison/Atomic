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
    
    func hold() throws {
        lock.writeLock()
        defer { lock.unlock() }
        
        guard !isHolding else { throw HoldingError.holdAlreadyPlaced }
        isHolding = true
    }
    
    func release() throws {
        lock.writeLock()
        defer { lock.unlock() }
        
        guard isHolding else { throw HoldingError.missmatchedReleaseHold }
        isHolding = false
    }
}

enum HoldingError: Error, CustomStringConvertible {
    case holdAlreadyPlaced
    case missmatchedReleaseHold
    
    var isFatal: Bool { true }
    
    var description: String {
        switch self {
        case .holdAlreadyPlaced: return "Fatal Error, hold already placed on object."
        case .missmatchedReleaseHold: return "Fatal Error, no hold to release on object."
        }
    }
}
