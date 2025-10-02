# SSH Agent setup using systemd user service
# This ensures SSH_AUTH_SOCK is available for both interactive and non-interactive sessions

# Always import SSH_AUTH_SOCK from systemd user environment (for VS Code Remote SSH)
if test -z "$SSH_AUTH_SOCK"
    set -x SSH_AUTH_SOCK (systemctl --user show-environment 2>/dev/null | grep SSH_AUTH_SOCK | cut -d= -f2)
end

# If SSH_AUTH_SOCK is still not set, try the runtime directory path
if test -z "$SSH_AUTH_SOCK"
    set -x SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
end

# Ensure the ssh-agent service is running
if not systemctl --user is-active --quiet ssh-agent.service 2>/dev/null
    systemctl --user start ssh-agent.service 2>/dev/null
end

# Auto-load SSH keys from ~/.ssh/autoload (only in interactive sessions)
if status is-interactive
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
