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

// Modifies the value
atomic.modify { value in
    value.append(contentsOf: ["Some", "elements"])
}

// Allows you to perform actions againtt a value
// without the value changing
let index = atomic.perform { value in
    value.firstIndex(where: { $0 == "elements" })
}
```
