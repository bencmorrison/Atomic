// Copyright © 2026 Ben Morrison. All rights reserved.

/// Identifies the Atomic instance using its ObjectIdentifier.
/// Identity is stable for the instance's lifetime and does not change with its value.
/// Separate instances have different identities, even when their values are equal.
extension Atomic: Identifiable {}
