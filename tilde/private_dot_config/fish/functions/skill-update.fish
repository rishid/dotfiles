function skill-update -d "Update a skill and sync to dotfiles"
    npx skills update $argv
    if test $status -ne 0
        echo "✗ npx skills update failed"
        return 1
    end

    chezmoi add ~/.claude/skills/
    if test -f ~/.claude/.skills-lock.json
        chezmoi add ~/.claude/.skills-lock.json
    end

    set -l commit_msg
    if test (count $argv) -eq 0; or contains -- --all $argv
        set commit_msg "chore(skill): update all skills"
    else
        set commit_msg "chore(skill): update $argv"
    end

    cd (git -C (chezmoi source-path) rev-parse --show-toplevel)
    git add .
    git commit -m $commit_msg
    if test $status -ne 0
        echo "⚠ git commit failed (nothing to commit?)"
    end

    echo "✓ Skill updated and committed to dotfiles"
end
