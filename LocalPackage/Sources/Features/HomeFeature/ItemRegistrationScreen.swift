//
//  ItemRegistrationScreen.swift
//  HomeFeature
//

import HomeFeatureUI
import StarterDomain
import SwiftUI

/// アイテムの登録画面（ロジックを持つView）
struct ItemRegistrationScreen: View {

    @Environment(ItemStore.self) var itemStore
    @Environment(\.dismiss) var dismiss
    @State var name = ""
    @State var isSaving = false
    @State var isPresentingError = false

    var body: some View {
        NavigationStack {
            ItemRegistrationView(
                name: $name,
                isSaving: isSaving,
                onTapSave: { Task { await save() } },
                onTapCancel: { dismiss() }
            )
        }
        .alert(Text("登録できませんでした", bundle: #bundle), isPresented: $isPresentingError) {
            Button(role: .cancel) {} label: { Text("OK", bundle: #bundle) }
        }
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await itemStore.register(name: name)
            dismiss()
        } catch {
            isPresentingError = true
        }
    }

}
