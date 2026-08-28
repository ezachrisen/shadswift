#!/bin/bash
# Captures the demo app's window to a PNG.
#
#   Scripts/capture-window.sh out.png [owner-name]
#
# Uses the window server's own list rather than AppleScript, so it never
# triggers the System Events automation prompt.
set -euo pipefail

OUT="${1:?usage: capture-window.sh out.png [owner]}"
OWNER="${2:-ShadSwift}"

ID=$(cat <<'SWIFT' | xcrun swift - "$OWNER"
import CoreGraphics
import Foundation

let owner = CommandLine.arguments.dropFirst().first ?? "ShadSwift"
let windows = CGWindowListCopyWindowInfo(
    [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
) as? [[String: Any]] ?? []

// The frontmost window belonging to the app, largest first.
let matches = windows
    .filter { ($0[kCGWindowOwnerName as String] as? String) == owner }
    .filter { ($0[kCGWindowLayer as String] as? Int) == 0 }
    .sorted {
        let a = $0[kCGWindowBounds as String] as? [String: CGFloat] ?? [:]
        let b = $1[kCGWindowBounds as String] as? [String: CGFloat] ?? [:]
        return (a["Width"] ?? 0) * (a["Height"] ?? 0) > (b["Width"] ?? 0) * (b["Height"] ?? 0)
    }

if let id = matches.first?[kCGWindowNumber as String] as? Int {
    print(id)
}
SWIFT
)

if [ -z "$ID" ]; then
  echo "no on-screen window owned by '$OWNER'" >&2
  exit 1
fi

screencapture -x -o -l "$ID" "$OUT"
echo "$OUT"
