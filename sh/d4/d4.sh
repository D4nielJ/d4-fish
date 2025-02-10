#!/bin/bash

# Add error handling function
set -e # Exit on error
error_handler() {
  echo "Error occurred in script at line: $1"
  exit 1
}
trap 'error_handler ${LINENO}' ERR

# Verify sudo access before starting
if ! sudo -v; then
  echo "This script requires sudo privileges"
  exit 1
fi

# Check internet connection
if ! ping -c 1 google.com >/dev/null 2>&1; then
  echo "No internet connection. This script requires internet access."
  exit 1
fi

# Get user info for Git configurations
read -p "Enter your Git username: " git_username
read -p "Enter your Git email: " git_email

# Update and upgrade system
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Install fish shell and set as default
sudo apt install fish -y
chsh -s $(which fish)

# Git configurations
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global --add init.defaultBranch main
git config --global --add alias.lg1 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
git config --global --add alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
git config --global --add alias.lg "lg1"

# Only set credential helper if running in WSL
if grep -qi microsoft /proc/version; then
  git config --global --add credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
else
  echo "Not running in WSL, skipping Windows-specific Git credential helper"
fi

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Install essential packages
packages="eza neofetch bat fzf fd-find neovim jq"
for package in $packages; do
  if ! apt-cache show "$package" >/dev/null 2>&1; then
    echo "Warning: Package $package not found in repositories"
  fi
done
sudo apt install -y $packages

# Fix bat alias
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# Install pnpm
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Install fisher and plugins
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jethrokuan/z"
fish -c "fisher install PatrickF1/fzf.fish"
fish -c "fisher install jorgebucaran/nvm.fish"

# Install Node.js using fish
fish -c "nvm install lts"
fish -c "nvm use lts"

# Clone dotfiles
# Check for existing files and rename them with '_' prefix if they exist
# Get list of files in the dotfiles repo
dotfiles_list=$(git --git-dir=$HOME/.dotfiles --work-tree=$HOME ls-tree -r HEAD --name-only)

# Clone dotfiles with improved backup
backup_suffix=$(date +%Y%m%d_%H%M%S)
for file in $dotfiles_list; do
  if [ -e "$HOME/$file" ]; then
    mv "$HOME/$file" "$HOME/${file}_backup_${backup_suffix}"
    echo "Backed up existing file: $file -> ${file}_backup_${backup_suffix}"
  fi
done

git clone --bare https://github.com/D4nielJ/d4-fish.git $HOME/.dotfiles
