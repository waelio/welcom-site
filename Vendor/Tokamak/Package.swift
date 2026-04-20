// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v13),
    .iOS(.v13),
  ],
  products: [
    .library(
      name: "TokamakDOM",
      targets: ["TokamakDOM"]
    ),
    .library(
      name: "TokamakStaticHTML",
      targets: ["TokamakStaticHTML"]
    ),
    .library(
      name: "TokamakShim",
      targets: ["TokamakShim"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      from: "0.15.0"
    ),
    .package(
      url: "https://github.com/OpenCombine/OpenCombine.git",
      from: "0.12.0"
    ),
    .package(
      path: "../OpenCombineJS"
    ),
  ],
  targets: [
    .target(
      name: "TokamakCore",
      dependencies: [
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
      ]
    ),
    .target(
      name: "TokamakShim",
      dependencies: [
        .target(name: "TokamakDOM", condition: .when(platforms: [.wasi])),
      ]
    ),
    .target(
      name: "TokamakStaticHTML",
      dependencies: [
        "TokamakCore",
      ]
    ),
    .target(
      name: "TokamakDOM",
      dependencies: [
        "TokamakCore",
        "TokamakStaticHTML",
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
        .product(
          name: "JavaScriptKit",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
        .product(
          name: "JavaScriptEventLoop",
          package: "JavaScriptKit",
          condition: .when(platforms: [.wasi])
        ),
        "OpenCombineJS",
      ]
    ),
  ]
)
