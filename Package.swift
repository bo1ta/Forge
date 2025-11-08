// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Forge",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(name: "Forge", targets: ["Forge"]),
    .library(name: "ForgeSwiftLog", targets: ["ForgeSwiftLog"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3")
  ],
  targets: [
    .target(name: "Forge"),
    .target(
      name: "ForgeSwiftLog",
      dependencies: [
        "Forge",
        .product(name: "Logging", package: "swift-log")
      ]),
    .testTarget(
      name: "ForgeTests",
      dependencies: ["Forge"]),
  ])
