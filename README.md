# Atomic

Atomic is a thread safe structure for accessing a value atomically. Atomic is mostly just a random project that scratches an itch.

## Swift Package

This is now a Swift Package!

## `Atomic<T>`

This is the main Atomic class that allows you to wrap a value for atomic usage. It allows for the most thread safe interactions with the wrapped value.

### Usage

```swift
// Create an atomic string
let atomic = Atomic<String>("Atomic String")

// Gets the current value
let value = atomic.get() 

// Sets the atomic value to the passed in value
atomic.set("New Atomic String")

/*
 Allows extended work to happen with the value and
 ensures the value will not be changed while the 
 modify is running.

 The atomic value will be set to the returns of 
 the closure.

 The `holdWhile(_)` function has a similar function
 but the value has no modifcations.
 */
atomic.modifyAfter { value in 
    if value == "New Atomic String" {
        return "New " + value
    } else {
        return "Well New String Again"
    }
}

/*
 Allows modifying of the atomic value directly. Useful for
 things like collections. It does not return anything.
*/

atomic.modifyIn { value in 
    value.append(contentsOf: ["Some", "elements"])
}

/*
 Allows multiple Atomics to have work done with their
 values while ensuring the values do not change. 

 Must be paired with a `release()` after work is done.
 */
let value1 = atomic.hold()
let value2 = atomic2.hold()

// do work with value1 and value 2

atomic.release()
atomic2.release()

```

## `SimpleAtomic<T>`

This is a `propertyWrapper` that is very simplified atomic wrapper. It allows atomic get and set access but does not include all the features of `Atomic<T>`

### Usage 

```swift
// Create a Simple Atomic
@SimpleAtomic var atomic = "Another Atomic String"

// Gets the value atomically
print(atomic)

// Sets the value atomically
atomic = "New Another Atomic String"

```

### Do Not Do
```swift
@SimpleAtomic var atomic = "Another Atomic String"

// LATER
if atomic == "Another Atomic String" {
    atomic = "Modifying " + atomic
} else {
    atomic = atomic + ". YAY!"
}
```

The result of the assigment is not guarenteed to tbe the same value as the check in the if statement.
