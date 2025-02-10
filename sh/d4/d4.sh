#!/bin/bash

# Enhanced error handling
set -euo pipefail
error_handler() {
  echo "Error occurred in script at line: $1" >&2
  exit 1
}
trap 'error_handler ${LINENO}' ERR

# Validate environment
USER_HOME="${HOME:-}"
if [ -z "$USER_HOME" ]; then
  echo "Error: HOME environment variable not set" >&2
  exit 1
fi

# Get Git credentials from arguments or prompt
git_username="${1:-}"
git_email="${2:-}"

# Function to validate email
validate_email() {
  local email="$1"
  [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]
}

# If running interactively, prompt for missing values
if [ -t 0 ]; then
  while [ -z "$git_username" ]; do
    read -rp "Enter your Git username: " git_username
    if [ -z "$git_username" ]; then
      echo "Username cannot be empty. Please try again." >&2
    fi
  done

  while [ -z "$git_email" ]; do
    read -rp "Enter your Git email: " git_email
    if [ -z "$git_email" ]; then
      echo "Email cannot be empty. Please try again." >&2
    elif ! validate_email "$git_email"; then
      echo "Invalid email format. Please try again." >&2
      git_email=""
    fi
  done
else
  # If not interactive and arguments are missing, show usage
  if [ -z "$git_username" ] || [ -z "$git_email" ]; then
    echo "Usage: $0 <git_username> <git_email>"
    echo "Example: $0 \"John Doe\" \"john@example.com\""
    exit 1
  fi

  # Validate email when provided as argument
  if ! validate_email "$git_email"; then
    echo "Error: Invalid email format" >&2
    exit 1
  fi
fi

# Confirm values
echo "Git configuration values:"
echo "Username: $git_username"
echo "Email: $git_email"
echo "==================================="
read -rp "Press Enter to continue or Ctrl+C to abort..."

# Verify sudo access
if ! sudo -v; then
  echo "This script requires sudo privileges" >&2
  exit 1
fi

# Check internet connection
if ! ping -c 1 google.com >/dev/null 2>&1; then
  echo "No internet connection. This script requires internet access." >&2
  exit 1
fi

# System updates
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y

# Install fish shell
if ! sudo apt install fish -y; then
  echo "Failed to install fish shell" >&2
  exit 1
fi

# Configure Git
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global alias.lg1 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
git config --global alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
git config --global alias.lg "lg1"

# WSL-specific Git credential helper
if grep -qi microsoft /proc/version; then
  if [ -f "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe" ]; then
    git config --global credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
  else
    echo "Warning: Git Credential Manager not found at expected location" >&2
  fi
else
  echo "Not running in WSL, skipping Windows-specific Git credential helper"
fi

# Install Starship
if ! curl -sS https://starship.rs/install.sh | sh; then
  echo "Failed to install Starship" >&2
  exit 1
fi

# Install essential packages
packages="eza neofetch bat fzf fd-find neovim jq unzip"
for package in $packages; do
  if ! apt-cache show "$package" >/dev/null 2>&1; then
    echo "Warning: Package $package not found in repositories"
  fi
done
sudo apt install -y $packages

# Fix bat alias
mkdir -p "$USER_HOME/.local/bin"
if [ -f "/usr/bin/batcat" ]; then
  ln -sf /usr/bin/batcat "$USER_HOME/.local/bin/bat"
else
  echo "Warning: batcat not found at /usr/bin/batcat" >&2
fi

# Install pnpm
if ! curl -fsSL https://get.pnpm.io/install.sh | sh -; then
  echo "Failed to install pnpm" >&2
  exit 1
fi

# Install fisher and plugins
fish_commands=(
  "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
  "fisher install jethrokuan/z"
  "fisher install PatrickF1/fzf.fish"
  "fisher install jorgebucaran/nvm.fish"
)

for cmd in "${fish_commands[@]}"; do
  if ! fish -c "$cmd"; then
    echo "Failed to execute fish command: $cmd" >&2
    exit 1
  fi
done

# Install Node.js using fish
if ! fish -c "nvm install lts && nvm use lts"; then
  echo "Failed to install Node.js" >&2
  exit 1
fi

