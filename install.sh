#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCHEME="devbar"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="devbar.app"
INSTALL_DIR="/Applications"

echo "Building $SCHEME..."
xcodebuild \
  -project "$PROJECT_DIR/devbar.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR" \
  clean build | xcpretty 2>/dev/null || true

APP_PATH=$(find "$BUILD_DIR" -name "$APP_NAME" -not -path "*/SourcePackages/*" | head -1)

if [ -z "$APP_PATH" ]; then
  echo "Error: Could not find built $APP_NAME"
  exit 1
fi

echo "Installing to $INSTALL_DIR..."
if [ -d "$INSTALL_DIR/$APP_NAME" ]; then
  # Kill running instance if any
  pkill -x devbar 2>/dev/null || true
  rm -rf "$INSTALL_DIR/$APP_NAME"
fi
cp -R "$APP_PATH" "$INSTALL_DIR/$APP_NAME"

echo "Launching devbar..."
open "$INSTALL_DIR/$APP_NAME"

echo "Done. devbar installed to $INSTALL_DIR/$APP_NAME"
