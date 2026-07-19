// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "KarabinerCompose",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "karabiner-compose",
            targets: ["KarabinerCompose"]
        )
    ],
    targets: [
        .executableTarget(
            name: "KarabinerCompose",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "KarabinerComposeTests",
            dependencies: ["KarabinerCompose"]
        )
    ],
    swiftLanguageModes: [.v6]
)
