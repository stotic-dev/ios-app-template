//
//  AppDependencies.swift
//  StarterDomain
//

import SwiftUI

/// アプリが使うClient・UseCaseをまとめたDIコンテナ
///
/// Environment（`\.appDependencies`）経由で注入する。Viewからは使うものだけをkeypathで取り出す
/// （.claude/rules/dependency-environment-access.md）
public struct AppDependencies: Sendable {

    public let itemClient: ItemClient

    public init(
        itemClient: ItemClient = .previewValue
    ) {
        self.itemClient = itemClient
    }

}

// MARK: Preview用の定義

public extension AppDependencies {

    static let previewValue: Self = .init()

}

public extension EnvironmentValues {

    @Entry var appDependencies: AppDependencies = .init()

}
