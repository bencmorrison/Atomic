// Copyright © 2023 Ben Morrison. All rights reserved.

import Foundation

extension Atomic: Comparable where T: Comparable {
    public static func < (lhs: Atomic<T>, rhs: Atomic<T>) -> Bool {
        lhs.lock.lock()
        rhs.lock.lock()
        defer {
            lhs.lock.unlock()
            rhs.lock.unlock()
        }

        return lhs.value < rhs.value
    }
}
