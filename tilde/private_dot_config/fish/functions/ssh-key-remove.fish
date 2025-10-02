function ssh-key-remove
    set -l key_path $argv[1]

    if test -z "$key_path"
        echo "Usage: ssh-key-remove <path-to-private-key>"
        return 1
    end

    ssh-add -d "$key_path"

    if test $status -eq 0
        echo "Successfully removed key: $key_path"

        # Ask if user wants to remove from auto-load list
        if test -f ~/.ssh/autoload -a (grep -q "^$key_path\$" ~/.ssh/autoload 2>/dev/null)
            read -P "Remove this key from ~/.ssh/autoload? [y/N]: " -l response
            if test "$response" = "y" -o "$response" = "Y"
                # Remove from autoload file
                grep -v "^$key_path\$" ~/.ssh/autoload > ~/.ssh/autoload.tmp
                mv ~/.ssh/autoload.tmp ~/.ssh/autoload
                echo "Removed from ~/.ssh/autoload"
            end
        end
    else
        echo "Failed to remove key: $key_path"
    end
end
