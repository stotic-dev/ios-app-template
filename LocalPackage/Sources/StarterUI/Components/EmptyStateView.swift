//
//  EmptyStateView.swift
//  StarterUI
//

import StarterResources
import SwiftUI
#if canImport(Prefire)
import Prefire
#endif

/// 表示するものが無いときの案内
public struct EmptyStateView: View {

    let systemImage: String
    let title: LocalizedStringResource
    let message: LocalizedStringResource

    public init(systemImage: String, title: LocalizedStringResource, message: LocalizedStringResource) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        ContentUnavailableView {
            Label {
                Text(title)
                    .foregroundStyle(Color(StarterColor.textPrimary))
            } icon: {
                Image(systemName: systemImage)
                    .foregroundStyle(Color(StarterColor.fillAccent))
            }
        } description: {
            Text(message)
                .foregroundStyle(Color(StarterColor.textSecondary))
        }
    }

}

#Preview(traits: .sizeThatFitsLayout) {
    EmptyStateView(
        systemImage: "tray",
        title: .init("プレビュー用のタイトル", bundle: #bundle),
        message: .init("プレビュー用のメッセージ", bundle: #bundle)
    )
}
