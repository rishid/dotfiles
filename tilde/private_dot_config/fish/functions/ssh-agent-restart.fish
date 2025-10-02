function ssh-agent-restart
    echo "Restarting ssh-agent service..."
    systemctl --user restart ssh-agent.service

    # Wait a moment for the service to start
    sleep 1

    # Re-import environment
    set -x SSH_AUTH_SOCK (systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)

    echo "SSH Agent restarted. New SSH_AUTH_SOCK: $SSH_AUTH_SOCK"

    # Reload keys from ~/.ssh/autoload (single source of truth)
    echo "Reloading keys..."

    if test -f ~/.ssh/autoload
        grep -v '^#' ~/.ssh/autoload | grep -v '^$' | while read -l key_path
            set -l full_path (string replace '~' $HOME "$key_path")
            if test -f "$full_path"
                ssh-add "$full_path" 2>/dev/null
            end
        end
    else
        echo "No ~/.ssh/autoload file found - no keys to reload"
    end
end
