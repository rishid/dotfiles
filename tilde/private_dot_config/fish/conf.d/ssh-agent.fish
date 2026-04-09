# SSH Agent setup
# Handles both macOS (launchd/native agent) and Linux (systemd user service)

if test (uname) = "Darwin"
    # macOS: SSH agent is managed by the OS; socket path can vary.
    # AddKeysToAgent in ~/.ssh/config keeps keys available across reboots.
    if test -z "$SSH_AUTH_SOCK"
        # Try the launchd-managed socket (macOS 12+)
        set -l agent_sock (ls /private/tmp/com.apple.launchd.*/Listeners 2>/dev/null | head -1)
        if test -n "$agent_sock"
            set -gx SSH_AUTH_SOCK $agent_sock
        else
            # Fall back to a user-managed agent stored in XDG_RUNTIME_DIR equivalent
            set -l sock_path "$HOME/.ssh/agent.sock"
            if not ssh-add -l &>/dev/null
                eval (ssh-agent -a "$sock_path" -s 2>/dev/null) > /dev/null
            end
            set -gx SSH_AUTH_SOCK "$sock_path"
        end
    end
else
    # Linux: SSH agent managed via systemd user service
    if test -z "$SSH_AUTH_SOCK"
        set -gx SSH_AUTH_SOCK (systemctl --user show-environment 2>/dev/null | grep SSH_AUTH_SOCK | cut -d= -f2)
    end

    if test -z "$SSH_AUTH_SOCK"
        set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
    end

    if not systemctl --user is-active --quiet ssh-agent.service 2>/dev/null
        systemctl --user start ssh-agent.service 2>/dev/null
    end
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
