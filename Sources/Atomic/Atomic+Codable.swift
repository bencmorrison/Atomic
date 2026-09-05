// Copyright © 2025 Ben Morrison. All rights reserved.

extension Atomic: Codable where T: Codable {
  public convenience init(from decoder: any Decoder) throws {
    let value = try T(from: decoder)
    self.init(value)
  }
  
  public func encode(to encoder: any Encoder) throws {
    try perform { try $0.encode(to: encoder) }
  }
}
