//
//  StarterKitApp.swift
//  StarterKit
//

import AppRoot
import SwiftUI

/// アプリのエントリーポイント
///
/// 実装はLocalPackage・InfraPackageに置き、ここでは本番の依存を注入してRootViewを出すだけにする
/// （docs/multimodules_structure.md）
@main
struct StarterKitApp: App {

    var body: some Scene {
        WindowGroup {
            RootView()
                .injectLiveDependencies()
        }
    }

}
