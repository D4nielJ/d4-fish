# D4

How to setup WSL Ubuntu and fish for software development in Windows 11.

## Manual setup

### 1. Install WSL ubuntu.

### 2. Make Ubuntu your default shell in windows Terminal.

### 3. Updating and making fish default shell.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install fish
chsh -s (which fish)
```

### 4. Git configurations:

```bash
git config --global user.name "<add username>"
git config --global user.email "<add email>"

git config --global --add init.defaultBranch main

git config --global --add alias.lg1 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
git config --global --add alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
git config --global --add alias.lg "lg1"

git config --global --add credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

### 5. clone dotfiles:

```fish
git clone --bare https://github.com/D4nielJ/d4-fish.git $HOME/.dotfiles
```

### 6. Install starship:

```fish
curl -sS https://starship.rs/install.sh | sh
```

### 7. Install packages and fisher:

```fish
sudo apt install eza
sudo apt install neofetch
sudo apt install bat
sudo apt install fzf
sudo apt install fd-find
sudo apt install neovim
sudo apt install jq
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

Bat has issues with Ubuntu, this might be required:

```
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
```

#### nvm:

```fish
fisher install jorgebucaran/nvm.fish
nvm install lts
nvm use lts
```

#### pnpm:

```fish
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

### 8. Fisher plugins:

```fish
fisher install jethrokuan/z
fisher install PatrickF1/fzf.fish
```
