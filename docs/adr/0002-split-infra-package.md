## タイトル: 重い外部SDKを持つモジュールをInfraPackageに分け、ユニットテストから外す

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: [ADR-0001](0001-spm-multimodule-structure.md)、[homete_iOS ADR-0046](https://github.com/stotic-dev/homete_iOS/blob/main/doc/adr/0046-split-infra-package-from-local-package.md)

## 文脈、背景や問題点の説明

SwiftPMは依存をパッケージ単位で解決する。Firebaseのような重いSDKをユニットテストと同じパッケージに置くと、テスト対象が
Domainだけでも毎回それらを解決・ビルドすることになる。homete_iOSでは解決するパッケージが23個から6個に減った。

## 決定事項

* Clientの `liveValue` 実装とService（`StarterInfrastructure`）、RootViewと依存の注入（`AppRoot`）を `InfraPackage` に置く
* `InfraPackage` は `../LocalPackage` をパス依存で参照する。外部SDKは `InfraPackage/Package.swift` にだけ書く
* バックエンドは未決定のため、今は外部SDKを持たない。データはメモリ上の仮実装（`InMemoryItemRepository`）に置く
* InfraPackageにはユニットテストを置かない。LocalPackageの変更で追従漏れが出ないよう、`ci_infra_package.yml` でビルドを確かめる

## 考慮した選択肢

* **SDKが入るまでLocalPackageだけにする**: 構成は単純だが、SDKを入れるときにパッケージの分割とCIの追加をまとめて行うことになる
* **空のInfraPackageを最初から用意する（採用）**: `liveValue` の置き場所が最初から決まっていて、SDKは依存を足すだけで済む

## 決定結果

### 決定にあたり考慮したメリット

* SDKを入れてもユニットテストの依存解決・ビルドが重くならない
* 重い依存がどこにあるかがパッケージの境界で分かる

### 決定にあたり考慮したデメリット

* 管理するパッケージと `Package.resolved` が1つ増える
* Domainの変更で実装側が追従していないと、テストではなく `infra_package_build` で落ちる

## 参考

* [マルチモジュール構成](../multimodules_structure.md)
