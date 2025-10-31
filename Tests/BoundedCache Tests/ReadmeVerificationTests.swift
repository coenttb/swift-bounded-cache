import Foundation
import Testing

@testable import BoundedCache

@Suite("README Verification")
struct ReadmeVerificationTests {

  @Test("Overview example (lines 12-31)")
  func overviewExample() {
    let cache = BoundedCache<String, Int>(capacity: 100)

    // Insert items - automatically evicts oldest when capacity is reached
    cache.insert(42, forKey: "answer")
    cache.insert(100, forKey: "century")

    // Retrieve items - accessing updates LRU order
    if let value = cache.getValue(forKey: "answer") {
      #expect(value == 42)
    }

    // Remove items when needed
    let removed = cache.removeValue(forKey: "century")
    #expect(removed == 100)

    #expect(cache.count == 1)
  }

  @Test("Quick Start example (lines 54-71)")
  func quickStartExample() {
    let cache = BoundedCache<String, Int>(capacity: 50)

    // Add items
    cache.insert(1, forKey: "one")
    cache.insert(2, forKey: "two")

    // Retrieve items (updates LRU order)
    if let value = cache.getValue(forKey: "one") {
      #expect(value == 1)
    }

    // Check count
    #expect(cache.count == 2)
  }

  @Test("LRU Eviction Policy example (lines 79-94)")
  func lruEvictionExample() {
    let cache = BoundedCache<String, Int>(capacity: 2)

    cache.insert(1, forKey: "first")
    cache.insert(2, forKey: "second")

    // Access "first" to make it more recently used
    _ = cache.getValue(forKey: "first")

    // Insert third item - "second" gets evicted (least recently used)
    cache.insert(3, forKey: "third")

    #expect(cache.getValue(forKey: "first") == 1)
    #expect(cache.getValue(forKey: "second") == nil)
    #expect(cache.getValue(forKey: "third") == 3)
  }

  @Test("Capacity Management example (lines 100-106)")
  func capacityManagementExample() {
    // Capacity is clamped to minimum of 1
    let cache = BoundedCache<String, Int>(capacity: 0)  // Actually becomes 1

    cache.insert(42, forKey: "answer")
    #expect(cache.count == 1)  // respects minimum capacity
  }

  @Test("Filtering Operations example (lines 112-125)")
  func filteringExample() {
    let cache = BoundedCache<String, Int>(capacity: 10)

    // Add various numbers
    cache.insert(1, forKey: "one")
    cache.insert(2, forKey: "two")
    cache.insert(3, forKey: "three")
    cache.insert(4, forKey: "four")

    // Keep only even numbers
    cache.filter { _, value in value % 2 == 0 }

    #expect(cache.count == 2)  // only "two" and "four" remain
    #expect(cache.getValue(forKey: "one") == nil)
    #expect(cache.getValue(forKey: "two") == 2)
    #expect(cache.getValue(forKey: "three") == nil)
    #expect(cache.getValue(forKey: "four") == 4)
  }

  @Test("User Session Cache example (lines 129-154)")
  func userSessionCacheExample() {
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

    let manager = SessionManager()
    let futureDate = Date().addingTimeInterval(3600)
    let pastDate = Date().addingTimeInterval(-3600)

    let activeSession = UserSession(userId: "user1", token: "token1", expiresAt: futureDate)
    let expiredSession = UserSession(userId: "user2", token: "token2", expiresAt: pastDate)

    manager.store(session: activeSession)
    manager.store(session: expiredSession)

    #expect(manager.getSession(for: "user1") != nil)

    manager.cleanExpiredSessions()

    #expect(manager.getSession(for: "user1") != nil)
    #expect(manager.getSession(for: "user2") == nil)
  }

  @Test("Database Query Cache example (lines 158-181)")
  func databaseQueryCacheExample() {
    struct QueryResult {
      let data: [String]
      let timestamp: Date
    }

    class DatabaseCache {
      private let cache = BoundedCache<String, QueryResult>(capacity: 500)
      private let cacheTimeout: TimeInterval = 300  // 5 minutes

      func getCachedResult(for query: String) -> [String]? {
        guard let result = cache.getValue(forKey: query),
          Date().timeIntervalSince(result.timestamp) < cacheTimeout
        else {
          return nil
        }
        return result.data
      }

      func cacheResult(_ data: [String], for query: String) {
        let result = QueryResult(data: data, timestamp: Date())
        cache.insert(result, forKey: query)
      }
    }

    let dbCache = DatabaseCache()

    dbCache.cacheResult(["User1", "User2"], for: "SELECT * FROM users")

    let result = dbCache.getCachedResult(for: "SELECT * FROM users")
    #expect(result != nil)
    #expect(result?.count == 2)
  }

