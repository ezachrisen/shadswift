#!/bin/bash
# Tags a new version and pushes it. Consuming projects pick it up with
# `swift package update ShadSwift`, or `./Scripts/update-consumers.sh` for all of them.
#
#   ./Scripts/release.sh 0.2.0
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/Scripts/env.sh"
cd "$ROOT"

VERSION="${1:-}"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "usage: $0 <major.minor.patch>" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Working tree is dirty — commit or stash first." >&2
  git status --short >&2
  exit 1
fi

if git rev-parse "v$VERSION" >/dev/null 2>&1; then
  echo "Tag v$VERSION already exists." >&2
  exit 1
fi

echo "Building…"
swift build

echo "Checking icon geometry…"
"$ROOT/Scripts/check-icons.sh"

git tag -a "v$VERSION" -m "ShadSwift $VERSION"
git push origin main
git push origin "v$VERSION"

echo
echo "Released v$VERSION."
echo "Update every consuming project with: ./Scripts/update-consumers.sh"
