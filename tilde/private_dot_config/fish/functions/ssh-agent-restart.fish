function ssh-agent-restart
    echo "Restarting ssh-agent service..."
    systemctl --user restart ssh-agent.service

    # Wait a moment for the service to start
    sleep 1

    # Re-import environment
    set -x SSH_AUTH_SOCK (systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)

    echo "SSH Agent restarted. New SSH_AUTH_SOCK: $SSH_AUTH_SOCK"

    # Reload keys from standard locations and ~/.ssh/autoload
    echo "Reloading keys..."

    # Load standard keys
    set -l standard_keys ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa ~/.ssh/id_dsa
    for key in $standard_keys
        if test -f "$key"
            ssh-add "$key" 2>/dev/null
        end
    end

    # Load keys from autoload file
    if test -f ~/.ssh/autoload
        grep -v '^#' ~/.ssh/autoload | grep -v '^$' | while read -l key_path
            set -l full_path (string replace '~' $HOME "$key_path")
            if test -f "$full_path"
                ssh-add "$full_path" 2>/dev/null
            end
        end
    end
end
