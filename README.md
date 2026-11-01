# ios-app-template

SwiftUI + SPMマルチモジュール構成のiOSアプリを始めるためのテンプレートです。モジュール構成・DI・ユニットテスト・VRT（スナップショットテスト）・CI/CD・Claude Codeの設定までを最初から揃えています。

実装方針・CI・環境構築は [homete_iOS](https://github.com/stotic-dev/homete_iOS) を元にしています。

## 入っているもの

| 分類 | 内容 |
|---|---|
| モジュール構成 | `LocalPackage`（Model / Domain / UI / Resources / Feature）、`InfraPackage`（Clientの`liveValue`・AppRoot）、`ProjectTools`（SwiftLint・SwiftFormat）、`DangerTools`。詳細は [docs/multimodules_structure.md](docs/multimodules_structure.md) |
| 実装方針 | クロージャを持つClient + `AppDependencies` によるDI、`@MainActor @Observable` のStore、`RouteResolver` によるFeature間の遷移、UIだけのView（`XxxFeatureUI`）とロジックを持つScreen（`XxxFeature`）の分離 |
| サンプル | アイテムの一覧と追加だけの `HomeFeature`（データはメモリ上）。アプリの最初の機能に置き換えて使います |
| プロジェクト | `StarterKit.xcodeproj`（Debug / Stg / Release、スキーム `StarterKit` と `production`）、VRT専用の `StarterKitVRT.xcodeproj` |
| テスト | Swift Testingのユニットテスト、Prefire + swift-snapshot-testing によるVRT、変更に関係するモジュールだけを検証する `make affected` 系のコマンド |
| CI/CD | GitHub Actions（パッケージのテスト・ビルド、Danger、`Package.resolved` の同期、リリースPRの作成からタグ付けまで）、Xcode Cloud（`ci_scripts/`）、Fastlane（Match・TestFlight・App Store） |
| 開発環境 | Makefile、git hooks（pre-commitでSwiftFormat）、rbenv / Bundler、[worktrunk](https://github.com/max-sixty/worktrunk) の設定 |
| Claude Code | `CLAUDE.md`、`.claude/`（ルール・スキル・エージェント・Stopフックでのプレビュー検査） |
| ドキュメント | 技術選定の記録（[docs/adr/](docs/adr/)）、コードスタイル、ローカライズ |

最低対応は iOS 26、開発は Xcode 27.1 以上です（CIは Xcode 26.4.1）。

## 使い方

### 1. リポジトリを作る

GitHubの「Use this template」から作るか、`gh` で作ります。

```bash
gh repo create <owner>/<repo> --template stotic-dev/ios-app-template --private --clone
cd <repo>
```

### 2. アプリ固有の値に置き換える

モジュールの接頭辞・アプリ名・バンドルID・表示名・Team IDを、ファイルの中身とファイル名の両方で一括で置き換えます。

```bash
scripts/rename-project.sh \
  --prefix Mochi \
  --app-name MochiNote \
  --bundle-id com.example.mochinote \
  --display-name もちノート \
  --team-id ABCDE12345 \
  --apple-id you@example.com \
  --match-git-url https://github.com/<owner>/<certificates>.git
```

| 引数 | 置き換え前 | 例 | 必須 |
|---|---|---|---|
| `--prefix` | `Starter`（`StarterModel`・`StarterDomain`・`StarterColor` など） | `Mochi` | ✅ |
| `--app-name` | `StarterKit`（xcodeproj・ターゲット・スキーム・フォルダ） | `MochiNote` | ✅ |
| `--bundle-id` | `com.example.starterkit`（開発用は `.dev` が付く） | `com.example.mochinote` | ✅ |
| `--display-name` | `スターターキット`（開発用は `[開発用]` が付く） | `もちノート` | 省略時はアプリ名 |
| `--team-id` | 空（`DEVELOPMENT_TEAM`・`ExportOptions`） | `ABCDE12345` | |
| `--repo` | `stotic-dev/ios-app-template` | `owner/repo` | 省略時は `git remote origin` |
| `--apple-id` | `you@example.com`（Fastlane） | | |
| `--match-git-url` | `https://github.com/OWNER/certificates.git`（Fastlane Match） | | |

`--dry-run` を付けると、変わるファイルの一覧だけを表示します。置き換えた結果はステージされるので、`git diff --cached` で確かめてからコミットしてください。

### 3. 環境を作って動かす

```bash
make setup-project      # rbenv・Ruby・Bundler・Fastlane・ProjectTools・git hooks
make test-packages-fast # LocalPackageのユニットテスト
open <アプリ名>.xcodeproj
```

VRTを扱うときは `<アプリ名>VRT.xcodeproj` を開きます（同じLocalPackageを参照するため、2つは同時に開けません）。よく使うコマンドは `make help` で一覧できます。

### 4. アプリに合わせて書き換える

- [ ] `README.md`（このファイル）をアプリの説明に書き換える
- [ ] `CLAUDE.md` の「プロジェクト概要」を書き換える
- [ ] [docs/product-direction.md](docs/product-direction.md) にターゲット・価値の柱・やらないことを書く（`pdm` エージェントと文言のルールが参照する）
- [ ] `.claude/rules/ux-writing.md` の「このアプリらしい言葉にするための原則」を書き換える
- [ ] サンプルの `HomeFeature` / `Item` を最初の機能に置き換える（Featureの足し方は [docs/multimodules_structure.md](docs/multimodules_structure.md)）
- [ ] `docs/localization.md` の用語の対応表を書き換える
- [ ] アプリアイコン（`<アプリ名>/Assets.xcassets` の `AppIcon`・`AppIconDev`）と色（`LocalPackage/Sources/<接頭辞>Resources/Resources/Colors.xcassets`）を差し替える
- [ ] 使わない仕組み（Xcode Cloud・リリース系のワークフローなど）があれば消す
- [ ] `scripts/rename-project.sh` を消す

## 初期設定チェックリスト（CI/CDを動かすまで）

コードは揃っていますが、外部サービス側の設定は各リポジトリで行います。必要になった順に設定してください。

- [ ] Apple Developer でバンドルID（本番用と `.dev`）を登録し、App Store Connect にアプリを作る
- [ ] Fastlane Match の証明書リポジトリを用意し、`make setup-signing`（`bundle exec fastlane update_profile` / `update_profile_prod`）で証明書・プロファイルを作る。App Store ConnectのAPIキー（`ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_API_KEY_PATH`）を環境変数に設定してから実行する
- [ ] GitHub リポジトリの Secrets
  - `DANGER_GITHUB_API_TOKEN`（Danger がPRにコメントする）
  - `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_SECRET_KEY`（`sync-metadata.yml` がメタデータを同期する）
- [ ] Xcode Cloud のワークフロー（`ci_scripts/` が `$CI_WORKFLOW` で分岐する）
  - `VRT_light`: プロジェクト `<アプリ名>VRT.xcodeproj`、スキーム `<アプリ名>VRTHost` の Build アクション。環境変数 `GH_APP_ID` / `GH_APP_PRIVATE_KEY_BASE64`（Secret）/ `GITHUB_REPOSITORY`（参照画像をPRへpushするGitHub App。Contents: Read and write）
  - `Upload Stg TestFlight` / `Upload Release Candidate TestFlight` / `Upload For AppStore`: スキーム `<アプリ名>`（Stg）/ `production`（Release）の Archive
- [ ] App Store Connect のメタデータ（`fastlane/metadata/`・`fastlane/screenshots/`）を用意する
- [ ] Issue を集める GitHub Project を作り、`.claude/skills/issue-create/SKILL.md` に番号とIDを書く

詳細は [ADR-0005（VRT）](docs/adr/0005-vrt-dedicated-project.md)・[ADR-0007（リリース）](docs/adr/0007-release-pipeline.md) を参照してください。

## ドキュメント

- [マルチモジュール構成](docs/multimodules_structure.md) — モジュールの責務・DI・画面遷移・Featureの足し方
- [コードスタイル統一: SwiftFormat & SwiftLint](docs/tech/code-style.md)
- [ローカライズ](docs/localization.md)
- [ADR（技術選定の記録）](docs/adr/)
