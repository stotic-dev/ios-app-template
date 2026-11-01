# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

<!-- テンプレートから作ったら、この段落をアプリの説明に書き換える -->
StarterKit は、SwiftUI + SPMマルチモジュール構成のiOSアプリ。プロダクト方針は [docs/product-direction.md](docs/product-direction.md) が正。

**技術スタック:**
- iOS 26以上 / SwiftUI + Swift 6（strict concurrency有効）
- SPMのローカルパッケージによるマルチモジュール構成
- バックエンド: 未決定（今はメモリ上の仮実装）
- CI/CD: GitHub Actions + Xcode Cloud + Fastlane

実装方針・CI・環境構築は [homete_iOS](https://github.com/stotic-dev/homete_iOS) を元にしている。`.claude/rules/` のコード例に出てくる `Housework〜` などの型名はその名残なので、パターンとして読む。

## よく使うコマンド

```bash
# 変更に関係するモジュールと、必要なビルド・テスト・VRTを表示（起点は BASE=<ref>、既定は origin/main）
make affected

# 変更に関係するLocalPackageのターゲットだけiOS向けにビルドし、影響が届くならInfraPackageもビルド
make build-affected

# 変更に関係するテストターゲットだけ実行（最も使う。xcodebuildは使わない）
make test-affected

# 直接変えたStarterUI・FeatureUIのプレビューだけ、iOS 27.0のiPhone 16でVRTを流す（参照スナップショットは更新しない）
make snapshot-affected

# 全ターゲットが対象の版。判定が当てにならないときや頼まれたときだけ使う
make test-packages-fast   # FILTER=<テストターゲット/Suite名>で絞れる
make build-local-package
make build-infra-package

make format               # SwiftFormat
make check-previews       # VRT(Prefire)のビルドが壊れる#Previewを静的に検出
make check-translations   # String Catalogの英訳の抜けを検出
make setup-project        # 初回セットアップ（Ruby・Bundler・ProjectTools・git hooks）
make help                 # 一覧
```

`make` の各ターゲットには `--disable-sandbox` が付いている。理由は `.claude/skills/swift-code-verification/SKILL.md` を参照。

アプリ本体のビルド（`StarterKit/`・`StarterKit.xcodeproj` を変えたときだけ）:

```bash
xcodebuild build -project StarterKit.xcodeproj -scheme StarterKit \
  -destination 'generic/platform=iOS Simulator' -quiet
```

## アーキテクチャ

**マルチモジュール構成**（SPM）: 実装コードはメインターゲットではなく `LocalPackage/` と `InfraPackage/` に置く。モジュールの一覧・責務・依存関係・DI・画面遷移・Featureの足し方は **[docs/multimodules_structure.md](docs/multimodules_structure.md)** が正。

```
StarterKit（エントリーポイントのみ）
  → AppRoot（RootView・Storeの組み立て・RouteResolverの実体）        [InfraPackage]
  → StarterInfrastructure（Clientの liveValue・Service）           [InfraPackage]
  → XxxFeature（XxxScreen: Store・シート・遷移）                     [LocalPackage]
  → XxxFeatureUI（XxxView: 値とクロージャだけ受け取るUI + #Preview）   [LocalPackage]
  → StarterUI / StarterResources（共通UI・アセット）                 [LocalPackage]
  → StarterDomain（Client・Store・UseCase・AppRoute）               [LocalPackage]
  → StarterModel（UIが使う値型）                                    [LocalPackage]
```

- `StarterUI`・`XxxFeatureUI` は `StarterDomain` に依存しない（[ADR-0003](docs/adr/0003-separate-ui-modules-from-domain.md)）
- Feature間の直接依存は禁止。Feature間の遷移は `AppRoute` + `RouteResolver`
- 重い外部SDKは `InfraPackage` にだけ置く（[ADR-0002](docs/adr/0002-split-infra-package.md)）
- 常にDIを使う。ViewからServiceに直接アクセスしない

**状態管理:** `@Observable`（CombineやObservableObjectは使わない）。Storeは `@MainActor`。全体的にasync/await。

**主要ファイル:**
- `StarterKit/StarterKitApp.swift` - エントリーポイント
- `InfraPackage/Sources/AppRoot/RootView.swift` - Storeの組み立てとルート画面
- `LocalPackage/Sources/StarterDomain/Dependencies/AppDependencies.swift` - DIコンテナ

## テスト戦略

**ユニットテスト**（`LocalPackage/Tests/`、Swift Testing）:
- テストターゲット: `StarterModelTests`、`StarterDomainTests`
- 実行: `make test-affected`（`swift test --filter`）。変更されたターゲットと、それに依存するターゲットのテストだけを流す（[ADR-0004](docs/adr/0004-verify-only-affected-modules.md)）
- 書き方は `swift-test-implementation` スキル

**スナップショットテスト（VRT）**（[ADR-0005](docs/adr/0005-vrt-dedicated-project.md)）:
- プロジェクトはVRT専用の `StarterKitVRT.xcodeproj`。ホストは空のアプリ `StarterKitVRTHost`。同じLocalPackageを参照するため、`StarterKit.xcodeproj` とは同時に開けない
- Prefire（`.prefire.yml`）が `#Preview` からテストを生成する。対象は `StarterUI` と `XxxFeatureUI`
- 参照画像は `StarterKitSnapshotTests/__Snapshots__/PreviewTests.generated/`。記録・更新はXcode Cloudの `VRT_light` に任せる
- iPhone 16 / iPhone SE (2nd generation) × ライト・ダーク、iOS 27

## CI/CD

**GitHub Actions**（`.github/workflows/`）:
1. `ci_local_package.yml` - LocalPackageのテスト。PRでは影響範囲だけ、mainへのpushでは全部
2. `ci_infra_package.yml` - InfraPackageのビルド（LocalPackageの変更でも、影響が届けばビルド）
3. `ci_danger.yml` - Danger（PRの行数・SwiftLint・VRT画像の差分）
4. `sync-package-resolved.yml` - dependabotのPRで、xcodeproj側の`Package.resolved`をそろえる（[ADR-0008](docs/adr/0008-sync-package-resolved.md)）
5. リリース系（[ADR-0007](docs/adr/0007-release-pipeline.md)）: `create-release-pr.yml` → `release-snapshot-diff.yml` / `sync-metadata.yml` / `merge-main-into-release.yml` → `release-merged.yml`、`create-release-note.yaml`

**Xcode Cloud**: `ci_scripts/` が `$CI_WORKFLOW`（`VRT` / `VRT_light` / `Upload Stg TestFlight` / `Upload Release Candidate TestFlight` / `Upload For AppStore`）で処理を分岐する。ビルドの状態・ログは `scripts/xcode-cloud.sh`（`xcode-cloud-check` スキル）で取れる（[ADR-0006](docs/adr/0006-xcode-cloud-cli-outside-claude-sandbox.md)）。

**構成とバンドルID:**

| 構成 | 用途 | バンドルID | 表示名 |
|---|---|---|---|
| Debug | Xcodeから実行 | `com.example.starterkit.dev` | [開発用]スターターキット |
| Stg | TestFlight（`STG`フラグ） | `com.example.starterkit.dev` | [開発用]スターターキット |
| Release | App Store | `com.example.starterkit` | スターターキット |

スキームは `StarterKit`（Debugで実行、Stgでアーカイブ）と `production`（Release）。バンドルID・表示名は `scripts/rename-project.sh` で設定する。

## 重要事項

### コードスタイル
- SwiftLint（`.swiftlint.yml`）はビルド時にSPMプラグインとして全ターゲットで走る。SwiftFormat（`.swiftformat`）はpre-commitフックと `make format`。詳細は [docs/tech/code-style.md](docs/tech/code-style.md)

### ローカライズ
文言は日本語をキーにして各モジュールの`Localizable.xcstrings`で管理する。パッケージ内では`Text("…", bundle: #bundle)`で必ずbundleを指定する。日本語を足す・変えたら英訳も入れ、`make check-translations`で確かめる。詳細は **[docs/localization.md](docs/localization.md)**（[ADR-0009](docs/adr/0009-localization-with-per-module-string-catalogs.md)）。

### 技術選定はADRに残す
`.claude/rules/adr.md` に従い `docs/adr/` に書く。

## エージェント

- **pdm**: 機能要望をビジネス観点（`docs/product-direction.md` の価値の柱）でレビューし、Issueを起票する。ユーザーが機能要望を出したらプロアクティブに使う
- **ios-code-reviewer**: Swiftの実装・リファクタリング・テストの後に技術観点でレビューする

## Xcode同梱スキルの取り込み

`.claude/skills/` のうち `swiftui-specialist` / `swiftui-whats-new-27` / `modernize-tests` / `audit-xcode-security-settings` はXcode 27に同梱されているAppleのスキルを `xcrun agent skills export --output-dir <dir>` でエクスポートしてそのまま置いたもの。**手で編集しない**（Xcodeを更新したら再エクスポートして差し替える）。シミュレータ・実機操作の `device-interaction` はXcode MCPサーバ（`xcrun mcpbridge`）への接続が前提なので `~/.claude/skills/` 側に置く。

## ルール（.claude/rules/）の運用

ルールファイルには必ずYAML frontmatterで`paths:`を指定し、対象のファイルを触るときだけ読み込まれるようにする。対象を無闇に広げない。`applyTo:`や本文の「対象範囲: 〜」はスコープとして機能しないので使わない。

```markdown
---
paths:
  - "LocalPackage/Sources/**/*.swift"
---
```

`adr.md` / `git-commit.md` は`paths:`を持たない（技術選定・コミット粒度はファイル種別に紐づかないため意図的に常時ロード）。
