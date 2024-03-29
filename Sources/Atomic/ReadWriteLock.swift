// Copyright © 2023 Ben Morrison. All rights reserved.

import Foundation

internal final class ReadWriteLock {
    private var pThreadLock: pthread_rwlock_t
    
    init() {
        pThreadLock = pthread_rwlock_t()
        pthread_rwlock_init(&pThreadLock, nil)
    }
    
    deinit {
        pthread_rwlock_destroy(&pThreadLock)
    }
    
    func readLock() {
        pthread_rwlock_rdlock(&pThreadLock)
    }
    
    func writeLock() {
        pthread_rwlock_wrlock(&pThreadLock)
    }
    
    func unlock() {
        pthread_rwlock_unlock(&pThreadLock)
    }
}
