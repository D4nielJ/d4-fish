# D4

How to setup WSL Ubuntu and fish for software development in Windows 11.

## Manual setup

1. Install WSL ubuntu.
2. Make Ubuntu your default shell in windows Terminal.
3. Updating and making fish default shell.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt autoremove -y
sudo apt install fish
chsh -s (which fish)
```

4. Git configurations:

```bash
git config --global user.name "<add username>"
git config --global user.email "<add email>"

git config --global --add init.defaultBranch main

git config --global --add alias.lg1 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all"
git config --global --add alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
git config --global --add alias.lg "lg1"

git config --global --add credential.helper "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe"
```

5. clone dotfiles:

```fish
git clone --bare https://github.com/D4nielJ/d4-fish.git $HOME/.dotfiles
```

6. Install starship:

```fish
curl -sS https://starship.rs/install.sh | sh
```
