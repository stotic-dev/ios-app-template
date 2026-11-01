//
//  ItemStore.swift
//  StarterDomain
//

import Observation

/// アイテムの一覧を保持する
@MainActor
@Observable
public final class ItemStore {

    public private(set) var items: [Item]

    private let itemClient: ItemClient

    public init(
        itemClient: ItemClient = .previewValue,
        items: [Item] = []
    ) {
        self.itemClient = itemClient
        self.items = items
    }

    /// 登録済みのアイテムを読み込む
    public func load() async throws {
        items = try await itemClient.fetchAll()
    }

    /// アイテムを登録する
    /// - Throws: 名前が不正なら`DomainError.invalidItemName`。保存に失敗したらClientのエラー
    @discardableResult
    public func register(name rawName: String) async throws -> Item {
        let name = try ItemName(rawName)
        let item = Item(name: name.value)
        try await itemClient.insertOrUpdate(item)
        items.append(item)
        return item
    }

}
