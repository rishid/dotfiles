function ssh-key-add
    set -l key_path $argv[1]

    if test -z "$key_path"
        echo "Usage: ssh-key-add <path-to-private-key>"
        return 1
    end

    if not test -f "$key_path"
        echo "Error: Key file '$key_path' not found"
        return 1
    end

    # Ensure ssh-agent is running
    if not systemctl --user is-active --quiet ssh-agent.service
        echo "Starting ssh-agent service..."
        systemctl --user start ssh-agent.service
        sleep 1
    end

    # Add the key
    ssh-add "$key_path"

    if test $status -eq 0
        echo "Successfully added key: $key_path"

                # Ask if user wants to add to auto-load list
        read -P "Add this key to auto-load list? [y/N]: " -l response
        if test "$response" = "y" -o "$response" = "Y"
            # Create ~/.ssh/autoload file if it doesn't exist
            if not test -f ~/.ssh/autoload
                touch ~/.ssh/autoload
                echo "# SSH Keys Auto-load Configuration" > ~/.ssh/autoload
                echo "# List one SSH private key path per line" >> ~/.ssh/autoload
                echo "# Lines starting with # are ignored" >> ~/.ssh/autoload
                echo "" >> ~/.ssh/autoload
            end

            # Check if key is already in the file
            if not grep -q "^$key_path\$" ~/.ssh/autoload 2>/dev/null
                echo "$key_path" >> ~/.ssh/autoload
                echo "Added to ~/.ssh/autoload"
            else
                echo "Key already in ~/.ssh/autoload"
            end
        end
    else
        echo "Failed to add key: $key_path"
    end
end
