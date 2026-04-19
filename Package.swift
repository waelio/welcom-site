// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WelcomSite",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .executable(
            name: "WelcomSite",
            targets: ["WelcomSite"]
        ),
    ],
    dependencies: [
        .package(path: "../WelcomTalk"),
        .package(path: "Vendor/Tokamak"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", exact: "0.15.0"),
    ],
    targets: [
        .target(
            name: "WelcomSiteCore",
            dependencies: [
                .product(name: "WelcomShared", package: "WelcomTalk"),
            ]
        ),
        .executableTarget(
            name: "WelcomSite",
            dependencies: [
                "WelcomSiteCore",
                .product(name: "TokamakShim", package: "Tokamak"),
                .product(
                    name: "JavaScriptKit",
                    package: "JavaScriptKit",
                    condition: .when(platforms: [.wasi])
                ),
            ]
        ),
        .testTarget(
            name: "WelcomSiteCoreTests",
            dependencies: ["WelcomSiteCore"]
        ),
    ]
)
