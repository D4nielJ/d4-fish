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

    if test -e ~/.profile.fish
        source ~/.profile.fish
    else
        echo "Warning: ~/.profile.fish not found"
    end

    # ~/.config/fish/config.fish
    starship init fish | source
end

# pnpm
set -gx PNPM_HOME "/home/$USER/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end


eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
