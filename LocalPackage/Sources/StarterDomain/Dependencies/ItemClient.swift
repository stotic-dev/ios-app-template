//
//  ItemClient.swift
//  StarterDomain
//

/// アイテムの情報を読み書きするClient
///
/// `previewValue`はこのファイルで、`liveValue`はInfraPackageのStarterInfrastructureで定義する
public struct ItemClient: Sendable {

    /// 登録済みのアイテムをすべて取得する
    public let fetchAll: @Sendable () async throws -> [Item]
    /// アイテムを登録・更新する
    public let insertOrUpdate: @Sendable (Item) async throws -> Void

    public init(
        fetchAll: @Sendable @escaping () async throws -> [Item] = { [] },
        insertOrUpdate: @Sendable @escaping (Item) async throws -> Void = { _ in }
    ) {
        self.fetchAll = fetchAll
        self.insertOrUpdate = insertOrUpdate
    }

}

public extension ItemClient {

    static let previewValue: ItemClient = .init(fetchAll: { Item.previewList })

}
