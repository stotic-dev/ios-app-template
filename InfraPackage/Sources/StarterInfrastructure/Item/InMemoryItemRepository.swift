//
//  InMemoryItemRepository.swift
//  StarterInfrastructure
//

import StarterDomain

/// アイテムの情報をメモリ上に保持する
///
/// - Note: 保存先（バックエンド・端末内DB）が決まるまでの仮実装。アプリを終了すると消える
actor InMemoryItemRepository {

    static let shared = InMemoryItemRepository()

    private var items: [Item.ID: Item] = [:]
    private var order: [Item.ID] = []

    func fetchAll() -> [Item] {
        order.compactMap { items[$0] }
    }

    func insertOrUpdate(_ item: Item) {
        if items[item.id] == nil {
            order.append(item.id)
        }
        items[item.id] = item
    }

}
