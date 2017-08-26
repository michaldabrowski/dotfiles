#!/usr/bin/env bash

export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Making symlinks..."
ln -sfv $DOTFILES_DIR/git/.gitconfig  ~
ln -sfv $DOTFILES_DIR/git/.gitignore_global  ~

echo "Installing Homebrew..."
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing Homebrew packages..."
brew bundle --file=brew/Brewfile

echo "Done."
