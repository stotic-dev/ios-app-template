//
//  RouteResolverInjection.swift
//  AppRoot
//

import StarterDomain
import SwiftUI

/// `AppRoute`の各caseに対応するViewを解決する。Feature間の遷移はすべてここを通す
private struct RouteResolverInjectionModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .environment(\.routeResolver, RouteResolver { route in
                switch route {
                case .setting:
                    // 設定画面のFeatureを作ったら差し替える
                    Text(verbatim: "Setting")
                }
            })
    }

}

extension View {

    func injectRouteResolver() -> some View {
        modifier(RouteResolverInjectionModifier())
    }

}
