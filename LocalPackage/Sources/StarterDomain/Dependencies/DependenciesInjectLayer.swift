//
//  DependenciesInjectLayer.swift
//  StarterDomain
//

import SwiftUI

/// Environmentに注入された`AppDependencies`を取り出し、Storeなどを組み立てる層に渡す
public struct DependenciesInjectLayer<Content: View>: View {

    @Environment(\.appDependencies) var appDependencies
    let content: (AppDependencies) -> Content

    public init(@ViewBuilder content: @escaping (AppDependencies) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(appDependencies)
    }

}
