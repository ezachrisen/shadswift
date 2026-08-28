#!/bin/bash
# Pulls the latest ShadSwift into every project that depends on it.
#
#   ./Scripts/update-consumers.sh              # searches ~/code
#   ./Scripts/update-consumers.sh ~/projects   # searches somewhere else
#   DRY_RUN=1 ./Scripts/update-consumers.sh    # just list what would be updated
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/Scripts/env.sh"

SEARCH_ROOT="${1:-$HOME/code}"
SELF="$(basename "$ROOT")"

if [[ ! -d "$SEARCH_ROOT" ]]; then
  echo "No such directory: $SEARCH_ROOT" >&2
  exit 1
fi

echo "Searching $SEARCH_ROOT for projects that depend on ShadSwift…"
echo

found=0
while IFS= read -r manifest; do
  project="$(dirname "$manifest")"
  [[ "$(basename "$project")" == "$SELF" ]] && continue
  grep -qi "shadswift" "$manifest" || continue

  found=$((found + 1))
  echo "→ $project"
  if [[ -n "${DRY_RUN:-}" ]]; then
    continue
  fi
  if (cd "$project" && swift package update ShadSwift 2>&1 | sed 's/^/    /'); then
    :
  else
    echo "    (failed — resolve by hand)"
  fi
done < <(find "$SEARCH_ROOT" -maxdepth 4 -name Package.swift -not -path "*/.build/*" 2>/dev/null)

# Xcode projects keep their pin in a Package.resolved inside the project bundle.
while IFS= read -r resolved; do
  grep -qi "shadswift" "$resolved" || continue
  container="$(dirname "$(dirname "$(dirname "$resolved")")")"
  found=$((found + 1))
  echo "→ $container  (Xcode — File ▸ Packages ▸ Update to Latest Package Versions)"
done < <(find "$SEARCH_ROOT" -maxdepth 6 -name Package.resolved -path "*.xc*" 2>/dev/null)

echo
if [[ "$found" -eq 0 ]]; then
  echo "Nothing found. Pass a different search root if your projects live elsewhere."
else
  echo "$found project(s)."
fi
