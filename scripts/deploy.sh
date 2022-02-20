#!/usr/bin/env bash -eu
# create symbolic links from $DOTFILES_PATH to $HOME

if [ ! -d "$DOTFILES_PATH" ]; then
  echo "ERROR: $DOTFILES_PATH does not exist."
  exit 1
fi

cd "$DOTFILES_PATH"

echo "create symbolic links from $DOTFILES_PATH to $HOME"

find "$DOTFILES_PATH/.config" -maxdepth 1 -mindepth 1 | xargs -I% ln -snfv % "$XDG_CONFIG_HOME"

for file in .??*; do
  [ "$file" = ".git" ] && continue
  [ "$file" = ".gitignore" ] && continue
  [ "$file" = ".gitattributes" ] && continue
  [ "$file" = ".github" ] && continue
  [ "$file" = ".DS_Store" ] && continue
  [ "$file" = ".editorconfig" ] && continue
  [ "$file" = ".config" ] && continue
  ln -snfv "$DOTFILES_PATH/$file" "$HOME/$file"
done

