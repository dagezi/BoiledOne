#!/bin/bash
# Builds BoiledOne with SwiftPM and assembles it into BoiledOne.app, since
# `swift build` alone only produces a bare executable, not the signed .app
# bundle that InputMethodKit requires.
set -euo pipefail

cd "$(dirname "$0")"

CONFIGURATION="release"
APP_NAME="BoiledOne.app"

swift build -c "$CONFIGURATION"

BIN_PATH="$(swift build -c "$CONFIGURATION" --show-bin-path)"

rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS" "$APP_NAME/Contents/Resources"

cp "$BIN_PATH/BoiledOne" "$APP_NAME/Contents/MacOS/BoiledOne"
cp Packaging/Info.plist "$APP_NAME/Contents/Info.plist"
cp Sources/BoiledOne/Resources/*.dict "$APP_NAME/Contents/Resources/" 2>/dev/null || true
cp Sources/BoiledOne/Resources/*.tiff "$APP_NAME/Contents/Resources/"

codesign --force --deep --sign - \
    --entitlements Packaging/BoiledOne.entitlements \
    "$APP_NAME"

echo "Built $APP_NAME"
