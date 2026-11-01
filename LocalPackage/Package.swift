// swift-tools-version: 6.2

import PackageDescription

// MARK: - Package

// 重い外部SDKを持たないモジュールとユニットテストを置く。重い外部SDKが要る実装はInfraPackageに置く（docs/adr/0002-split-infra-package.md）
let package = Package(
    name: "LocalPackage",
    defaultLocalization: "ja",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        lib("StarterModel"),
        lib("StarterDomain"),
        lib("StarterUI"),
        lib("StarterResources"),
        lib("HomeFeatureUI"),
        lib("HomeFeature"),
        lib("StarterSnapshotTestSupport"),
    ],
    dependencies: [
        .package(path: "../ProjectTools"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", from: "6.6.2"),
        .package(url: "https://github.com/BarredEwe/Prefire.git", exact: "6.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.19.7"),
    ],
    targets: [

        // MARK: Core Targets

        // UIが使う値型のドメインモデル。Store・UseCase・Clientは置かない（docs/adr/0003-separate-ui-modules-from-domain.md）
        .target(
            name: "StarterModel",
            resources: [localizableStrings()],
            plugins: [swiftLintPlugin()]
        ),
        // UIが使わない値型・Clientプロトコル・Store・UseCase・AppRoute
        .target(
            name: "StarterDomain",
            dependencies: ["StarterModel"],
            plugins: [swiftLintPlugin()]
        ),
        // StarterDomainには依存させない。Store・UseCase・Clientの変更でVRTが全件にならないようにする（docs/adr/0003-separate-ui-modules-from-domain.md）
        .target(
            name: "StarterUI",
            dependencies: [
                "StarterModel",
                "StarterResources",
                .product(name: "Prefire", package: "Prefire", condition: .when(platforms: [.iOS])),
            ],
            resources: [localizableStrings()],
            plugins: [swiftLintPlugin()]
        ),
        .target(
            name: "StarterResources",
            // SwiftGenPluginが読む設定とテンプレート。ビルドのリソースには含めない
            exclude: ["swiftgen.yml", "Resources/swiftgen-templates"],
            resources: [
                .process("Resources/Colors.xcassets"),
                .process("Resources/Image.xcassets"),
            ],
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin"),
            ]
        ),

        // MARK: Feature Targets

        // UIのみのView（XxxView / XxxContent）とプレビュー。StarterDomainには依存させない
        featureUI(name: "HomeFeatureUI"),
        // ロジックを持つView（XxxScreen）とStore連携。プレビューは置かない
        feature(name: "HomeFeature"),

        // MARK: Test Support

        // VRT（StarterKitSnapshotTests）専用。アプリ本体からは依存しない
        .target(
            name: "StarterSnapshotTestSupport",
            dependencies: [
                .product(name: "Prefire", package: "Prefire", condition: .when(platforms: [.iOS])),
                .product(
                    name: "SnapshotTesting",
                    package: "swift-snapshot-testing",
                    condition: .when(platforms: [.iOS])
                ),
            ],
            plugins: [swiftLintPlugin()]
        ),

        // MARK: Test Targets

        .testTarget(
            name: "StarterModelTests",
            dependencies: ["StarterModel"],
            plugins: [swiftLintPlugin()]
        ),
        .testTarget(
            name: "StarterDomainTests",
            dependencies: ["StarterDomain"],
            plugins: [swiftLintPlugin()]
        ),
    ]
)

// MARK: - Helpers

func swiftLintPlugin() -> Target.PluginUsage {
    .plugin(name: "SwiftLintPlugin", package: "ProjectTools")
}

/// UIのみのViewを置くFeatureUIモジュール。依存はStarterModel・StarterUI・StarterResourcesと、必要なら他のFeatureUIだけ
func featureUI(name: String, extraDeps: [Target.Dependency] = []) -> Target {
    .target(
        name: name,
        dependencies: [
            "StarterModel",
            "StarterUI",
            "StarterResources",
            .product(name: "Prefire", package: "Prefire", condition: .when(platforms: [.iOS])),
        ] + extraDeps,
        path: "./Sources/Features/\(name)",
        resources: [localizableStrings()],
        plugins: [swiftLintPlugin()]
    )
}

/// ロジックを持つViewを置くFeatureモジュール。同じ名前のFeatureUIとStarterDomainに依存する
func feature(name: String, extraDeps: [Target.Dependency] = []) -> Target {
    .target(
        name: name,
        dependencies: [.target(name: "\(name)UI"), "StarterDomain", "StarterUI"] + extraDeps,
        path: "./Sources/Features/\(name)",
        resources: [localizableStrings()],
        plugins: [swiftLintPlugin()]
    )
}

/// 画面に出す文言のString Catalog。キーは日本語の文言そのもので、英語などの訳はXcodeの「Generate Translation」で入れる
func localizableStrings() -> Resource {
    .process("Localizable.xcstrings")
}

func lib(_ name: String) -> Product {
    .library(name: name, targets: [name])
}
