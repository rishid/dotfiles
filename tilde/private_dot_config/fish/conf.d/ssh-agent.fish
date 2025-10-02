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

    # Auto-load SSH keys using two strategies

    # Strategy 1: Auto-discover standard SSH keys
    set -l standard_keys ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa ~/.ssh/id_dsa

    for key in $standard_keys
        if test -f "$key"
            # Check if key is already loaded
            if not ssh-add -l 2>/dev/null | grep -q (ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
                ssh-add "$key" 2>/dev/null
            end
        end
    end

    # Strategy 2: Load keys listed in ~/.ssh/autoload (if it exists)
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
