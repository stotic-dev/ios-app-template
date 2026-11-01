//
//  PrimaryButtonStyle.swift
//  StarterUI
//

import StarterResources
import SwiftUI

/// 画面の主要な操作に使うボタンのスタイル
public struct PrimaryButtonStyle: ButtonStyle {

    @Environment(\.isEnabled) var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color(StarterColor.textOnAccent))
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color(StarterColor.fillAccent), in: .capsule)
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }

}

public extension ButtonStyle where Self == PrimaryButtonStyle {

    static var primary: PrimaryButtonStyle {
        .init()
    }

}
