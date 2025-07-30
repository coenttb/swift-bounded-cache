@testable import BoundedCache
import Testing

@Test("Basic insert and retrieve functionality")
func testBasicInsertAndRetrieve() {
        let cache = BoundedCache<String, Int>(capacity: 3)

        cache.insert(1, forKey: "one")
        cache.insert(2, forKey: "two")

        #expect(cache.getValue(forKey: "one") == 1)
        #expect(cache.getValue(forKey: "two") == 2)
        #expect(cache.getValue(forKey: "three") == nil)
}

@Test("Capacity limit and eviction")
func testCapacityLimit() {
        let cache = BoundedCache<String, Int>(capacity: 2)

        cache.insert(1, forKey: "one")
        cache.insert(2, forKey: "two")
        cache.insert(3, forKey: "three") // Should evict "one"

        #expect(cache.getValue(forKey: "one") == nil)
        #expect(cache.getValue(forKey: "two") == 2)
        #expect(cache.getValue(forKey: "three") == 3)
        #expect(cache.count == 2)
}

@Test("Update existing key")
func testUpdateExistingKey() {
        let cache = BoundedCache<String, Int>(capacity: 2)

        cache.insert(1, forKey: "key")
        cache.insert(2, forKey: "key") // Update existing

        #expect(cache.getValue(forKey: "key") == 2)
        #expect(cache.count == 1)
}

@Test("LRU eviction policy")
func testLRUEviction() {
        let cache = BoundedCache<String, Int>(capacity: 2)

        cache.insert(1, forKey: "first")
        cache.insert(2, forKey: "second")

        // Access first key to make it more recently used
        _ = cache.getValue(forKey: "first")

        cache.insert(3, forKey: "third") // Should evict "second"

        #expect(cache.getValue(forKey: "first") == 1)
        #expect(cache.getValue(forKey: "second") == nil)
        #expect(cache.getValue(forKey: "third") == 3)
}

@Test("Remove value functionality")
func testRemoveValue() {
        let cache = BoundedCache<String, Int>(capacity: 3)

        cache.insert(1, forKey: "one")
        cache.insert(2, forKey: "two")

        let removed = cache.removeValue(forKey: "one")

        #expect(removed == 1)
        #expect(cache.getValue(forKey: "one") == nil)
        #expect(cache.getValue(forKey: "two") == 2)
        #expect(cache.count == 1)
}

@Test("Remove non-existent key")
func testRemoveNonExistentKey() {
        let cache = BoundedCache<String, Int>(capacity: 2)

        let removed = cache.removeValue(forKey: "nonexistent")

        #expect(removed == nil)
}

@Test("Remove all items")
func testRemoveAll() {
        let cache = BoundedCache<String, Int>(capacity: 3)

        cache.insert(1, forKey: "one")
        cache.insert(2, forKey: "two")

        cache.removeAll()

        #expect(cache.getValue(forKey: "one") == nil)
        #expect(cache.getValue(forKey: "two") == nil)
        #expect(cache.isEmpty)
}

@Test("Filter functionality")
func testFilter() {
        let cache = BoundedCache<String, Int>(capacity: 5)

        cache.insert(1, forKey: "one")
        cache.insert(2, forKey: "two")
        cache.insert(3, forKey: "three")
        cache.insert(4, forKey: "four")

        // Keep only even values
        cache.filter { _, value in value % 2 == 0 }

        #expect(cache.getValue(forKey: "one") == nil)
        #expect(cache.getValue(forKey: "two") == 2)
        #expect(cache.getValue(forKey: "three") == nil)
        #expect(cache.getValue(forKey: "four") == 4)
        #expect(cache.count == 2)
}

@Test("Minimum capacity enforcement")
func testMinimumCapacity() {
        let cache = BoundedCache<String, Int>(capacity: 0)
        #expect(cache.isEmpty)

        cache.insert(1, forKey: "test")
        #expect(cache.count == 1) // Should be clamped to minimum 1
}

@Test("Access order preservation")
func testAccessOrderPreservation() {
        let cache = BoundedCache<String, String>(capacity: 3)

        cache.insert("A", forKey: "1")
        cache.insert("B", forKey: "2")
        cache.insert("C", forKey: "3")

        // Update key "2" - should move it to end of access order
        cache.insert("B_updated", forKey: "2")

        // Add new item - should evict "1" (oldest)
        cache.insert("D", forKey: "4")

        #expect(cache.getValue(forKey: "1") == nil)
        #expect(cache.getValue(forKey: "2") == "B_updated")
        #expect(cache.getValue(forKey: "3") == "C")
        #expect(cache.getValue(forKey: "4") == "D")
}
