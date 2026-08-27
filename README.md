# Cache

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-molecules/swift-cache/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-molecules/swift-cache/actions/workflows/ci.yml)

`Cache<Key, Value>` — a thread-safe, compute-if-absent async cache. `value(for:compute:)` returns a cached value, or runs the async compute closure on a miss and stores the result. Concurrent callers requesting the same missing key **coalesce onto a single in-flight computation** rather than each running the work — so a burst of cache misses for one key does the expensive work once, not N times.

---

## Key Features

- **Compute-if-absent** — `value(for:compute:)` runs the async closure only on a miss; hits return immediately.
- **Request coalescing** — concurrent misses for the same key await one shared computation (no thundering herd, no duplicate work).
- **Typed throws** — fallible computation surfaces as `Cache.Error`; a failed computation does not poison later attempts.
- **`Sendable`** — safe to share across tasks; `Key: Hashable & Sendable`, `Value: Sendable`.

---

## Quick Start

```swift
import Cache

let cache = Cache<String, Int>()

// Compute-if-absent: the closure runs once per key. Concurrent callers for the
// same key await the single in-flight computation rather than duplicating it.
let timeout = try await cache.value(for: "config.timeout") {
    try await fetchTimeout()        // your async work — only runs on a miss
}
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-cache.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Cache", package: "swift-cache")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Pending (nightly-toolchain follow-up) |

---

## Related Packages

- [`swift-async`](https://github.com/swift-molecules/swift-async) — the async coordination primitives the cache's in-flight-computation sharing is built on.
- [`swift-dictionary`](https://github.com/swift-molecules/swift-dictionary) — the keyed storage behind the cache's entry table.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
