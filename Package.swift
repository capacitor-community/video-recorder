// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Y",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Y",
            targets: ["ExamplePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "ExamplePlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/ExamplePlugin"),
        .testTarget(
            name: "ExamplePluginTests",
            dependencies: ["ExamplePlugin"],
            path: "ios/Tests/ExamplePluginTests")
    ]
)
