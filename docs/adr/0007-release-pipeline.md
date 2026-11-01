## タイトル: リリースはリリースPRを起点に、Xcode CloudとGitHub Actionsで自動化する

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: homete_iOS の ADR-0016・0027・0032・0039・0045・0050

## 文脈、背景や問題点の説明

リリース作業（バージョンの更新・ビルドのアップロード・メタデータの同期・タグ付け）を手で行うと、手順の漏れが起きる。

## 決定事項

* `create-release-pr.yml`（手動実行）でバージョンを指定し、`MARKETING_VERSION` を更新した `release/<version>` ブランチとPRを作る
* `release/*` へのpushで、Xcode Cloudの `Upload Release Candidate TestFlight` / `Upload For AppStore` がビルドしてアップロードする
* `fastlane/metadata/`・`fastlane/screenshots/` の変更は `sync-metadata.yml` がApp Store Connectへ同期する。審査への提出は手動
* リリースPRでは `release-snapshot-diff.yml` が前回リリースのタグとVRTの参照画像を比較し、PRにレポートする
* リリースPRがmainにマージされたら `release-merged.yml` がタグとGitHub Releaseを作る

## 考慮した選択肢

* **Fastlaneをローカルから実行する**: 実行する人の環境に依存する。代替手段として `fastlane release` は残す
* **リリースPRを起点にCIで自動化する（採用）**

## 決定結果

### 決定にあたり考慮したメリット

* リリース手順がPRの上で追える

### 決定にあたり考慮したデメリット

* Xcode Cloudのワークフロー・App Store Connect APIキー・GitHub Appなど、初期設定が多い（README参照）

## 参考

* `fastlane/Fastfile`、`.github/workflows/`
