#!/usr/bin/env bash
# install.sh — install the vibe-coding skill for Claude Code and/or Codex CLI.
# Same SKILL.md, two target directories. Run from inside the vibe-coding/ folder.
set -euo pipefail

SKILL_NAME="vibe-coding"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLAUDE_DIR="$HOME/.claude/skills/$SKILL_NAME"
CODEX_DIR="$HOME/.codex/skills/$SKILL_NAME"
# Universal fallback path discovered by several CLI agents (Codex, Gemini, etc.)
AGENTS_DIR="$HOME/.agents/skills/$SKILL_NAME"

target="${1:-all}"   # all | claude | codex | agents
mode="${2:-copy}"    # copy | link

install_one () {
  local dest="$1"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  if [ "$mode" = "link" ]; then
    ln -s "$SRC_DIR" "$dest"
    echo "linked  -> $dest"
  else
    cp -R "$SRC_DIR" "$dest"
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
    echo "usage: ./install.sh [all|claude|codex|agents] [copy|link]" >&2
    exit 1
    ;;
esac

echo
echo "Done. To start a new project, copy the project starter into your repo:"
echo "  cp -R \"$SRC_DIR/assets/.vibe\"     /path/to/your/project/.vibe"
echo "  cp    \"$SRC_DIR/assets/AGENTS.md\" /path/to/your/project/AGENTS.md"
echo
echo "Then open the project in Claude Code or Codex CLI and say:"
echo "  \"start a new vibe-coding project\"   (or \"resume my vibe-coding project\")"
