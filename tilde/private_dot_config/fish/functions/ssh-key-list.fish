function ssh-key-list
    echo "Currently loaded SSH keys:"
    ssh-add -l 2>/dev/null || echo "  No keys loaded or agent not accessible"

    echo -e "\nAuto-load configuration:"

    # Show standard keys that are auto-discovered
    echo "  Standard keys (auto-discovery):"
    set -l standard_keys ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa ~/.ssh/id_dsa
    set -l found_standard false
    for key in $standard_keys
        if test -f "$key"
            echo "    ✓ $key"
            set found_standard true
        end
    end
    if not $found_standard
        echo "    (no standard keys found)"
    end

    # Show ~/.ssh/autoload file contents
    echo "  Custom keys (from ~/.ssh/autoload):"
    if test -f ~/.ssh/autoload
        set -l found_custom false
        grep -v '^#' ~/.ssh/autoload | grep -v '^$' | while read -l key
            set found_custom true
            if test -f (string replace '~' $HOME "$key")
                echo "    ✓ $key"
            else
                echo "    ✗ $key (file not found)"
            end
        end
        if not $found_custom
            echo "    (no custom keys configured)"
        end
    else
        echo "    (~/.ssh/autoload not configured)"
    end
end
