function _skill-dotfiles-sync -d "Sync skill changes back to chezmoi dotfiles repo"
    # Usage: _skill-dotfiles-sync <commit-message>
    chezmoi add ~/.claude/skills/
    if test $status -ne 0
        echo "✗ chezmoi add failed for ~/.claude/skills/"
        return 1
    end

    if test -f ~/.claude/.skills-lock.json
        chezmoi add ~/.claude/.skills-lock.json
    end

    # Use git -C instead of cd so the caller's working directory is not mutated
    set -l repo_root (git -C (chezmoi source-path) rev-parse --show-toplevel)
    git -C $repo_root add .
    git -C $repo_root commit -m $argv[1]
    if test $status -ne 0
        echo "⚠ git commit failed (nothing to commit?)"
    end
end
