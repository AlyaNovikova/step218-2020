// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "ContactsCLUtility",
  products: [],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "0.2.0"),
    .package(path: "../Contacts"),
  ],
  targets: [
    .target(
      name: "ContactsCLUtility",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Contacts", package: "Contacts"),
      ]),
    .testTarget(
      name: "ContactsCLUtilityTests",
      dependencies: ["ContactsCLUtility"]),
  ]
)
