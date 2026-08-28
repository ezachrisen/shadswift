#!/bin/bash
# Installs the ShadSwift agent skill for your user, so Claude Code knows the
# library in every project.
#
# Symlinks by default, so `git pull` in this repo updates the skill with no
# reinstall. Pass --copy for a real copy (another machine, or a shared box).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/Skill/shadswift"
DEST="$HOME/.claude/skills/shadswift"

if [[ ! -f "$SRC/SKILL.md" ]]; then
  echo "No skill at $SRC" >&2
  exit 1
fi

mkdir -p "$HOME/.claude/skills"

if [[ -e "$DEST" || -L "$DEST" ]]; then
  echo "Replacing existing $DEST"
  rm -rf "$DEST"
fi

if [[ "${1:-}" == "--copy" ]]; then
  cp -R "$SRC" "$DEST"
  echo "Copied → $DEST"
  echo "Re-run this after pulling library updates."
else
  ln -s "$SRC" "$DEST"
  echo "Linked  $DEST → $SRC"
  echo "Updates to this repo take effect immediately."
fi

echo
echo "Claude Code will load it in any project. Verify with /skills or by asking"
echo "Claude to build something with ShadSwift."
