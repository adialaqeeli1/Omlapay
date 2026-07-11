// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "country_codes",
    platforms: [
        .iOS("12.0")
    ],
    products: [
        .library(name: "country-codes", targets: ["country_codes"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "country_codes",
            dependencies: []
        )
    ]
)
