//
//  HomeView.swift
//  HomeFeatureUI
//

import StarterModel
import StarterResources
import StarterUI
import SwiftUI
#if canImport(Prefire)
import Prefire
#endif

/// ホーム画面（UIのみ）。値とタップのクロージャだけを受け取る
public struct HomeView: View {

    let items: [Item]
    let onTapAdd: () -> Void

    public init(items: [Item], onTapAdd: @escaping () -> Void) {
        self.items = items
        self.onTapAdd = onTapAdd
    }

    public var body: some View {
        Group {
            if items.isEmpty {
                EmptyStateView(
                    systemImage: "tray",
                    title: .init("まだ登録されていません", bundle: #bundle),
                    message: .init("右上の＋から、アイテムを追加しましょう", bundle: #bundle)
                )
            } else {
                List(items) { item in
                    Label(item.name, systemImage: "square.fill")
                        .foregroundStyle(Color(StarterColor.textPrimary))
                }
            }
        }
        .navigationTitle(Text("アイテム", bundle: #bundle))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onTapAdd) {
                    Label {
                        Text("登録する", bundle: #bundle)
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

}

#Preview("HomeView_登録あり") {
    NavigationStack {
        HomeView(items: Item.previewList, onTapAdd: {})
    }
}

#Preview("HomeView_未登録") {
    NavigationStack {
        HomeView(items: [], onTapAdd: {})
    }
}
