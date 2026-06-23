#!/usr/bin/env bash
# init.sh — scaffold a new vibe-coding project in a target directory.
# Copies the .vibe state starter and AGENTS.md so you don't cp by hand.
#
# Usage:
#   ./scripts/init.sh                 # scaffold into the current directory
#   ./scripts/init.sh /path/to/proj   # scaffold into a specific directory
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-$(pwd)}"

if [ ! -d "$TARGET" ]; then
  echo "Target directory does not exist: $TARGET" >&2
  exit 1
fi

if [ -e "$TARGET/.vibe" ]; then
  echo "Refusing to overwrite existing $TARGET/.vibe" >&2
  echo "(this project already has vibe-coding state — use 'resume' instead)" >&2
  exit 1
fi

cp -R "$SRC_DIR/assets/.vibe"     "$TARGET/.vibe"
cp    "$SRC_DIR/assets/AGENTS.md" "$TARGET/AGENTS.md"

echo "Scaffolded vibe-coding project in: $TARGET"
echo "  + .vibe/      (project state — commit this to git)"
echo "  + AGENTS.md   (agent entry instructions)"
echo
echo "Now open $TARGET in Claude Code or Codex CLI and say:"
echo "  \"start a new vibe-coding project\""
