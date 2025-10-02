function ssh-agent-status
    echo "SSH Agent Service Status:"
    systemctl --user status ssh-agent.service

    echo -e "\nSSH_AUTH_SOCK: $SSH_AUTH_SOCK"

    echo -e "\nLoaded keys:"
    ssh-add -l 2>/dev/null || echo "No keys loaded or agent not accessible"
end
