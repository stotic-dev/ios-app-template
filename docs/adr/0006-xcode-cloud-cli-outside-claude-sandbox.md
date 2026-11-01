## タイトル: Xcode Cloudの状態を確かめるCLIは、Claude Codeのサンドボックス外で動かす

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: homete_iOS ADR-0049

## 文脈、背景や問題点の説明

Xcode Cloudのビルド結果・ログ・xcresultは、App Store Connect APIで取れる。APIの秘密鍵の読み取りと、App Store Connect・
artifactのダウンロード先への通信が要るため、Claude Codeのサンドボックス内では動かない。

## 決定事項

* `scripts/xcode-cloud.sh` を `.claude/settings.json` の `sandbox.excludedCommands` と `permissions.allow` の両方に入れる
* 除外するのはスクリプトのパスに限り、`make *` のような広いパターンは入れない

## 考慮した選択肢

* **サンドボックス内で動かす**: 秘密鍵の読み取りと通信先の許可を広げることになる
* **スクリプトだけを除外する（採用）**

## 決定結果

### 決定にあたり考慮したメリット

* CIの失敗の調査をClaude Codeに任せられる

### 決定にあたり考慮したデメリット

* スクリプトの中身を変えるときは、サンドボックス外で動くことを前提にレビューする

## 参考

* `.claude/skills/xcode-cloud-check/SKILL.md`
