//
//  HomeScreen.swift
//  HomeFeature
//

import HomeFeatureUI
import StarterDomain
import SwiftUI

/// ホーム画面（ロジックを持つView）。Storeの呼び出しと、シートの提示を受け持つ
public struct HomeScreen: View {

    @Environment(ItemStore.self) var itemStore
    @State var isPresentingRegistration = false

    public init() {}

    public var body: some View {
        NavigationStack {
            HomeView(
                items: itemStore.items,
                onTapAdd: { isPresentingRegistration = true }
            )
        }
        .sheet(isPresented: $isPresentingRegistration) {
            ItemRegistrationScreen()
        }
        .task {
            try? await itemStore.load()
        }
    }

}
