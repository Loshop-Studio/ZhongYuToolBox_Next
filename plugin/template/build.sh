#!/usr/bin/env bash
set -euo pipefail

DART_EVAL_VERSION="0.8.5"
ROOT="$(cd "$(dirname "$0")" && pwd)"
BINDINGS_DIR="$ROOT/.dart_eval/bindings"
BUILD_DIR="$ROOT/build/package"
DIST_DIR="$ROOT/dist"
PLUGIN_FILE="$DIST_DIR/zytb_plugin_template.zytbplugin"

cd "$ROOT"
flutter pub get

mkdir -p "$BINDINGS_DIR"
if [[ ! -f "$BINDINGS_DIR/flutter_eval.json" ]]; then
  curl -fL \
    -H "Accept: application/octet-stream" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/ethanblake4/flutter_eval/releases/assets/341897071" \
    -o "$BINDINGS_DIR/flutter_eval.json"
fi

dart pub global activate dart_eval "$DART_EVAL_VERSION"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

dart pub global run dart_eval:dart_eval compile -o "$BUILD_DIR/plugin.evc"
cp "$ROOT/manifest.json" "$BUILD_DIR/manifest.json"
rm -f "$PLUGIN_FILE"
(cd "$BUILD_DIR" && zip -qr "$PLUGIN_FILE" .)

echo "Built: $PLUGIN_FILE"
