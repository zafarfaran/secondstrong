// swift-tools-version: 6.0
import PackageDescription

// Layers: SSCore -> SSDesign -> features (SSOnboarding, ...) -> App/.
// Features never import each other; check-harness.sh enforces it.
// See docs/architecture/ios.md.
let package = Package(
    name: "SecondStrongKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "SSCore", targets: ["SSCore"]),
        .library(name: "SSDesign", targets: ["SSDesign"]),
        .library(name: "SSOnboarding", targets: ["SSOnboarding"]),
        .library(name: "SSToday", targets: ["SSToday"]),
        .library(name: "SSWidgets", targets: ["SSWidgets"]),
    ],
    targets: [
        .target(name: "SSCore"),
        .target(name: "SSDesign", dependencies: ["SSCore"], resources: [.process("Resources/Images"), .process("Resources/Fonts"), .copy("Resources/Clips")]),
        .target(name: "SSOnboarding", dependencies: ["SSCore", "SSDesign"]),
        .target(name: "SSToday", dependencies: ["SSCore", "SSDesign"]),
        .target(name: "SSWidgets", dependencies: ["SSCore", "SSDesign"]),
        .executableTarget(name: "OnboardingPreview", dependencies: ["SSOnboarding", "SSToday", "SSDesign", "SSCore"], path: "Preview"),
        .testTarget(name: "SSDesignTests", dependencies: ["SSDesign", "SSCore"]),
        .testTarget(name: "SSCoreTests", dependencies: ["SSCore"]),
        .testTarget(name: "SSOnboardingTests", dependencies: ["SSOnboarding", "SSCore"]),
        .testTarget(name: "SSTodayTests", dependencies: ["SSToday", "SSCore"]),
        .testTarget(name: "SSWidgetsTests", dependencies: ["SSWidgets", "SSCore", "SSDesign"]),
    ]
)
