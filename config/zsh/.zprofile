# Login shell: PATH and environment variables.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

typeset -U path
path=("$HOME/.local/bin" $path)

export EDITOR="emacs"
export LANG="ja_JP.UTF-8"
