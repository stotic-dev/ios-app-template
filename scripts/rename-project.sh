#!/bin/bash
# テンプレートのアプリ固有の値（モジュールの接頭辞・アプリ名・バンドルID・表示名・Team IDなど）を一括で置き換える。
# テンプレートからリポジトリを作った直後に、1回だけ実行する。
#
#   scripts/rename-project.sh \
#     --prefix Mochi \
#     --app-name MochiNote \
#     --bundle-id com.example.mochinote \
#     --display-name もちノート \
#     --team-id ABCDE12345
#
# 置き換えるもの:
#   StarterKit               → --app-name（xcodeproj・ターゲット・スキーム・フォルダ名）
#   Starter                  → --prefix（StarterModel・StarterDomain などのモジュール名、StarterColor など）
#   com.example.starterkit   → --bundle-id（Debug/Stg は末尾に .dev、VRTは .vrthost / .snapshottests）
#   スターターキット          → --display-name（Debug/Stg は「[開発用]」が前に付く）
#   DEVELOPMENT_TEAM・ExportOptions の teamID → --team-id
#   stotic-dev/ios-app-template → --repo（省略時は git remote origin から）
#   you@example.com          → --apple-id（Fastlane の Appfile・Matchfile）
#   https://github.com/OWNER/certificates.git → --match-git-url（Fastlane Match の証明書リポジトリ）
set -euo pipefail

usage() {
  sed -n '2,21p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

PREFIX="" APP_NAME="" BUNDLE_ID="" DISPLAY_NAME="" TEAM_ID="" REPO="" APPLE_ID="" MATCH_GIT_URL="" DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --prefix) PREFIX="$2"; shift 2 ;;
    --app-name) APP_NAME="$2"; shift 2 ;;
    --bundle-id) BUNDLE_ID="$2"; shift 2 ;;
    --display-name) DISPLAY_NAME="$2"; shift 2 ;;
    --team-id) TEAM_ID="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --apple-id) APPLE_ID="$2"; shift 2 ;;
    --match-git-url) MATCH_GIT_URL="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h | --help) usage 0 ;;
    *) echo "不明な引数: $1" >&2; usage 1 ;;
  esac
done

die() { echo "error: $*" >&2; exit 1; }

[ -n "$PREFIX" ] || die "--prefix を指定してください"
[ -n "$APP_NAME" ] || die "--app-name を指定してください"
[ -n "$BUNDLE_ID" ] || die "--bundle-id を指定してください"
[ -n "$DISPLAY_NAME" ] || DISPLAY_NAME="$APP_NAME"

