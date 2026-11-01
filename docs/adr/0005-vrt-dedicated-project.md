## タイトル: VRTは専用のXcodeプロジェクトと空のホストアプリで流し、参照画像はCIで記録する

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: homete_iOS の ADR-0005・0029・0030・0047・0052

## 文脈、背景や問題点の説明

Prefireで `#Preview` からスナップショットテストを生成し、見た目の退行を検知する。アプリ本体をテストホストにすると
InfraPackageの外部SDKまで解決・ビルドすることになり、VRTの時間を押し上げる。また参照画像はローカルとCIで描画がわずかに違う。

## 決定事項

* VRTは専用の `StarterKitVRT.xcodeproj` で流す。参照するのはLocalPackageだけ。ホストはLocalPackageに依存しない空のアプリ `StarterKitVRTHost`
* 生成テストのテンプレートは `StarterKitSnapshotTests/Sources/generateTestTemplate.stencil`。iPhone 16 / iPhone SE (2nd generation) × ライト・ダークで撮る
* 参照画像の記録はXcode Cloudの `VRT_light` ワークフロー（`ci_scripts/ci_post_xcodebuild.sh`）が行い、PRブランチへcommit・pushする。ローカルの `make snapshot-affected` は参照を更新しない
* push用の認証はGitHub Appのインストールアクセストークンを使う

## 考慮した選択肢

* **アプリ本体のプロジェクトにテストターゲットを置く**: プロジェクトは1つで済むが、外部SDKの解決が付いてくる
* **ローカルで記録した参照画像をコミットする**: CIとの描画差でフレーキーになる

## 決定結果

### 決定にあたり考慮したメリット

* VRTが外部SDKを解決しない
* 参照画像の環境が1つにそろう

### 決定にあたり考慮したデメリット

* 同じLocalPackageを参照するため、`StarterKit.xcodeproj` と `StarterKitVRT.xcodeproj` は同時に開けない
* Featureを足したら、VRTプロジェクトのテストターゲットのリンク設定も更新する

## 参考

* `.claude/rules/prefire-preview.md`
