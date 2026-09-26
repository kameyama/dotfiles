# dotfiles

XDG Base Directory に沿った最小構成の dotfiles。

## 構成

```
home/     -> ~/          (.zshenv のみ。ZDOTDIR を ~/.config/zsh に向ける)
config/   -> ~/.config/  (zsh, git, mise, starship)
Brewfile                 (brew bundle 用)
install.sh               (シンボリックリンク作成)
```

## セットアップ

```bash
git clone <repo> ~/dotfiles
~/dotfiles/install.sh          # リンクのみ
~/dotfiles/install.sh --brew   # リンク + brew bundle
```

既存ファイルは `~/.dotfiles_backup/<日時>/` に退避される。

## マシン固有の設定（git 管理外）

- `~/.config/zsh/local.zsh`
- `~/.config/git/config.local`（`user.name` / `user.email` など）

```ini
[user]
	name = Your Name
	email = you@example.com
```

## 追加方法

`config/<tool>/...` にファイルを置いて `install.sh` を再実行する。
