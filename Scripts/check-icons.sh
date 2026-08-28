#!/bin/bash
# Verifies every bundled Lucide glyph parses into real geometry.
# A silent parser failure renders as nothing, which is easy to miss by eye.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/Scripts/env.sh"

swift run --package-path "$ROOT" ShadSwiftDocs --check-icons
