# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

macOS (Apple Silicon, Homebrew は `/opt/homebrew`) 向けの XDG Base Directory 準拠の dotfiles。ビルドやテストはない。

## コマンド

```bash
just install   # ./install.sh: シンボリックリンク作成（既存の実ファイルは ~/.dotfiles_backup/<日時>/ に退避）
just brew      # brew bundle
just check     # 変更後の検証: bash -n / zsh -n / git config -l / brew bundle check
```

レシピは `~/justfile` にある（リポジトリの外。実行ルールは `~/.claude/CLAUDE.md` の「コマンドの実行」）。`install.sh` と `brew bundle` は `~/` や `/opt/homebrew` に書き込むため、直接実行せず `just` 経由で単独のコマンドとして呼ぶ。`zsh -n` は1ファイルずつしか検査しないので、`check` ではループで回している。

## 構成の要点

- **リンクの対応**: `install.sh` は `home/` 以下を `~/`、`config/` 以下を `~/.config/` へ**ファイル単位で**リンクする（ディレクトリごとのリンクではない）。ファイルを追加したら `install.sh` を再実行する。ファイルを削除やリネームしても、`~/.config` 側の古いリンクは残る。
- **zsh の読み込み順**: `home/.zshenv` で XDG 変数と `ZDOTDIR=~/.config/zsh` を設定する。以降は `config/zsh/.zprofile`（ログインシェル: brew shellenv、PATH、`EDITOR=emacs`）、`config/zsh/.zshrc`（対話シェル）の順に読まれる。`~/.zshrc` などホーム直下の zsh ファイルは使わない。`.zshrc` は `.zshenv` で定義した `$XDG_*` を前提にしている。
- **外部ツールの初期化**: `.zshrc` では mise, zoxide, fzf, starship を `command -v` でガードして読み込む。未インストールでも壊れない形を保つ。
- **マシン固有の設定は git 管理外**: `~/.config/zsh/local.zsh` と `~/.config/git/config.local`（`user.name` / `user.email`）。`config/git/config` は `[include]` で後者を読む。名前やメールアドレスをリポジトリに書かない。
- **git のエディタ**: `core.editor` は設定せず `$EDITOR` に従う。

## ツール方針

- 言語ランタイム（python, node, terraform, uv）は **mise** で管理する（`config/mise/config.toml`）。asdf, pyenv, direnv は使わない（移行済み）。julia は mise ではなく brew の `juliaup` で管理する。
- `Brewfile` には直接使うパッケージだけを書き、依存で入るもの（例: emacs-plus が使う gnutls, texinfo）は書かない。
- `emacs-plus@31` は公式以外の tap（`d12frosted/emacs-plus`）から入れる。tap 全体を `brew trust d12frosted/emacs-plus` で信頼済みにしておく必要がある。formula 単位で信頼すると、tap に新しい版が追加されたときに `brew bundle` が止まる。
