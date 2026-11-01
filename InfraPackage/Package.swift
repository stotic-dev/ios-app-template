// swift-tools-version: 6.2

import PackageDescription

// MARK: - Package

// Firebaseなど重い外部SDKを持つモジュールだけを置く。
// LocalPackageのユニットテストがこれらを解決・ビルドしなくて済むよう、パッケージを分けている（docs/adr/0002-split-infra-package.md）。
// バックエンドは未決定のため、外部SDKはまだ持たない。決まったらここのdependenciesに足す
let package = Package(
    name: "InfraPackage",
    defaultLocalization: "ja",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        lib("StarterInfrastructure"),
        lib("AppRoot"),
    ],
    dependencies: [
        .package(path: "../ProjectTools"),
        .package(path: "../LocalPackage"),
    ],
    targets: [
        // ClientのliveValue実装とService
        .target(
            name: "StarterInfrastructure",
            dependencies: [
                localPackage("StarterDomain"),
            ],
            plugins: [swiftLintPlugin()]
        ),
        // RootView・依存の注入・RouteResolverの実体
        .target(
            name: "AppRoot",
            dependencies: [
                "StarterInfrastructure",
                localPackage("StarterDomain"),
                localPackage("StarterUI"),
                localPackage("HomeFeature"),
            ],
            plugins: [swiftLintPlugin()]
        ),
    ]
)

// MARK: - Helpers

func swiftLintPlugin() -> Target.PluginUsage {
    .plugin(name: "SwiftLintPlugin", package: "ProjectTools")
}

func localPackage(_ name: String) -> Target.Dependency {
    .product(name: name, package: "LocalPackage")
}

func lib(_ name: String) -> Product {
    .library(name: name, targets: [name])
}
