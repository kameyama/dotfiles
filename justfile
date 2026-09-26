set shell := ["bash", "-euo", "pipefail", "-c"]

# レシピ一覧
default:
    just --list

# Symlink dotfiles into ~ and ~/.config
install:
    ./install.sh

# Install packages from Brewfile
brew:
    brew bundle --file=Brewfile

# Read-only checks: shell syntax, git config, Brewfile
check:
    bash -n install.sh
    for f in home/.zshenv config/zsh/.zprofile config/zsh/.zshrc; do zsh -n "$f"; done
    git config -f config/git/config -l >/dev/null
    brew bundle check --file=Brewfile --verbose
