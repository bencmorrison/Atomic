# Locking
Simple and Thread safe structures

# Examples
### Creating a lock
```swift
let lockedInt = Locking<Int>(value: 12)
```

#### Locks also support optionals
```swift
var lockedString = Locking<String?>(value: "OMG")
```

### Asinging Values to Locks and to varables
```swift
var str: String? = nil
var strLock = Locking<String?>(value: "Test String")

str <= strLock // str now is an optional string with the value "Test String"

str = "Another Test String"
strLock <= str // strLock now is an optional string with the value "Another Test String"
```

# Functions
## Ensure
Ensures the value is the same durning the entire operation (good for multiple accesses)
``` swift
var lock3 = Locking<Int>(value: 13)
lock3.ensure { $0 + 100 }
```

## Compare
Compares to Locks
```swift
let isLessThan = lock.compare(with: lock3) { $0 < $1 }
```

