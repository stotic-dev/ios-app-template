//
//  AppRoute.swift
//  StarterDomain
//

/// Feature間の画面遷移先。Feature内の遷移はFeatureごとのルートenumで扱い、ここには足さない
/// （docs/multimodules_structure.md）
public enum AppRoute: Hashable, Sendable {

    /// 設定画面
    case setting

}
