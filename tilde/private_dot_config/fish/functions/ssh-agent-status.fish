function ssh-agent-status -d "Show ssh-agent status and loaded keys"
    if test (uname) = "Darwin"
        echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
        echo ""
    else
        echo "SSH Agent Service Status:"
        systemctl --user status ssh-agent.service
        echo ""
        echo "SSH_AUTH_SOCK: $SSH_AUTH_SOCK"
        echo ""
    end

    echo "Loaded keys:"
    ssh-add -l 2>/dev/null; or echo "No keys loaded or agent not accessible"
end
