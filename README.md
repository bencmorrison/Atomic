# Locking
Simple and Thread safe structures

# Examples
### Creating an imutable lock
```swift
let lock = Locking<Int>(value: 12)
```

### Crating a mutable lock
```swift
var lock2 = Locking<String?>(value: "OMG")
lock2 <= "OMG2" // New Value for lock2
```

### Asinging Values to Locks and to varables
```swift
var str: String = "nil"
str <= lock2

lock2 <= str
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

