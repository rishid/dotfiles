# SSH Agent setup for bash/sh compatibility
# Handles both macOS (launchd/native agent) and Linux (systemd user service)

if [ "$(uname)" = "Darwin" ]; then
    # macOS: SSH agent is managed by the OS; AddKeysToAgent in ~/.ssh/config
    # keeps keys loaded across reboots via Keychain.
    if [ -z "$SSH_AUTH_SOCK" ]; then
        # Try the launchd-managed socket (macOS 12+)
        AGENT_SOCK=$(ls /private/tmp/com.apple.launchd.*/Listeners 2>/dev/null | head -1 || true)
        if [ -n "$AGENT_SOCK" ]; then
            export SSH_AUTH_SOCK="$AGENT_SOCK"
        else
            # Fall back to a user-managed agent
            SOCK_PATH="$HOME/.ssh/agent.sock"
            if ! ssh-add -l >/dev/null 2>&1; then
                eval "$(ssh-agent -a "$SOCK_PATH" -s 2>/dev/null)" > /dev/null
            fi
            export SSH_AUTH_SOCK="$SOCK_PATH"
        fi
    fi
else
    # Linux: SSH agent managed via systemd user service
    if [ -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK=$(systemctl --user show-environment 2>/dev/null | grep SSH_AUTH_SOCK | cut -d= -f2)
    fi

    if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    fi

    if command -v systemctl >/dev/null 2>&1; then
        if ! systemctl --user is-active --quiet ssh-agent.service 2>/dev/null; then
            systemctl --user start ssh-agent.service 2>/dev/null
        fi
    fi
fi
