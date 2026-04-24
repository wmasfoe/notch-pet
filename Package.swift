// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotchPet",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "NotchPet",
            targets: ["NotchPet"]
        )
    ],
    targets: [
        .executableTarget(
            name: "NotchPet",
            path: "NotchPet",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "NotchPetTests",
            dependencies: ["NotchPet"],
            path: "NotchPetTests"
        )
    ]
)
