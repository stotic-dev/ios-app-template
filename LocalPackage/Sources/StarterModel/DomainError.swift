//
//  DomainError.swift
//  StarterModel
//

/// ドメインのルールに反したときのエラー
public enum DomainError: Error, Equatable, Sendable {

    /// アイテムの名前が空、または長すぎる
    case invalidItemName

}
