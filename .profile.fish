# variables
set --universal nvm_default_version lts
set -gx STARSHIP_CONFIG ~/.config/starship.toml
set -gx FISH_CONFIG ~/.config/fish/config.fish
set -gx FISH_PROFILE ~/.profile.fish
set -p PATH "/mnt/c/Program Files/Zen Browser" $PATH
set -gx EDITOR vim

if test -d ~/.local/bin
    set -gx PATH ~/.local/bin $PATH
end

set -g bell_style none

function get_win_var -d "Retrieve a Windows environment variable" -a var_name
    cmd.exe /c "echo %$var_name%" 2>/dev/null | tr -d '\r'
end

function wcd -d "Change directory to a Windows path in WSL" -a directory
    if test -z "$directory"
        echo "Usage: wcd <windows-path>"
        return 1
    end
    set -l path (wslpath $directory 2>/dev/null)
    if test $status -eq 0
        cd $path
    else
        echo "Error: Invalid Windows path '$directory'"
        return 1
    end
end

function take -d "Create a directory and change into it" -a directory
    if test -z "$argv"
        echo "Usage: take <directory>"
        return 1
    end
    mkdir -p $argv && cd $argv
end

function init_prettier -d "Initialize .prettierrc in current directory"
    cp $HOME/.config/prettier/.prettierrc.json .prettierrc.json
end
# Usage:
# Stop-Port 3000
# Stop-Port 3000,3001,3002
function stop_port -d "Use it to stop the process in certain port"
    if test (count $argv) -eq 0
        echo "Usage: stop-port PORT1 [PORT2 PORT3 ...]"
        return 1
    end

    for port in $argv
        set process (lsof -i :$port | awk 'NR==2 {print $2}')
        if test -n "$process"
            kill -9 $process
            echo "Killed process $process using port $port"
        else
            echo "No process found using port $port"
        end
    end
end

function itl -d "Opens intellij-idea-community"
    nohup intellij-idea-community $argv >/dev/null 2>&1 & disown
end

function wtermin4l -d "Wtermin4l to admin the windows terminal settings"
    deno run --allow-env --allow-read --allow-write --allow-sys jsr:@d4nielj/wtermin4l $argv
end

#dotfiles git manager
function dotfiles --wraps=git -d 'Manage dotfiles repository with home as working directory'
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end

abbr dt dotfiles

# abbreviatures
# eza functions
abbr exa eza
abbr ll 'eza -l --header --icons --git'
abbr ls 'eza -l --header --icons --git'
abbr lt 'eza -l --header --icons --git --tree'
abbr la 'eza -la --header --icons --git'
abbr ldir 'eza -l --header --icons --git --only-dirs'

# git commands
abbr fetch 'git fetch'
abbr clone 'git clone'
abbr pull 'git pull'
abbr push 'git push'
abbr merge 'git merge'
abbr add 'git add'
abbr gco 'git checkout'
abbr gcob 'git checkout -b'
abbr stat 'git status'
abbr commit 'git commit'
abbr cmt 'git commit'
abbr gcm 'git commit'
abbr glog 'git log'
abbr lg 'git log --pretty=format:"%C(auto)%h %C(yellow)%d %C(reset)%s %C(bold blue)<%an>%C(reset)" --graph'
abbr gam 'git add . && git commit -m'
abbr stash 'git stash'
abbr pop 'git stash pop'
abbr gpob 'git pull origin (git branch --show-current)'
abbr gpub 'git push --set-upstream origin (git branch --show-current)'
abbr rebase 'git rebase'
abbr reset 'git reset'
abbr branch 'git branch'
abbr gbd 'git branch -d'
abbr gcp 'git cherry-pick'
abbr dif 'git diff'

# explorer helpers
abbr wenv get_win_var
abbr ~~ 'wcd (get_win_var USERPROFILE)'
abbr pr 'wcd (get_win_var USERPROFILE)/projects'
abbr dev 'cd ~/dev'
abbr dwl 'wcd (get_win_var USERPROFILE)/downloads'
abbr cfg 'cd ~/.config'

# pnpm
abbr pn pnpm
abbr dlx 'pnpm dlx'

# miscelanous
abbr pp 'code $FISH_PROFILE'
abbr rld 'source $FISH_CONFIG'
abbr theme 'code $STARSHIP_CONFIG'
abbr vim nvim
abbr g git
abbr ii explorer.exe
abbr dn deno
abbr idea idea64.exe
abbr wt wtermin4l

# Insecure otaku stuff (CRINGE):
function genshin
    powershell.exe -c "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression \"&{\$((New-Object System.Net.WebClient).DownloadString('https://gist.github.com/MadeBaruna/1d75c1d37d19eca71591ec8a31178235/raw/getlink.ps1'))} global\""
end

function zzz
    powershell.exe -c "iwr -useb stardb.gg/signal | iex"
end

# End
function fish_greeting
    echo "🌿 Breathe in. Breathe out. Code with intention."
end
