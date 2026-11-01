//
//  LockIsolated.swift
//  StarterDomainTests
//

import Synchronization

/// `@Sendable`なクロージャの中から書き換える値を、テストで確かめるための入れ物
final class LockIsolated<Value: Sendable>: Sendable {

    private let mutex: Mutex<Value>

    init(_ value: Value) {
        mutex = .init(value)
    }

    var value: Value {
        mutex.withLock { $0 }
    }

    func append<Element>(_ element: Element) where Value == [Element] {
        mutex.withLock { $0.append(element) }
    }

}
