#!/bin/bash
# Renders every component snapshot and regenerates the HTML documentation.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/Scripts/env.sh"

swift run --package-path "$ROOT" ShadSwiftDocs "$ROOT/Docs"
echo
echo "Open ${ROOT}/Docs/index.html"
