// Copyright © 2025 Ben Morrison. All rights reserved.

extension Atomic: Decodable where T: Decodable {
  /// Decodes the wrapped value and creates an Atomic with a new default lock handle.
  /// - Parameter decoder: The decoder to read the wrapped value from.
  /// - Throws: Any error thrown while decoding the wrapped value.
  public convenience init(from decoder: any Decoder) throws {
    let value = try T(from: decoder)
    self.init(value)
  }
}

extension Atomic: Encodable where T: Encodable {
  /// Encodes the wrapped value while holding the read lock. The handle is not encoded.
  /// - Parameter encoder: The encoder to write the wrapped value to.
  /// - Throws: Any error thrown while encoding the wrapped value.
  public func encode(to encoder: any Encoder) throws {
    try perform { try $0.encode(to: encoder) }
  }
}
