import Testing

@testable import Atomic

struct AtomicSendableTests {

  @Test
  func testSendableConformance() async {
    // Test that Atomic<Sendable> is Sendable and can be passed across concurrency boundaries
    let atomicInt = Atomic(42)
    let atomicString = Atomic("Hello")
    let atomicArray = Atomic([1, 2, 3])

    await Task {
      // These should compile without warnings when T is Sendable
      let value1 = atomicInt.get()
      let value2 = atomicString.get()
      let value3 = atomicArray.get()

      #expect(value1 == 42)
      #expect(value2 == "Hello")
      #expect(value3 == [1, 2, 3])
    }.value
  }

  @Test
  func testDetachedTaskMutatesTheSameInstance() async {
    func requireSendable<Value: Sendable>(_ value: Value) -> Value { value }
    let atomic = requireSendable(Atomic([1, 2]))

    let count = await Task.detached {
      atomic.modify { values in
        values.append(3)
        return values.count
      }
    }.value

    #expect(count == 3)
    #expect(atomic.get() == [1, 2, 3])
  }
}
