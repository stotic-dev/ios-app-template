//
//  AppDependencies+liveValue.swift
//  StarterInfrastructure
//

import StarterDomain

// MARK: Live用の定義

public extension AppDependencies {

    static let liveValue: Self = .init(
        itemClient: .liveValue
    )

}
