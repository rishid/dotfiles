function claudecr -d "Code review with bypass mode - pass PR URL, number, or text"
    # claudecr exists because the /review skill spawns many tools and bash commands,
    # making interactive permission prompts extremely disruptive. This wrapper skips
    # permissions and pins the model so reviews are consistent and uninterrupted.
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
    claude --dangerously-skip-permissions --model claude-sonnet-4-6 "/code-review $input"
end
