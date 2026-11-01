//
//  ItemRegistrationView.swift
//  HomeFeatureUI
//

import StarterModel
import StarterUI
import SwiftUI
#if canImport(Prefire)
import Prefire
#endif

/// アイテムの登録画面（UIのみ）
public struct ItemRegistrationView: View {

    @Binding var name: String
    let isSaving: Bool
    let onTapSave: () -> Void
    let onTapCancel: () -> Void

    public init(
        name: Binding<String>,
        isSaving: Bool,
        onTapSave: @escaping () -> Void,
        onTapCancel: @escaping () -> Void
    ) {
        _name = name
        self.isSaving = isSaving
        self.onTapSave = onTapSave
        self.onTapCancel = onTapCancel
    }

    public var body: some View {
        Form {
            Section {
                TextField(text: $name) {
                    Text("名前", bundle: #bundle)
                }
            } footer: {
                Text("\(ItemName.maxLength)文字以内で入力してください", bundle: #bundle)
            }
        }
        .navigationTitle(Text("アイテムを追加", bundle: #bundle))
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: onTapCancel) {
                    Text("キャンセル", bundle: #bundle)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onTapSave) {
                    Text("保存", bundle: #bundle)
                }
                .disabled(isSaving)
            }
        }
    }

}

#Preview("ItemRegistrationView_未入力") {
    NavigationStack {
        ItemRegistrationView(name: .constant(""), isSaving: false, onTapSave: {}, onTapCancel: {})
    }
}

#Preview("ItemRegistrationView_入力済み") {
    NavigationStack {
        ItemRegistrationView(name: .constant("りんご"), isSaving: false, onTapSave: {}, onTapCancel: {})
    }
}
