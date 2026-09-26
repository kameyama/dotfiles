#!/usr/bin/env bash
# Symlink dotfiles into $HOME. Existing files are moved to a backup directory.
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    echo "backup: $dst -> $BACKUP/"
  fi
  ln -snf "$src" "$dst"
  echo "link:   $dst -> $src"
}

# home/*   -> ~/*
# config/* -> ~/.config/*
cd "$DOTFILES"
find home -type f | while read -r f; do link "$DOTFILES/$f" "$HOME/${f#home/}"; done
find config -type f | while read -r f; do link "$DOTFILES/$f" "$XDG_CONFIG_HOME/${f#config/}"; done

if [ "${1:-}" = "--brew" ] && command -v brew >/dev/null; then
  brew bundle --file="$DOTFILES/Brewfile"
fi
