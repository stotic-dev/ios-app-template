//
//  ItemStoreTests.swift
//  StarterDomainTests
//

import StarterDomain
import Testing

@MainActor
struct ItemStoreTests {

    @Test("読み込むと、Clientから取得したアイテムを保持する")
    func load() async throws {
        let expected = [Item.makeForPreview(id: "1", name: "りんご")]
        let store = ItemStore(itemClient: .init(fetchAll: { expected }))

        try await store.load()

        #expect(store.items == expected)
    }

    @Test("登録すると、整えた名前で保存して一覧に加える")
    func register() async throws {
        let saved = LockIsolated<[Item]>([])
        let store = ItemStore(itemClient: .init(insertOrUpdate: { saved.append($0) }))

        let item = try await store.register(name: " みかん ")

        #expect(item.name == "みかん")
        #expect(saved.value == [item])
        #expect(store.items == [item])
    }

    @Test("名前が不正なら、保存せずにエラーにする")
    func registerWithInvalidName() async {
        let saved = LockIsolated<[Item]>([])
        let store = ItemStore(itemClient: .init(insertOrUpdate: { saved.append($0) }))

        await #expect(throws: DomainError.invalidItemName) {
            try await store.register(name: "  ")
        }
        #expect(saved.value.isEmpty)
        #expect(store.items.isEmpty)
    }

}
