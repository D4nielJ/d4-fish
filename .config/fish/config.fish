if status is-interactive
    # Load variables from .env-global
    if not test -e ~/.env-global
        touch ~/.env-global
    end

    for line in (cat ~/.env-global | string trim)
        # Skip empty lines and comments
        if string match -qr '^[^#]' $line
            # Extract key and value using fish's built-in string functions
            set -l key (string split -m1 = $line)[1]
            set -l value (string split -m1 = $line)[2]

            # Set the variable if the key is valid
            if string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' $key
                set -gx $key $value
            else
                echo "Warning: Invalid variable name '$key' in $argv"
            end
        end
    end

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

    # eza functions
    function ll
        eza -l --header --icons --git $argv
    end

    # Long listing with tree vie
    function lt
        eza -l --header --icons --git --tree $argv
    end

    # List all files (including hidden)
    function la
        eza -la --header --icons --git $argv
    end

    # Show only directories
    function ldir
        eza -l --header --icons --git --only-dirs $argv
    end

    # aliases
    alias rld 'source ~/.config/fish/config.fish'

    # git commands
    alias fetch 'git fetch'
    alias clone 'git clone'
    alias pull 'git pull'
    alias merge 'git merge'
    alias add 'git add'
    alias gco 'git checkout'
    alias gcob 'git checkout -b'

    # explorer helpers
    alias wenv get_win_var
    alias ~~ 'wcd (get_win_var USERPROFILE)'
    alias pr 'wcd (get_win_var USERPROFILE)/projects'
    alias dev 'cd ~/dev'
    alias dwl 'wcd (get_win_var USERPROFILE)/downloads'
    alias cfg 'cd ~/.config'
    alias ls ll
    alias pp 'code ~/.config/fish/config.fish'
    alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    alias dt dotfiles
end

# ~/.config/fish/config.fish
starship init fish | source
