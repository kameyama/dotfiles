# Interactive shell settings.

# History
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000
[ -d "${HISTFILE:h}" ] || mkdir -p "${HISTFILE:h}"
setopt share_history hist_ignore_all_dups hist_ignore_space hist_reduce_blanks hist_no_store

# Options
setopt auto_cd auto_pushd pushd_ignore_dups interactive_comments
bindkey -e

# Completion
[ -d "$XDG_CACHE_HOME/zsh" ] || mkdir -p "$XDG_CACHE_HOME/zsh"
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# Aliases
alias ls='ls -G'
alias ll='ls -lah'
alias g='git'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto --exclude-dir=.git'
alias less='less -rq'

# Tools (loaded only if installed)
export FZF_DEFAULT_OPTS='--color=fg+:11 --height 70% --reverse --select-1 --exit-0 --multi'
command -v mise     >/dev/null && eval "$(mise activate zsh)"
command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"
command -v fzf      >/dev/null && source <(fzf --zsh)
command -v starship >/dev/null && eval "$(starship init zsh)"

# Machine-specific settings (not tracked by git)
[ -f "$ZDOTDIR/local.zsh" ] && source "$ZDOTDIR/local.zsh"
