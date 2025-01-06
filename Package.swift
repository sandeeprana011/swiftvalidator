// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
    name: "swiftvalidator",
    platforms: [
        .macOS(.v15),
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "swiftvalidator",
            targets: ["swiftvalidator"]
        ),
        .executable(
            name: "xibidgenerator",
            targets: ["xibidgenerator"]
        ),
        .executable(
            name: "xibidlint",
            targets: ["xibidlint"]
        ),
        .plugin(
            name: "ValidateSwiftLint",
            targets: ["ValidateSwiftLint"]
        ),
        .plugin(
            name: "XibAccessibilityIdentifierLint",
            targets: ["XibAccessibilityIdentifierLint"]
        ),
        .plugin(
            name: "XibIDGenerateCommand",
            targets: ["XibIDGenerateCommand"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/swiftlang/swift-syntax.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "swiftvalidator",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ]
        ),
        .executableTarget(
            name: "xibidgenerator",
            dependencies: [
                
            ]
        ),
        .executableTarget(
            name: "xibidlint",
            dependencies: [
                
            ]
        ),
        .plugin(
            name: "ValidateSwiftLint",
            capability: .buildTool(),
            dependencies: ["swiftvalidator"],
            path: "Sources/Plugins/ValidateSwiftLint"
        ),
        .plugin(
            name: "XibAccessibilityIdentifierLint",
            capability: .buildTool(),
            dependencies: ["xibidlint"],
            path: "Sources/Plugins/XibAccessibilityIdentifierLint"
        ),
        
        .plugin(
            name: "XibIDGenerateCommand",
            capability: .command(
                intent: .custom(verb: "XibIDGenerateCommand", description: "Update the accessibility identifiers in the xib files"),
                permissions: [.writeToPackageDirectory(reason: "We need to update the accessibility identifiers in the xib files")]),
            dependencies: ["xibidgenerator"],
            path: "Sources/Plugins/XibIDGenerateCommand"
        )
    ]
)
