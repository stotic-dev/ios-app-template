//
//  Item.swift
//  StarterModel
//

import Foundation

/// アイテム
public struct Item: Identifiable, Hashable, Sendable, Codable {

    public let id: String
    public var name: String

    public init(name: String, id: String = UUID().uuidString) {
        self.id = id
        self.name = name
    }

}
