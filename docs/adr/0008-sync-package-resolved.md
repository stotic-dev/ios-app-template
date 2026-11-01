## タイトル: xcodeproj側のPackage.resolvedを、パッケージ側の解決結果にそろえる

* **承認済**
* 意思決定者: stotic-dev
* 日付: 2026-11-01
* 関連: homete_iOS ADR-0053

## 文脈、背景や問題点の説明

xcodeprojでビルドすると、使われるのはxcodeproj側の `Package.resolved` だけで、LocalPackage・InfraPackage側のものは読まれない。
dependabotはパッケージ側だけを更新するため、そのままではアプリの依存の版が上がらない。

## 決定事項

* 外部ライブラリはLocalPackage・InfraPackageの `Package.swift` からだけ参照し、xcodeprojから直接参照しない
* `scripts/sync-package-resolved.py` で、アプリ・VRTのxcodeprojの `Package.resolved` をパッケージ側にそろえる
* dependabotのPRでは `sync-package-resolved.yml` がそろえるコミットを積む。手で依存を上げたらスクリプトを流す

## 考慮した選択肢

* **xcodeprojにもバージョン指定を持つ**: 指定が二重になり、片方だけ更新されるとXcode Cloudの依存解決が失敗する

## 決定結果

### 決定にあたり考慮したメリット

* 依存の版の正がパッケージ側の1か所になる

### 決定にあたり考慮したデメリット

* xcodeproj側の `Package.resolved` を手で更新しないよう注意が要る

## 参考

* [マルチモジュール構成](../multimodules_structure.md)
