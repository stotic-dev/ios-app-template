//
//  ItemClient+liveValue.swift
//  StarterInfrastructure
//

import StarterDomain

/// previewValueはStarterDomainのClientのファイルで、liveValueはここで定義する
extension ItemClient {

    static let liveValue: ItemClient = .init(
        fetchAll: { await InMemoryItemRepository.shared.fetchAll() },
        insertOrUpdate: { await InMemoryItemRepository.shared.insertOrUpdate($0) }
    )

}
