//
//  RootView.swift
//  AppRoot
//

import HomeFeature
import StarterDomain
import SwiftUI

/// アプリのルート画面。Storeを組み立てて、Environmentへ注入する
public struct RootView: View {

    public init() {}

    public var body: some View {
        DependenciesInjectLayer { dependencies in
            RootContent(dependencies: dependencies)
        }
    }

}

private struct RootContent: View {

    @State var itemStore: ItemStore

    init(dependencies: AppDependencies) {
        _itemStore = State(initialValue: ItemStore(itemClient: dependencies.itemClient))
    }

    var body: some View {
        HomeScreen()
            .environment(itemStore)
            .injectRouteResolver()
    }

}
