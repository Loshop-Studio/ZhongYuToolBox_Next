#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DART_EVAL_VERSION="0.8.5"
BINDINGS_DIR="$ROOT/.dart_eval/bindings"
BINDINGS_FILE="$BINDINGS_DIR/flutter_eval.json"
EXAMPLE_BINDINGS_FILE="$ROOT/../example/.dart_eval/bindings/flutter_eval.json"
BUILD_DIR="$ROOT/build/package"
DIST_DIR="$ROOT/dist"
PLUGIN_ID="com.zhongyu.toolbox.profile"
PLUGIN_FILE="$DIST_DIR/$PLUGIN_ID/$PLUGIN_ID.zytbplugin"
INDEX_FILE="$DIST_DIR/index.txt"

cd "$ROOT"
flutter pub get
mkdir -p "$BINDINGS_DIR"
if [[ -f "$EXAMPLE_BINDINGS_FILE" ]]; then
  cp "$EXAMPLE_BINDINGS_FILE" "$BINDINGS_FILE"
elif [[ ! -f "$BINDINGS_FILE" ]]; then
  curl --fail --location --retry 3 \
    --header 'Accept: application/octet-stream' \
    --header 'X-GitHub-Api-Version: 2022-11-28' \
    --output "$BINDINGS_FILE" \
    'https://api.github.com/repos/ethanblake4/flutter_eval/releases/assets/341897071'
fi

dart pub global activate dart_eval "$DART_EVAL_VERSION"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR" "$(dirname "$PLUGIN_FILE")"
dart pub global run dart_eval:dart_eval compile -o "$BUILD_DIR/plugin.evc"
cp "$ROOT/manifest.json" "$BUILD_DIR/manifest.json"
(cd "$BUILD_DIR" && zip -q -r "$PLUGIN_FILE" manifest.json plugin.evc)
printf '(com.zhongyu.toolbox.profile@1.0.5)[个人信息]查看和编辑当前账号个人资料。\n' > "$INDEX_FILE"
printf 'Built: %s\n' "$PLUGIN_FILE"
printf 'Index: %s\n' "$INDEX_FILE"
