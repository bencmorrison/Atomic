//
//  File.swift
//  
//
//  Created by Benjamin Morrison on 12/7/2022.
//

import Foundation

extension Atomic: Codable where T: Codable {
    private enum CodingKeys: CodingKey {
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(T.self, forKey: .value)
        self.init(value)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
    }
}
