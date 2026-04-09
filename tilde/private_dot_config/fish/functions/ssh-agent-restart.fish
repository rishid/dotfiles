function ssh-agent-restart -d "Restart ssh-agent and reload autoload keys"
    if test (uname) = "Darwin"
        # macOS: kill existing agent and start a new one
        set -l sock_path "$HOME/.ssh/agent.sock"
        pkill -u (id -u) ssh-agent 2>/dev/null; or true
        rm -f "$sock_path"
        eval (ssh-agent -a "$sock_path" -s 2>/dev/null) > /dev/null
        set -gx SSH_AUTH_SOCK "$sock_path"
        echo "SSH Agent restarted. SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
    else
        # Linux: restart systemd user service
        echo "Restarting ssh-agent service..."
        systemctl --user restart ssh-agent.service

        sleep 1

        set -gx SSH_AUTH_SOCK (systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)
        echo "SSH Agent restarted. SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
    end

    # Reload keys from ~/.ssh/autoload
    if test -f ~/.ssh/autoload
        echo "Reloading keys..."
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
