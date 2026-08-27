// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-cache",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Cache",
            targets: ["Cache"]
        ),
        .library(
            name: "Cache Test Support",
            targets: ["Cache Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-array.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-async.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-effect.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dictionary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-column.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-ring.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership-shared.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-heap.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-collection.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "Cache",
            dependencies: [
                .product(name: "Array Primitive", package: "swift-array"),
                .product(name: "Array", package: "swift-array"),
                .product(name: "Async", package: "swift-async"),
                .product(name: "Async Waiter", package: "swift-async"),
                .product(name: "Async Mutex", package: "swift-async"),
                .product(name: "Ownership", package: "swift-ownership"),
                .product(name: "Effect", package: "swift-effect"),
                .product(name: "Dictionary", package: "swift-dictionary"),
                .product(name: "Column", package: "swift-column"),
                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring"),
                .product(
                    name: "Ownership Shared Primitive",
                    package: "swift-ownership-shared"
                ),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Storage Contiguous",
                    package: "swift-storage"
                ),
                .product(name: "Memory Heap", package: "swift-memory-heap"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(name: "Buffer Primitive", package: "swift-buffer"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "Collection", package: "swift-collection"),
            ]
        ),
        .target(
            name: "Cache Test Support",
            dependencies: [
                "Cache",
                .product(name: "Time Test Support", package: "swift-time"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Cache Tests",
            dependencies: [
                "Cache",
                "Cache Test Support",
                .product(name: "Async", package: "swift-async"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
