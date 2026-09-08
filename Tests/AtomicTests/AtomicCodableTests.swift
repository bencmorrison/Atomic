import Foundation
import Testing

@testable import Atomic

struct AtomicCodableTests {

  private struct Record: Codable, Equatable {
    let name: String
    let values: [Int]
  }

  private struct EncodeOnly: Encodable {
    let value: Int
  }

  private struct DecodeOnly: Decodable {
    let value: Int
  }

  private struct FailingValue: Codable {
    init() {}
    init(from decoder: any Decoder) throws { throw TestFailure.expected }
    func encode(to encoder: any Encoder) throws { throw TestFailure.expected }
  }

  @Test
  func testRoundTripUsesWrappedRepresentation() throws {
    let record = Record(name: "Atomic", values: [1, 2, 3])
    let original = Atomic(record, handle: LockHandle(NSRecursiveLock()))
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys

    let data = try encoder.encode(original)
    let wrappedData = try encoder.encode(record)
    #expect(data == wrappedData)
    let decoded = try JSONDecoder().decode(Atomic<Record>.self, from: data)
    #expect(decoded.get() == record)
    #expect(decoded.handle !== original.handle)
    decoded.modify { $0 = Record(name: "Changed", values: []) }
    #expect(original.get() == record)
  }

  @Test
  func testIndependentEncodingAndDecodingConformances() throws {
    let data = try JSONEncoder().encode(Atomic(EncodeOnly(value: 42)))
    let decoded = try JSONDecoder().decode(Atomic<DecodeOnly>.self, from: data)
    #expect(decoded.get().value == 42)
  }

  @Test
  func testOptionalRoundTrip() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let data = try encoder.encode(Atomic<Int?>(nil))
    #expect(String(decoding: data, as: UTF8.self) == "null")
    #expect(try decoder.decode(Atomic<Int?>.self, from: data).get() == nil)
    let present = try encoder.encode(Atomic<Int?>(42))
    #expect(try decoder.decode(Atomic<Int?>.self, from: present).get() == 42)
  }

  @Test
  func testInvalidValueFailsDecoding() {
    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(Atomic<Int>.self, from: Data("\"text\"".utf8))
    }
  }

  @Test
  func testWrappedErrorsPropagate() {
    #expect(throws: TestFailure.expected) {
      try JSONDecoder().decode(Atomic<FailingValue>.self, from: Data("{}".utf8))
    }
    #expect(throws: TestFailure.expected) {
      try JSONEncoder().encode(Atomic(FailingValue()))
    }
  }

  @Test(arguments: TestLockKind.allCases)
  func testEncodingErrorReleasesLock(kind: TestLockKind) {
    let atomic = Atomic(FailingValue(), handle: LockHandle(kind.makeLock()))
    #expect(throws: TestFailure.expected) { try JSONEncoder().encode(atomic) }

    let finished = DispatchSemaphore(value: 0)
    Thread.detachNewThread {
      atomic.set(FailingValue())
      finished.signal()
    }
    #expect(finished.wait(timeout: .now() + 5) == .success)
  }
}
