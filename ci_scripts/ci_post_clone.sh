#!/bin/sh

set -e

# Xcode Cloudランナーのアーキテクチャ（Intel / Apple Silicon）を確認する
echo "=== Runner architecture ==="
echo "uname -m: $(uname -m)"
echo "arch: $(arch)"
echo "==========================="

# Xcode CloudでSwift Package Managerプラグイン・マクロの検証をスキップする
# SwiftGenPlugin、PrefireTestsPlugin、SwiftLintPluginなどのBuild Tool Pluginを許可するために必要
# どのワークフローでも共通で必要なため、switch-caseの外で実行する
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

case "$CI_WORKFLOW" in
    "VRT" | "VRT_light")
        echo "=== $CI_WORKFLOW workflow ==="

        # スナップショット参照ファイルの確認
        SNAPSHOT_DIR="$CI_PRIMARY_REPOSITORY_PATH/StarterKitSnapshotTests/__Snapshots__/PreviewTests.generated"
        CI_SCRIPTS_SNAPSHOT_DIR="$CI_PRIMARY_REPOSITORY_PATH/ci_scripts/__Snapshots__"

        echo "CI_PRIMARY_REPOSITORY_PATH: $CI_PRIMARY_REPOSITORY_PATH"

        if [ -d "$SNAPSHOT_DIR" ]; then
            FILE_COUNT=$(ls "$SNAPSHOT_DIR" | wc -l)
            echo "✓ Snapshot directory exists at original path. File count: $FILE_COUNT"
        else
            echo "WARNING: Snapshot directory not found at: $SNAPSHOT_DIR"
        fi

        if [ -d "$CI_SCRIPTS_SNAPSHOT_DIR" ]; then
            FILE_COUNT=$(ls "$CI_SCRIPTS_SNAPSHOT_DIR" | wc -l)
            echo "✓ Snapshot directory accessible via ci_scripts. File count: $FILE_COUNT"
        else
            echo "WARNING: ci_scripts snapshot directory not found at: $CI_SCRIPTS_SNAPSHOT_DIR"
        fi
        echo "==========================="
        ;;

    "Upload For AppStore" | "Upload Release Candidate TestFlight" | "Upload Stg TestFlight")
        echo "=== $CI_WORKFLOW workflow ==="

        # 外部SDKの設定ファイル（GoogleService-Info.plistなど）やシークレットのxcconfigが必要になったら、
        # Xcode Cloudの環境変数（Secret）にbase64で入れておき、ここでデコードして配置する。例:
        #
        #   if [ -z "$SECRET_XCCONFIG" ]; then
        #       echo "ERROR: SECRET_XCCONFIG environment variable is not set"
        #       exit 1
        #   fi
        #   echo "$SECRET_XCCONFIG" | base64 --decode > "$CI_PRIMARY_REPOSITORY_PATH/StarterKit/Resources/Secret.xcconfig"
        echo "No secrets to decode."
        echo "==========================="
        ;;

    *)
        echo "Skipping ci_post_clone.sh (CI_WORKFLOW=$CI_WORKFLOW)"
        ;;
esac
