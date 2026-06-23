#!/usr/bin/env bash
# install.sh — install the vibe-coding skill for Claude Code and/or Codex CLI.
# Same SKILL.md, multiple target directories.
#
# Usage (run from repo root or scripts/):
#   ./scripts/install.sh                # all targets, copy mode
#   ./scripts/install.sh all link       # symlink mode (auto-updates on git pull)
#   ./scripts/install.sh claude         # only Claude Code
#   ./scripts/install.sh codex          # only Codex CLI
#   ./scripts/install.sh agents         # only universal ~/.agents fallback
set -euo pipefail

SKILL_NAME="vibe-coding"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_SRC="$REPO_ROOT/skills/$SKILL_NAME"

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "error: cannot find $SKILL_SRC/SKILL.md" >&2
  echo "       run this script from a clone of vibe-coding-skills" >&2
  exit 1
fi

CLAUDE_DIR="$HOME/.claude/skills/$SKILL_NAME"
CODEX_DIR="$HOME/.codex/skills/$SKILL_NAME"
AGENTS_DIR="$HOME/.agents/skills/$SKILL_NAME"

target="${1:-all}"   # all | claude | codex | agents
mode="${2:-copy}"    # copy | link

install_one () {
  local dest="$1"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  if [ "$mode" = "link" ]; then
    ln -s "$SKILL_SRC" "$dest"
    echo "linked  $SKILL_SRC -> $dest"
  else
    cp -R "$SKILL_SRC" "$dest"
    echo "copied  -> $dest"
  fi
}

case "$target" in
  claude) install_one "$CLAUDE_DIR" ;;
  codex)  install_one "$CODEX_DIR" ;;
  agents) install_one "$AGENTS_DIR" ;;
  all)
    install_one "$CLAUDE_DIR"
    install_one "$CODEX_DIR"
    install_one "$AGENTS_DIR"
    ;;
  *)
    echo "usage: ./scripts/install.sh [all|claude|codex|agents] [copy|link]" >&2
    exit 1
    ;;
esac

echo
echo "Done. Open any project in Claude Code or Codex CLI and say:"
echo "  \"start a new vibe-coding project\""
echo "The skill will scaffold .vibe/ in that project automatically."
