function ssh-agent-status -d "Show ssh-agent service status and loaded keys"
    echo "SSH Agent Service Status:"
    systemctl --user status ssh-agent.service

    echo -e "\nSSH_AUTH_SOCK: $SSH_AUTH_SOCK"

    echo -e "\nLoaded keys:"
    ssh-add -l 2>/dev/null || echo "No keys loaded or agent not accessible"
end
