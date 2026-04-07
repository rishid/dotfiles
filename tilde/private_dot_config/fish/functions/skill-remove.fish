function skill-remove -d "Remove a skill and update dotfiles"
    if test (count $argv) -eq 0
        echo "Usage: skill-remove <skill-name>"
        return 1
    end

    npx skills remove $argv
    if test $status -ne 0
        echo "✗ npx skills remove failed"
        return 1
    end

    chezmoi add ~/.claude/skills/
    if test -f ~/.claude/.skills-lock.json
        chezmoi add ~/.claude/.skills-lock.json
    end

    cd (git -C (chezmoi source-path) rev-parse --show-toplevel)
    git add .
    git commit -m "chore(skill): remove $argv"
    if test $status -ne 0
        echo "⚠ git commit failed (nothing to commit?)"
    end

    echo "✓ Skill removed and committed to dotfiles"
end
