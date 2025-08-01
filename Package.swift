// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorCommunityVideoRecorder",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorCommunityVideoRecorder",
            targets: ["VideoRecorder"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "VideoRecorder",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/VideoRecorder"),
        .testTarget(
            name: "VideoRecorderTests",
            dependencies: ["VideoRecorder"],
            path: "ios/Tests/VideoRecorderTests")
    ]
)