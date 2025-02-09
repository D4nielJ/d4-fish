function fish_greeting
    echo "🌿 Breathe in. Breathe out. Code with intention."
end

# Add this to your config.fish to make Windows variables available
function get_win_var -a var_name
    cmd.exe /c "echo %$var_name%" 2>/dev/null | tr -d '\r'
end

function wcd -a directory
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

function take
    if test -z "$argv"
        echo "Usage: take <directory>"
        return 1
    end
    mkdir -p $argv && cd $argv
end

# abbreviatures
abbr rld 'source ~/.config/fish/config.fish'

# eza functions
abbr ll 'eza -l --header --icons --git'
abbr lt 'eza -l --header --icons --git --tree'
abbr la 'eza -la --header --icons --git'
abbr ldir 'eza -l --header --icons --git --only-dirs'

# git commands
abbr fetch 'git fetch'
abbr clone 'git clone'
abbr pull 'git pull'
abbr merge 'git merge'
abbr add 'git add'
abbr gco 'git checkout'
abbr gcob 'git checkout -b'

# explorer helpers
abbr wenv get_win_var
abbr ~~ 'wcd (get_win_var USERPROFILE)'
abbr pr 'wcd (get_win_var USERPROFILE)/projects'
abbr dev 'cd ~/dev'
abbr dwl 'wcd (get_win_var USERPROFILE)/downloads'
abbr cfg 'cd ~/.config'
abbr ls ll
abbr pp 'code ~/.config/fish/config.fish'
abbr dotfiles 'git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
abbr dt dotfiles
