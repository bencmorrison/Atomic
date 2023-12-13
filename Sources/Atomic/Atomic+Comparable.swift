// Copyright © 2023 Ben Morrison. All rights reserved.

import Foundation

extension Atomic: Comparable where T: Comparable {
    public static func < (lhs: Atomic<T>, rhs: Atomic<T>) -> Bool {
        lhs.lock.readLock()
        rhs.lock.readLock()
        defer {
            lhs.lock.unlock()
            rhs.lock.unlock()
        }

        return lhs.value < rhs.value
    }
}
