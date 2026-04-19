// swift-tools-version:5.7
import PackageDescription
let package = Package(
  name: "OpenCombineJS",
  platforms: [
    .macOS(.v13),
    .iOS(.v13),
  ],
  products: [
    .executable(name: "OpenCombineJSExample", targets: ["OpenCombineJSExample"]),
    .library(name: "OpenCombineJS", targets: ["OpenCombineJS"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      exact: "0.15.0"
    ),
    .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.13.0"),
  ],
  targets: [
    .executableTarget(
      name: "OpenCombineJSExample",
      dependencies: [
        "OpenCombineJS",
      ]
    ),
    .target(
      name: "OpenCombineJS",
      dependencies: [
        "JavaScriptKit", "OpenCombine",
      ]
    ),
  ]
)
