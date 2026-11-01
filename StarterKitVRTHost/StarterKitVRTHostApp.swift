//
//  StarterKitVRTHostApp.swift
//  StarterKitVRTHost
//

import SwiftUI

/// VRT（スナップショットテスト）専用のホストアプリ。
///
/// 描画対象のViewはStarterKitSnapshotTests側がLocalPackageの各モジュールを直接リンクして持つ。
/// このターゲットはkey windowを用意するためだけに存在し、LocalPackageには一切依存しない。
///
/// アプリ本体をホストにすると AppRoot → StarterInfrastructure 経由で
/// InfraPackageの重い外部SDKのビルドが丸ごと必要になり、VRTの実行時間を押し上げる。
@main
struct StarterKitVRTHostApp: App {

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }

}
