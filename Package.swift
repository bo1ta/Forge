// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Forge",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(
      name: "Forge",
      targets: ["Forge"]),
  ],
  targets: [
    .target(
      name: "Forge"),
    .testTarget(
      name: "ForgeTests",
      dependencies: ["Forge"]),
  ])
