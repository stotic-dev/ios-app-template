//
//  Exports.swift
//  StarterDomain
//

// UIが使う値型はStarterModelに置いている（docs/adr/0003-separate-ui-modules-from-domain.md）。StarterDomainを使う側が
// StarterModelも併せてimportしなくて済むよう、再公開する
@_exported import StarterModel
