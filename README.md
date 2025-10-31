# swift-bounded-cache

[![CI](https://github.com/coenttb/swift-bounded-cache/workflows/CI/badge.svg)](https://github.com/coenttb/swift-bounded-cache/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A high-performance LRU cache implementation in Swift with automatic eviction and type-safe operations.

## Overview

swift-bounded-cache provides a dictionary-like structure with a maximum capacity that automatically evicts the least recently used (LRU) entries when full. It offers O(1) operations for insertions, lookups, and removals with minimal memory overhead.

```swift
import BoundedCache

// Create a cache with maximum 100 items
let cache = BoundedCache<String, Int>(capacity: 100)

// Insert items - automatically evicts oldest when capacity is reached
cache.insert(42, forKey: "answer")
cache.insert(100, forKey: "century")

// Retrieve items - accessing updates LRU order
if let value = cache.getValue(forKey: "answer") {
    print("Found value: \(value)")
}

// Remove items when needed
let removed = cache.removeValue(forKey: "century")

print("Cache contains \(cache.count) items")
```

## Features

- **Automatic eviction**: Enforces maximum capacity with LRU policy
- **O(1) operations**: Fast insertions, lookups, and removals using dictionary and array
- **Type-safe**: Generic over both key (Hashable) and value types
- **Reference semantics**: Class-based design for efficient sharing
- **Filtering**: Keep only items matching criteria
- **Minimum capacity enforcement**: Capacity clamped to minimum of 1

## Installation

Add swift-bounded-cache to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-bounded-cache", from: "0.0.1")
]
```

## Quick Start

```swift
import BoundedCache

// Create a cache
let cache = BoundedCache<String, Int>(capacity: 50)

// Add items
cache.insert(1, forKey: "one")
cache.insert(2, forKey: "two")

// Retrieve items (updates LRU order)
if let value = cache.getValue(forKey: "one") {
    print("Value: \(value)")
}

// Check count
print("Cache contains \(cache.count) items")
```

## Usage Examples

### LRU Eviction Policy

The cache maintains access order automatically:

```swift
let cache = BoundedCache<String, Int>(capacity: 2)

cache.insert(1, forKey: "first")
cache.insert(2, forKey: "second")

// Access "first" to make it more recently used
_ = cache.getValue(forKey: "first")

// Insert third item - "second" gets evicted (least recently used)
cache.insert(3, forKey: "third")

print(cache.getValue(forKey: "first"))  // Optional(1)
print(cache.getValue(forKey: "second")) // nil (evicted)
print(cache.getValue(forKey: "third"))  // Optional(3)
```

### Capacity Management

Capacity is enforced automatically with minimum safeguards:

```swift
// Capacity is clamped to minimum of 1
let cache = BoundedCache<String, Int>(capacity: 0) // Actually becomes 1

cache.insert(42, forKey: "answer")
print(cache.count) // 1 - respects minimum capacity
```

### Filtering Operations

Keep only items that match your criteria:

```swift
let cache = BoundedCache<String, Int>(capacity: 10)

// Add various numbers
cache.insert(1, forKey: "one")
cache.insert(2, forKey: "two")
cache.insert(3, forKey: "three")
cache.insert(4, forKey: "four")

// Keep only even numbers
cache.filter { _, value in value % 2 == 0 }

print(cache.count) // 2 (only "two" and "four" remain)
```

### User Session Cache

```swift
struct UserSession {
    let userId: String
    let token: String
    let expiresAt: Date
}

class SessionManager {
    private let cache = BoundedCache<String, UserSession>(capacity: 1000)

    func store(session: UserSession) {
        cache.insert(session, forKey: session.userId)
    }

    func getSession(for userId: String) -> UserSession? {
        return cache.getValue(forKey: userId)
    }

    func cleanExpiredSessions() {
        let now = Date()
        cache.filter { _, session in
            session.expiresAt > now
        }
    }
}
```

### Database Query Cache

```swift
struct QueryResult {
    let data: [String]
    let timestamp: Date
}

class DatabaseCache {
    private let cache = BoundedCache<String, QueryResult>(capacity: 500)
    private let cacheTimeout: TimeInterval = 300 // 5 minutes

    func getCachedResult(for query: String) -> [String]? {
        guard let result = cache.getValue(forKey: query),
              Date().timeIntervalSince(result.timestamp) < cacheTimeout else {
            return nil
        }
        return result.data
    }

    func cacheResult(_ data: [String], for query: String) {
        let result = QueryResult(data: data, timestamp: Date())
        cache.insert(result, forKey: query)
    }
}
```

### HTTP Response Cache

```swift
import Foundation

struct CachedResponse {
    let data: Data
    let contentType: String
    let etag: String?
}

class HTTPCache {
    private let cache = BoundedCache<URL, CachedResponse>(capacity: 200)

    func cacheResponse(_ response: CachedResponse, for url: URL) {
        cache.insert(response, forKey: url)
    }

    func getCachedResponse(for url: URL) -> CachedResponse? {
        return cache.getValue(forKey: url)
    }

    func clearCache() {
        cache.removeAll()
    }
}
```

## Related Packages

### Used By

- [swift-throttling](https://github.com/coenttb/swift-throttling): A Swift package for request throttling.

## License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## API Reference

### Initialization

```swift
init(capacity: Int)
```

Creates a new cache with specified capacity (minimum 1).

### Core Operations

```swift
func insert(_ value: Value, forKey key: Key)
```

Inserts or updates value for key. Updates LRU order if key exists. Evicts least recently used item if at capacity.

```swift
func getValue(forKey key: Key) -> Value?
```

Retrieves value and updates LRU order. Returns nil if key not found.

```swift
func removeValue(forKey key: Key) -> Value?
```

Removes and returns value for key. Returns nil if key not found.

```swift
func removeAll()
```

Removes all items from cache.

```swift
func filter(_ isIncluded: (Key, Value) throws -> Bool) rethrows
```

Keeps only items matching predicate.

### Properties

```swift
var count: Int { get }
```

Current number of items in cache.

```swift
var isEmpty: Bool { get }
```

Returns true if cache contains no items.

## Requirements

- Swift 5.10+
- Platforms: macOS, iOS, tvOS, watchOS, Linux