setup_dotfiles() {
  local dotfiles_dir="$USER_HOME/.dotfiles"
  local backup_dir="$USER_HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

  echo "Setting up dotfiles..."

  # Clone the repository
  if ! git clone --bare https://github.com/D4nielJ/d4-fish.git "$dotfiles_dir"; then
    echo "Failed to clone dotfiles repository"
    return 1
  fi

  mkdir -p "$backup_dir"

  # Disable error handling locally
  local conflicts
  local checkout_status
  {
    conflicts=$(git --git-dir="$dotfiles_dir" --work-tree="$USER_HOME" checkout 2>&1)
    checkout_status=$?
  } || true

  if [ $checkout_status -ne 0 ]; then
    echo "Handling conflicts..."
    echo "$conflicts" | while IFS= read -r line; do
      if [[ $line =~ ^[[:space:]]+(.+)$ ]]; then
        local file="${BASH_REMATCH[1]}"
        if [ -e "$USER_HOME/$file" ]; then
          echo "Backing up: $file"
          mkdir -p "$backup_dir/$(dirname "$file")"
          mv "$USER_HOME/$file" "$backup_dir/$file"
        fi
      fi
    done

    echo "Attempting checkout again..."
    if ! git --git-dir="$dotfiles_dir" --work-tree="$USER_HOME" checkout; then
      echo "Error: Failed to checkout dotfiles even after handling conflicts"
      return 1
    fi
  fi

  git --git-dir="$dotfiles_dir" --work-tree="$USER_HOME" config --local status.showUntrackedFiles no
  echo "Dotfiles setup completed successfully"
  return 0
}

# Call the function with error handling
if ! setup_dotfiles; then
  echo "Failed to set up dotfiles"
  exit 1
fi

# Configure git for dotfiles
git --git-dir="$dotfiles_dir" --work-tree="$USER_HOME" config --local status.showUntrackedFiles no
echo "Dotfiles setup completed successfully"

# Install SpaceMono Nerd Font (Windows)
echo "Installing SpaceMono Nerd Font..."

if grep -qi microsoft /proc/version; then
  temp_dir=$(mktemp -d)
  font_zip="$temp_dir/SpaceMono.zip"
  font_dir="$temp_dir/SpaceMono"
  windows_font_dir="/mnt/c/Windows/Fonts"

  if [ ! -d "$windows_font_dir" ]; then
    echo "Error: Cannot access Windows Fonts directory" >&2
    exit 1
  fi

  if ! curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SpaceMono.zip" -o "$font_zip"; then
    echo "Failed to download SpaceMono font" >&2
    exit 1
  fi

  if ! unzip -q "$font_zip" -d "$font_dir"; then
    echo "Failed to extract font archive" >&2
    exit 1
  fi

  find "$font_dir" -name "*.ttf" -exec cp {} "$windows_font_dir/" \;
  rm -rf "$temp_dir"

  echo "SpaceMono Nerd Font installed successfully."
  # Create temporary directory
  temp_dir=$(mktemp -d)
  font_zip="$temp_dir/SpaceMono.zip"
  font_dir="$temp_dir/SpaceMono"

  # Windows Fonts directory path from WSL
  windows_font_dir="/mnt/c/Windows/Fonts"

  # Check if we can access the Windows directory
  if [ ! -d "$windows_font_dir" ]; then
    echo "Error: Cannot access Windows Fonts directory"
    exit 1
  fi

  # Download the font
  curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SpaceMono.zip" -o "$font_zip"

  # Extract fonts
  unzip -q "$font_zip" -d "$font_dir"

  # Install fonts to Windows directory
  echo "Copying fonts to Windows..."
  find "$font_dir" -name "*.ttf" -exec cp {} "$windows_font_dir/" \;

  # Clean up
  rm -rf "$temp_dir"

  echo "SpaceMono Nerd Font installed successfully."
  echo "Note: You may need to restart your Windows terminal for the changes to take effect."
else
  echo "Not running in WSL, skipping Windows font installation."
fi

# Sync Windows Terminal settings
echo "Syncing Windows Terminal settings..."

if grep -qi microsoft /proc/version; then
  # Get Windows username from environment variable
  windows_username=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')

  # Windows Terminal settings location (different paths for different Windows versions)
  windows_terminal_settings="/mnt/c/Users/$windows_username/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
  windows_terminal_settings_preview="/mnt/c/Users/$windows_username/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json"

  # Source settings file
  dotfiles_settings="$HOME/.config/terminal/settings.json"

  if [ -f "$dotfiles_settings" ]; then
    # Backup existing settings if they exist
    for settings_path in "$windows_terminal_settings" "$windows_terminal_settings_preview"; do
      if [ -f "$settings_path" ]; then
        backup_path="${settings_path}.backup-$(date +%Y%m%d_%H%M%S)"
        echo "Backing up existing settings to: $backup_path"
        cp "$settings_path" "$backup_path"

        echo "Copying new settings to: $settings_path"
        cp "$dotfiles_settings" "$settings_path"

        # Ensure proper permissions
        chmod 644 "$settings_path"
      fi
    done
    echo "Windows Terminal settings updated successfully."
    echo "Note: You may need to restart Windows Terminal for the changes to take effect."
  else
    echo "Warning: Terminal settings file not found at $dotfiles_settings"
  fi
else
  echo "Not running in WSL, skipping Windows Terminal settings sync."
fi

echo "Changing default shell to fish..."
if ! chsh -s $(which fish); then
  echo "Automatic shell change failed. You can change it manually later with:"
  echo "chsh -s $(which fish)"
  echo "Or add this to your ~/.bashrc:"
  echo "if [ -t 1 ]; then exec fish; fi"
  # Continue script despite chsh failure
  set +e
fi
