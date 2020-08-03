// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "Contacts",
  products: [
    .library(
      name: "Contacts",
      targets: ["Contacts"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Contacts",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
    ]),
    .testTarget(
      name: "ContactsTests",
      dependencies: ["Contacts"]),
  ]
)
