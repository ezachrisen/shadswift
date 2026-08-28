#!/bin/bash
# Regenerates Sources/ShadSwift/Support/LucideIcons.swift from the upstream
# Lucide SVGs. Lucide is ISC licensed.
#
# Add a glyph by putting its Lucide name in ICONS below and re-running.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

ICONS="check chevron-down chevron-up chevron-right chevron-left chevrons-up-down x plus \
minus search user users settings bell mail calendar house folder file trash-2 copy pencil \
share download upload star heart info circle-alert triangle-alert circle-check circle-x \
credit-card log-out ellipsis ellipsis-vertical panel-left panel-right arrow-up arrow-down \
arrow-right arrow-left arrow-up-right sparkles bot send refresh-cw eye eye-off lock globe \
terminal image play pause git-branch git-pull-request cloud cloud-upload zap tag bookmark \
clock funnel list layout-grid clipboard-list circle loader-circle grip-vertical slash arrow-up-down"

echo "==> Fetching $(echo $ICONS | wc -w | tr -d ' ') glyphs"
for name in $ICONS; do
  code=$(curl -sSL -o "$WORK/$name.svg" -w "%{http_code}" \
    "https://raw.githubusercontent.com/lucide-icons/lucide/main/icons/$name.svg")
  if [ "$code" != "200" ]; then
    echo "   missing upstream: $name" >&2
    rm -f "$WORK/$name.svg"
  fi
done

echo "==> Generating LucideIcons.swift"
SVG_DIR="$WORK" python3 "$ROOT/Scripts/generate-icons.py" > "$ROOT/Sources/ShadSwift/Support/LucideIcons.swift"

echo "==> Verifying every glyph parses"
source "$ROOT/Scripts/env.sh"
swift run --package-path "$ROOT" ShadSwiftDocs --check-icons
