import Testing

@testable import Atomic

struct AtomicCustomDebugStringConvertibleTests {

  private struct Value: CustomDebugStringConvertible {
    let count: Int
    var log: TestLog? = nil
    var debugDescription: String {
      log?.append("format")
      return "Value(count: \(count))"
    }
  }

  @Test
  func testDebugDescriptionUsesCurrentWrappedValue() {
    let atomic = Atomic(Value(count: 1))
    #expect(String(reflecting: atomic) == "Atomic(Value(count: 1))")
    atomic.set(Value(count: 2))
    #expect(atomic.debugDescription == "Atomic(Value(count: 2))")
  }

  @Test
  func testDebugDescriptionRunsUnderReadLock() {
    let log = TestLog()
    let atomic = Atomic(Value(count: 1, log: log), handle: LockHandle(RecordingLock("value", log: log)))
    #expect(atomic.debugDescription == "Atomic(Value(count: 1))")
    #expect(log.take() == ["read value", "format", "release value"])
  }
}