[[ "$PREFIX" =~ ^[A-Z][A-Za-z0-9]*$ ]] || die "--prefix は英大文字で始まる英数字にしてください: $PREFIX"
[[ "$APP_NAME" =~ ^[A-Z][A-Za-z0-9]*$ ]] || die "--app-name は英大文字で始まる英数字にしてください: $APP_NAME"
[[ "$BUNDLE_ID" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]] || die "--bundle-id の形式が正しくありません: $BUNDLE_ID"
[ -z "$TEAM_ID" ] || [[ "$TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || die "--team-id は10文字の英大文字・数字です: $TEAM_ID"
[[ "$DISPLAY_NAME" != *'"'* && "$DISPLAY_NAME" != *'\'* ]] || die "--display-name に \" と \\ は使えません"
# アプリ名とモジュール名がぶつからないようにする（StarterKit と StarterUI のように同じ接頭辞は可）
case "$APP_NAME" in
  "${PREFIX}Model" | "${PREFIX}Domain" | "${PREFIX}UI" | "${PREFIX}Resources" | "${PREFIX}Infrastructure" | "${PREFIX}SnapshotTestSupport")
    die "--app-name がモジュール名（$APP_NAME）とぶつかります" ;;
esac

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || die "gitリポジトリの中で実行してください"
cd "$ROOT"

[ -d StarterKit.xcodeproj ] || die "StarterKit.xcodeproj がありません。置き換え済みではありませんか？"
if [ "$DRY_RUN" -eq 0 ] && [ -n "$(git status --porcelain)" ]; then
  die "未コミットの変更があります。コミットしてから実行してください（置き換えの差分を確認しやすくするため）"
fi

if [ -z "$REPO" ]; then
  # GitHubのリモートでなければ置き換えない
  REPO=$(git remote get-url origin 2>/dev/null | sed -nE 's#^(https://github\.com/|git@github\.com:)([^/]+/[^/]+)$#\2#p' | sed 's#\.git$##') || true
fi
[ -z "$REPO" ] || [[ "$REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "--repo は owner/name の形式で指定してください: $REPO"
REPO_OWNER="${REPO%%/*}"

echo "接頭辞:       Starter → $PREFIX"
echo "アプリ名:     StarterKit → $APP_NAME"
echo "バンドルID:   com.example.starterkit → $BUNDLE_ID"
echo "表示名:       スターターキット → $DISPLAY_NAME"
echo "Team ID:      ${TEAM_ID:-（空のまま）}"
echo "リポジトリ:   ${REPO:-（置き換えない）}"
echo "Apple ID:     ${APPLE_ID:-（置き換えない）}"
echo "Match:        ${MATCH_GIT_URL:-（置き換えない）}"

# 置き換えは perl の1パスで行う（StarterKit を先に置き換えた結果が Starter の置き換えに巻き込まれないように）
export PREFIX APP_NAME BUNDLE_ID DISPLAY_NAME TEAM_ID REPO REPO_OWNER APPLE_ID MATCH_GIT_URL
SELF="scripts/rename-project.sh"

replace_contents() {
  perl -0777 -i -pe '
    BEGIN {
      %map = (
        "StarterKit" => $ENV{APP_NAME},
        "Starter" => $ENV{PREFIX},
        "com.example.starterkit" => $ENV{BUNDLE_ID},
      );
      $map{"スターターキット"} = $ENV{DISPLAY_NAME};
      if ($ENV{REPO} ne "") {
        $map{"stotic-dev/ios-app-template"} = $ENV{REPO};
        $map{"--owner stotic-dev"} = "--owner $ENV{REPO_OWNER}";
      }
      $map{"you\@example.com"} = $ENV{APPLE_ID} if $ENV{APPLE_ID} ne "";
      $map{"https://github.com/OWNER/certificates.git"} = $ENV{MATCH_GIT_URL} if $ENV{MATCH_GIT_URL} ne "";
      $re = join "|", map { quotemeta } sort { length($b) <=> length($a) } keys %map;
    }
    s/($re)/$map{$1}/g;
    if ($ENV{TEAM_ID} ne "") {
      s/DEVELOPMENT_TEAM = "";/DEVELOPMENT_TEAM = $ENV{TEAM_ID};/g;
      s#(<key>teamID</key>\s*<string>)(</string>)#$1$ENV{TEAM_ID}$2#g;
    }
  ' "$1"
}

new_path() {
  printf '%s' "$1" | perl -pe 's/(StarterKit|Starter)/$1 eq "StarterKit" ? $ENV{APP_NAME} : $ENV{PREFIX}/ge'
}

# 1. ファイルの中身（テキストだけ。このスクリプト自身は除く）
changed=0
while IFS= read -r -d '' f; do
  [ "$f" = "$SELF" ] && continue
  [ -L "$f" ] && continue
  [ -f "$f" ] || continue
  grep -Iq . "$f" 2>/dev/null || continue
  if [ "$DRY_RUN" -eq 1 ]; then
    tmp=$(mktemp); cp "$f" "$tmp"; replace_contents "$tmp"
    cmp -s "$f" "$tmp" || { echo "  変更: $f"; changed=$((changed + 1)); }
    rm -f "$tmp"
  else
    before=$(shasum "$f")
    replace_contents "$f"
    [ "$before" = "$(shasum "$f")" ] || changed=$((changed + 1))
  fi
done < <(git ls-files -z)
echo "中身を置き換えたファイル: $changed"

# 2. ファイル・フォルダの名前（シンボリックリンクはリンク先も置き換える）
renamed=0
while IFS= read -r -d '' f; do
  [ "$f" = "$SELF" ] && continue
  dest=$(new_path "$f")
  if [ -L "$f" ]; then
    target=$(readlink "$f")
    new_target=$(new_path "$target")
    if [ "$dest" != "$f" ] || [ "$new_target" != "$target" ]; then
      renamed=$((renamed + 1))
      [ "$DRY_RUN" -eq 1 ] && { echo "  リンク: $f -> $new_target"; continue; }
      git rm -q --cached "$f"; rm "$f"
      mkdir -p "$(dirname "$dest")"
      ln -s "$new_target" "$dest"
      git add "$dest"
    fi
    continue
  fi
  [ "$dest" = "$f" ] && continue
  renamed=$((renamed + 1))
  [ "$DRY_RUN" -eq 1 ] && { echo "  移動: $f -> $dest"; continue; }
  mkdir -p "$(dirname "$dest")"
  git mv "$f" "$dest"
done < <(git ls-files -z)
echo "名前を変えたファイル: $renamed"

if [ "$DRY_RUN" -eq 0 ]; then
  # 移動で空になったフォルダを消す（gitは空のフォルダを持たないので、消しても失うものはない）
  find . -depth -type d -empty -not -path './.git' -not -path './.git/*' -delete 2>/dev/null || true
  git add -A -- . ':!scripts/rename-project.sh' >/dev/null

  left=$(git grep -l -I -e 'StarterKit' -e 'com\.example\.starterkit' -e 'スターターキット' -- ':!scripts/rename-project.sh' || true)
  if [ -n "$left" ]; then
    echo "warning: 置き換えきれなかった箇所があります:" >&2
    echo "$left" >&2
  fi

  cat <<EOF

置き換えました。変更はステージ済みです（git diff --cached で確認できます）。
次にやること:
  1. make setup-project
  2. open ${APP_NAME}.xcodeproj（スキーム ${APP_NAME} で実行）
  3. README.md・CLAUDE.md・docs/product-direction.md をアプリに合わせて書き換える
  4. README の「初期設定チェックリスト」に沿って外部サービスを設定する
このスクリプトはもう使わないので、消してかまいません（git rm scripts/rename-project.sh）。
EOF
fi