  @Test("HTTP Response Cache example (lines 185-209)")
  func httpResponseCacheExample() {
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

    let httpCache = HTTPCache()
    let url = URL(string: "https://example.com/api")!
    let response = CachedResponse(
      data: Data("test".utf8),
      contentType: "application/json",
      etag: "abc123"
    )

    httpCache.cacheResponse(response, for: url)

    let cached = httpCache.getCachedResponse(for: url)
    #expect(cached != nil)
    #expect(cached?.contentType == "application/json")

    httpCache.clearCache()
    #expect(httpCache.getCachedResponse(for: url) == nil)
  }

  @Test("API Reference - insert operation (line 224)")
  func apiInsertOperation() {
    let cache = BoundedCache<String, Int>(capacity: 2)

    cache.insert(1, forKey: "first")
    #expect(cache.count == 1)

    // Update existing key
    cache.insert(10, forKey: "first")
    #expect(cache.count == 1)
    #expect(cache.getValue(forKey: "first") == 10)

    // Test eviction
    cache.insert(2, forKey: "second")
    cache.insert(3, forKey: "third")

    // "first" should be evicted (least recently used after update)
    #expect(cache.getValue(forKey: "first") == nil)
    #expect(cache.getValue(forKey: "second") == 2)
    #expect(cache.getValue(forKey: "third") == 3)
  }

  @Test("API Reference - getValue operation (line 230)")
  func apiGetValueOperation() {
    let cache = BoundedCache<String, Int>(capacity: 3)

    cache.insert(1, forKey: "one")

    // Retrieve updates LRU order
    let value = cache.getValue(forKey: "one")
    #expect(value == 1)

    // Non-existent key returns nil
    #expect(cache.getValue(forKey: "nonexistent") == nil)
  }

  @Test("API Reference - removeValue operation (line 236)")
  func apiRemoveValueOperation() {
    let cache = BoundedCache<String, Int>(capacity: 3)

    cache.insert(1, forKey: "one")
    cache.insert(2, forKey: "two")

    let removed = cache.removeValue(forKey: "one")
    #expect(removed == 1)
    #expect(cache.getValue(forKey: "one") == nil)
    #expect(cache.count == 1)

    // Removing non-existent key returns nil
    #expect(cache.removeValue(forKey: "nonexistent") == nil)
  }

  @Test("API Reference - removeAll operation (line 242)")
  func apiRemoveAllOperation() {
    let cache = BoundedCache<String, Int>(capacity: 3)

    cache.insert(1, forKey: "one")
    cache.insert(2, forKey: "two")

    cache.removeAll()

    #expect(cache.count == 0)
    #expect(cache.isEmpty)
  }

  @Test("API Reference - filter operation (line 248)")
  func apiFilterOperation() {
    let cache = BoundedCache<String, Int>(capacity: 5)

    cache.insert(1, forKey: "a")
    cache.insert(2, forKey: "b")
    cache.insert(3, forKey: "c")

    // Keep only even values
    cache.filter { _, value in value % 2 == 0 }

    #expect(cache.count == 1)
    #expect(cache.getValue(forKey: "a") == nil)
    #expect(cache.getValue(forKey: "b") == 2)
    #expect(cache.getValue(forKey: "c") == nil)
  }

  @Test("API Reference - count property (line 256)")
  func apiCountProperty() {
    let cache = BoundedCache<String, Int>(capacity: 3)

    #expect(cache.count == 0)

    cache.insert(1, forKey: "one")
    #expect(cache.count == 1)

    cache.insert(2, forKey: "two")
    #expect(cache.count == 2)

    cache.removeValue(forKey: "one")
    #expect(cache.count == 1)
  }

  @Test("API Reference - isEmpty property (line 262)")
  func apiIsEmptyProperty() {
    let cache = BoundedCache<String, Int>(capacity: 3)

    #expect(cache.isEmpty)

    cache.insert(1, forKey: "one")
    #expect(!cache.isEmpty)

    cache.removeAll()
    #expect(cache.isEmpty)
  }
}
