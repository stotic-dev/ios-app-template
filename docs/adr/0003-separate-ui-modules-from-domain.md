## タイトル: UIのモジュールをStore・UseCase・Clientから切り離す

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: [homete_iOS ADR-0063](https://github.com/stotic-dev/homete_iOS/blob/main/doc/adr/0063-split-ui-modules-from-domain-for-affected-vrt.md)

## 文脈、背景や問題点の説明

homete_iOSでは、すべてのFeatureと共通UIが `HometeDomain` に依存していたため、画面に関係しないStore・Clientの変更でも
VRTが全件になった。後から分割するには、値型の移動とプレビューの書き直しが数十ファイル単位で必要になった。

## 決定事項

* UIが使う値型（ドメインモデル）は `StarterModel` に置く。依存は無し（最下層）。Store・UseCase・Clientは置かない
* `StarterDomain` はUIが使わない値型・Client・Store・UseCase・AppRouteを持ち、`StarterModel` を再公開する
* `StarterUI` は `StarterModel`・`StarterResources` にだけ依存する
* Featureは `XxxFeatureUI`（UIのみのView `XxxView` / `XxxContent` とプレビュー）と `XxxFeature`（ロジックを持つView `XxxScreen` / `XxxComponent`）に分ける。`XxxFeatureUI` は `StarterDomain` に依存しない
* プレビューは `StarterUI` と `XxxFeatureUI` にだけ置く

## 考慮した選択肢

* **Featureを1モジュールにする**: モジュール数は少ないが、UIとロジックの分離がレビュー頼みになり、VRTの対象も絞れない
* **UIに表示専用の型（ViewState）だけを渡す**: もっとも確実だが、ドメインモデルと同じ形の型を画面ごとに持つことになる
* **値型のドメインモデルはUIから使ってよく、Store・Clientからだけ切り離す（採用）**

## 決定結果

### 決定にあたり考慮したメリット

* 「UIのみのViewはStoreに依存しない」ルールを、モジュールの依存関係で保証できる
* Store・Clientだけの変更ではVRTが流れない
* プレビューが値を直接渡す形にそろい、表示のバリエーションを引数だけで並べられる

### 決定にあたり考慮したデメリット

* Featureごとにモジュールが2つになる。`Package.swift`・`.prefire.yml`・VRTのリンク設定・`affected-modules.py` の保守が要る

## 参考

* `.claude/rules/ui-logic-view-separation.md`、`.claude/rules/presentation-logic-placement.md`
