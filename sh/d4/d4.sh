#!/bin/bash

# Add error handling function
set -e # Exit on error
error_handler() {
  echo "Error occurred in script at line: $1"
  exit 1
}
trap 'error_handler ${LINENO}' ERR

# Clear the screen and show prompts clearly
clear
echo "==================================="
echo "Git Configuration Setup"
echo "==================================="

# Get user info for Git configurations with validation
git_username=""
git_email=""

while [ -z "$git_username" ]; do
  read -p "Enter your Git username: " git_username
  if [ -z "$git_username" ]; then
    echo "Username cannot be empty. Please try again."
  fi
done

while [ -z "$git_email" ]; do
  read -p "Enter your Git email: " git_email
  if [ -z "$git_email" ]; then
    echo "Email cannot be empty. Please try again."
  fi
done

# Store the values for confirmation
echo "Git configuration values:"
echo "Username: $git_username"
echo "Email: $git_email"
echo "==================================="
read -p "Press Enter to continue..."

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

# Update and upgrade system
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Install fish shell and set as default
sudo apt install fish -y

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

# Clone dotfiles with conflict handling
echo "Setting up dotfiles..."
dotfiles_dir="$HOME/.dotfiles"
conflict_files=(
  "$HOME/.profile.fish"
  "$HOME/.config/fish/config.fish"
  "$HOME/.config/starship.toml"
)

# Check for and rename conflicting files
for file in "${conflict_files[@]}"; do
  if [ -e "$file" ]; then
    new_name="$(dirname "$file")/_original-$(basename "$file")"
    echo "Renaming existing $file to $new_name to prevent conflicts"
    mv "$file" "$new_name"
  fi
done

# Clone the bare repository
git clone --bare https://github.com/D4nielJ/d4-fish.git "$dotfiles_dir"

echo "Changing default shell to fish..."
if ! chsh -s $(which fish); then
  echo "Automatic shell change failed. You can change it manually later with:"
  echo "chsh -s $(which fish)"
  echo "Or add this to your ~/.bashrc:"
  echo "if [ -t 1 ]; then exec fish; fi"
  # Continue script despite chsh failure
  set +e
fi
