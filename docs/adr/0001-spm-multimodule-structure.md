## タイトル: 実装をSPMのローカルパッケージに置き、マルチモジュールで依存方向を固定する

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: [homete_iOS ADR-0001](https://github.com/stotic-dev/homete_iOS/blob/main/doc/adr/0001-spm-multimodule-structure.md)

## 文脈、背景や問題点の説明

アプリ本体はこれから作る。[homete_iOS](https://github.com/stotic-dev/homete_iOS) はモノリシックな構成から始めて、
後からSPMのマルチモジュールへ移行するのに複数のPRと期間を要した。最初から同じ構成で始めれば、移行のコストを払わずに済む。

## 決定事項

* 実装コードはメインターゲットではなく、ローカルパッケージ `LocalPackage/`・`InfraPackage/` に置く。メインターゲット（`StarterKit/`）はエントリーポイントだけを持つ
* 層は `StarterModel` → `StarterDomain` → `XxxFeature` → `AppRoot` → `StarterKit` とし、依存方向を一方向に固定する
* Feature間の直接依存は禁止し、`StarterDomain` の `AppRoute` と `RouteResolver` 経由で画面遷移する
* DIはサードパーティを使わず、クロージャを持つClientと `AppDependencies` をEnvironmentで注入する
* SwiftLint・SwiftFormatは `ProjectTools/` パッケージで版を固定し、SwiftLintはビルドツールプラグインとして全ターゲットに付ける

## 考慮した選択肢

* **メインターゲットに直接書き、育ってから分割する**: 初期は楽だが、homete_iOSで経験した移行コストを後で払う
* **Tuist・XcodeGenでプロジェクトを生成する**: 柔軟だが、ツールの習得と保守が増える。SPMのローカルパッケージで足りる
* **SPMのローカルパッケージ（採用）**

## 決定結果

### 決定にあたり考慮したメリット

* モジュール境界がコンパイラで強制され、誤った依存が入らない
* 変更したモジュールだけが再コンパイルされ、ユニットテストは `swift test` でシミュレータ無しに流せる
* homete_iOSのルール・スキル・CIをほぼそのまま使える

### 決定にあたり考慮したデメリット

* 画面が少ないうちはモジュール・ファイルの数が実装量に対して多い
* `RouteResolver` の分だけ、Feature間の画面遷移のコード追跡が間接的になる

## 参考

* [マルチモジュール構成](../multimodules_structure.md)
