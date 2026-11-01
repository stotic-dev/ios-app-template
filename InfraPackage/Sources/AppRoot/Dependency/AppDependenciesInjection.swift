//
//  AppDependenciesInjection.swift
//  AppRoot
//

import StarterDomain
import StarterInfrastructure
import SwiftUI

public extension View {

    /// 本番の依存を注入する。アプリのエントリーポイントで1度だけ呼ぶ
    func injectLiveDependencies() -> some View {
        environment(\.appDependencies, .liveValue)
    }

}
