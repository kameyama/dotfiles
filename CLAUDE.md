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

レシピはリポジトリ直下の `justfile` にある。`install.sh` と `brew bundle` は `~/` や `/opt/homebrew` に書き込むため、直接実行せず `just` 経由で単独のコマンドとして呼ぶ（前に `cd` を付けたり `&&` でつないだりしない）。`zsh -n` は1ファイルずつしか検査しないので、`check` ではループで回している。

- `just install` は `~/dotfiles`（メインのチェックアウト）で実行する。`install.sh` は自分の置き場所へリンクを張るので、worktree で実行すると、worktree を消したときにリンクが切れる。
- レシピは「サンドボックス外で実行してよいコマンドの許可リスト」として扱う。追加すると許可範囲が広がるので、何をするレシピかを説明し、ユーザーの許可を得てから追加する。レシピにない操作（`brew uninstall` など）はユーザーに実行を依頼する。

## セキュリティ（最優先）

このリポジトリは個人PCの設定だが、会社PCでも使い、GitHub に push する。リポジトリに入れてよいのは、どのPCでもそのまま使える汎用の設定だけ。

- **書かない・commit しないもの**: シークレット（トークン、パスワード、秘密鍵、認証情報）と会社の情報（社名、ドメイン、メールアドレス、人名、AWS などのプロファイル名やアカウントID、社内のホスト名や URL、顧客名や案件名、業務リポジトリのパス）。ファイルの中身だけでなく、コメント、例示、ファイル名、commit メッセージ、PR 本文にも書かない。
- **業務用・マシン固有の設定の置き場所**（すべて git 管理外）:
  - `~/.config/zsh/local.zsh`（環境変数、PATH、業務ツールの初期化）
  - `~/.config/git/config.local`（`user.name` / `user.email` など）
  - `~/.config/mise/conf.d/*.toml`（業務でだけ使うツール）。`mise use -g` はリンク先であるリポジトリの `config/mise/config.toml` を書き換えるので使わない。
  - `~/.config/dotfiles/deny-patterns`（会社の情報を検出するパターン。個人PCでは空ファイル）
- **PCの既存設定を取り込むとき**: `~/` や `~/.config` の中身をリポジトリへ移す前に、1行ずつ汎用か業務用かを判断し、業務用は上の git 管理外のファイルへ回す。判断できない行はリポジトリに入れず、ユーザーに聞く。
- **commit の作者**: 会社PCでは `config.local` の業務用メールが作者として記録される。このリポジトリでは、リポジトリローカルの `user.email` に個人用アドレス（GitHub の noreply など）を設定しておく。commit 前に `git config user.email` を確認し、会社のアドレスなら commit しない。
- **commit 前・push 前**: `check-secrets` スキルで検査してから commit・push する。見つけたら commit せずユーザーに報告する。commit 後に気づいたら push せず、ユーザーに報告する（履歴の書き換えが必要になる）。
- **hook**: `.claude/settings.json` の PreToolUse hook（`.claude/hooks/check-secrets.sh`）が、Claude の `git commit` / `git push` の前に機械的な検査を走らせ、見つかれば止める。hook はパターンにある語しか捕まえないので、スキルの目で読む検査の代わりにはならない。止められたら、hook を外したり回避したりせず、`check-secrets` スキルで中身を確かめてユーザーに報告する。

## 構成の要点

- **リンクの対応**: `install.sh` は `home/` 以下を `~/`、`config/` 以下を `~/.config/` へ**ファイル単位で**リンクする（ディレクトリごとのリンクではない）。ファイルを追加したら `install.sh` を再実行する。ファイルを削除やリネームしても、`~/.config` 側の古いリンクは残る。
- **zsh の読み込み順**: `home/.zshenv` で XDG 変数と `ZDOTDIR=~/.config/zsh` を設定する。以降は `config/zsh/.zprofile`（ログインシェル: brew shellenv、PATH、`EDITOR=emacs`）、`config/zsh/.zshrc`（対話シェル）の順に読まれる。`~/.zshrc` などホーム直下の zsh ファイルは使わない。`.zshrc` は `.zshenv` で定義した `$XDG_*` を前提にしている。
- **外部ツールの初期化**: `.zshrc` では mise, zoxide, fzf, starship を `command -v` でガードして読み込む。未インストールでも壊れない形を保つ。
- **マシン固有の設定は git 管理外**: 置き場所は「セキュリティ」を参照。`config/git/config` は `[include]` で `~/.config/git/config.local` を読み、`.zshrc` は最後に `~/.config/zsh/local.zsh` を読む。
- **git のエディタ**: `core.editor` は設定せず `$EDITOR` に従う。

## ツール方針

- 言語ランタイム（python, node, terraform, uv）は **mise** で管理する（`config/mise/config.toml`）。asdf, pyenv, direnv は使わない（移行済み）。julia は mise ではなく brew の `juliaup` で管理する。
- `Brewfile` には直接使うパッケージだけを書き、依存で入るもの（例: emacs-plus が使う gnutls, texinfo）は書かない。
- `emacs-plus@31` は公式以外の tap（`d12frosted/emacs-plus`）から入れる。tap 全体を `brew trust d12frosted/emacs-plus` で信頼済みにしておく必要がある。formula 単位で信頼すると、tap に新しい版が追加されたときに `brew bundle` が止まる。
