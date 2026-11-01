## タイトル: 変更に関係するモジュールだけをビルド・テストする

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: [homete_iOS ADR-0048](https://github.com/stotic-dev/homete_iOS/blob/main/doc/adr/0048-verify-only-affected-modules.md)

## 文脈、背景や問題点の説明

モジュールが増えると、どの変更でも全ビルド・全テストを流すのは待ち時間が無駄になる。ローカル（Claude Codeの検証を含む）とCIで、
変更が届く範囲だけを検証したい。

## 決定事項

* `scripts/affected-modules.py` が `swift package dump-package` から依存グラフを読み、変更されたターゲットと、それに推移的に依存するターゲットを割り出す
* ローカルは `make affected` / `make build-affected` / `make test-affected` / `make snapshot-affected` を使う
* CIは、PRでは影響範囲のテストだけ、mainへのpushでは全テストを流す
* VRTは、ローカルでは直接変えたモジュールのプレビューだけ、CIでは推移的に影響を受けるモジュールのプレビューを流す。`Package.resolved`・VRTの設定・リリースPRでは全件

## 考慮した選択肢

* **常に全件を流す**: 判定を誤る心配は無いが、モジュールが増えるほど遅くなる
* **依存グラフから判定する（採用）**

## 決定結果

### 決定にあたり考慮したメリット

* 待ち時間が変更の大きさに比例する

### 決定にあたり考慮したデメリット

* 依存グラフに出ない変化（ツールチェーンの更新など）はリリースPRまで見つからない
* VRTのモジュールの一覧を `.prefire.yml` と `affected-modules.py` の両方で保守する

## 参考

* `.claude/skills/swift-code-verification/SKILL.md`
