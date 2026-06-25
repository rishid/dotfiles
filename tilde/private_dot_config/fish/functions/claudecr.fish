function claudecr -d "Code review with bypass mode - pass PR URL, number, or text"
    if test (count $argv) -eq 0
        echo "Usage: claudecr <PR_URL | PR_NUMBER | TEXT>"
        echo "Examples:"
        echo "  claudecr https://github.com/owner/repo/pull/284"
        echo "  claudecr https://github.com/owner/repo/pull/284/changes"
        echo "  claudecr 284"
        echo "  claudecr PR 284 focus on security"
        return 0
    end

    set -l input (string join " " $argv)
    claude --dangerously-skip-permission "review $input"
end
