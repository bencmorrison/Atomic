import Foundation
import Testing

@testable import Atomic

struct LockHandleTests {

  @Test
  func testIdentityAndCreationOrder() {
    let first = LockHandle(NSRecursiveLock())
    let alias = first
    let second = LockHandle(NSRecursiveLock())
    let third = LockHandle(NSRecursiveLock())

    #expect(first == alias)
    #expect(first != second)
    #expect(first < second)
    #expect(second < third)
    #expect(first < third)
    #expect(!(first < first))
    #expect(!(second < first))
  }

  @Test
  func testConcurrentCreationProducesUniqueIdentifiers() async {
    let handles = await withTaskGroup(of: LockHandle.self, returning: [LockHandle].self) { group in
      for _ in 0..<500 {
        group.addTask { LockHandle(NSRecursiveLock()) }
      }
      var results: [LockHandle] = []
      for await handle in group { results.append(handle) }
      return results
    }

    #expect(Set(handles.map(\.id)).count == 500)
    let ordered = handles.sorted()
    for (first, second) in zip(ordered, ordered.dropFirst()) {
      #expect(first < second)
    }
  }
}
