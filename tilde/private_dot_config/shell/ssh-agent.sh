# SSH Agent setup for bash/sh compatibility
# This ensures VS Code Remote SSH can access the systemd ssh-agent

# Import SSH_AUTH_SOCK from systemd user environment
if [ -z "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK=$(systemctl --user show-environment 2>/dev/null | grep SSH_AUTH_SOCK | cut -d= -f2)
fi

# If SSH_AUTH_SOCK is still not set, try the runtime directory path
if [ -z "$SSH_AUTH_SOCK" ] && [ -n "$XDG_RUNTIME_DIR" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
fi

# Ensure the ssh-agent service is running (only if systemctl is available)
if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl --user is-active --quiet ssh-agent.service 2>/dev/null; then
        systemctl --user start ssh-agent.service 2>/dev/null
    fi
fi
