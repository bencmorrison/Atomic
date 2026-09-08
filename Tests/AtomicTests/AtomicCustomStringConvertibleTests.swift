import Testing

@testable import Atomic

struct AtomicCustomStringConvertibleTests {

  private struct Value: CustomStringConvertible {
    let count: Int
    var log: TestLog? = nil
    var description: String {
      log?.append("format")
      return "Count: \(count)"
    }
  }

  @Test
  func testDescriptionUsesCurrentWrappedValue() {
    let atomic = Atomic(Value(count: 1))
    #expect(String(describing: atomic) == "Count: 1")
    atomic.set(Value(count: 2))
    #expect(atomic.description == "Count: 2")
  }

  @Test
  func testDescriptionRunsUnderReadLock() {
    let log = TestLog()
    let atomic = Atomic(Value(count: 1, log: log), handle: LockHandle(RecordingLock("value", log: log)))
    #expect(atomic.description == "Count: 1")
    #expect(log.take() == ["read value", "format", "release value"])
  }
}
