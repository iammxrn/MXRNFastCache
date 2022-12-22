// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MXRNFastCache",
    products: [
        .library(
            name: "MXRNFastCache",
            targets: ["MXRNFastCache"]
        )
    ],
    targets: [
        .target(
            name: "MXRNFastCache",
            dependencies: []
        )
    ]
)
