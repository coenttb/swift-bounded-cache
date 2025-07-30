// swift-tools-version:5.10

import PackageDescription

extension String {
    static let boundedCache: Self = "BoundedCache"
}

extension Target.Dependency {
    static var boundedCache: Self { .target(name: .boundedCache) }
}

let package = Package(
    name: "swift-bounded-cache",
    products: [
        .library(name: .boundedCache, targets: [.boundedCache])
    ],
    dependencies: [],
    targets: [
        .target(
            name: .boundedCache,
            dependencies: []
        ),
        .testTarget(
            name: .boundedCache.tests,
            dependencies: [
                .boundedCache
            ]
        )
    ]
)

extension String { var tests: Self { self + " Tests" } }
