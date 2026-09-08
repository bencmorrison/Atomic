import Foundation
import Testing

@testable import Atomic

struct AtomicIdentifiableTests {

  @Test
  func testIdentitySurvivesMutations() {
    let atomic = Atomic(1)
    let alias = atomic
    let id = atomic.id

    atomic.set(2)
    atomic.modify { $0 += 1 }
    atomic.exchange(4)

    #expect(atomic.id == id)
    #expect(alias.id == id)
    #expect(id == ObjectIdentifier(atomic))
  }

  @Test
  func testEqualValuesAndSharedHandlesHaveSeparateIdentities() {
    let handle = LockHandle(NSRecursiveLock())
    let first = Atomic(42, handle: handle)
    let second = Atomic(42, handle: handle)

    #expect(first == second)
    #expect(first.id != second.id)
  }
}
