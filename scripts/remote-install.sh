#!/usr/bin/env bash
# remote-install.sh — one-line installer for the vibe-coding skill.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/zlx362211854/vibe-coding-skills/main/scripts/remote-install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/zlx362211854/vibe-coding-skills/main/scripts/remote-install.sh | bash -s -- codex
#   curl -fsSL https://raw.githubusercontent.com/zlx362211854/vibe-coding-skills/main/scripts/remote-install.sh | bash -s -- all link
#
# Args (positional, both optional):
#   $1 = target: all | claude | codex | agents   (default: all)
#   $2 = mode:   copy | link                     (default: copy)
set -euo pipefail

REPO_URL="https://github.com/zlx362211854/vibe-coding-skills.git"
CACHE_DIR="$HOME/.cache/vibe-coding-skills"

target="${1:-all}"
mode="${2:-copy}"

if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required" >&2
  exit 1
fi

mkdir -p "$(dirname "$CACHE_DIR")"

if [ -d "$CACHE_DIR/.git" ]; then
  echo ">> updating cached clone at $CACHE_DIR"
  git -C "$CACHE_DIR" fetch --depth 1 origin HEAD
  git -C "$CACHE_DIR" reset --hard FETCH_HEAD
else
  echo ">> cloning $REPO_URL -> $CACHE_DIR"
  rm -rf "$CACHE_DIR"
  git clone --depth 1 "$REPO_URL" "$CACHE_DIR"
fi

chmod +x "$CACHE_DIR/scripts/install.sh"
"$CACHE_DIR/scripts/install.sh" "$target" "$mode"

echo
echo "Tip: re-run this same curl line later to upgrade."
echo "     Or use 'link' mode and 'git -C $CACHE_DIR pull' to live-update."
