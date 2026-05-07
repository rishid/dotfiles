# SSH Agent setup
# Handles both macOS (launchd/native agent) and Linux (systemd user service)

# Helper function to check if the current SSH agent is actually alive
function _is_ssh_agent_alive
    ssh-add -l >/dev/null 2>&1
    # Status 2 means "Error connecting to agent". 0 and 1 mean it's alive.
    if test $status -eq 2
        return 1
    end
    return 0
end

# ----------------------------------------------------------------------
# SSH Agent Setup
# ----------------------------------------------------------------------
if test (uname) = "Darwin"
    # macOS Setup
    if not _is_ssh_agent_alive
        set -l valid_sock_found 0

        # 1. Try finding a *valid and alive* launchd socket
        for sock in /private/tmp/com.apple.launchd.*/Listeners
            if test -S "$sock"
                set -gx SSH_AUTH_SOCK "$sock"
                if _is_ssh_agent_alive
                    set valid_sock_found 1
                    break
                end
            end
        end

        # 2. Fallback to user-managed agent if launchd failed
        if test $valid_sock_found -eq 0
            set -l sock_path "$HOME/.ssh/agent.sock"
            set -gx SSH_AUTH_SOCK "$sock_path"

            if not _is_ssh_agent_alive
                # Remove stale socket file before starting a new agent
                rm -f "$sock_path" >/dev/null 2>&1
                eval (ssh-agent -c -a "$sock_path" | sed 's/^setenv/set -gx/') >/dev/null 2>&1
            end
        end
    end

else
    # Linux Setup
    if not _is_ssh_agent_alive
        # 1. Ask systemd for the socket path
        set -l systemd_sock (systemctl --user show-environment 2>/dev/null | grep SSH_AUTH_SOCK | cut -d= -f2)

        if test -n "$systemd_sock"
            set -gx SSH_AUTH_SOCK "$systemd_sock"
        end

        # 2. Fallback to standard XDG path if systemd variable was empty or dead
        if not _is_ssh_agent_alive
            if test -n "$XDG_RUNTIME_DIR"
                set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"
            else
                set -gx SSH_AUTH_SOCK "/run/user/"(id -u)"/ssh-agent.socket"
            end
        end

        # 3. Ensure systemd service is actually active
        if not systemctl --user is-active --quiet ssh-agent.service 2>/dev/null
            systemctl --user start ssh-agent.service 2>/dev/null
        end
    end
end

# ----------------------------------------------------------------------
# Auto-load SSH Keys
# ----------------------------------------------------------------------
if status is-interactive
    if test -f ~/.ssh/autoload
        while read -l key_path
            # Skip empty lines and comments
            if test -n "$key_path" -a (string sub -s 1 -l 1 "$key_path") != "#"
                set -l full_path (string replace '~' $HOME "$key_path")

                if test -f "$full_path"
                    set -l key_fp (ssh-keygen -lf "$full_path" 2>/dev/null | awk '{print $2}')

                    if test -n "$key_fp"
                        if not ssh-add -l 2>/dev/null | grep -q "$key_fp"
                            ssh-add "$full_path"
                        end
                    end
                end
            end
        end < ~/.ssh/autoload
    end
end
