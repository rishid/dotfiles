# SSH Agent setup using systemd user service

if status is-interactive
    # Import SSH_AUTH_SOCK from systemd user environment
    if test -z "$SSH_AUTH_SOCK"
        set -x SSH_AUTH_SOCK (systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)
    end

    # If SSH_AUTH_SOCK is still not set, try the runtime directory path
    if test -z "$SSH_AUTH_SOCK"
        set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    end

    # Ensure the ssh-agent service is running
    if not systemctl --user is-active --quiet ssh-agent.service
        systemctl --user start ssh-agent.service
    end

    # Auto-load SSH keys from ~/.ssh/autoload (single source of truth)
    if test -f ~/.ssh/autoload
        while read -l key_path
            # Skip empty lines and comments
            if test -n "$key_path" -a (string sub -s 1 -l 1 "$key_path") != "#"
                set -l full_path (string replace '~' $HOME "$key_path")
                if test -f "$full_path"
                    if not ssh-add -l 2>/dev/null | grep -q (ssh-keygen -lf "$full_path" 2>/dev/null | awk '{print $2}')
                        ssh-add "$full_path" 2>/dev/null
                    end
                end
            end
        end < ~/.ssh/autoload
    end
end
