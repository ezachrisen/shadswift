#!/bin/bash
# Builds ShadSwiftDemo and wraps it in a real .app bundle so it launches with a
# Dock icon, a menu bar and normal window behaviour.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/Scripts/env.sh"

CONFIG="${1:-release}"
APP="$ROOT/build/ShadSwiftDemo.app"

echo "==> Building ShadSwiftDemo ($CONFIG)"
swift build -c "$CONFIG" --product ShadSwiftDemo --package-path "$ROOT"
BIN="$(swift build -c "$CONFIG" --product ShadSwiftDemo --package-path "$ROOT" --show-bin-path)/ShadSwiftDemo"

echo "==> Assembling $APP"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/ShadSwiftDemo"

# SwiftPM keeps target resources in a sibling bundle; the app needs its own copy
# or Geist will not be found at runtime.
BIN_DIR="$(dirname "$BIN")"
for bundle in "$BIN_DIR"/*.bundle; do
  [ -e "$bundle" ] || continue
  cp -R "$bundle" "$APP/Contents/Resources/"
done

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>            <string>ShadSwift</string>
    <key>CFBundleDisplayName</key>     <string>ShadSwift</string>
    <key>CFBundleExecutable</key>      <string>ShadSwiftDemo</string>
    <key>CFBundleIdentifier</key>      <string>dev.shadswift.demo</string>
    <key>CFBundlePackageType</key>     <string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key>         <string>1</string>
    <key>LSMinimumSystemVersion</key>  <string>14.0</string>
    <key>NSPrincipalClass</key>        <string>NSApplication</string>
    <key>NSHighResolutionCapable</key> <true/>
    <!-- A gallery app has nothing worth restoring, and the restore prompt
         blocks window creation after any crash during development. -->
    <key>NSQuitAlwaysKeepsWindows</key>  <false/>
    <key>ApplePersistenceIgnoreState</key><true/>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP" 2>/dev/null || true
echo "==> Done: $APP"
