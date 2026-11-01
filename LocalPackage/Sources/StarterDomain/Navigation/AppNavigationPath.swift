//
//  AppNavigationPath.swift
//  StarterDomain
//

import Observation

/// Feature内のNavigationStackの遷移を管理する。`RouteType`にはFeatureごとのルートenumを渡す
@MainActor
@Observable
public final class AppNavigationPath<RouteType: Hashable> {

    public var path: [RouteType]

    public init(path: [RouteType] = []) {
        self.path = path
    }

    public func push(_ route: RouteType) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func popToRoot() {
        path.removeAll()
    }

}
