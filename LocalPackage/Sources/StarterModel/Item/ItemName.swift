//
//  ItemName.swift
//  StarterModel
//

import Foundation

/// アイテムの名前。入力された文字列を検証してから作る
public struct ItemName: Hashable, Sendable {

    /// 名前の最大文字数
    public static let maxLength = 20

    public let value: String

    /// 前後の空白を取り除いて検証する
    /// - Throws: 空、または`maxLength`を超える場合は`DomainError.invalidItemName`
    public init(_ rawValue: String) throws(DomainError) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.count <= Self.maxLength else {
            throw .invalidItemName
        }
        value = trimmed
    }

}
