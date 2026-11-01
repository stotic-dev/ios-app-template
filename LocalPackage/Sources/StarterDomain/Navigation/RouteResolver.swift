//
//  RouteResolver.swift
//  StarterDomain
//

import SwiftUI

/// `AppRoute`から遷移先のViewを解決する。実体はAppRootで注入する
///
/// Feature同士を直接依存させずに、別のFeatureの画面へ遷移するために使う
public struct RouteResolver: Sendable {

    private var _resolve: @MainActor @Sendable (AppRoute) -> AnyView

    public init(
        @ViewBuilder resolve: @escaping @MainActor @Sendable (AppRoute) -> some View
    ) {
        _resolve = { AnyView(resolve($0)) }
    }

    @MainActor
    public func resolve(_ route: AppRoute) -> some View {
        _resolve(route)
    }

}

public extension EnvironmentValues {

    @Entry var routeResolver: RouteResolver = .preview

}

public extension RouteResolver {

    static let preview = RouteResolver { route in
        Text("Preview: \(String(describing: route))")
    }

}
