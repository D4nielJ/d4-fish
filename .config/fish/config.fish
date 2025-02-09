if status is-interactive
    function fish_greeting
        echo "🌿 Breathe in. Breathe out. Code with intention."
    end

    # Add this to your config.fish to make Windows variables available
    function get_win_var -a var_name
        cmd.exe /c "echo %$var_name%" 2>/dev/null | tr -d '\r'
    end

    function wcd -a directory
        cd (wslpath $directory)
    end

    function take
        mkdir -p $argv && cd $argv
    end

    # exa functions
    function ll
        exa -l --header --icons --git $argv
    end

    # Long listing with tree vie
    function lt
        exa -l --header --icons --git --tree $argv
    end

    # List all files (including hidden)
    function la
        exa -la --header --icons --git $argv
    end

    # Show only directories
    function ldir
        exa -l --header --icons --git --only-dirs $argv
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
    alias dev 'wcd (get_win_var USERPROFILE)/dev'
    alias dwl 'wcd (get_win_var USERPROFILE)/downloads'
    alias cfg 'cd ~/.config'
    alias ls ll
    alias pp 'code ~/.config/fish/config.fish'
    alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
    alias dt dotfiles
end
