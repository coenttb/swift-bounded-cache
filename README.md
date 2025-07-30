# swift-bounded-cache

<p align="center">
  <img src="https://img.shields.io/badge/Swift-5.10-orange.svg" alt="Swift 5.10">
  <img src="https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-lightgray.svg" alt="Platforms">
  <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/Release-0.0.1-green.svg" alt="Release">
</p>

<p align="center">
  <strong>A high-performance LRU cache implementation in Swift</strong><br>
  Type-safe, memory-efficient caching with automatic eviction and thread-safe operations
</p>

## Overview

**swift-bounded-cache** provides a dictionary-like structure with a maximum capacity that automatically evicts the least recently used (LRU) entries when full. Built with performance and safety in mind, it offers a clean, intuitive API for caching scenarios where memory usage needs to be controlled.

```swift
import BoundedCache

// Create a cache with maximum 100 items
let cache = BoundedCache<String, User>(capacity: 100)

// Insert items - automatically evicts oldest when capacity is reached
cache.insert(user1, forKey: "user123")
cache.insert(user2, forKey: "user456")

// Retrieve items - accessing updates LRU order
if let user = cache.getValue(forKey: "user123") {
    print("Found user: \(user.name)")
}

// Remove items when needed
let removedUser = cache.removeValue(forKey: "user456")

print("Cache contains \(cache.count) items")
```

## Why swift-bounded-cache?

### 🛡️ Memory Safe
- **Automatic eviction**: Never exceeds specified capacity
- **LRU policy**: Intelligently removes least recently used items
- **Reference semantics**: Efficient sharing without copying

### ⚡ High Performance
- **O(1) operations**: Fast insertions, lookups, and removals
- **Minimal overhead**: Direct array and dictionary operations
- **Class-based design**: No expensive copying on assignment

### 🧩 Developer Friendly
- **Type-safe**: Generic over both key and value types
- **Intuitive API**: Familiar dictionary-like interface
- **Swift-first**: Built for modern Swift development

### 🔧 Flexible Operations
- **Filtering**: Keep only items matching criteria
- **Bulk operations**: Remove all items efficiently
- **Capacity management**: Minimum capacity enforcement

## Quick Start

### Installation

Add swift-bounded-cache to your Swift package:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-bounded-cache", from: "0.0.1")
]
```

For Xcode projects, add the package URL: `https://github.com/coenttb/swift-bounded-cache`

### Your First Cache

```swift
import BoundedCache

// Create a cache for user sessions
let sessionCache = BoundedCache<String, UserSession>(capacity: 50)

// Add sessions
sessionCache.insert(session1, forKey: sessionId)
sessionCache.insert(session2, forKey: anotherSessionId)

// Retrieve and automatically update LRU order
if let session = sessionCache.getValue(forKey: sessionId) {
    // Session found and moved to most recently used
    handleActiveSession(session)
}
```

## Core Concepts

### 🏗️ LRU Eviction Policy

The cache maintains access order automatically:

```swift
let cache = BoundedCache<String, Int>(capacity: 2)

cache.insert(1, forKey: "first")
cache.insert(2, forKey: "second")

// Access "first" to make it more recently used
_ = cache.getValue(forKey: "first")

// Insert third item - "second" gets evicted (least recently used)
cache.insert(3, forKey: "third")

print(cache.getValue(forKey: "first"))  // Optional(1) ✅
print(cache.getValue(forKey: "second")) // nil (evicted) ❌
print(cache.getValue(forKey: "third"))  // Optional(3) ✅
```

### 🎛️ Capacity Management

Capacity is enforced automatically with minimum safeguards:

```swift
// Capacity is clamped to minimum of 1
let cache = BoundedCache<String, Int>(capacity: 0) // Actually becomes 1

cache.insert(42, forKey: "answer")
print(cache.count) // 1 - respects minimum capacity
```

### 🔍 Filtering Operations

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

## Real-World Examples

### 📱 User Session Cache

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

### 🗄️ Database Query Cache

```swift
struct QueryResult: Codable {
    let data: [User]
    let timestamp: Date
}

class DatabaseCache {
    private let cache = BoundedCache<String, QueryResult>(capacity: 500)
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    func getCachedResult(for query: String) -> [User]? {
        guard let result = cache.getValue(forKey: query),
              Date().timeIntervalSince(result.timestamp) < cacheTimeout else {
            return nil
        }
        return result.data
    }
    
    func cacheResult(_ users: [User], for query: String) {
        let result = QueryResult(data: users, timestamp: Date())
        cache.insert(result, forKey: query)
    }
}
```

### 🌐 HTTP Response Cache

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
    
    func clearStaleEntries(olderThan interval: TimeInterval) {
        // Implementation would depend on adding timestamps to CachedResponse
        cache.removeAll() // Simplified for example
    }
}
```

## API Reference

### Core Operations

```swift
// Initialize with capacity (minimum 1)
init(capacity: Int)

// Insert or update value for key
func insert(_ value: Value, forKey key: Key)

// Retrieve value and update LRU order
func getValue(forKey key: Key) -> Value?

// Remove specific key-value pair
func removeValue(forKey key: Key) -> Value?

// Remove all items
func removeAll()

// Filter items by predicate
func filter(_ isIncluded: (Key, Value) throws -> Bool) rethrows

// Current item count
var count: Int { get }
```

### Usage Patterns

```swift
let cache = BoundedCache<String, ExpensiveObject>(capacity: 100)

// Typical cache pattern
func getOrCreate(key: String) -> ExpensiveObject {
    if let cached = cache.getValue(forKey: key) {
        return cached // Found in cache, LRU order updated
    }
    
    let newObject = ExpensiveObject(key: key)
    cache.insert(newObject, forKey: key)
    return newObject
}

// Batch operations
func cleanupOldEntries() {
    let cutoffDate = Date().addingTimeInterval(-3600) // 1 hour ago
    cache.filter { _, object in
        object.creationDate > cutoffDate
    }
}
```

## Requirements

- Swift 5.10+ (Full Swift 6 support)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## Support

- 🐛 **[Issue Tracker](https://github.com/coenttb/swift-bounded-cache/issues)** - Report bugs or request features
- 💬 **[Discussions](https://github.com/coenttb/swift-bounded-cache/discussions)** - Ask questions and share ideas
- 📧 **[Newsletter](http://coenttb.com/en/newsletter/subscribe)** - Stay updated
- 🐦 **[X (Twitter)](http://x.com/coenttb)** - Follow for updates
- 💼 **[LinkedIn](https://www.linkedin.com/in/tenthijeboonkkamp)** - Connect professionally

## License

This project is licensed under the Apache License 2.0. See [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ by <a href="https://coenttb.com">coenttb</a><br>
</p>
