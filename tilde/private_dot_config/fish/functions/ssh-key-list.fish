function ssh-key-list
    echo "Currently loaded SSH keys:"
    ssh-add -l 2>/dev/null || echo "  No keys loaded or agent not accessible"

    echo -e "\nAuto-load configuration:"

    # Show ~/.ssh/autoload file contents
    echo "  Keys from ~/.ssh/autoload:"
    if test -f ~/.ssh/autoload
        set -l found_keys false
        grep -v '^#' ~/.ssh/autoload | grep -v '^$' | while read -l key
            set found_keys true
            if test -f (string replace '~' $HOME "$key")
                echo "    ✓ $key"
            else
                echo "    ✗ $key (file not found)"
            end
        end
        if not $found_keys
            echo "    (no keys configured - all entries are commented out)"
        end
    else
        echo "    (~/.ssh/autoload not found)"
        echo "    (create this file and list your SSH keys, one per line)"
    end
end
