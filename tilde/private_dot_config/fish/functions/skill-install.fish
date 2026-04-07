function skill-install -d "Install a skill and track with chezmoi"
    if not command -q npx
        echo "✗ npx not found — install Node.js first"
        return 1
    end

    if test (count $argv) -eq 0
        echo "Usage: skill-install <source>"
        echo "Example: skill-install anthropics/skills@frontend-design"
        return 1
    end

    npx skills add --copy $argv
    if test $status -ne 0
        echo "✗ npx skills add failed"
        return 1
    end

    chezmoi add ~/.claude/skills/
    if test $status -ne 0
        echo "✗ chezmoi add failed for ~/.claude/skills/"
        return 1
    end

    if test -f ~/.claude/.skills-lock.json
        chezmoi add ~/.claude/.skills-lock.json
    end

    cd (git -C (chezmoi source-path) rev-parse --show-toplevel)
    git add .
    git commit -m "feat(skill): add $argv"
    if test $status -ne 0
        echo "⚠ git commit failed (nothing to commit?)"
    end

    echo "✓ Skill installed and committed to dotfiles"
end
